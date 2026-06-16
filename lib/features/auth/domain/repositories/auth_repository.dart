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

  /// Registers a new guest account via `POST /auth/register/`, persists the
  /// returned tokens, and returns the authenticated [User] — same shape as
  /// [login]. Throws `ApiException` on validation failures (`fieldErrors`
  /// keyed by `email`/`password`/etc., see `UserRegistrationSerializer`).
  Future<User> register({
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    required String password,
    required String passwordConfirm,
  });

  /// Fetches the current profile via `GET /auth/me/`. Used by
  /// `AuthController.bootstrap` on cold start and after any flow that needs
  /// a fresh profile. Throws `ApiException` — including `statusCode == 401`
  /// if the access token is invalid *and* the interceptor's automatic
  /// refresh-then-retry also failed (i.e. the session truly expired).
  Future<User> fetchMe();

  /// Explicitly exchanges the stored refresh token for a new access/refresh
  /// pair, via the same [TokenRefresher] `AuthInterceptor` uses for its
  /// automatic 401 retries — no separate implementation of the refresh
  /// exchange here. Returns `false` (after clearing local tokens) if there
  /// is no refresh token or the session is no longer valid.
  Future<bool> refresh();

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
