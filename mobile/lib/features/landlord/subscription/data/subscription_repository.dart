import '../../../../core/network/api_client.dart';

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

  Future<Map<String, dynamic>> subscribe(String planId) async {
    final response = await _client.post('/landlord/subscriptions/subscribe', data: {'plan_id': planId});
    return response.data['data'] ?? {};
  }
}
