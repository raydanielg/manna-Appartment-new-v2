import 'dart:io';
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
      state = state.copyWith(isLoading: false, error: e.toString());
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
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
