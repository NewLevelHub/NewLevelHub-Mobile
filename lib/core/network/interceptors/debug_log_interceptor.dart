import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs HTTP method, path, and status code in debug builds only.
///
/// Request/response bodies are never logged for [sensitivePaths] (passwords,
/// refresh tokens, etc.).
class DebugLogInterceptor extends Interceptor {
  DebugLogInterceptor({void Function(String message)? log})
      : _log = log ?? debugPrint;

  final void Function(String message) _log;

  /// Paths whose request/response bodies must not appear in logs.
  static const sensitivePaths = <String>{
    '/auth/login/',
    '/auth/register/',
    '/auth/register/invite/',
    '/auth/token/refresh/',
    '/auth/logout/',
    '/auth/password/reset/confirm/',
    '/me/password/',
  };

  static bool isSensitivePath(String path) {
    final normalized = path.endsWith('/') ? path : '$path/';
    return sensitivePaths.any(
      (sensitive) =>
          normalized.contains(sensitive) || sensitive.contains(normalized),
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.uri.path;
    final sensitive = isSensitivePath(path);
    _log(
      '[DIO] → ${options.method} $path'
      '${sensitive ? ' (body redacted)' : ''}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final path = response.requestOptions.uri.path;
    final sensitive = isSensitivePath(path);
    _log(
      '[DIO] ← ${response.requestOptions.method} $path '
      '${response.statusCode}'
      '${sensitive ? ' (body redacted)' : ''}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.uri.path;
    final status = err.response?.statusCode ?? '—';
    final sensitive = isSensitivePath(path);
    _log(
      '[DIO] ✕ ${err.requestOptions.method} $path $status'
      '${sensitive ? ' (body redacted)' : ''}',
    );
    handler.next(err);
  }
}
