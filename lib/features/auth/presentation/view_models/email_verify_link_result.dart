/// Outcome of [EmailVerifyLinkViewModel.verify] that the view renders.
sealed class EmailVerifyLinkResult {
  const EmailVerifyLinkResult();
}

/// 200 — token was valid and the email is now verified.
final class EmailVerifyLinkSuccess extends EmailVerifyLinkResult {
  const EmailVerifyLinkSuccess();
}

/// 400, token already used. The backend doesn't attach an error `code` for
/// this case (see `AuthService.verifyEmail`) — the ViewModel matches on the
/// translated `detail` message text instead.
final class EmailVerifyLinkAlreadyUsed extends EmailVerifyLinkResult {
  const EmailVerifyLinkAlreadyUsed();
}

/// 400, token expired. Same caveat as [EmailVerifyLinkAlreadyUsed] — matched
/// by message text, not an error code.
final class EmailVerifyLinkExpired extends EmailVerifyLinkResult {
  const EmailVerifyLinkExpired();
}

/// 404 (token doesn't exist) or 400 `VALIDATION_ERROR` (token isn't even a
/// valid UUID — a garbled/truncated link). Both render as a generic
/// "invalid link" message rather than the raw backend text.
final class EmailVerifyLinkInvalid extends EmailVerifyLinkResult {
  const EmailVerifyLinkInvalid();
}

/// Any other failure (network, 500, validation) — [message] is already a
/// user-displayable string from `ApiException.message`.
final class EmailVerifyLinkFailure extends EmailVerifyLinkResult {
  const EmailVerifyLinkFailure(this.message);

  final String message;
}
