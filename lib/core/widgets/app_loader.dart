import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

enum AppLoaderSize { inline, fullscreen }

/// Loading indicator — inline (embedded) or fullscreen overlay.
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = AppLoaderSize.inline,
    this.message,
  });

  final AppLoaderSize size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    const indicator = CircularProgressIndicator();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (size == AppLoaderSize.fullscreen) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(child: content),
      );
    }

    return content;
  }
}
