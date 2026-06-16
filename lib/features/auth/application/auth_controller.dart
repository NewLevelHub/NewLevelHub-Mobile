import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/models/user.dart';
import '../../../core/router/app_routes.dart';
import '../domain/auth_state.dart';
import '../domain/repositories/auth_repository.dart';

/// Centralized authentication state (MOB-101…107): tracks [AuthState],
/// exposes [currentUser] for the router and role-based UI, and reacts to
/// session expiry. Wired to [GoRouter.refreshListenable] and
/// `DioClient.onSessionExpired`.
///
/// ViewModels call [AuthRepository] for the actual network operation
/// (login/register/logout/...), then report the outcome here via
/// [setAuthenticatedUser] / [markUnauthenticated] so every screen observing
/// this controller sees a consistent, single source of truth.
class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AuthState _state = const AuthState.loading();
  GoRouter? _router;

  AuthState get state => _state;

  bool get isAuthenticated => _state is AuthStateAuthenticated;

  /// The signed-in user's profile. `null` while [state] is `loading` or
  /// `unauthenticated`.
  User? get currentUser => switch (_state) {
        AuthStateAuthenticated(user: final user) => user,
        _ => null,
      };

  void attachRouter(GoRouter router) {
    _router = router;
  }

  /// Cold start: if a local session exists, loads the current profile via
  /// `GET /auth/me/` (through [AuthRepository.fetchMe]) so role-based
  /// UI/router guards have an up-to-date user immediately — rather than
  /// just confirming the tokens are valid. Call once from the splash
  /// screen.
  ///
  /// Falls back to [AuthState.unauthenticated] on any failure: no local
  /// tokens, `fetchMe` 401 even after the interceptor's own refresh
  /// attempt, or a network error. That refresh-then-fail path also already
  /// triggers [onSessionExpired] independently via `DioClient
  /// .onSessionExpired` — this just makes sure [state] reflects it too.
  Future<void> bootstrap() async {
    _setState(const AuthState.loading());

    final hasSession = await _authRepository.hasActiveSession();
    if (!hasSession) {
      _setState(const AuthState.unauthenticated());
      return;
    }

    try {
      final user = await _authRepository.fetchMe();
      _setState(AuthState.authenticated(user));
    } catch (_) {
      _setState(const AuthState.unauthenticated());
    }
  }

  /// Stores the profile returned by a successful login/register and marks
  /// the session active in a single notification.
  void setAuthenticatedUser(User user) {
    _setState(AuthState.authenticated(user));
  }

  void markUnauthenticated() {
    _setState(const AuthState.unauthenticated());
  }

  /// Called when refresh fails or the session is no longer valid (MOB-006).
  void onSessionExpired() {
    markUnauthenticated();
    _router?.go(AppRoutes.login);
  }

  void _setState(AuthState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }
}
