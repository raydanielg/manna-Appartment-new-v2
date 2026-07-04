import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class DashboardRepository {
  final ApiClient _client;
  DashboardRepository(this._client);

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _client.get(ApiEndpoints.landlordDashboard);
    return response.data['data'] ?? {};
  }
}
