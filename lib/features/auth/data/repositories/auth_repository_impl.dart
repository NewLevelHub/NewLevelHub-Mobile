import '../../../../core/auth/models/user.dart';
import '../../../../core/auth/token_refresher.dart';
import '../../../../core/auth/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

/// Default [AuthRepository]: calls [AuthService], persists the returned
/// tokens via [TokenStorage], and hands the clean [User] domain model up —
/// callers never see the raw login/register response or token pair.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthService authService,
    required TokenStorage tokenStorage,
    TokenRefresher? tokenRefresher,
  })  : _authService = authService,
        _tokenStorage = tokenStorage,
        _tokenRefresher = tokenRefresher ??
            TokenRefresher(dio: authService.dio, tokenStorage: tokenStorage);

  final AuthService _authService;
  final TokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;

  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final result = await _authService.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    await _tokenStorage.saveTokens(
      access: result.tokens.access,
      refresh: result.tokens.refresh,
    );

    return result.user;
  }

  @override
  Future<User> register({
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    required String password,
    required String passwordConfirm,
  }) async {
    final result = await _authService.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
      passwordConfirm: passwordConfirm,
    );

    await _tokenStorage.saveTokens(
      access: result.tokens.access,
      refresh: result.tokens.refresh,
    );

    return result.user;
  }

  @override
  Future<User> fetchMe() => _authService.fetchMe();

  @override
  Future<bool> refresh() async {
    final access = await _tokenRefresher.refresh();
    if (access == null) {
      await _tokenStorage.clearTokens();
      return false;
    }
    return true;
  }

  @override
  Future<bool> hasActiveSession() => _tokenStorage.hasTokens();

  @override
  Future<void> resendVerificationEmail() =>
      _authService.resendVerificationEmail();

  @override
  Future<void> verifyEmailToken(String token) =>
      _authService.verifyEmail(token);

  @override
  Future<void> logout() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _authService.logout(refresh);
      } catch (_) {
        // Best-effort: a network failure or an already-invalid refresh
        // token (400) must not block the local session teardown below.
      }
    }
    await _tokenStorage.clearTokens();
  }
}
