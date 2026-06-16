import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'interceptors/debug_log_interceptor.dart';

/// Singleton HTTP client configured for the Django REST API.
class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  factory DioClient() => instance;

  static const Duration _timeout = Duration(seconds: 30);

  late final Dio dio = _createDio();

  Dio _createDio() {
    final client = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        headers: {
          'Accept': ApiConfig.defaultHeaders['Accept']!,
          'Accept-Language': ApiConfig.defaultHeaders['Accept-Language']!,
        },
      ),
    );

    if (kDebugMode) {
      client.interceptors.add(DebugLogInterceptor());
    }

    return client;
  }
}
