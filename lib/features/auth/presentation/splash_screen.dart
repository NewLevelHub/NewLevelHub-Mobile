import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';
import '../application/auth_controller.dart';

/// Resolves the initial route on cold start: [AuthController.bootstrap]
/// checks for local tokens and, if present, loads the profile via
/// `GET /auth/me/` — then this screen routes to `/home` or `/login`.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.authController,
    super.key,
  });

  final AuthController authController;

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

    await widget.authController.bootstrap();
    if (!mounted) return;

    context.go(
      widget.authController.isAuthenticated
          ? AppRoutes.home
          : AppRoutes.login,
    );
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
                color: AppColors.brand,
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
