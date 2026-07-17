import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/kyc_repository.dart';

final kycRepositoryProvider = Provider((ref) => KycRepository(ref.read(apiClientProvider)));

final kycProvider = StateNotifierProvider<KycNotifier, KycState>((ref) {
  return KycNotifier(ref.read(kycRepositoryProvider));
});

class KycState {
  final bool isLoading;
  final String? error;
  final String? status;
  final bool isSubmitted;

  const KycState({
    this.isLoading = false,
    this.error,
    this.status,
    this.isSubmitted = false,
  });

  KycState copyWith({
    bool? isLoading,
    String? error,
    String? status,
    bool? isSubmitted,
  }) {
    return KycState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      status: status ?? this.status,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class KycNotifier extends StateNotifier<KycState> {
  final KycRepository _repository;

  KycNotifier(this._repository) : super(const KycState());

  void clearError() => state = state.copyWith(error: null);

  Future<bool> checkStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.getStatus();
      final status = data?['kyc_status']?.toString() ?? 'pending';
      state = state.copyWith(isLoading: false, status: status);
      return status == 'approved';
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> submit({
    required String idNumber,
    required File idPhotoFront,
    required File idPhotoBack,
    required File selfiePhoto,
    File? ownershipProof,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.submit(
        idNumber: idNumber,
        idPhotoFront: idPhotoFront,
        idPhotoBack: idPhotoBack,
        selfiePhoto: selfiePhoto,
        ownershipProof: ownershipProof,
      );
      state = state.copyWith(isLoading: false, isSubmitted: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  String _parseError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          return errors.values
              .expand((e) => e is List ? e.map((m) => m.toString()) : [e.toString()])
              .join('\n');
        }
        if (data['message'] != null) return data['message'].toString();
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet and try again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to server. Please check your internet connection.';
      }
    }
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
