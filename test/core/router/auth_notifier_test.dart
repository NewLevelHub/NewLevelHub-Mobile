import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:newlevelhub_mobile/core/router/app_routes.dart';
import 'package:newlevelhub_mobile/core/router/auth_notifier.dart';

void main() {
  group('AuthNotifier', () {
    test('starts unauthenticated', () {
      final notifier = AuthNotifier();
      expect(notifier.isAuthenticated, isFalse);
    });

    test('markAuthenticated updates state and notifies listeners', () {
      final notifier = AuthNotifier();
      var notifications = 0;
      notifier.addListener(() => notifications++);

      notifier.markAuthenticated();

      expect(notifier.isAuthenticated, isTrue);
      expect(notifications, 1);
      notifier.markAuthenticated();
      expect(notifications, 1);
    });

    test('markUnauthenticated updates state and notifies listeners', () {
      final notifier = AuthNotifier()
        ..markAuthenticated();
      var notifications = 0;
      notifier.addListener(() => notifications++);

      notifier.markUnauthenticated();

      expect(notifier.isAuthenticated, isFalse);
      expect(notifications, 1);
    });

    testWidgets('onSessionExpired clears auth and navigates to login', (tester) async {
      final notifier = AuthNotifier()..markAuthenticated();
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
      notifier.attachRouter(router);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      notifier.onSessionExpired();
      await tester.pumpAndSettle();

      expect(notifier.isAuthenticated, isFalse);
      expect(router.state.matchedLocation, AppRoutes.login);
      expect(find.text('login'), findsOneWidget);
    });
  });
}
