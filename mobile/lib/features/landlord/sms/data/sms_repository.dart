import '../../../../core/network/api_client.dart';

class SmsRepository {
  final ApiClient _client;
  SmsRepository(this._client);

  Future<List<dynamic>> getLogs() async {
    final response = await _client.get('/landlord/sms/logs');
    final data = response.data['data'];
    if (data is Map && data['data'] is List) return data['data'];
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> sendBroadcast(Map<String, dynamic> data) async {
    final response = await _client.post('/landlord/sms/broadcast', data: data);
    return response.data ?? {};
  }

  Future<int> getBalance() async {
    final response = await _client.get('/landlord/sms/balance');
    final data = response.data['data'];
    if (data is Map) return data['sms_balance'] ?? 0;
    return 0;
  }
}
