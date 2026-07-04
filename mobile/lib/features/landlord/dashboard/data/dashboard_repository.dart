import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class DashboardRepository {
  final ApiClient _client;
  DashboardRepository(this._client);

  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final response = await _client.get(ApiEndpoints.landlordDashboard);
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        throw data['message'].toString();
      }
      throw 'Failed to load dashboard. Please try again.';
    }
  }
}
