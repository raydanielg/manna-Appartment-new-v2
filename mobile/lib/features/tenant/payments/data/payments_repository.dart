import '../../../../core/network/api_client.dart';

class TenantPaymentsRepository {
  final ApiClient _client;
  TenantPaymentsRepository(this._client);

  Future<List<dynamic>> getMyPayments() async {
    final response = await _client.get('/tenant/payments');
    return response.data['data'] ?? [];
  }
}
