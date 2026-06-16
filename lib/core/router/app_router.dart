import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/token_storage.dart';
import '../network/connectivity_probe.dart';
import '../network/dio_client.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/ui_kit_demo_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/auth_placeholder_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/views/debug_deep_link_screen.dart';
import '../../features/auth/presentation/views/email_verify_link_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/verify_email_screen.dart';
import '../../features/users/presentation/profile_placeholder_screen.dart';
import 'app_routes.dart';

/// Creates the application [GoRouter] with auth / main flow separation.
GoRouter createAppRouter({
  required AuthController authController,
  TokenStorage? tokenStorage,
  AuthRepository? authRepository,
  bool runConnectivityProbeOnStart = true,
  ConnectivityProbe? connectivityProbe,
}) {
  final storage = tokenStorage ?? DioClient.instance.tokenStorage;
  final repository = authRepository ??
      AuthRepositoryImpl(
        authService: AuthService(DioClient.instance.dio),
        tokenStorage: storage,
      );

  String? redirect(BuildContext context, GoRouterState state) {
    if (state.matchedLocation == AppRoutes.splash) {
      return null;
    }

    final isAuth = authController.isAuthenticated;
    final location = state.matchedLocation;

    if (AppRoutes.authRequired.contains(location) && !isAuth) {
      return AppRoutes.login;
    }

    if (location == AppRoutes.login && isAuth) {
      return AppRoutes.home;
    }

    return null;
  }

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authController,
    redirect: redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => SplashScreen(
          authController: authController,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          authRepository: repository,
          authController: authController,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const AuthPlaceholderScreen(
          title: 'Регистрация',
          subtitle: 'Регистрация гостя в разработке',
        ),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          // Deep link landing (`?token=...`) vs. the "check your inbox"
          // waiting screen shown right after register/login (`?email=...`)
          // — same path, see `EmailVerifyLinkScreen` doc comment.
          final token = state.uri.queryParameters['token'];
          if (token != null && token.isNotEmpty) {
            return EmailVerifyLinkScreen(
              token: token,
              authRepository: repository,
            );
          }
          return VerifyEmailScreen(
            email: state.uri.queryParameters['email'] ?? '',
            authRepository: repository,
            authController: authController,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invite,
        builder: (context, state) => AuthPlaceholderScreen(
          title: 'Регистрация по приглашению',
          subtitle: 'Регистрация по приглашению в разработке',
          queryToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const AuthPlaceholderScreen(
          title: 'Сброс пароля',
          subtitle: 'Запрос сброса пароля в разработке',
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => AuthPlaceholderScreen(
          title: 'Новый пароль',
          subtitle: 'Установка нового пароля в разработке',
          queryToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => PlaceholderScreen(
          runProbeOnStart: runConnectivityProbeOnStart,
          connectivityProbe: connectivityProbe,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => ProfilePlaceholderScreen(
          authRepository: repository,
          authController: authController,
        ),
      ),
      GoRoute(
        path: AppRoutes.uiKitDemo,
        builder: (context, state) => const UiKitDemoScreen(),
      ),
      GoRoute(
        path: AppRoutes.debugVerifyEmailToken,
        builder: (context, state) => const DebugDeepLinkScreen(),
      ),
    ],
  );
}
