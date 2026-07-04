import '../../../../core/network/api_client.dart';

class TenantMaintenanceRepository {
  final ApiClient _client;
  TenantMaintenanceRepository(this._client);

  Future<List<dynamic>> getMyRequests() async {
    final response = await _client.get('/tenant/maintenance');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> submitRequest(Map<String, dynamic> data) async {
    final response = await _client.post('/tenant/maintenance', data: data);
    return response.data['data'] ?? {};
  }
}
