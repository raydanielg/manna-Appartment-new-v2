import '../../../../core/network/api_client.dart';

class ContractRepository {
  final ApiClient _client;
  ContractRepository(this._client);

  Future<Map<String, dynamic>> getMyContract() async {
    final response = await _client.get('/tenant/my-contract');
    return response.data['data'] ?? {};
  }
}
