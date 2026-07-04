import '../../../../core/network/api_client.dart';

class ProfileRepository {
  final ApiClient _client;
  ProfileRepository(this._client);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get('/tenant/profile');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.patch('/tenant/profile', data: data);
    return response.data['data'] ?? {};
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _client.post('/tenant/profile/change-password', data: {'current_password': currentPassword, 'new_password': newPassword});
  }
}
