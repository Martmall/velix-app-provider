import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the session tokens in the platform's secure storage.
///
/// If Android can't decrypt what an earlier install left behind (an app reinstalled or restored
/// from a device backup gets the encrypted file but not the key), reads used to throw. That failed
/// every API call before it was sent ("An unexpected network error occurred"). Now an unreadable
/// store is wiped and treated as signed out, so the user can simply sign in again.
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      try {
        await _storage.deleteAll();
      } catch (_) {
        // Nothing more to do; the next write starts a fresh store.
      }
      return null;
    }
  }

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

  Future<String?> getToken() => _read(_keyToken);
  Future<String?> getRefreshToken() => _read(_keyRefreshToken);
  Future<String?> getUserRole() => _read(_keyUserRole);
  Future<String?> getUserId() => _read(_keyUserId);

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
