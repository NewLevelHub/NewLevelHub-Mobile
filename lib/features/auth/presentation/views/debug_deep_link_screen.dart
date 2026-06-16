import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../auth_strings.dart';

/// Debug-only fallback for testing the email-verification deep link without
/// sending a real email — paste a token (e.g. straight from the backend's
/// `EmailVerificationToken` table or Celery log) and jump to the same
/// confirmation screen a real `newlevelhub://verify-email?token=...` link
/// would open. Only reachable from `kDebugMode`-gated entry points (see
/// `PlaceholderScreen`, `LoginScreen`) — never shown in a release build.
class DebugDeepLinkScreen extends StatefulWidget {
  const DebugDeepLinkScreen({super.key});

  @override
  State<DebugDeepLinkScreen> createState() => _DebugDeepLinkScreenState();
}

class _DebugDeepLinkScreenState extends State<DebugDeepLinkScreen> {
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _submit() {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;
    context.go('${AppRoutes.verifyEmail}?token=${Uri.encodeQueryComponent(token)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AuthStrings.debugDeepLinkTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.bug_report_outlined,
                size: 64,
                color: AppColors.brand,
              ),
              const SizedBox(height: 24),
              Text(
                AuthStrings.debugDeepLinkTitle,
                style: AppTextStyles.display(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: AuthStrings.debugDeepLinkHint,
                hint: '00000000-0000-0000-0000-000000000000',
                controller: _tokenController,
                autofocus: true,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: AuthStrings.debugDeepLinkSubmit,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
