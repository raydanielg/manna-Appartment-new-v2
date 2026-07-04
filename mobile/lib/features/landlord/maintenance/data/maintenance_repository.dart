import '../../../../core/network/api_client.dart';

class MaintenanceRepository {
  final ApiClient _client;
  MaintenanceRepository(this._client);

  Future<List<dynamic>> getRequests() async {
    final response = await _client.get('/landlord/maintenance-requests');
    final data = response.data['data'];
    if (data is Map && data['data'] is List) return data['data'];
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> getRequest(String id) async {
    final response = await _client.get('/landlord/maintenance-requests/$id');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? notes}) async {
    final data = {'status': status};
    if (notes != null && notes.isNotEmpty) data['landlord_notes'] = notes;
    final response = await _client.patch('/landlord/maintenance-requests/$id/status', data: data);
    return response.data['data'] ?? {};
  }
}
