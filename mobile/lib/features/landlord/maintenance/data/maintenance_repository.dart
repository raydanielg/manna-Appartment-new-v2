import '../../../../core/network/api_client.dart';

class MaintenanceRepository {
  final ApiClient _client;
  MaintenanceRepository(this._client);

  Future<List<dynamic>> getRequests() async {
    final response = await _client.get('/landlord/maintenance-requests');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> updateStatus(String id, String status) async {
    final response = await _client.patch('/landlord/maintenance-requests/$id/status', data: {'status': status});
    return response.data['data'] ?? {};
  }
}
