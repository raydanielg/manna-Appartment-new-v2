import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class PaymentsRepository {
  final ApiClient _client;
  PaymentsRepository(this._client);

  Future<List<dynamic>> getPayments() async {
    final response = await _client.get(ApiEndpoints.payments);
    return response.data['data'] ?? [];
  }
}
