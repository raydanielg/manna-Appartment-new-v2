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
    String? description,
    List<String> imagePaths = const [],
  }) async {
    final files = <MultipartFile>[];
    for (final path in imagePaths) {
      final name = path.split('/').last;
      files.add(await MultipartFile.fromFile(path, filename: name));
    }
    final formData = FormData.fromMap({
      'name': name,
      'address': address,
      'type': type,
      if (description != null && description.isNotEmpty) 'description': description,
      if (files.isNotEmpty) 'images': files,
    });
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
