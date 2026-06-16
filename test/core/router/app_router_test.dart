import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/network/api_exception.dart';
import 'package:newlevelhub_mobile/core/router/app_router.dart';
import 'package:newlevelhub_mobile/core/router/app_routes.dart';
import 'package:newlevelhub_mobile/features/auth/application/auth_controller.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';

void main() {
  group('createAppRouter', () {
    late _FakeAuthRepository repository;
    late AuthController authController;

    setUp(() {
      repository = _FakeAuthRepository();
      authController = AuthController(authRepository: repository);
    });

    Widget buildTestApp() {
      final router = createAppRouter(
        authController: authController,
        authRepository: repository,
        runConnectivityProbeOnStart: false,
      );
      authController.attachRouter(router);

      return MaterialApp.router(routerConfig: router);
    }

    testWidgets('starts at splash', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('redirects to login when no tokens', (tester) async {
      repository.hasActiveSessionResult = false;

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsWidgets);
      expect(authController.isAuthenticated, isFalse);
    });

    testWidgets('redirects to home when session is valid', (tester) async {
      repository.hasActiveSessionResult = true;
      repository.fetchMeResult = _user();

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Мобильное приложение в разработке'),
        findsOneWidget,
      );
      expect(authController.isAuthenticated, isTrue);
    });

    testWidgets('the profile icon on home navigates to /profile', (tester) async {
      repository.hasActiveSessionResult = true;
      repository.fetchMeResult = _user();

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Профиль'));
      await tester.pumpAndSettle();

      expect(find.text('Профиль'), findsWidgets);
      expect(find.text('Выйти'), findsOneWidget);
    });

    testWidgets('redirects to login when session is invalid', (tester) async {
      repository.hasActiveSessionResult = true;
      repository.fetchMeException = const ApiException(
        code: 'UNAUTHENTICATED',
        message: 'Требуется авторизация',
        statusCode: 401,
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsWidgets);
      expect(authController.isAuthenticated, isFalse);
    });

    testWidgets('blocks profile without auth', (tester) async {
      final router = createAppRouter(
        authController: authController,
        authRepository: repository,
        runConnectivityProbeOnStart: false,
      );
      authController.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go(AppRoutes.profile);
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsWidgets);
      expect(router.state.matchedLocation, AppRoutes.login);
    });

    testWidgets('redirects authenticated user away from login', (tester) async {
      repository.hasActiveSessionResult = true;
      repository.fetchMeResult = _user();

      final router = createAppRouter(
        authController: authController,
        authRepository: repository,
        runConnectivityProbeOnStart: false,
      );
      authController.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(authController.isAuthenticated, isTrue);
      expect(router.state.matchedLocation, AppRoutes.home);

      router.go(AppRoutes.login);
      await tester.pump();

      expect(router.state.matchedLocation, AppRoutes.home);
    });

    testWidgets('preserves invite token query parameter', (tester) async {
      final router = createAppRouter(
        authController: authController,
        authRepository: repository,
        runConnectivityProbeOnStart: false,
      );
      authController.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('${AppRoutes.invite}?token=invite-abc');
      await tester.pumpAndSettle();

      expect(find.text('token: invite-abc'), findsOneWidget);
      expect(router.state.uri.queryParameters['token'], 'invite-abc');
    });

    testWidgets('routes /verify-email?token=... to the deep link confirmation screen', (tester) async {
      final router = createAppRouter(
        authController: authController,
        // Avoids a real network call from EmailVerifyLinkScreen.initState.
        authRepository: repository,
        runConnectivityProbeOnStart: false,
      );
      authController.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('${AppRoutes.verifyEmail}?token=link-token');
      await tester.pumpAndSettle();

      expect(find.text('Подтверждение email'), findsOneWidget);
      // Distinct from the "check your inbox" waiting screen, which would
      // render the resend button instead.
      expect(find.text('Отправить письмо повторно'), findsNothing);
    });

    testWidgets('routes /verify-email?email=... to the waiting-for-confirmation screen', (tester) async {
      final router = createAppRouter(
        authController: authController,
        authRepository: repository,
        runConnectivityProbeOnStart: false,
      );
      authController.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('${AppRoutes.verifyEmail}?email=user@example.com');
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('preserves reset-password token query parameter', (tester) async {
      final router = createAppRouter(
        authController: authController,
        authRepository: repository,
        runConnectivityProbeOnStart: false,
      );
      authController.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('${AppRoutes.resetPassword}?token=reset-xyz');
      await tester.pumpAndSettle();

      expect(find.text('token: reset-xyz'), findsOneWidget);
      expect(router.state.uri.queryParameters['token'], 'reset-xyz');
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

/// Used by the splash-flow tests (cold-start bootstrap) and by the
/// `/verify-email?token=...` routing test, to keep `EmailVerifyLinkScreen`'s
/// `initState` verify call off the real network.
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
