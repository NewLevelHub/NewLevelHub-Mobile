import 'package:dio/dio.dart';

import '../network/error_parser.dart';
import 'token_storage.dart';

/// The single implementation of the `/auth/token/refresh/` exchange.
///
/// Shared by [AuthInterceptor]'s automatic retry-on-401 path and
/// `AuthRepository.refresh()`'s explicit/manual path, so the refresh-token
/// logic itself lives in exactly one place — see
/// `AuthInterceptor.AuthInterceptor` and `AuthRepositoryImpl.refresh` for the
/// two call sites.
class TokenRefresher {
  TokenRefresher({required Dio dio, required this.tokenStorage}) : _dio = dio;

  final Dio _dio;
  final TokenStorage tokenStorage;

  static const sessionExpiredCodes = <String>{
    'SESSION_IDLE_TIMEOUT',
    'SESSION_ABSOLUTE_TIMEOUT',
  };

  Future<String?>? _inFlight;

  /// Exchanges the stored refresh token for a new access/refresh pair and
  /// persists it (refresh tokens rotate — the previous one becomes invalid).
  ///
  /// Returns the new access token, or `null` when there is no local refresh
  /// token or the session is no longer valid (401, or a session-expired
  /// error code) — callers should treat `null` as "log the user out".
  /// Rethrows on other failures (e.g. network errors), which callers should
  /// not treat as a definitive session expiry.
  ///
  /// Concurrent calls are coalesced into a single network request.
  Future<String?> refresh() {
    return _inFlight ??= _performRefresh().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/token/refresh/',
        data: <String, dynamic>{'refresh': refreshToken},
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
    return code != null && sessionExpiredCodes.contains(code);
  }
}
