import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_repository.dart';
import '../data/models/login_response_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  String? get role => user?.role;
  bool get isKycApproved => user == null || user!.role != 'landlord' || user!.kycStatus == 'approved';
  bool get isOrganizationActive => user == null || user!.role != 'landlord' || user!.organizationStatus == 'active';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Logger _logger = Logger();

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _repository.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final user = await _repository.getStoredUser();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _logger.e('Auth check error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(phone, password);
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e) {
      _logger.e('Login error: $e');
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? businessName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.register(
        name: name,
        phone: phone,
        password: password,
        email: email,
        businessName: businessName,
      );
      final user = await _repository.getStoredUser();
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      _logger.e('Register error: $e');
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> forgotPassword(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forgotPassword(phone);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      _logger.e('Forgot password error: $e');
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.verifyOtp(phone, otp);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      _logger.e('Verify OTP error: $e');
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> resetPassword(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(phone, password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      _logger.e('Reset password error: $e');
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  Future<void> refreshUserFromServer() async {
    try {
      final kycData = await _repository.getKycStatus();
      final kycStatus = kycData?['kyc_status'];
      final user = state.user;
      if (user != null && kycStatus != null) {
        final updated = user.copyWith(kycStatus: kycStatus.toString());
        state = state.copyWith(user: updated);
        await SecureStorageService.setUserData(jsonEncode(updated.toJson()));
      }
    } catch (e) {
      _logger.e('Refresh user error: $e');
    }
  }

  Future<void> refreshFullProfile() async {
    try {
      final data = await _repository.getProfile();
      final user = state.user;
      if (user != null && data.isNotEmpty) {
        final updated = user.copyWith(
          fullName: data['full_name']?.toString() ?? user.fullName,
          email: data['email']?.toString() ?? user.email,
          phone: data['phone']?.toString() ?? user.phone,
          avatar: data['avatar']?.toString() ?? user.avatar,
          kycStatus: data['organization']?['kyc_status']?.toString() ?? user.kycStatus,
        );
        state = state.copyWith(user: updated);
        await SecureStorageService.setUserData(jsonEncode(updated.toJson()));
      }
    } catch (e) {
      _logger.e('Refresh full profile error: $e');
    }
  }

  Future<bool> updateProfile({String? fullName, String? email, String? phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.updateProfile(fullName: fullName, email: email, phone: phone);
      final user = state.user;
      if (user != null) {
        final updated = user.copyWith(
          fullName: data['full_name']?.toString() ?? user.fullName,
          email: data['email']?.toString() ?? user.email,
          phone: data['phone']?.toString() ?? user.phone,
        );
        state = state.copyWith(user: updated, isLoading: false);
        await SecureStorageService.setUserData(jsonEncode(updated.toJson()));
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> updateAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final data = await _repository.updateAvatar(formData);
      final user = state.user;
      if (user != null) {
        final avatarUrl = data['avatar_url']?.toString();
        final updated = user.copyWith(avatar: avatarUrl);
        state = state.copyWith(user: updated, isLoading: false);
        await SecureStorageService.setUserData(jsonEncode(updated.toJson()));
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _parseError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          return errors.values
              .expand((e) => e is List ? e.map((m) => m.toString()) : [e.toString()])
              .join('\n');
        }
      }
    }
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
