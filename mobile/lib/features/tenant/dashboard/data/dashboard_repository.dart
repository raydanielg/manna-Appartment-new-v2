import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class TenantDashboardRepository {
  final ApiClient _client;
  TenantDashboardRepository(this._client);

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _client.get(ApiEndpoints.tenantDashboard);
    return response.data['data'] ?? {};
  }
}
