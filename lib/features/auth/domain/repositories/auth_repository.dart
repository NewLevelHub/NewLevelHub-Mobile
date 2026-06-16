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
}
