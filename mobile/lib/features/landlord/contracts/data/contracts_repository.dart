import '../../../../core/network/api_client.dart';

class ContractsRepository {
  final ApiClient _client;
  ContractsRepository(this._client);

  Future<List<dynamic>> getContracts() async {
    final response = await _client.get('/contracts');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getContract(String id) async {
    final response = await _client.get('/contracts/');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> createContract(Map<String, dynamic> data) async {
    final response = await _client.post('/contracts', data: data);
    return response.data['data'] ?? {};
  }

  Future<void> terminateContract(String id) async {
    await _client.post('/contracts//terminate');
  }
}
