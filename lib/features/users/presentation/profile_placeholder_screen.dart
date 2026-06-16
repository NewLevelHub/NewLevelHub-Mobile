import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/auth_notifier.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import 'users_strings.dart';
import 'view_models/profile_view_model.dart';

/// Temporary profile screen until MOB-201+ are implemented. Already wires
/// the real logout flow (confirm dialog → best-effort server logout →
/// local session teardown → `/login`).
class ProfilePlaceholderScreen extends StatefulWidget {
  const ProfilePlaceholderScreen({
    required this.authRepository,
    required this.authNotifier,
    super.key,
  });

  final AuthRepository authRepository;
  final AuthNotifier authNotifier;

  @override
  State<ProfilePlaceholderScreen> createState() =>
      _ProfilePlaceholderScreenState();
}

class _ProfilePlaceholderScreenState extends State<ProfilePlaceholderScreen> {
  late final ProfileViewModel _viewModel = ProfileViewModel(
    authRepository: widget.authRepository,
    authNotifier: widget.authNotifier,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleLogoutPressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(UsersStrings.logoutConfirmTitle),
        content: const Text(UsersStrings.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(UsersStrings.logoutConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(UsersStrings.logout),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _viewModel.logout();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UsersStrings.profileTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return AppEmptyView(
              icon: Icons.person_outline,
              message: UsersStrings.profilePlaceholderMessage,
              actionLabel: _viewModel.isLoggingOut
                  ? UsersStrings.logoutLoading
                  : UsersStrings.logout,
              onAction: _viewModel.isLoggingOut ? null : _handleLogoutPressed,
            );
          },
        ),
      ),
    );
  }
}
