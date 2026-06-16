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
}
