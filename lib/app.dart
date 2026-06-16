import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/placeholder_screen.dart';

class NewLevelHubApp extends StatelessWidget {
  const NewLevelHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Level Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const PlaceholderScreen(),
    );
  }
}
