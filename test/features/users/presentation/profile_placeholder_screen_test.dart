import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/router/app_routes.dart';
import 'package:newlevelhub_mobile/core/router/auth_notifier.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/users/presentation/profile_placeholder_screen.dart';
import 'package:newlevelhub_mobile/features/users/presentation/users_strings.dart';

void main() {
  group('ProfilePlaceholderScreen logout', () {
    late _FakeAuthRepository repository;
    late AuthNotifier authNotifier;

    setUp(() {
      repository = _FakeAuthRepository();
      authNotifier = AuthNotifier()..markAuthenticated();
    });

    Widget buildTestApp() {
      final router = GoRouter(
        initialLocation: AppRoutes.profile,
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => ProfilePlaceholderScreen(
              authRepository: repository,
              authNotifier: authNotifier,
            ),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => const Scaffold(body: Text('Вход')),
          ),
        ],
      );
      return MaterialApp.router(routerConfig: router);
    }

    testWidgets('shows a confirm dialog before logging out', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await tester.tap(find.text(UsersStrings.logout));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(UsersStrings.logoutConfirmTitle), findsOneWidget);
      expect(repository.logoutCalls, 0);
    });

    testWidgets('cancelling the dialog does not log out', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await tester.tap(find.text(UsersStrings.logout));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UsersStrings.logoutConfirmCancel));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(repository.logoutCalls, 0);
      expect(authNotifier.isAuthenticated, isTrue);
    });

    testWidgets('confirming logs out and navigates to /login', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await tester.tap(find.text(UsersStrings.logout));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(UsersStrings.logout),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.logoutCalls, 1);
      expect(authNotifier.isAuthenticated, isFalse);
      expect(find.text('Вход'), findsOneWidget);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasActiveSession() async => true;

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<void> verifyEmailToken(String token) async {}
}
