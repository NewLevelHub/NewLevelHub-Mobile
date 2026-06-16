import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/token_refresher.dart';
import '../auth/token_storage.dart';

/// Injects `Authorization: Bearer <access>` and refreshes tokens on 401.
///
/// See `mobile_api.md` → «Рекомендуемый flow». The actual refresh exchange
/// lives in [TokenRefresher] — shared with `AuthRepository.refresh()` so the
/// token-refresh logic itself is implemented exactly once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.onSessionExpired,
    required Dio dio,
    Dio? refreshDio,
    TokenRefresher? tokenRefresher,
  })  : _dio = dio,
        _tokenRefresher = tokenRefresher ??
            TokenRefresher(
              dio: refreshDio ?? _createRefreshClient(dio),
              tokenStorage: tokenStorage,
            );

  final TokenStorage tokenStorage;
  final void Function() onSessionExpired;
  final Dio _dio;
  final TokenRefresher _tokenRefresher;

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

  Future<String?> _obtainFreshAccessToken() => _tokenRefresher.refresh();

  Future<void> _handleSessionExpired() async {
    await tokenStorage.clearTokens();
    onSessionExpired();
  }
}
