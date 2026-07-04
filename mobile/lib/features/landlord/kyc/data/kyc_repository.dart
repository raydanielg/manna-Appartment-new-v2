import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class KycRepository {
  final ApiClient _client;
  KycRepository(this._client);

  Future<Map<String, dynamic>?> getStatus() async {
    final response = await _client.get(ApiEndpoints.kycStatus);
    final data = response.data['data'] ?? response.data;
    return data is Map<String, dynamic> ? data : null;
  }

  Future<void> submit({
    required String idNumber,
    required File idPhotoFront,
    required File idPhotoBack,
    required File selfiePhoto,
    File? ownershipProof,
  }) async {
    final formData = FormData.fromMap({
      'id_number': idNumber,
      'id_photo_front': await MultipartFile.fromFile(idPhotoFront.path),
      'id_photo_back': await MultipartFile.fromFile(idPhotoBack.path),
      'selfie_photo': await MultipartFile.fromFile(selfiePhoto.path),
      if (ownershipProof != null)
        'ownership_proof': await MultipartFile.fromFile(ownershipProof.path),
    });

    await _client.post(ApiEndpoints.kyc, data: formData);
  }
}
