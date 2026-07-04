import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'X-Platform': AppConfig.mobilePlatformHeader,
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.i('REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logger.e('ERROR: ${e.response?.statusCode} ${e.requestOptions.path}');
          if (e.response?.statusCode == 401) {
            await SecureStorageService.clearAll();
          }
          return handler.next(e);
        },
      ),
    );

    if (AppConfig.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: _encodeBody(data),
      queryParameters: queryParameters,
      options: _jsonOptions(data, options),
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: _encodeBody(data),
      queryParameters: queryParameters,
      options: _jsonOptions(data, options),
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: _encodeBody(data),
      queryParameters: queryParameters,
      options: _jsonOptions(data, options),
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: _encodeBody(data),
      queryParameters: queryParameters,
      options: _jsonOptions(data, options),
    );
  }

  dynamic _encodeBody(dynamic data) {
    if (data == null || data is String || data is FormData || data is List<int>) {
      return data;
    }
    return jsonEncode(data);
  }

  Options? _jsonOptions(dynamic data, Options? options) {
    final String contentType;
    if (data is FormData) {
      contentType = 'multipart/form-data';
    } else {
      contentType = 'application/json';
    }
    if (options != null) {
      return options.copyWith(contentType: contentType);
    }
    return Options(contentType: contentType);
  }

  Future<Response> uploadFile(
    String path, {
    required File file,
    String field = 'file',
    Map<String, dynamic>? extraData,
  }) async {
    final formData = FormData.fromMap({
      field: await MultipartFile.fromFile(file.path),
      ...?extraData,
    });
    return _dio.post(path, data: formData);
  }
}
