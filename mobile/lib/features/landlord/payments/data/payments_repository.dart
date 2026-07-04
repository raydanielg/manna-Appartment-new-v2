import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class PaymentsRepository {
  final ApiClient _client;
  PaymentsRepository(this._client);

  Future<List<dynamic>> getPayments() async {
    final response = await _client.get(ApiEndpoints.payments);
    final data = response.data['data'];
    if (data is Map && data['data'] is List) return data['data'];
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.payments, data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updatePayment(String id, Map<String, dynamic> data) async {
    final response = await _client.patch('${ApiEndpoints.payments}/$id', data: data);
    return response.data['data'] ?? {};
  }

  Future<void> deletePayment(String id) async {
    await _client.delete('${ApiEndpoints.payments}/$id');
  }

  Future<Map<String, dynamic>> getPayment(String id) async {
    final response = await _client.get('${ApiEndpoints.payments}/$id');
    return response.data['data'] ?? {};
  }
}
