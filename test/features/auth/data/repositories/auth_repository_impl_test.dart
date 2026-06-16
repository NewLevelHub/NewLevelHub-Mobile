import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/auth_tokens.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/auth/token_storage.dart';
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
