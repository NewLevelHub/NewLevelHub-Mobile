import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';
import 'package:newlevelhub_mobile/core/router/app_routes.dart';
import 'package:newlevelhub_mobile/features/auth/application/auth_controller.dart';
import 'package:newlevelhub_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:newlevelhub_mobile/features/users/presentation/profile_placeholder_screen.dart';
import 'package:newlevelhub_mobile/features/users/presentation/users_strings.dart';

void main() {
  group('ProfilePlaceholderScreen logout', () {
    late _FakeAuthRepository repository;
    late AuthController authController;

    setUp(() {
      repository = _FakeAuthRepository();
      authController = AuthController(authRepository: repository)
        ..setAuthenticatedUser(_user());
    });

    Widget buildTestApp() {
      final router = GoRouter(
        initialLocation: AppRoutes.profile,
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => ProfilePlaceholderScreen(
              authRepository: repository,
              authController: authController,
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
      expect(authController.isAuthenticated, isTrue);
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
      expect(authController.isAuthenticated, isFalse);
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
  Future<User> fetchMe() => throw UnimplementedError();

  @override
  Future<bool> refresh() => throw UnimplementedError();
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
