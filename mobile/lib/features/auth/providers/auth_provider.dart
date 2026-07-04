import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../core/network/api_client.dart';
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

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _parseError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
