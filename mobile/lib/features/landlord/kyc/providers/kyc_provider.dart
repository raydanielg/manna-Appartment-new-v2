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
      error: error == '' ? null : (error ?? this.error),
      status: status ?? this.status,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class KycNotifier extends StateNotifier<KycState> {
  final KycRepository _repository;

  KycNotifier(this._repository) : super(const KycState());

  void clearError() => state = state.copyWith(error: '');

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
      // ErrorInterceptor already parsed a user-friendly message into error.error
      if (error.error is String && (error.error as String).isNotEmpty) {
        return error.error as String;
      }

      final data = error.response?.data;
      if (data is Map) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              for (final msg in value) {
                messages.add(msg.toString());
              }
            } else if (value is String) {
              messages.add(value);
            }
          });
          if (messages.isNotEmpty) return messages.join('\n');
        }
        if (data['message'] is String && (data['message'] as String).isNotEmpty) {
          return data['message'];
        }
        if (data['error'] is String && (data['error'] as String).isNotEmpty) {
          return data['error'];
        }
      }

      // Network error fallback
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Connection timed out. Please check your internet and try again.';
        case DioExceptionType.connectionError:
          return 'Could not connect to server. Please check your internet connection.';
        case DioExceptionType.cancel:
          return 'Request was cancelled. Please try again.';
        default:
          break;
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return 'Server error. Please try again later.';
      }
    }
    if (error is Exception) {
      final msg = error.toString().replaceAll('Exception: ', '');
      if (msg.isNotEmpty && msg != 'null') return msg;
    }
    return 'Something went wrong. Please try again.';
  }
}
