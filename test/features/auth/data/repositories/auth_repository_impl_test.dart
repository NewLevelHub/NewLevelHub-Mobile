import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/auth_tokens.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/auth/token_storage.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:newlevelhub_mobile/features/auth/data/services/auth_service.dart';

void main() {
  group('AuthRepositoryImpl.login', () {
    late _FakeAuthService authService;
    late TokenStorage tokenStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      authService = _FakeAuthService();
      tokenStorage = TokenStorage(store: _InMemoryStore());
      repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: tokenStorage,
      );
    });

    test('forwards email, password and rememberMe to the service', () async {
      await repository.login(
        email: 'user@example.com',
        password: 'SecurePass123!',
        rememberMe: true,
      );

      expect(authService.capturedEmail, 'user@example.com');
      expect(authService.capturedPassword, 'SecurePass123!');
      expect(authService.capturedRememberMe, isTrue);
    });

    test('persists the returned tokens via TokenStorage', () async {
      await repository.login(
        email: 'user@example.com',
        password: 'SecurePass123!',
        rememberMe: false,
      );

      expect(await tokenStorage.getAccessToken(), 'fake-access');
      expect(await tokenStorage.getRefreshToken(), 'fake-refresh');
    });

    test('returns the domain User without leaking tokens', () async {
      final user = await repository.login(
        email: 'user@example.com',
        password: 'SecurePass123!',
        rememberMe: false,
      );

      expect(user, authService.userToReturn);
    });

    test('propagates exceptions from the service without persisting tokens', () async {
      authService.exceptionToThrow = Exception('boom');

      await expectLater(
        repository.login(email: 'a@b.c', password: 'pw', rememberMe: false),
        throwsException,
      );

      expect(await tokenStorage.hasTokens(), isFalse);
    });
  });

  group('AuthRepositoryImpl.hasActiveSession', () {
    late TokenStorage tokenStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      tokenStorage = TokenStorage(store: _InMemoryStore());
      repository = AuthRepositoryImpl(
        authService: _FakeAuthService(),
        tokenStorage: tokenStorage,
      );
    });

    test('is false with no stored tokens', () async {
      expect(await repository.hasActiveSession(), isFalse);
    });

    test('is true once tokens are persisted', () async {
      await tokenStorage.saveTokens(access: 'a', refresh: 'r');

      expect(await repository.hasActiveSession(), isTrue);
    });
  });

  group('AuthRepositoryImpl.resendVerificationEmail', () {
    test('delegates to AuthService', () async {
      final authService = _FakeAuthService();
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: TokenStorage(store: _InMemoryStore()),
      );

      await repository.resendVerificationEmail();

      expect(authService.resendCalls, 1);
    });

    test('propagates exceptions from the service', () async {
      final authService = _FakeAuthService()
        ..exceptionToThrow = Exception('boom');
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: TokenStorage(store: _InMemoryStore()),
      );

      await expectLater(
        repository.resendVerificationEmail(),
        throwsException,
      );
    });
  });

  group('AuthRepositoryImpl.verifyEmailToken', () {
    test('delegates to AuthService', () async {
      final authService = _FakeAuthService();
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: TokenStorage(store: _InMemoryStore()),
      );

      await repository.verifyEmailToken('a-token');

      expect(authService.verifyCalls, 1);
      expect(authService.lastVerifiedToken, 'a-token');
    });

    test('propagates exceptions from the service', () async {
      final authService = _FakeAuthService()..exceptionToThrow = Exception('boom');
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: TokenStorage(store: _InMemoryStore()),
      );

      await expectLater(
        repository.verifyEmailToken('a-token'),
        throwsException,
      );
    });
  });

  group('AuthRepositoryImpl.logout', () {
    test('clears stored tokens', () async {
      final tokenStorage = TokenStorage(store: _InMemoryStore());
      await tokenStorage.saveTokens(access: 'a', refresh: 'r');
      final repository = AuthRepositoryImpl(
        authService: _FakeAuthService(),
        tokenStorage: tokenStorage,
      );

      await repository.logout();

      expect(await tokenStorage.hasTokens(), isFalse);
    });

    test('calls AuthService.logout with the stored refresh token', () async {
      final tokenStorage = TokenStorage(store: _InMemoryStore());
      await tokenStorage.saveTokens(access: 'a', refresh: 'stored-refresh');
      final authService = _FakeAuthService();
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: tokenStorage,
      );

      await repository.logout();

      expect(authService.logoutCalls, 1);
      expect(authService.lastLogoutRefresh, 'stored-refresh');
    });

    test('clears tokens even when the server call fails (network error)', () async {
      final tokenStorage = TokenStorage(store: _InMemoryStore());
      await tokenStorage.saveTokens(access: 'a', refresh: 'r');
      final authService = _FakeAuthService()
        ..exceptionToThrow = Exception('network down');
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: tokenStorage,
      );

      await repository.logout();

      expect(await tokenStorage.hasTokens(), isFalse);
    });

    test('clears tokens even when the server rejects an invalid refresh (400)', () async {
      final tokenStorage = TokenStorage(store: _InMemoryStore());
      await tokenStorage.saveTokens(access: 'a', refresh: 'r');
      final authService = _FakeAuthService()
        ..exceptionToThrow = const ApiException(
          message: 'Refresh-токен обязателен',
          statusCode: 400,
        );
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: tokenStorage,
      );

      await repository.logout();

      expect(await tokenStorage.hasTokens(), isFalse);
    });

    test('does not call the server when there is no stored refresh token', () async {
      final authService = _FakeAuthService();
      final repository = AuthRepositoryImpl(
        authService: authService,
        tokenStorage: TokenStorage(store: _InMemoryStore()),
      );

      await repository.logout();

      expect(authService.logoutCalls, 0);
    });
  });
}

class _FakeAuthService extends AuthService {
  _FakeAuthService() : super(Dio());

  User userToReturn = User(
    id: 1,
    email: 'user@example.com',
    firstName: 'Анна',
    lastName: 'Иванова',
    fullName: 'Анна Иванова',
    role: UserRole.employee,
    isEmailVerified: true,
    dateJoined: DateTime(2024, 1, 1),
  );

  AuthTokens tokensToReturn = const AuthTokens(
    access: 'fake-access',
    refresh: 'fake-refresh',
  );

  Object? exceptionToThrow;

  String? capturedEmail;
  String? capturedPassword;
  bool? capturedRememberMe;
  int resendCalls = 0;
  int verifyCalls = 0;
  String? lastVerifiedToken;
  int logoutCalls = 0;
  String? lastLogoutRefresh;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    capturedEmail = email;
    capturedPassword = password;
    capturedRememberMe = rememberMe;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }

    return LoginResponse(user: userToReturn, tokens: tokensToReturn);
  }

  @override
  Future<void> resendVerificationEmail() async {
    resendCalls++;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    verifyCalls++;
    lastVerifiedToken = token;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalls++;
    lastLogoutRefresh = refreshToken;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }
}

class _InMemoryStore implements SecureKeyValueStore {
  final _data = <String, String>{};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }
}
