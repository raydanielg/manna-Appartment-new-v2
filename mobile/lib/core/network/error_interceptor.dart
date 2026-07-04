import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Something went wrong';
    final data = err.response?.data;
    if (data is Map && data['message'] != null) {
      message = data['message'];
    } else if (data is Map && data['error'] != null) {
      message = data['error'];
    }
    err = err.copyWith(error: message);
    handler.next(err);
  }
}
