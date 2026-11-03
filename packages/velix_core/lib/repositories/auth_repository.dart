import 'dart:async';
import '../models/user_model.dart';
import '../data_sources/remote/auth_remote_data_source.dart';
import '../data_sources/remote/verification_remote_data_source.dart';
import '../network/upload_file.dart';
import '../storage/secure_storage_service.dart';

abstract class IAuthRepository {
  Future<UserModel> signIn({required String email, required String password});

  /// Creates the account. No session yet: the user must confirm the emailed code with
  /// [verifyRegistrationOtp] before they can sign in.
  Future<RegistrationResult> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });
  Future<UserModel> verifyRegistrationOtp({required String email, required String code});
  Future<void> resendVerificationEmail({required String email});
  Future<void> requestLoginOtp({required String email});
  Future<UserModel> verifyLoginOtp({required String email, required String code});
  Future<void> forgotPassword({required String email});
  Future<UserModel> signInWithGoogle({UserRole role = UserRole.user});

  /// Uploads identity documents for review: a customer's driver's licence, or a partner's
  /// business/KYC documents. Returns the review status afterwards.
  Future<VerificationStatus> submitVerificationDocuments({
    required List<UploadFile> files,
    required bool asPartner,
    String? businessName,
  });
  Future<VerificationStatus> getVerificationStatus({required bool asPartner});

  Future<UserModel> updateProfile({String? fullName, String? phone, String? avatarUrl});
  Future<UserModel?> getCurrentUser({bool refresh = false});
  Future<void> signOut();
}

class RemoteAuthRepository implements IAuthRepository {
  final AuthRemoteDataSource _remote = AuthRemoteDataSource();
  final VerificationRemoteDataSource _verification = VerificationRemoteDataSource();
  final SecureStorageService _storage = SecureStorageService();
  UserModel? _cachedUser;

  Future<UserModel> _cache(Future<UserModel> call) async => _cachedUser = await call;

  @override
  Future<UserModel> signIn({required String email, required String password}) =>
      _cache(_remote.login(email: email, password: password));

  @override
  Future<RegistrationResult> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) =>
      _remote.register(fullName: fullName, email: email, phone: phone, password: password, role: role);

  @override
  Future<UserModel> verifyRegistrationOtp({required String email, required String code}) =>
      _cache(_remote.verifyRegistrationOtp(email: email, code: code));

  @override
  Future<void> resendVerificationEmail({required String email}) =>
      _remote.resendVerificationEmail(email: email);

  @override
  Future<void> requestLoginOtp({required String email}) => _remote.requestLoginOtp(email: email);

  @override
  Future<UserModel> verifyLoginOtp({required String email, required String code}) =>
      _cache(_remote.verifyLoginOtp(email: email, code: code));

  @override
  Future<void> forgotPassword({required String email}) => _remote.forgotPassword(email: email);

  @override
  Future<UserModel> signInWithGoogle({UserRole role = UserRole.user}) =>
      _cache(_remote.signInWithGoogle(role: role));

  @override
  Future<VerificationStatus> submitVerificationDocuments({
    required List<UploadFile> files,
    required bool asPartner,
    String? businessName,
  }) =>
      asPartner
          ? _verification.uploadPartnerDocuments(files, companyName: businessName)
          : _verification.uploadCustomerDocuments(files);

  @override
  Future<VerificationStatus> getVerificationStatus({required bool asPartner}) =>
      asPartner ? _verification.partnerStatus() : _verification.customerStatus();

  @override
  Future<UserModel> updateProfile({String? fullName, String? phone, String? avatarUrl}) =>
      _cache(_remote.updateProfile(fullName: fullName, phone: phone, avatarUrl: avatarUrl));

  @override
  Future<UserModel?> getCurrentUser({bool refresh = false}) async {
    if (_cachedUser != null && !refresh) return _cachedUser;
    _cachedUser = await _remote.getCurrentUser();
    return _cachedUser;
  }

  @override
  Future<void> signOut() async {
    await _remote.logout();
    await _storage.clearAll();
    _cachedUser = null;
  }
}
