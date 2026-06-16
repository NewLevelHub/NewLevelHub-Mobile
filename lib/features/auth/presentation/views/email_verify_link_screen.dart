import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_strings.dart';
import '../view_models/email_verify_link_result.dart';
import '../view_models/email_verify_link_view_model.dart';

/// Confirms an email-verification deep link — `/verify-email?token=...`.
///
/// Reached via `DeepLinkListener` (cold/warm start) from
/// `https://newlevelhub.kz/verify-email?token=...`,
/// `newlevelhub://verify-email?token=...`, or the debug-only manual token
/// entry screen. Distinct from [VerifyEmailScreen] (`?email=...`), which is
/// the "we sent you a letter, please check your inbox" waiting screen shown
/// right after register/login — this screen is the landing page for the
/// link inside that letter.
class EmailVerifyLinkScreen extends StatefulWidget {
  const EmailVerifyLinkScreen({
    required this.token,
    required this.authRepository,
    super.key,
  });

  final String token;
  final AuthRepository authRepository;

  @override
  State<EmailVerifyLinkScreen> createState() => _EmailVerifyLinkScreenState();
}

class _EmailVerifyLinkScreenState extends State<EmailVerifyLinkScreen> {
  late final EmailVerifyLinkViewModel _viewModel = EmailVerifyLinkViewModel(
    authRepository: widget.authRepository,
    token: widget.token,
  );

  @override
  void initState() {
    super.initState();
    _viewModel.verify();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _goToLogin() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AuthStrings.verifyLinkTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const AppLoader(size: AppLoaderSize.fullscreen);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _ResultView(viewModel: _viewModel, onLogin: _goToLogin),
            );
          },
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.viewModel, required this.onLogin});

  final EmailVerifyLinkViewModel viewModel;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final result = viewModel.result;

    return switch (result) {
      EmailVerifyLinkSuccess() => _StatusBody(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          title: AuthStrings.verifyLinkSuccessTitle,
          message: AuthStrings.verifyLinkSuccessMessage,
          primaryActionLabel: AuthStrings.verifyLinkGoToLogin,
          onPrimaryAction: onLogin,
        ),
      EmailVerifyLinkAlreadyUsed() => _StatusBody(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          title: AuthStrings.verifyLinkAlreadyUsedTitle,
          primaryActionLabel: AuthStrings.verifyLinkGoToLogin,
          onPrimaryAction: onLogin,
        ),
      EmailVerifyLinkExpired() => _ExpiredBody(
          viewModel: viewModel,
          onLogin: onLogin,
        ),
      EmailVerifyLinkInvalid() => _StatusBody(
          icon: Icons.link_off,
          iconColor: AppColors.error,
          title: AuthStrings.verifyLinkInvalidTitle,
          message: AuthStrings.verifyLinkInvalidMessage,
          primaryActionLabel: AuthStrings.verifyLinkGoToLogin,
          onPrimaryAction: onLogin,
        ),
      EmailVerifyLinkFailure(message: final message) => _StatusBody(
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          title: AuthStrings.verifyLinkErrorTitle,
          message: message,
          primaryActionLabel: AuthStrings.verifyLinkGoToLogin,
          onPrimaryAction: onLogin,
        ),
      null => const SizedBox.shrink(),
    };
  }
}

/// `TOKEN_EXPIRED` — offers a resend (only when [EmailVerifyLinkViewModel]
/// found a local access token, i.e. the device is still signed in from the
/// register/login flow that issued this link) alongside "go to login".
class _ExpiredBody extends StatelessWidget {
  const _ExpiredBody({required this.viewModel, required this.onLogin});

  final EmailVerifyLinkViewModel viewModel;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Icon(
          Icons.hourglass_disabled_outlined,
          size: 64,
          color: AppColors.warning,
        ),
        const SizedBox(height: 24),
        Text(
          AuthStrings.verifyLinkExpiredTitle,
          style: AppTextStyles.display(context),
          textAlign: TextAlign.center,
        ),
        if (viewModel.resendMessage != null) ...[
          const SizedBox(height: 24),
          if (viewModel.resendFailed)
            AppErrorBanner(message: viewModel.resendMessage!)
          else
            Text(
              viewModel.resendMessage!,
              style: AppTextStyles.body(context)
                  .copyWith(color: AppColors.success),
              textAlign: TextAlign.center,
            ),
        ],
        if (viewModel.canResend) ...[
          const SizedBox(height: 32),
          AppButton(
            label: AuthStrings.verifyLinkResend,
            isLoading: viewModel.isResending,
            onPressed: viewModel.resend,
          ),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 32),
        AppButton(
          label: AuthStrings.verifyLinkGoToLogin,
          variant: viewModel.canResend
              ? AppButtonVariant.text
              : AppButtonVariant.primary,
          onPressed: onLogin,
        ),
      ],
    );
  }
}

/// Shared layout for the success / already-used / invalid / failure states:
/// icon, title, optional message, single primary action.
class _StatusBody extends StatelessWidget {
  const _StatusBody({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Icon(icon, size: 64, color: iconColor),
        const SizedBox(height: 24),
        Text(
          title,
          style: AppTextStyles.display(context),
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),
        AppButton(label: primaryActionLabel, onPressed: onPrimaryAction),
      ],
    );
  }
}
