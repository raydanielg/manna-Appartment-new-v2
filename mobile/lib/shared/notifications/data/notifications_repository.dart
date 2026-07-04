import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class NotificationsRepository {
  final ApiClient _client;
  NotificationsRepository(this._client);

  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final response = await _client.get(ApiEndpoints.notifications, queryParameters: {'page': page});
    return response.data['data'] ?? {};
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get('${ApiEndpoints.notifications}/unread-count');
    return response.data['data']?['count'] ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _client.patch('${ApiEndpoints.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.post('${ApiEndpoints.notifications}/read-all');
  }

  Future<void> registerFcmToken(String token, {String platform = 'android'}) async {
    await _client.post(ApiEndpoints.registerFcmToken, data: {'token': token, 'platform': platform});
  }
}
