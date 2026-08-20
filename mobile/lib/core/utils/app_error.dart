import 'package:dio/dio.dart';

class AppError {
  /// Extracts a clean, user-friendly error message from any error object.
  /// Handles DioException, generic Exception, and string errors.
  static String getMessage(dynamic error) {
    if (error is DioException) {
      // If ErrorInterceptor already set a clean message, use it
      if (error.error is String && (error.error as String).isNotEmpty) {
        return error.error as String;
      }
      // Try response data
      final data = error.response?.data;
      if (data is Map) {
        final msg = data['message']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
        final err = data['error']?.toString();
        if (err != null && err.isNotEmpty) return err;
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
      // Network errors
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
          return 'Something went wrong. Please try again.';
      }
    }
    return error.toString();
  }

  /// Returns true if the error is a 403 setup-related error (KYC, subscription, organization)
  static bool isSetupError(dynamic error) {
    final msg = getMessage(error).toLowerCase();
    return msg.contains('kyc') ||
        msg.contains('subscription') ||
        msg.contains('organization') ||
        msg.contains('inactive or expired') ||
        msg.contains('renew to continue') ||
        msg.contains('verification is required');
  }

  /// Returns true if the error is a 403 KYC verification error
  static bool isKycError(dynamic error) {
    final msg = getMessage(error).toLowerCase();
    return msg.contains('kyc') || msg.contains('verification is required');
  }

  /// Returns true if the error is a 403 subscription error
  static bool isSubscriptionError(dynamic error) {
    final msg = getMessage(error).toLowerCase();
    return msg.contains('subscription') ||
        msg.contains('inactive or expired') ||
        msg.contains('renew to continue');
  }

  /// Returns true if the error is a network connectivity error
  static bool isNetworkError(dynamic error) {
    final msg = getMessage(error).toLowerCase();
    return msg.contains('connection') ||
        msg.contains('internet') ||
        msg.contains('timeout') ||
        msg.contains('connect to server');
  }
}
