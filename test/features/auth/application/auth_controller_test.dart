import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/core/router/app_routes.dart';
import 'package:newlevelhub_mobile/features/auth/domain/auth_state.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/auth/application/auth_controller.dart';

void main() {
  group('AuthController', () {
    late _FakeAuthRepository repository;
    late AuthController controller;

    setUp(() {
      repository = _FakeAuthRepository();
      controller = AuthController(authRepository: repository);
    });

    test('starts in the loading state', () {
      expect(controller.state, const AuthState.loading());
      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
    });

    group('bootstrap', () {
      test('moves to unauthenticated when there is no local session', () async {
        repository.hasActiveSessionResult = false;

        await controller.bootstrap();

        expect(controller.state, const AuthState.unauthenticated());
        expect(controller.isAuthenticated, isFalse);
      });

      test('loads the profile via fetchMe when a local session exists', () async {
        repository.hasActiveSessionResult = true;
        repository.fetchMeResult = _user();

        await controller.bootstrap();

        expect(controller.isAuthenticated, isTrue);
        expect(controller.currentUser, _user());
      });

      test('falls back to unauthenticated when fetchMe fails (e.g. refresh failed)', () async {
        repository.hasActiveSessionResult = true;
        repository.fetchMeException = const ApiException(
          code: 'UNAUTHENTICATED',
          message: 'Требуется авторизация',
          statusCode: 401,
        );

        await controller.bootstrap();

        expect(controller.isAuthenticated, isFalse);
        expect(controller.currentUser, isNull);
      });

      test('notifies listeners exactly once per state transition', () async {
        repository.hasActiveSessionResult = true;
        repository.fetchMeResult = _user();
        var notifications = 0;
        controller.addListener(() => notifications++);

        await controller.bootstrap();

        // loading -> loading (no-op, same value) -> authenticated
        expect(notifications, 1);
      });
    });

    test('setAuthenticatedUser stores the user and marks authenticated', () {
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setAuthenticatedUser(_user());

      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser, _user());
      expect(notifications, 1);
    });

    test('markUnauthenticated clears the stored user', () {
      controller.setAuthenticatedUser(_user());

      controller.markUnauthenticated();

      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
    });

    testWidgets('onSessionExpired clears auth and navigates to login', (tester) async {
      controller.setAuthenticatedUser(_user());
      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Scaffold(body: Text('home')),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => const Scaffold(body: Text('login')),
          ),
        ],
      );
      controller.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      controller.onSessionExpired();
      await tester.pumpAndSettle();

      expect(controller.isAuthenticated, isFalse);
      expect(router.state.matchedLocation, AppRoutes.login);
      expect(find.text('login'), findsOneWidget);
    });
  });
}

User _user() => User(
      id: 1,
      email: 'user@example.com',
      firstName: 'Анна',
      lastName: 'Иванова',
      fullName: 'Анна Иванова',
      role: UserRole.employee,
      isEmailVerified: true,
      dateJoined: DateTime(2024, 1, 1),
    );

class _FakeAuthRepository implements AuthRepository {
  bool hasActiveSessionResult = false;
  User? fetchMeResult;
  Object? fetchMeException;

  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> register({
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    required String password,
    required String passwordConfirm,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<User> fetchMe() async {
    if (fetchMeException != null) {
      throw fetchMeException!;
    }
    return fetchMeResult!;
  }

  @override
  Future<bool> refresh() => throw UnimplementedError();

  @override
  Future<bool> hasActiveSession() async => hasActiveSessionResult;

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<void> verifyEmailToken(String token) async {}

  @override
  Future<void> logout() async {}
}
