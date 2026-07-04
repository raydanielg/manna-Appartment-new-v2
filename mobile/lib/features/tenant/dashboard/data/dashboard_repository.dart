import '../../../../core/network/api_client.dart';

class TenantDashboardRepository {
  final ApiClient _client;
  TenantDashboardRepository(this._client);

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _client.get('/tenant/dashboard');
    return response.data['data'] ?? {};
  }
}
