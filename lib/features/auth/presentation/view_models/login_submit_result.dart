/// Outcome of [LoginViewModel.submit] that the view reacts to for
/// navigation. Inline state (errors, loading) is read straight off the
/// ViewModel via its getters instead.
sealed class LoginSubmitResult {
  const LoginSubmitResult();
}

/// Local validation failed (empty/invalid email or password) — field errors
/// are already published via `LoginViewModel.emailError`/`passwordError`.
/// The view re-renders; no navigation happens.
final class LoginSubmitValidationFailed extends LoginSubmitResult {
  const LoginSubmitValidationFailed();
}

/// Login succeeded — tokens are persisted and the session is marked active.
/// The view should navigate to `AppRoutes.home`.
final class LoginSubmitSuccess extends LoginSubmitResult {
  const LoginSubmitSuccess();
}

/// Backend returned 403 `EMAIL_NOT_VERIFIED`. The view should navigate to
/// `AppRoutes.verifyEmail`, passing [email] along.
final class LoginSubmitEmailNotVerified extends LoginSubmitResult {
  const LoginSubmitEmailNotVerified(this.email);

  final String email;
}

/// Any other failure (invalid credentials, blocked account, network/server
/// error). [message] is already published via `LoginViewModel.errorMessage`
/// — the view just re-renders, no navigation.
final class LoginSubmitFailure extends LoginSubmitResult {
  const LoginSubmitFailure(this.message);

  final String message;
}
