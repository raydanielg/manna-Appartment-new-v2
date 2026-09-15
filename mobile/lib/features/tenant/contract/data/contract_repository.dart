import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class ContractRepository {
  final ApiClient _client;
  ContractRepository(this._client);

  Future<Map<String, dynamic>> getMyContract() async {
    final response = await _client.get('/tenant/my-contract');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> signMyContract(String signaturePath) async {
    final file = File(signaturePath);
    final name = signaturePath.split('/').last;
    final formData = {
      'signature': await MultipartFile.fromFile(file.path, filename: name),
    };
    final response = await _client.post('/tenant/my-contract/sign', data: FormData.fromMap(formData));
    return response.data ?? {};
  }
}
