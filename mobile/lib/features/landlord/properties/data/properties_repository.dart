import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'models/property_model.dart';

class PropertiesRepository {
  final ApiClient _client;
  PropertiesRepository(this._client);

  Future<List<PropertyModel>> getProperties() async {
    final response = await _client.get(ApiEndpoints.properties);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => PropertyModel.fromJson(e)).toList();
  }

  Future<PropertyModel> getProperty(String id) async {
    final response = await _client.get('${ApiEndpoints.properties}/$id');
    return PropertyModel.fromJson(response.data['data'] ?? {});
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.properties, data: data);
    return PropertyModel.fromJson(response.data['data'] ?? {});
  }

  Future<PropertyModel> updateProperty(String id, Map<String, dynamic> data) async {
    final response = await _client.put('${ApiEndpoints.properties}/$id', data: data);
    return PropertyModel.fromJson(response.data['data'] ?? {});
  }

  Future<void> deleteProperty(String id) async {
    await _client.delete('${ApiEndpoints.properties}/$id');
  }
}
