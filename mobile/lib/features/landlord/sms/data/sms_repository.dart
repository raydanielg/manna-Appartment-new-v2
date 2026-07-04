import '../../../../core/network/api_client.dart';

class SmsRepository {
  final ApiClient _client;
  SmsRepository(this._client);

  Future<List<dynamic>> getLogs() async {
    final response = await _client.get('/landlord/sms/logs');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> sendBroadcast(Map<String, dynamic> data) async {
    final response = await _client.post('/landlord/sms/send', data: data);
    return response.data['data'] ?? {};
  }
}
