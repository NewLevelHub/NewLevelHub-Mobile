import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/router/auth_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_strings.dart';
import '../view_models/verify_email_resend_result.dart';
import '../view_models/verify_email_view_model.dart';

/// "Waiting for email confirmation" screen — `/verify-email`.
///
/// Shown after register (MOB-102, tokens issued → resend available), after
/// login's 403 `EMAIL_NOT_VERIFIED` (MOB-101, no tokens issued by that
/// flow → resend hidden, same as invite), and after invite-register
/// (MOB-105, no tokens issued → resend hidden, instruction text only).
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    required this.email,
    required this.authRepository,
    required this.authNotifier,
    super.key,
  });

  final String email;
  final AuthRepository authRepository;
  final AuthNotifier authNotifier;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final VerifyEmailViewModel _viewModel = VerifyEmailViewModel(
    authRepository: widget.authRepository,
    authNotifier: widget.authNotifier,
    email: widget.email,
  );

  @override
  void initState() {
    super.initState();
    _viewModel.loadSession();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleResend() async {
    final result = await _viewModel.resend();
    if (!mounted) return;

    switch (result) {
      case VerifyEmailResendAlreadyVerified():
        context.go(AppRoutes.home);
      case VerifyEmailResendSuccess():
      case VerifyEmailResendRateLimited():
      case VerifyEmailResendFailure():
        break; // Errors/info are already shown inline via the ViewModel's state.
    }
  }

  Future<void> _handleBackToLogin() async {
    await _viewModel.logout();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AuthStrings.verifyEmailTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoadingSession) {
              return const AppLoader(size: AppLoaderSize.fullscreen);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: AppColors.brand,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _viewModel.canResend
                        ? AuthStrings.verifyEmailInstructions
                        : AuthStrings.verifyEmailInviteInstructions,
                    style: AppTextStyles.body(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _viewModel.email,
                    style: AppTextStyles.subtitle(context),
                    textAlign: TextAlign.center,
                  ),
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 24),
                    AppErrorBanner(message: _viewModel.errorMessage!),
                  ],
                  if (_viewModel.infoMessage != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      _viewModel.infoMessage!,
                      style: AppTextStyles.body(context)
                          .copyWith(color: AppColors.success),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_viewModel.canResend) ...[
                    const SizedBox(height: 32),
                    AppButton(
                      label: _viewModel.isInCooldown
                          ? AuthStrings.resendCooldown(
                              _viewModel.cooldownSeconds)
                          : AuthStrings.resendEmail,
                      isLoading: _viewModel.isResending,
                      onPressed: _viewModel.isInCooldown
                          ? null
                          : _handleResend,
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: AuthStrings.backToLogin,
                    variant: AppButtonVariant.text,
                    onPressed: _handleBackToLogin,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
