import 'package:flutter/foundation.dart';

import '../../../auth/application/auth_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Drives the profile screen. Currently only logout — extend with profile
/// data loading as the feature grows.
///
/// The view only reads state via the public getters and calls [logout] — it
/// never touches [AuthRepository] directly.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required AuthRepository authRepository,
    required AuthController authController,
  })  : _authRepository = authRepository,
        _authController = authController;

  final AuthRepository _authRepository;
  final AuthController _authController;

  bool _isLoggingOut = false;

  /// `true` while [logout] is in flight — disable the logout button to
  /// avoid duplicate taps.
  bool get isLoggingOut => _isLoggingOut;

  /// Best-effort server logout (`AuthRepository.logout`), then always marks
  /// the session unauthenticated locally. Never throws — `AuthRepository.
  /// logout` is documented as infallible, but any unexpected exception is
  /// swallowed here too so the view can unconditionally navigate to
  /// `AppRoutes.login` right after awaiting this call.
  Future<void> logout() async {
    _isLoggingOut = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (_) {
      // Local teardown below still happens regardless.
    } finally {
      _authController.markUnauthenticated();
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}
