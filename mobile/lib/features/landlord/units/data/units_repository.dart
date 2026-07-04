import '../../../../core/network/api_client.dart';

class UnitsRepository {
  final ApiClient _client;
  UnitsRepository(this._client);

  Future<List<dynamic>> getUnits({String? propertyId}) async {
    final path = propertyId != null ? '/properties//units' : '/units';
    final response = await _client.get(path);
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getUnit(String id) async {
    final response = await _client.get('/units/');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> createUnit(Map<String, dynamic> data) async {
    final response = await _client.post('/units', data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateUnit(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/units/', data: data);
    return response.data['data'] ?? {};
  }

  Future<void> deleteUnit(String id) async {
    await _client.delete('/units/');
  }
}
