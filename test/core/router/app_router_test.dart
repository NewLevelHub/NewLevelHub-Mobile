import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/auth_api.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/token_storage.dart';
import 'package:newlevelhub_mobile/core/router/app_router.dart';
import 'package:newlevelhub_mobile/core/router/app_routes.dart';
import 'package:newlevelhub_mobile/core/router/auth_notifier.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';

void main() {
  group('createAppRouter', () {
    late AuthNotifier authNotifier;
    late _FakeTokenStorage tokenStorage;
    late _FakeAuthApi authApi;

    setUp(() {
      authNotifier = AuthNotifier();
      tokenStorage = _FakeTokenStorage();
      authApi = _FakeAuthApi();
    });

    Widget buildTestApp() {
      final router = createAppRouter(
        authNotifier: authNotifier,
        tokenStorage: tokenStorage,
        authApi: authApi,
        runConnectivityProbeOnStart: false,
      );
      authNotifier.attachRouter(router);

      return MaterialApp.router(routerConfig: router);
    }

    testWidgets('starts at splash', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('redirects to login when no tokens', (tester) async {
      tokenStorage.hasTokensResult = false;

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsWidgets);
      expect(authNotifier.isAuthenticated, isFalse);
    });

    testWidgets('redirects to home when session is valid', (tester) async {
      tokenStorage.hasTokensResult = true;
      authApi.validateSessionResult = true;

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Мобильное приложение в разработке'),
        findsOneWidget,
      );
      expect(authNotifier.isAuthenticated, isTrue);
    });

    testWidgets('redirects to login when session is invalid', (tester) async {
      tokenStorage.hasTokensResult = true;
      authApi.validateSessionResult = false;

      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsWidgets);
      expect(authNotifier.isAuthenticated, isFalse);
    });

    testWidgets('blocks profile without auth', (tester) async {
      final router = createAppRouter(
        authNotifier: authNotifier,
        tokenStorage: tokenStorage,
        authApi: authApi,
        runConnectivityProbeOnStart: false,
      );
      authNotifier.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go(AppRoutes.profile);
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsWidgets);
      expect(router.state.matchedLocation, AppRoutes.login);
    });

    testWidgets('redirects authenticated user away from login', (tester) async {
      tokenStorage.hasTokensResult = true;
      authApi.validateSessionResult = true;

      final router = createAppRouter(
        authNotifier: authNotifier,
        tokenStorage: tokenStorage,
        authApi: authApi,
        runConnectivityProbeOnStart: false,
      );
      authNotifier.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(authNotifier.isAuthenticated, isTrue);
      expect(router.state.matchedLocation, AppRoutes.home);

      router.go(AppRoutes.login);
      await tester.pump();

      expect(router.state.matchedLocation, AppRoutes.home);
    });

    testWidgets('preserves invite token query parameter', (tester) async {
      final router = createAppRouter(
        authNotifier: authNotifier,
        tokenStorage: tokenStorage,
        authApi: authApi,
        runConnectivityProbeOnStart: false,
      );
      authNotifier.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('${AppRoutes.invite}?token=invite-abc');
      await tester.pumpAndSettle();

      expect(find.text('token: invite-abc'), findsOneWidget);
      expect(router.state.uri.queryParameters['token'], 'invite-abc');
    });

    testWidgets('routes /verify-email?token=... to the deep link confirmation screen', (tester) async {
      final router = createAppRouter(
        authNotifier: authNotifier,
        tokenStorage: tokenStorage,
        authApi: authApi,
        // Avoids a real network call from EmailVerifyLinkScreen.initState.
        authRepository: _FakeAuthRepository(),
        runConnectivityProbeOnStart: false,
      );
      authNotifier.attachRouter(router);

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
        authNotifier: authNotifier,
        tokenStorage: tokenStorage,
        authApi: authApi,
        runConnectivityProbeOnStart: false,
      );
      authNotifier.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('${AppRoutes.verifyEmail}?email=user@example.com');
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('preserves reset-password token query parameter', (tester) async {
      final router = createAppRouter(
        authNotifier: authNotifier,
        tokenStorage: tokenStorage,
        authApi: authApi,
        runConnectivityProbeOnStart: false,
      );
      authNotifier.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('${AppRoutes.resetPassword}?token=reset-xyz');
      await tester.pumpAndSettle();

      expect(find.text('token: reset-xyz'), findsOneWidget);
      expect(router.state.uri.queryParameters['token'], 'reset-xyz');
    });
  });
}

class _FakeTokenStorage extends TokenStorage {
  _FakeTokenStorage() : super(store: _InMemoryStore());

  bool hasTokensResult = false;

  @override
  Future<bool> hasTokens() async => hasTokensResult;
}

class _FakeAuthApi implements AuthApi {
  bool validateSessionResult = false;

  @override
  Future<bool> validateSession() async => validateSessionResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Used only by the `/verify-email?token=...` routing test, to keep
/// `EmailVerifyLinkScreen`'s `initState` verify call off the real network.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasActiveSession() async => false;

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<void> verifyEmailToken(String token) async {}

  @override
  Future<void> logout() async {}
}

class _InMemoryStore implements SecureKeyValueStore {
  final _data = <String, String>{};

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }
}
