import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle network-level errors first (no server response)
    if (err.response == null) {
      String message;
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          message = 'Connection timed out. Please check your internet and try again.';
          break;
        case DioExceptionType.connectionError:
          message = 'Could not connect to server. Please check your internet connection.';
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled. Please try again.';
          break;
        case DioExceptionType.unknown:
          message = 'Something went wrong. Please try again.';
          break;
        default:
          message = 'Something went wrong. Please try again.';
      }
      err = err.copyWith(error: message);
      handler.next(err);
      return;
    }

    String message = 'Something went wrong. Please try again.';
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Handle server errors (5xx) with generic message
    if (statusCode != null && statusCode >= 500) {
      message = 'Server error. Please try again later.';
      err = err.copyWith(error: message);
      handler.next(err);
      return;
    }

    // Handle 403 Forbidden - extract clean message from server
    if (statusCode == 403) {
      if (data is Map) {
        final serverMsg = data['message']?.toString() ?? '';
        if (serverMsg.isNotEmpty) {
          message = serverMsg;
        }
      }
      err = err.copyWith(error: message);
      handler.next(err);
      return;
    }

    // Handle 404 Not Found
    if (statusCode == 404) {
      if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
        message = data['message'];
      } else {
        message = 'The requested resource was not found.';
      }
      err = err.copyWith(error: message);
      handler.next(err);
      return;
    }

    if (data is Map) {
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        message = data['message'];
      } else if (data['error'] is String && (data['error'] as String).isNotEmpty) {
        message = data['error'];
      }

      // Extract validation errors
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
        if (messages.isNotEmpty) {
          message = messages.join('\n');
        }
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    err = err.copyWith(error: message);
    handler.next(err);
  }
}
