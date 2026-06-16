import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../auth/models/user.dart';
import 'app_routes.dart';

/// Tracks authentication state and reacts to session expiry.
///
/// Wired to [GoRouter.refreshListenable] and [DioClient.onSessionExpired].
class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  User? _currentUser;

  GoRouter? _router;

  bool get isAuthenticated => _isAuthenticated;

  /// The signed-in user's profile, set via [setAuthenticatedUser]. `null`
  /// when unauthenticated, or when authenticated through a flow that hasn't
  /// loaded the profile yet (e.g. splash session validation).
  User? get currentUser => _currentUser;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  void markAuthenticated() {
    if (_isAuthenticated) return;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Stores the profile returned by a successful login/register and marks
  /// the session active in a single notification.
  void setAuthenticatedUser(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  void markUnauthenticated() {
    if (!_isAuthenticated && _currentUser == null) return;
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Called when refresh fails or the session is no longer valid (MOB-006).
  void onSessionExpired() {
    markUnauthenticated();
    _router?.go(AppRoutes.login);
  }
}
