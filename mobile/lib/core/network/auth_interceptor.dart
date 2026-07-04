import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['X-Platform'] = AppConfig.mobilePlatformHeader;
    final token = await SecureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ';
    }
    handler.next(options);
  }
}
