import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../network/api_client.dart';
import '../../storage/secure_storage_service.dart';

/// Result of POST /register. The backend issues no tokens until the 6-digit code emailed to
/// [email] is confirmed via [AuthRemoteDataSource.verifyRegistrationOtp].
class RegistrationResult {
  final String email;
  final bool requiresVerification;
  final String message;
  RegistrationResult({required this.email, required this.requiresVerification, required this.message});
}

class AuthRemoteDataSource {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  /// Stores the session from an auth response (`data` holds the user plus api_token /
  /// refresh_token) and returns the user. Throws if the response carries no token.
  Future<UserModel> _storeSession(dynamic body) async {
    final data = ApiClient.objectFrom(body);
    final accessToken = data['api_token'] ?? data['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw ApiException('Sign-in did not return a session. Please try again.');
    }
    await _storage.saveToken(accessToken);
    final refreshToken = data['refresh_token'] ?? data['refreshToken'];
    if (refreshToken is String && refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(refreshToken);
    }
    return UserModel.fromJson(data);
  }

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _apiClient.post('/login', data: {
      'email': email.trim(),
      'password': password,
    });
    return _storeSession(response.data);
  }

  Future<RegistrationResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final response = await _apiClient.post('/register', data: {
      'first_name': parts.first,
      if (parts.length > 1) 'last_name': parts.sublist(1).join(' '),
      'email': email.trim(),
      if (phone.trim().isNotEmpty) 'contact_number': phone.trim(),
      'password': password,
      'user_type': role == UserRole.partner ? 'provider' : 'user',
    });
    final body = response.data is Map ? response.data as Map : const {};
    final data = body['data'] is Map ? body['data'] as Map : const {};
    return RegistrationResult(
      email: (data['email'] ?? email).toString(),
      requiresVerification: data['requires_verification'] != false,
      message: (body['message'] ?? 'A verification code has been sent to your email.').toString(),
    );
  }

  /// Confirms the code emailed after registration and starts the session.
  Future<UserModel> verifyRegistrationOtp({required String email, required String code}) async {
    final response = await _apiClient.post('/verify-registration-otp', data: {
      'email': email.trim(),
      'code': code.trim(),
    });
    return _storeSession(response.data);
  }

  Future<void> resendVerificationEmail({required String email}) async {
    await _apiClient.post('/resend-verification-email', data: {'email': email.trim()});
  }

  /// Passwordless sign-in, step 1: emails a one-time code.
  Future<void> requestLoginOtp({required String email}) async {
    await _apiClient.post('/request-login-otp', data: {'email': email.trim()});
  }

  /// Passwordless sign-in, step 2.
  Future<UserModel> verifyLoginOtp({required String email, required String code}) async {
    final response = await _apiClient.post('/verify-login-otp', data: {
      'email': email.trim(),
      'code': code.trim(),
    });
    return _storeSession(response.data);
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post('/forgot-password', data: {'email': email.trim()});
  }

  /// Exchanges a Supabase OAuth session for a Velix session.
  Future<UserModel> oauthLogin({
    required String provider,
    required String name,
    required String email,
    String? avatarUrl,
    String? supabaseAccessToken,
    UserRole role = UserRole.user,
  }) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final response = await _apiClient.post('/social-login', data: {
      'login_type': provider.toLowerCase(),
      'email': email,
      'first_name': parts.first,
      if (parts.length > 1) 'last_name': parts.sublist(1).join(' '),
      if (avatarUrl != null) 'social_image': avatarUrl,
      'user_type': role == UserRole.partner ? 'provider' : 'user',
      if (supabaseAccessToken != null && supabaseAccessToken.isNotEmpty)
        'supabase_access_token': supabaseAccessToken,
    });
    return _storeSession(response.data);
  }

  /// Google sign-in via Supabase OAuth. On mobile this opens the browser and returns false-y
  /// until the deep link (io.supabase.velix://login-callback/) brings a session back; call it
  /// again (or listen to Supabase auth state) once that session exists.
  Future<UserModel> signInWithGoogle({UserRole role = UserRole.user}) async {
    final supa = Supabase.instance.client;
    var session = supa.auth.currentSession;
    if (session == null) {
      final launched = await supa.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.velix://login-callback/',
      );
      if (!launched) throw ApiException('Google sign-in was cancelled.');
      session = supa.auth.currentSession;
      if (session == null) {
        throw ApiException('Finish signing in with Google in your browser, then try again.');
      }
    }
    final meta = session.user.userMetadata ?? {};
    final email = session.user.email ?? '';
    return oauthLogin(
      provider: 'google',
      name: (meta['full_name'] ?? meta['name'] ?? email.split('@').first).toString(),
      email: email,
      avatarUrl: (meta['avatar_url'] ?? meta['picture'])?.toString(),
      supabaseAccessToken: session.accessToken,
      role: role,
    );
  }

  /// The signed-in user, or null when there is no valid session.
  Future<UserModel?> getCurrentUser() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _apiClient.get('/user');
      return UserModel.fromJson(ApiClient.objectFrom(response.data));
    } on ApiException catch (e) {
      if (e.statusCode == 401) return null;
      rethrow;
    }
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final parts = fullName?.trim().split(RegExp(r'\s+'));
    await _apiClient.post('/update-profile', data: {
      if (parts != null && parts.first.isNotEmpty) 'firstName': parts.first,
      if (parts != null && parts.length > 1) 'lastName': parts.sublist(1).join(' '),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (avatarUrl != null && avatarUrl.startsWith('http')) 'avatarUrl': avatarUrl,
    });
    // /update-profile's response shape is minimal; re-read the canonical profile.
    final user = await getCurrentUser();
    if (user == null) throw ApiException('Your session has expired. Please sign in again.');
    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } on ApiException catch (e) {
      debugPrint('[AuthRemoteDataSource] logout call failed (session cleared anyway): $e');
    }
    await _storage.clearAll();
  }
}
