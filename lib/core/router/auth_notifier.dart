import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Tracks authentication state and reacts to session expiry.
///
/// Wired to [GoRouter.refreshListenable] and [DioClient.onSessionExpired].
class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  GoRouter? _router;

  bool get isAuthenticated => _isAuthenticated;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  void markAuthenticated() {
    if (_isAuthenticated) return;
    _isAuthenticated = true;
    notifyListeners();
  }

  void markUnauthenticated() {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Called when refresh fails or the session is no longer valid (MOB-006).
  void onSessionExpired() {
    markUnauthenticated();
    _router?.go(AppRoutes.login);
  }
}
