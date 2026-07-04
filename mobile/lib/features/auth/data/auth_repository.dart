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

  Future<Map<String, dynamic>?> getKycStatus() async {
    try {
      final response = await _client.get(ApiEndpoints.kycStatus);
      final data = response.data['data'] ?? response.data;
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? businessName,
  }) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'phone': phone,
        'password': password,
        if (email != null) 'email': email,
        if (businessName != null) 'business_name': businessName,
        'platform': 'mobile',
      },
    );
    final data = response.data['data'] ?? response.data;
    final loginResponse = LoginResponse.fromJson(data);
    await SecureStorageService.setToken(loginResponse.accessToken);
    if (loginResponse.refreshToken != null) {
      await SecureStorageService.setRefreshToken(loginResponse.refreshToken!);
    }
    await SecureStorageService.setUserData(jsonEncode(loginResponse.user.toJson()));
  }

  Future<void> forgotPassword(String phone) async {
    await _client.post(
      ApiEndpoints.forgotPassword,
      data: {'phone': phone, 'platform': 'mobile'},
    );
  }

  Future<void> verifyOtp(String phone, String otp) async {
    await _client.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp, 'platform': 'mobile'},
    );
  }

  Future<void> resetPassword(String phone, String password) async {
    await _client.post(
      ApiEndpoints.resetPassword,
      data: {'phone': phone, 'password': password, 'platform': 'mobile'},
    );
  }

  Future<void> registerFcmToken(String token) async {
    await _client.post(ApiEndpoints.registerFcmToken, data: {'token': token, 'platform': 'android'});
  }
}
