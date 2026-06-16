import '../../../../core/auth/models/user.dart';

/// Abstracts authentication operations from the UI layer. ViewModels depend
/// on this interface, never on [AuthService]/Dio directly.
abstract interface class AuthRepository {
  /// Logs in with email/password via `POST /auth/login/`, persists the
  /// returned tokens, and returns the authenticated [User].
  ///
  /// Throws `EmailNotVerifiedException` on 403 `EMAIL_NOT_VERIFIED` and
  /// `ApiException` for other failures (400 invalid credentials, 403
  /// blocked account, etc.) — see `core/network/api_exception.dart`.
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// `true` when a local access token exists — i.e. the user just went
  /// through `register`/`login` and can call Bearer-authenticated
  /// endpoints. `false` after `register-by-invite` (no tokens are issued)
  /// or once tokens have been cleared by [logout].
  Future<bool> hasActiveSession();

  /// Resends the verification email via `POST /auth/email/resend/`
  /// (requires an access token — see [hasActiveSession]).
  ///
  /// Throws `ApiException` with `statusCode == 403` if the email is
  /// already verified, `statusCode == 429` if the resend rate limit (3
  /// requests / 10 min) was hit, or another `ApiException` on other
  /// failures.
  Future<void> resendVerificationEmail();

  /// Confirms a verification token via `GET /auth/email/verify/?token=...`
  /// (public — no access token required).
  ///
  /// Throws `ApiException` with `statusCode == 404` if the token doesn't
  /// exist, `statusCode == 400` if it was already used or has expired (see
  /// `EmailVerifyLinkViewModel` for how these two are told apart), or
  /// another `ApiException` on other failures.
  Future<void> verifyEmailToken(String token);

  /// Logs out: best-effort `POST /auth/logout/` to blacklist the refresh
  /// token server-side, then **always** clears the local session — even on
  /// a network failure or a 400 (refresh missing/already invalid). Callers
  /// should treat this as infallible and proceed straight to navigation.
  Future<void> logout();
}
