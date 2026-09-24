import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';

  Future<void> saveAuthData({
    required String token,
    required String role,
    required String userId,
    String? refreshToken,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyUserId, value: userId);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getRefreshToken() async => await _storage.read(key: _keyRefreshToken);
  Future<String?> getUserRole() async => await _storage.read(key: _keyUserRole);
  Future<String?> getUserId() async => await _storage.read(key: _keyUserId);

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserId);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
