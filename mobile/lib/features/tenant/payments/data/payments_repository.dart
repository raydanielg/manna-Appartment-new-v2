import '../../../../core/network/api_client.dart';

class TenantPaymentsRepository {
  final ApiClient _client;
  TenantPaymentsRepository(this._client);

  Future<List<dynamic>> getMyPayments() async {
    final response = await _client.get('/tenant/my-payments');
    final data = response.data['data'];
    if (data is Map && data['data'] is List) return data['data'];
    if (data is List) return data;
    return [];
  }
}
