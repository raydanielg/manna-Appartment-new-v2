import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/api_client.dart';

class ContractsRepository {
  final ApiClient _client;
  ContractsRepository(this._client);

  Future<List<dynamic>> getContracts() async {
    final response = await _client.get('/landlord/contracts');
    final data = response.data['data'];
    if (data is Map && data['data'] is List) return data['data'];
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> getContract(String id) async {
    final response = await _client.get('/landlord/contracts/$id');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> createContract(Map<String, dynamic> data) async {
    final response = await _client.post('/landlord/contracts', data: data);
    return response.data['data'] ?? {};
  }

  Future<void> terminateContract(String id) async {
    await _client.post('/landlord/contracts/$id/terminate');
  }

  Future<Map<String, dynamic>> signContract(String id, String signaturePath) async {
    final file = File(signaturePath);
    final name = signaturePath.split('/').last;
    final formData = {
      'signature': await MultipartFile.fromFile(file.path, filename: name),
    };
    final response = await _client.post('/landlord/contracts/$id/sign', data: FormData.fromMap(formData));
    return response.data ?? {};
  }

  Future<String> downloadPdf(String id) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/contract_$id.pdf';
    await _client.download('/landlord/contracts/$id/download', savePath);
    return savePath;
  }

  Future<String> downloadTemplate({String? tenantId}) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final savePath = '${dir.path}/contract_template_$timestamp.docx';
    await _client.download(
      '/landlord/contracts/template/download',
      savePath,
      queryParameters: tenantId != null ? {'tenant_id': tenantId} : null,
    );
    return savePath;
  }
}
