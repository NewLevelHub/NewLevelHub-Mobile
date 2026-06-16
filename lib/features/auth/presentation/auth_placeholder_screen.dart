import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_routes.dart';

/// Temporary auth-flow screen until Epic 1 forms are implemented.
class AuthPlaceholderScreen extends StatelessWidget {
  const AuthPlaceholderScreen({
    required this.title,
    super.key,
    this.subtitle,
    this.queryToken,
  });

  final String title;
  final String? subtitle;
  final String? queryToken;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final token = queryToken ?? GoRouterState.of(context).uri.queryParameters['token'];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (token != null && token.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'token: $token',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  AppConfig.appName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (title != 'Вход') ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('На экран входа'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
