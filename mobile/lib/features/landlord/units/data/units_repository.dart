import '../../../../core/network/api_client.dart';

class UnitsRepository {
  final ApiClient _client;
  UnitsRepository(this._client);

  Future<List<dynamic>> getUnits({String? propertyId}) async {
    final path = propertyId != null ? '/landlord/properties/$propertyId/units' : '/landlord/units';
    final response = await _client.get(path);
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getUnit(String id) async {
    final response = await _client.get('/landlord/units/$id');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> createUnit(String propertyId, Map<String, dynamic> data) async {
    final response = await _client.post('/landlord/properties/$propertyId/units', data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateUnit(String id, Map<String, dynamic> data) async {
    final response = await _client.patch('/landlord/units/$id', data: data);
    return response.data['data'] ?? {};
  }

  Future<void> deleteUnit(String id) async {
    await _client.delete('/landlord/units/$id');
  }
}
