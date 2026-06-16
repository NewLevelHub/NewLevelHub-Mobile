import 'package:flutter/material.dart';

import '../network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_empty_view.dart';
import 'app_error_banner.dart';
import 'app_error_view.dart';
import 'app_loader.dart';
import 'app_text_field.dart';

/// Demo screen showcasing all UI-kit widgets (debug / QA).
class UiKitDemoScreen extends StatefulWidget {
  const UiKitDemoScreen({super.key});

  @override
  State<UiKitDemoScreen> createState() => _UiKitDemoScreenState();
}

class _UiKitDemoScreenState extends State<UiKitDemoScreen> {
  bool _isLoading = false;
  bool _showGeneralError = true;
  bool _showNetworkError = false;

  static const _demoException = ApiException(
    message: 'Неверный email или пароль',
    statusCode: 400,
    fieldErrors: {
      'email': ['Введите корректный email'],
      'password': ['Пароль обязателен'],
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Kit')),
      body: SafeArea(
        child: _showNetworkError
            ? AppErrorView(
                message: 'Не удалось связаться с сервером.\nПроверьте подключение.',
                onRetry: () => setState(() => _showNetworkError = false),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Кнопки', style: AppTextStyles.title(context)),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Primary',
                    isLoading: _isLoading,
                    onPressed: () {
                      setState(() => _isLoading = true);
                      Future<void>.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _isLoading = false);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Secondary',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Text',
                    variant: AppButtonVariant.text,
                    expanded: false,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 32),
                  Text('Поля ввода', style: AppTextStyles.title(context)),
                  const SizedBox(height: 16),
                  if (_showGeneralError) ...[
                    AppErrorBanner(
                      message: _demoException.message,
                      onDismiss: () => setState(() => _showGeneralError = false),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    label: 'Email',
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _demoException.fieldError('email'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Пароль',
                    hint: '••••••••',
                    obscureText: true,
                    errorText: _demoException.fieldError('password'),
                  ),
                  const SizedBox(height: 32),
                  Text('Состояния', style: AppTextStyles.title(context)),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 80,
                    child: Center(child: AppLoader()),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppEmptyView(
                        message: 'Список пуст',
                        actionLabel: 'Обновить',
                        onAction: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Показать сетевую ошибку',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => setState(() => _showNetworkError = true),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'SnackBar ошибки',
                    variant: AppButtonVariant.text,
                    expanded: false,
                    onPressed: () => showAppErrorSnackBar(
                      context,
                      'Произошла непредвиденная ошибка',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
