import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../application/auth_controller.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_strings.dart';
import 'verify_email_resend_result.dart';

/// Drives the "waiting for email confirmation" screen: checks whether a
/// resend is possible (an access token must exist — see
/// `AuthRepository.hasActiveSession`), submits resend requests, and tracks
/// the 429 cooldown. The view only reads state via the public getters and
/// calls [loadSession]/[resend]/[logout] — it never touches the repository
/// directly.
class VerifyEmailViewModel extends ChangeNotifier {
  VerifyEmailViewModel({
    required AuthRepository authRepository,
    required AuthController authController,
    required String email,
    Duration rateLimitCooldown = const Duration(seconds: 60),
  })  : _authRepository = authRepository,
        _authController = authController,
        _email = email,
        _rateLimitCooldown = rateLimitCooldown;

  final AuthRepository _authRepository;
  final AuthController _authController;
  final String _email;
  final Duration _rateLimitCooldown;

  Timer? _cooldownTimer;

  bool _isLoadingSession = true;
  bool _canResend = false;
  bool _isResending = false;
  int _cooldownSeconds = 0;
  String? _errorMessage;
  String? _infoMessage;

  String get email => _email;

  /// `true` while [loadSession] is checking for a local access token.
  bool get isLoadingSession => _isLoadingSession;

  /// `true` once a local access token was found — the resend button (and
  /// its cooldown) is only shown then. `false` after `register-by-invite`
  /// (no tokens are issued there) — only the instruction text is shown.
  bool get canResend => _canResend;

  bool get isResending => _isResending;

  /// Seconds left before another resend attempt is allowed after a 429.
  int get cooldownSeconds => _cooldownSeconds;

  bool get isInCooldown => _cooldownSeconds > 0;

  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  /// Checks for a local access token. Call once from the view's `initState`.
  Future<void> loadSession() async {
    _canResend = await _authRepository.hasActiveSession();
    _isLoadingSession = false;
    notifyListeners();
  }

  /// Calls `POST /auth/email/resend/`. No-op (returns the previous failure
  /// state) while already resending or in cooldown.
  Future<VerifyEmailResendResult> resend() async {
    if (_isResending || isInCooldown || !_canResend) {
      return const VerifyEmailResendFailure('');
    }

    _isResending = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      await _authRepository.resendVerificationEmail();
      _infoMessage = AuthStrings.resendEmailSent;
      return const VerifyEmailResendSuccess();
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        // The only 403 this endpoint returns is "already verified".
        return const VerifyEmailResendAlreadyVerified();
      }
      if (e.statusCode == 429) {
        _startCooldown();
        _errorMessage = AuthStrings.resendCooldown(_cooldownSeconds);
        return const VerifyEmailResendRateLimited();
      }
      _errorMessage = e.message;
      return VerifyEmailResendFailure(e.message);
    } finally {
      _isResending = false;
      notifyListeners();
    }
  }

  /// Clears the local session and marks the app unauthenticated. The view
  /// should navigate to `AppRoutes.login` afterwards.
  Future<void> logout() async {
    await _authRepository.logout();
    _authController.markUnauthenticated();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownSeconds = _rateLimitCooldown.inSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _cooldownSeconds -= 1;
      if (_cooldownSeconds <= 0) {
        _cooldownSeconds = 0;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
