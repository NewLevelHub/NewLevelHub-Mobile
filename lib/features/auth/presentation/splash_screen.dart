import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_api.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/router/auth_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';

/// Validates stored tokens on cold start and routes to auth or main flow.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.tokenStorage,
    required this.authApi,
    required this.authNotifier,
    super.key,
  });

  final TokenStorage tokenStorage;
  final AuthApi authApi;
  final AuthNotifier authNotifier;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveInitialRoute());
  }

  Future<void> _resolveInitialRoute() async {
    if (!mounted) return;

    try {
      final hasTokens = await widget.tokenStorage.hasTokens();
      if (!hasTokens) {
        _goToLogin();
        return;
      }

      final isValid = await widget.authApi.validateSession();
      if (!mounted) return;

      if (isValid) {
        widget.authNotifier.markAuthenticated();
        context.go(AppRoutes.home);
      } else {
        _goToLogin();
      }
    } catch (_) {
      if (!mounted) return;
      _goToLogin();
    }
  }

  void _goToLogin() {
    widget.authNotifier.markUnauthenticated();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.apartment_outlined,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppConfig.appName,
                style: AppTextStyles.display(context),
              ),
              const SizedBox(height: 32),
              const AppLoader(),
            ],
          ),
        ),
      ),
    );
  }
}
