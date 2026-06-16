import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/token_storage.dart';
import 'error_parser.dart';

/// Injects `Authorization: Bearer <access>` and refreshes tokens on 401.
///
/// See `mobile_api.md` → «Рекомендуемый flow».
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.onSessionExpired,
    required Dio dio,
    Dio? refreshDio,
  })  : _dio = dio,
        _refreshDio = refreshDio ?? _createRefreshClient(dio);

  final TokenStorage tokenStorage;
  final void Function() onSessionExpired;
  final Dio _dio;
  final Dio _refreshDio;

  static Dio _createRefreshClient(Dio dio) {
    return Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        headers: Map<String, dynamic>.from(dio.options.headers),
      ),
    );
  }

  static const _extraAuthRetried = 'auth_retried';

  /// Paths that must not receive a Bearer token.
  static const publicPaths = <String>{
    '/auth/login/',
    '/auth/register/',
    '/auth/token/refresh/',
    '/auth/logout/',
    '/auth/password/reset/',
    '/auth/password/reset/confirm/',
    '/auth/register/invite/',
    '/auth/email/verify/',
    '/ping/',
    '/health/',
  };

  static const _sessionExpiredCodes = <String>{
    'SESSION_IDLE_TIMEOUT',
    'SESSION_ABSOLUTE_TIMEOUT',
  };

  Future<String?>? _refreshFuture;

  static bool isPublicPath(String path) {
    final normalized = _normalizePath(path);
    return publicPaths.any(
      (publicPath) =>
          normalized == publicPath || normalized.endsWith(publicPath),
    );
  }

  static String _normalizePath(String path) {
    var normalized = path.startsWith('/') ? path : '/$path';
    if (!normalized.endsWith('/')) {
      normalized = '$normalized/';
    }
    return normalized;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (isPublicPath(options.uri.path)) {
      handler.next(options);
      return;
    }

    final access = await tokenStorage.getAccessToken();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.uri.path;

    if (statusCode != 401) {
      handler.next(err);
      return;
    }

    if (isPublicPath(path)) {
      handler.next(err);
      return;
    }

    if (err.requestOptions.extra[_extraAuthRetried] == true) {
      await _handleSessionExpired();
      handler.next(err);
      return;
    }

    try {
      final newAccess = await _obtainFreshAccessToken();
      if (newAccess == null) {
        await _handleSessionExpired();
        handler.next(err);
        return;
      }

      final retryOptions = err.requestOptions;
      retryOptions.extra[_extraAuthRetried] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';

      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<String?> _obtainFreshAccessToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refresh = await tokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/token/refresh/',
        data: <String, dynamic>{'refresh': refresh},
      );

      final data = response.data;
      if (data == null) {
        return null;
      }

      final access = data['access']?.toString();
      final newRefresh = data['refresh']?.toString();
      if (access == null ||
          access.isEmpty ||
          newRefresh == null ||
          newRefresh.isEmpty) {
        return null;
      }

      await tokenStorage.saveTokens(access: access, refresh: newRefresh);
      return access;
    } on DioException catch (error) {
      if (_shouldExpireSession(error)) {
        return null;
      }
      rethrow;
    }
  }

  bool _shouldExpireSession(DioException error) {
    if (error.response?.statusCode == 401) {
      return true;
    }

    final apiError = ErrorParser.parse(error);
    final code = apiError.code;
    return code != null && _sessionExpiredCodes.contains(code);
  }

  Future<void> _handleSessionExpired() async {
    await tokenStorage.clearTokens();
    onSessionExpired();
  }
}
