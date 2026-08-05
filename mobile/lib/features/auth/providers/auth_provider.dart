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
  final bool kycMandatory;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.kycMandatory = true,
  });

  bool get isAuthenticated => user != null;
  String? get role => user?.role;
  bool get isKycApproved => user == null || user!.role != 'landlord' || user!.kycStatus == 'approved' || !kycMandatory;
  bool get isOrganizationActive => user == null || user!.role != 'landlord' || user!.organizationStatus == null || user!.organizationStatus == 'active';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? kycMandatory,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error == '' ? null : (error ?? this.error),
      kycMandatory: kycMandatory ?? this.kycMandatory,
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
        final org = data['organization'];
        final updated = user.copyWith(
          fullName: data['full_name']?.toString() ?? user.fullName,
          email: data['email']?.toString() ?? user.email,
          phone: data['phone']?.toString() ?? user.phone,
          avatar: data['avatar']?.toString() ?? user.avatar,
          kycStatus: org is Map ? org['kyc_status']?.toString() ?? user.kycStatus : user.kycStatus,
          businessName: org is Map ? org['business_name']?.toString() ?? user.businessName : user.businessName,
          organizationStatus: org is Map ? org['status']?.toString() ?? user.organizationStatus : user.organizationStatus,
          smsBalance: org is Map
              ? (org['sms_balance'] is int
                  ? org['sms_balance'] as int
                  : (org['sms_balance'] != null ? int.tryParse(org['sms_balance'].toString()) : null)) ?? user.smsBalance
              : user.smsBalance,
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

  Future<bool> createOrganization(String businessName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.createOrganization(businessName);
      final user = state.user;
      if (user != null) {
        final updated = user.copyWith(
          businessName: data['business_name']?.toString() ?? businessName,
          organizationId: data['id']?.toString() ?? user.organizationId,
          organizationStatus: data['status']?.toString() ?? 'active',
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

  void clearError() {
    state = state.copyWith(error: '');
  }

  String _parseError(dynamic error) {
    if (error is DioException) {
      // ErrorInterceptor already parsed a user-friendly message into error.error
      if (error.error is String && (error.error as String).isNotEmpty) {
        return error.error as String;
      }

      // Fallback: parse response data directly
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
        case DioExceptionType.badCertificate:
          return 'Security certificate error. Please contact support.';
        default:
          break;
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return 'Server error. Please try again later.';
      }
      if (statusCode == 401) {
        return 'Invalid phone number or password.';
      }
      if (statusCode == 403) {
        return 'You do not have permission to perform this action.';
      }
      if (statusCode == 404) {
        return 'Service not found. Please try again later.';
      }
      if (statusCode == 422) {
        return 'The data provided is invalid. Please check your inputs.';
      }
    }
    if (error is Exception) {
      final msg = error.toString().replaceAll('Exception: ', '');
      if (msg.isNotEmpty && msg != 'null') return msg;
    }
    return 'Something went wrong. Please try again.';
  }
}
