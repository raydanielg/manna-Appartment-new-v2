import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class TenantsRepository {
  final ApiClient _client;
  TenantsRepository(this._client);

  Future<List<dynamic>> getTenants() async {
    final response = await _client.get(ApiEndpoints.tenants);
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getTenant(String id) async {
    final response = await _client.get('${ApiEndpoints.tenants}/$id');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> createTenant(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.tenants, data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateTenant(String id, Map<String, dynamic> data) async {
    final response = await _client.patch('${ApiEndpoints.tenants}/$id', data: data);
    return response.data['data'] ?? {};
  }

  Future<void> deleteTenant(String id) async {
    await _client.delete('${ApiEndpoints.tenants}/$id');
  }
}
