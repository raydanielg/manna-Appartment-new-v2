import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'models/property_model.dart';

class PropertiesRepository {
  final ApiClient _client;
  PropertiesRepository(this._client);

  Future<List<PropertyModel>> getProperties() async {
    final response = await _client.get(ApiEndpoints.properties);
    final data = response.data['data'];
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => PropertyModel.fromJson(e)).toList();
    }
    if (data is List) {
      return data.map((e) => PropertyModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<PropertyModel> getProperty(String id) async {
    final response = await _client.get('${ApiEndpoints.properties}/$id');
    return PropertyModel.fromJson(response.data['data'] ?? {});
  }

  Future<PropertyModel> createProperty({
    required String name,
    required String address,
    required String type,
    String? location,
    String? description,
    List<String> imagePaths = const [],
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'address': address,
      'type': type,
      if (location != null && location.isNotEmpty) 'location': location,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    for (var i = 0; i < imagePaths.length; i++) {
      final path = imagePaths[i];
      final fileName = path.split('/').last;
      formData.files.add(MapEntry('images[$i]', await MultipartFile.fromFile(path, filename: fileName)));
    }
    final response = await _client.post(ApiEndpoints.properties, data: formData);
    return PropertyModel.fromJson(response.data['data'] ?? {});
  }

  Future<PropertyModel> updateProperty(String id, Map<String, dynamic> data) async {
    final response = await _client.patch('${ApiEndpoints.properties}/$id', data: data);
    return PropertyModel.fromJson(response.data['data'] ?? {});
  }

  Future<void> deleteProperty(String id) async {
    await _client.delete('${ApiEndpoints.properties}/$id');
  }
}
