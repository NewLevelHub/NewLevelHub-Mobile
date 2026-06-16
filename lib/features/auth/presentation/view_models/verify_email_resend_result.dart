/// Outcome of [VerifyEmailViewModel.resend] that the view reacts to for
/// navigation. Inline state (cooldown, error/info banner) is read straight
/// off the ViewModel via its getters instead.
sealed class VerifyEmailResendResult {
  const VerifyEmailResendResult();
}

/// Email sent — `VerifyEmailViewModel.infoMessage` already published.
final class VerifyEmailResendSuccess extends VerifyEmailResendResult {
  const VerifyEmailResendSuccess();
}

/// Backend returned 403 — the email is already verified. The view should
/// navigate to `AppRoutes.home`.
final class VerifyEmailResendAlreadyVerified extends VerifyEmailResendResult {
  const VerifyEmailResendAlreadyVerified();
}

/// Backend returned 429 (rate limit). `VerifyEmailViewModel.cooldownSeconds`
/// is already counting down — the view just re-renders, no navigation.
final class VerifyEmailResendRateLimited extends VerifyEmailResendResult {
  const VerifyEmailResendRateLimited();
}

/// Any other failure — `VerifyEmailViewModel.errorMessage` already
/// published. The view just re-renders, no navigation.
final class VerifyEmailResendFailure extends VerifyEmailResendResult {
  const VerifyEmailResendFailure(this.message);

  final String message;
}
