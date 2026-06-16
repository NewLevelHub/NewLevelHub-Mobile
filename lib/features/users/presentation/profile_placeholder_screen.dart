import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_empty_view.dart';

/// Temporary profile screen until MOB-201+ are implemented.
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: const SafeArea(
        child: AppEmptyView(
          icon: Icons.person_outline,
          message: 'Экран профиля в разработке',
        ),
      ),
    );
  }
}
