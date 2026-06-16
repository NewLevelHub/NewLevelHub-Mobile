import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_storage.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';
import 'interceptors/debug_log_interceptor.dart';

/// Singleton HTTP client configured for the Django REST API.
class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  factory DioClient() => instance;

  static const Duration _timeout = Duration(seconds: 30);

  /// Secure token store shared with [AuthInterceptor].
  final TokenStorage tokenStorage = TokenStorage();

  /// Called when refresh fails or the session is no longer valid.
  void Function() onSessionExpired = () {};

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

    client.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onSessionExpired: () => onSessionExpired(),
        dio: client,
      ),
    );

    if (kDebugMode) {
      client.interceptors.add(DebugLogInterceptor());
    }

    return client;
  }
}
