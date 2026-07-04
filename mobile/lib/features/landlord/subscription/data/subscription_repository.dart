import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class SubscriptionRepository {
  final ApiClient _client;
  SubscriptionRepository(this._client);

  Future<Map<String, dynamic>> getCurrentPlan() async {
    final response = await _client.get('/landlord/subscriptions/current');
    return response.data['data'] ?? {};
  }

  Future<List<dynamic>> getPlans() async {
    final response = await _client.get('/landlord/subscriptions/plans');
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getInvoices() async {
    final response = await _client.get('/landlord/subscriptions/invoices');
    final data = response.data;
    if (data is Map && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    if (data is Map && data['data'] is Map && data['data']['data'] is List) {
      return data['data']['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> activateFreeTrial() async {
    final response = await _client.post(ApiEndpoints.freeTrial);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> subscribe(String planId) async {
    final response = await _client.post('/landlord/subscriptions/subscribe', data: {'plan_id': planId});
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> initiatePayment(String planId, String phone) async {
    final response = await _client.post('/payments-gateway/initiate', data: {
      'type': 'subscription',
      'id': planId,
      'phone': phone,
    });
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    final response = await _client.get('/payments-gateway/verify/$reference');
    return response.data['data'] ?? {};
  }
}
