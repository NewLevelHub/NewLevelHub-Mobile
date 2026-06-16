import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_strings.dart';
import 'email_verify_link_result.dart';

/// Drives the deep-link email confirmation screen reached from
/// `https://newlevelhub.kz/verify-email?token=...` /
/// `newlevelhub://verify-email?token=...`.
///
/// Calls `GET /auth/email/verify/?token=...` once on [verify] and classifies
/// the outcome into [EmailVerifyLinkResult]. The view only reads state via
/// the public getters and calls [verify]/[resend] — it never touches the
/// repository directly.
class EmailVerifyLinkViewModel extends ChangeNotifier {
  EmailVerifyLinkViewModel({
    required AuthRepository authRepository,
    required String token,
  })  : _authRepository = authRepository,
        _token = token;

  final AuthRepository _authRepository;
  final String _token;

  /// The backend's plain `{detail}` text for `auth.token_already_used` /
  /// `auth.token_expired` (see `locale/ru.json` in the backend repo). The
  /// `/auth/email/verify/` endpoint returns these as a raw 400 `{detail}`
  /// string with no `code` field — unlike the `TOKEN_ALREADY_USED` /
  /// `TOKEN_EXPIRED` codes used elsewhere in the backend's error catalogue
  /// (`apps/core/error_codes.py`). Matching on message text is a workaround
  /// for that gap; flag it to the backend team if it becomes brittle (e.g.
  /// once non-`ru` locales are wired in).
  static const _alreadyUsedMessage = 'Токен уже использован.';
  static const _expiredMessage = 'Токен истёк.';

  bool _isLoading = true;
  EmailVerifyLinkResult? _result;
  bool _canResend = false;
  bool _isResending = false;
  String? _resendMessage;
  bool _resendFailed = false;

  bool get isLoading => _isLoading;
  EmailVerifyLinkResult? get result => _result;

  /// `true` once a local access token was found — only then can
  /// `POST /auth/email/resend/` be called (it requires a Bearer token).
  bool get canResend => _canResend;

  bool get isResending => _isResending;
  String? get resendMessage => _resendMessage;
  bool get resendFailed => _resendFailed;

  /// Calls the verify endpoint once. Call from the view's `initState`.
  Future<void> verify() async {
    if (_token.isEmpty) {
      _isLoading = false;
      _result = const EmailVerifyLinkFailure(AuthStrings.verifyLinkNoTokenMessage);
      notifyListeners();
      return;
    }

    _canResend = await _authRepository.hasActiveSession();

    try {
      await _authRepository.verifyEmailToken(_token);
      _result = const EmailVerifyLinkSuccess();
    } on ApiException catch (e) {
      _result = _classify(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  EmailVerifyLinkResult _classify(ApiException e) {
    if (e.statusCode == 404) {
      return const EmailVerifyLinkInvalid();
    }
    if (e.statusCode == 400) {
      // Malformed token (not a UUID at all — a garbled/truncated link).
      // `EmailVerifySerializer.token` rejects it before the lookup even
      // happens, so this goes through the proper `{success, error}`
      // envelope with `code: VALIDATION_ERROR` — but the message itself is
      // DRF's untranslated field error ("Must be a valid UUID."), which
      // isn't something to show a Russian-speaking user. Treat it the same
      // as "link doesn't exist".
      if (e.code == 'VALIDATION_ERROR') {
        return const EmailVerifyLinkInvalid();
      }
      if (e.message == _alreadyUsedMessage) {
        return const EmailVerifyLinkAlreadyUsed();
      }
      if (e.message == _expiredMessage) {
        return const EmailVerifyLinkExpired();
      }
    }
    return EmailVerifyLinkFailure(e.message);
  }

  /// Calls `POST /auth/email/resend/`. No-op while already resending or
  /// without an active session (see [canResend]).
  Future<void> resend() async {
    if (_isResending || !_canResend) {
      return;
    }

    _isResending = true;
    _resendMessage = null;
    _resendFailed = false;
    notifyListeners();

    try {
      await _authRepository.resendVerificationEmail();
      _resendMessage = AuthStrings.verifyLinkResendSent;
      _resendFailed = false;
    } on ApiException catch (e) {
      _resendMessage = e.message;
      _resendFailed = true;
    } finally {
      _isResending = false;
      notifyListeners();
    }
  }
}
