import '../../../../core/network/api_client.dart';

class StaffRepository {
  final ApiClient _client;
  StaffRepository(this._client);

  Future<List<dynamic>> getStaff() async {
    final response = await _client.get('/staff');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> createStaff(Map<String, dynamic> data) async {
    final response = await _client.post('/staff', data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updatePermissions(String id, List<String> permissions) async {
    final response = await _client.put('/staff//permissions', data: {'permissions': permissions});
    return response.data['data'] ?? {};
  }
}
