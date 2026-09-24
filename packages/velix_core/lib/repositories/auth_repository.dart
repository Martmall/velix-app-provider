import 'dart:async';
import '../models/user_model.dart';
import '../data_sources/remote/auth_remote_data_source.dart';
import '../storage/secure_storage_service.dart';

abstract class IAuthRepository {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });
  Future<UserModel> oauthSignIn({
    required String provider,
    required String name,
    required String email,
    String? avatarUrl,
  });
  Future<bool> verifyOtp({required String phone, required String code});
  Future<UserModel> completeKyc({required String licenseNumber, required String documentPath});
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? licenseNumber,
    String? bankName,
    String? bankAccount,
    String? cacNumber,
    String? businessName,
  });
  Future<UserModel> topUpWallet({required double amount, String? userId});
  Future<UserModel> deductWallet({required double amount, String? userId, String? bookingId});
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
}

class RemoteAuthRepository implements IAuthRepository {
  final AuthRemoteDataSource _remote = AuthRemoteDataSource();
  final SecureStorageService _storage = SecureStorageService();
  UserModel? _cachedUser;

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    final user = await _remote.login(email: email, password: password);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserModel> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final user = await _remote.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserModel> oauthSignIn({
    required String provider,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final user = await _remote.oauthLogin(
      provider: provider,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
    _cachedUser = user;
    return user;
  }

  @override
  Future<bool> verifyOtp({required String phone, required String code}) async {
    return _remote.verifyOtp(code: code);
  }

  @override
  Future<UserModel> completeKyc({required String licenseNumber, required String documentPath}) async {
    final user = await _remote.completeKyc(licenseNumber: licenseNumber, frontIdUrl: documentPath);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? licenseNumber,
    String? bankName,
    String? bankAccount,
    String? cacNumber,
    String? businessName,
  }) async {
    final updated = await _remote.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      licenseNumber: licenseNumber,
      bankName: bankName,
      bankAccount: bankAccount,
      cacNumber: cacNumber,
      businessName: businessName,
    );
    _cachedUser = updated;
    return updated;
  }

  @override
  Future<UserModel> topUpWallet({required double amount, String? userId}) async {
    final user = await _remote.topUpWallet(amount: amount, userId: userId ?? _cachedUser?.id);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserModel> deductWallet({required double amount, String? userId, String? bookingId}) async {
    final user = await _remote.deductWallet(amount: amount, userId: userId ?? _cachedUser?.id, bookingId: bookingId);
    _cachedUser = user;
    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;
    try {
      final user = await _remote.getCurrentUser();
      if (user != null) {
        _cachedUser = user;
        return user;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> signOut() async {
    try {
      await _remote.logout();
    } catch (_) {}
    await _storage.clearAll();
    _cachedUser = null;
  }
}
