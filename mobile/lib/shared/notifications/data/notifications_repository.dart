import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class NotificationsRepository {
  final ApiClient _client;
  NotificationsRepository(this._client);

  Future<List<dynamic>> getNotifications() async {
    final response = await _client.get(ApiEndpoints.notifications);
    return response.data['data'] ?? [];
  }
}
