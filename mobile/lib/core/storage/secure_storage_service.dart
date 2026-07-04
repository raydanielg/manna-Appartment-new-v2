import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<void> setToken(String token) => _storage.write(key: _tokenKey, value: token);
  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  static Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  static Future<void> setRefreshToken(String token) => _storage.write(key: _refreshTokenKey, value: token);
  static Future<void> deleteRefreshToken() => _storage.delete(key: _refreshTokenKey);

  static Future<String?> getUserData() => _storage.read(key: _userKey);
  static Future<void> setUserData(String data) => _storage.write(key: _userKey, value: data);
  static Future<void> deleteUserData() => _storage.delete(key: _userKey);

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
