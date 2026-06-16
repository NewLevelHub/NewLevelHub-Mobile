import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/auth/models/user.dart';

part 'auth_state.freezed.dart';

/// Centralized authentication state, owned by `AuthController`.
///
/// `loading` covers the cold-start window while [AuthController.bootstrap]
/// is deciding between the other two states (checking for local tokens and,
/// if present, fetching the current profile via `GET /auth/me/`) — never
/// re-entered afterwards.
@freezed
class AuthState with _$AuthState {
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
}
