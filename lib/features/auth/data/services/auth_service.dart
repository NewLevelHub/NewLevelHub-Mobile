import 'package:dio/dio.dart';

import '../../../../core/auth/models/auth_tokens.dart';
import '../../../../core/auth/models/user.dart';
import '../../../../core/network/error_parser.dart';

/// Raw response of `POST /auth/login/`: profile + JWT pair. Transient —
/// never exposed past [AuthRepositoryImpl], which persists the tokens and
/// hands the [User] up to the UI layer.
class LoginResponse {
  const LoginResponse({required this.user, required this.tokens});

  final User user;
  final AuthTokens tokens;
}

/// Stateless wrapper around the shared Dio client for the login endpoint.
/// No business logic — parses the JSON response and converts transport
/// errors to [ApiException] via [ErrorParser].
class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<LoginResponse> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login/',
        data: <String, dynamic>{
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        },
      );

      final data = response.data!;
      return LoginResponse(
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        tokens: AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  /// `POST /auth/email/resend/` — requires a Bearer access token, attached
  /// automatically by `AuthInterceptor`. Response body is a `{detail}`
  /// message on success; only the status matters to the caller.
  Future<void> resendVerificationEmail() async {
    try {
      await _dio.post<Map<String, dynamic>>('/auth/email/resend/');
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  /// `GET /auth/email/verify/?token=...` — public, no Bearer required (see
  /// `AuthInterceptor.publicPaths`). Only the status matters to the caller;
  /// the response body is a `{detail}` message on success.
  ///
  /// On failure: 404 when the token doesn't exist (envelope error, code
  /// `NOT_FOUND`); 400 with a plain `{detail}` message (no error `code`) when
  /// the token was already used or has expired — the backend doesn't attach
  /// `TOKEN_ALREADY_USED`/`TOKEN_EXPIRED` here unlike other token endpoints,
  /// see `EmailVerifyLinkViewModel` for how the message text is matched.
  Future<void> verifyEmail(String token) async {
    try {
      await _dio.get<Map<String, dynamic>>(
        '/auth/email/verify/',
        queryParameters: <String, dynamic>{'token': token},
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  /// `POST /auth/logout/` — public, no Bearer required (see
  /// `AuthInterceptor.publicPaths`); blacklists [refreshToken] server-side.
  /// Response body is a `{detail}` message on success.
  ///
  /// Throws `ApiException` with `statusCode == 400` if [refreshToken] is
  /// missing or already invalid — see `AuthRepositoryImpl.logout`, which
  /// treats this call as best-effort and always clears local tokens
  /// regardless of the outcome.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/logout/',
        data: <String, dynamic>{'refresh': refreshToken},
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }
}
