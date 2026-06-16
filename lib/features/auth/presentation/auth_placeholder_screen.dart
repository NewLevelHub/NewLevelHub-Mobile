import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_text_field.dart';

/// Temporary auth-flow screen until Epic 1 forms are implemented.
class AuthPlaceholderScreen extends StatefulWidget {
  const AuthPlaceholderScreen({
    required this.title,
    super.key,
    this.subtitle,
    this.queryToken,
    this.showFormDemo = false,
  });

  final String title;
  final String? subtitle;
  final String? queryToken;
  final bool showFormDemo;

  @override
  State<AuthPlaceholderScreen> createState() => _AuthPlaceholderScreenState();
}

class _AuthPlaceholderScreenState extends State<AuthPlaceholderScreen> {
  bool _isSubmitting = false;

  static const _demoErrors = ApiException(
    message: 'Проверьте введённые данные',
    statusCode: 400,
    fieldErrors: {
      'email': ['Введите корректный email'],
    },
  );

  Future<void> _onSubmitDemo() async {
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    showAppErrorSnackBar(context, 'Форма в разработке');
  }

  @override
  Widget build(BuildContext context) {
    final token = widget.queryToken ??
        GoRouterState.of(context).uri.queryParameters['token'];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.brand,
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: AppTextStyles.display(context),
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.subtitle!,
                  style: AppTextStyles.bodySecondary(context),
                  textAlign: TextAlign.center,
                ),
              ],
              if (token != null && token.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'token: $token',
                  style: AppTextStyles.caption(context).copyWith(
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.showFormDemo) ...[
                const SizedBox(height: 32),
                const AppErrorBanner(
                  message: 'Проверьте введённые данные',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _demoErrors.fieldError('email'),
                ),
                const SizedBox(height: 16),
                const AppTextField(
                  label: 'Пароль',
                  hint: '••••••••',
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Войти',
                  isLoading: _isSubmitting,
                  onPressed: _onSubmitDemo,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Регистрация',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go(AppRoutes.register),
                ),
              ],
              const SizedBox(height: 32),
              Text(
                AppConfig.appName,
                style: AppTextStyles.caption(context),
                textAlign: TextAlign.center,
              ),
              if (widget.title != 'Вход') ...[
                const SizedBox(height: 16),
                AppButton(
                  label: 'На экран входа',
                  variant: AppButtonVariant.text,
                  expanded: false,
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
