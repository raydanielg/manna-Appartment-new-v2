import '../../../../core/network/api_client.dart';

class UnitRepository {
  final ApiClient _client;
  UnitRepository(this._client);

  Future<Map<String, dynamic>> getMyUnit() async {
    final response = await _client.get('/tenant/my-unit');
    return response.data['data'] ?? {};
  }
}
