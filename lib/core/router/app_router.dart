import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_api.dart';
import '../auth/token_storage.dart';
import '../network/connectivity_probe.dart';
import '../network/dio_client.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/ui_kit_demo_screen.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/auth_placeholder_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/verify_email_screen.dart';
import '../../features/users/presentation/profile_placeholder_screen.dart';
import 'app_routes.dart';
import 'auth_notifier.dart';

/// Creates the application [GoRouter] with auth / main flow separation.
GoRouter createAppRouter({
  required AuthNotifier authNotifier,
  TokenStorage? tokenStorage,
  AuthApi? authApi,
  AuthRepository? authRepository,
  bool runConnectivityProbeOnStart = true,
  ConnectivityProbe? connectivityProbe,
}) {
  final storage = tokenStorage ?? DioClient.instance.tokenStorage;
  final sessionApi = authApi ?? AuthApi(DioClient.instance.dio);
  final repository = authRepository ??
      AuthRepositoryImpl(
        authService: AuthService(DioClient.instance.dio),
        tokenStorage: storage,
      );

  String? redirect(BuildContext context, GoRouterState state) {
    if (state.matchedLocation == AppRoutes.splash) {
      return null;
    }

    final isAuth = authNotifier.isAuthenticated;
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
    refreshListenable: authNotifier,
    redirect: redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => SplashScreen(
          tokenStorage: storage,
          authApi: sessionApi,
          authNotifier: authNotifier,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          authRepository: repository,
          authNotifier: authNotifier,
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
        builder: (context, state) => VerifyEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
          authRepository: repository,
          authNotifier: authNotifier,
        ),
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
        builder: (context, state) => const ProfilePlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoutes.uiKitDemo,
        builder: (context, state) => const UiKitDemoScreen(),
      ),
    ],
  );
}
