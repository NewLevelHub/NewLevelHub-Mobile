import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/router/auth_notifier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_strings.dart';
import '../view_models/login_submit_result.dart';
import '../view_models/login_view_model.dart';

/// Email/password login form — `POST /auth/login/`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.authRepository,
    required this.authNotifier,
    super.key,
  });

  final AuthRepository authRepository;
  final AuthNotifier authNotifier;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel = LoginViewModel(
    authRepository: widget.authRepository,
    authNotifier: widget.authNotifier,
  );
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final result = await _viewModel.submit();
    if (!mounted) return;

    switch (result) {
      case LoginSubmitSuccess():
        context.go(AppRoutes.home);
      case LoginSubmitEmailNotVerified(email: final email):
        context.go(
          '${AppRoutes.verifyEmail}?email=${Uri.encodeQueryComponent(email)}',
        );
      case LoginSubmitValidationFailed():
      case LoginSubmitFailure():
        break; // Errors are already shown inline via the ViewModel's state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AuthStrings.loginTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AuthStrings.loginSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_viewModel.errorMessage != null) ...[
                    _ErrorBanner(message: _viewModel.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    onChanged: _viewModel.updateEmail,
                    decoration: InputDecoration(
                      labelText: AuthStrings.emailLabel,
                      hintText: AuthStrings.emailHint,
                      errorText: _viewModel.emailError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onChanged: _viewModel.updatePassword,
                    onSubmitted: (_) => _handleSubmit(),
                    decoration: InputDecoration(
                      labelText: AuthStrings.passwordLabel,
                      errorText: _viewModel.passwordError,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Checkbox(
                        value: _viewModel.rememberMe,
                        onChanged: (value) =>
                            _viewModel.setRememberMe(value ?? false),
                      ),
                      const Expanded(child: Text(AuthStrings.rememberMe)),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.forgotPassword),
                        child: const Text(AuthStrings.forgotPassword),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _viewModel.isLoading ? null : _handleSubmit,
                    child: Text(
                      _viewModel.isLoading
                          ? AuthStrings.signInLoading
                          : AuthStrings.signIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text(AuthStrings.noAccount),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.debugVerifyEmailToken),
                      child: const Text('Debug: токен подтверждения email'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}
