import '../../../../core/network/api_client.dart';

class AdminLandlordsRepository {
  final ApiClient _client;
  AdminLandlordsRepository(this._client);

  Future<List<dynamic>> getLandlords({String? status, String? search}) async {
    final response = await _client.get('/admin/landlords', queryParameters: {
      if (status != null && status != 'all') 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final data = response.data['data'];
    if (data is Map && data['data'] is List) return data['data'];
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> createLandlord(Map<String, dynamic> data) async {
    final response = await _client.post('/admin/landlords', data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> getLandlord(String id) async {
    final response = await _client.get('/admin/landlords/$id');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? reason}) async {
    final data = {'status': status};
    if (reason != null && reason.isNotEmpty) data['reason'] = reason;
    final response = await _client.patch('/admin/landlords/$id/status', data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateKycStatus(String id, String status) async {
    final response = await _client.patch('/admin/landlords/$id/kyc', data: {'kyc_status': status});
    return response.data['data'] ?? {};
  }

  Future<void> deleteLandlord(String id) async {
    await _client.delete('/admin/landlords/$id');
  }

  Future<void> bulkDeleteLandlords(List<String> ids) async {
    await _client.post('/admin/landlords/bulk-delete', data: {'ids': ids});
  }

  Future<Map<String, dynamic>> updateLandlord(String id, Map<String, dynamic> data) async {
    final response = await _client.patch('/admin/landlords/$id', data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateLandlordOwner(String id, Map<String, dynamic> data) async {
    final response = await _client.patch('/admin/landlords/$id/owner', data: data);
    return response.data['data'] ?? {};
  }
}
