import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Something went wrong. Please try again.';
    final data = err.response?.data;

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
