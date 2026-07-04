import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/login_response_model.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<LoginResponse> login(String phone, String password) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {'phone': phone, 'password': password, 'platform': 'mobile'},
    );
    final loginResponse = LoginResponse.fromJson(response.data['data'] ?? response.data);
    await SecureStorageService.setToken(loginResponse.accessToken);
    if (loginResponse.refreshToken != null) {
      await SecureStorageService.setRefreshToken(loginResponse.refreshToken!);
    }
    await SecureStorageService.setUserData(jsonEncode(loginResponse.user.toJson()));
    return loginResponse;
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (_) {
      // ignore
    } finally {
      await SecureStorageService.clearAll();
    }
  }

  Future<UserModel?> getStoredUser() async {
    final data = await SecureStorageService.getUserData();
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  Future<String?> getToken() => SecureStorageService.getToken();

  Future<void> registerFcmToken(String token) async {
    await _client.post(ApiEndpoints.registerFcmToken, data: {'token': token, 'platform': 'android'});
  }
}
