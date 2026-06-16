import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

/// Primary / secondary / text button with loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.expanded = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool expanded;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final child = _buildChild(context);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
    };

    if (!expanded) return button;

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: switch (variant) {
            AppButtonVariant.primary => Theme.of(context).colorScheme.onPrimary,
            AppButtonVariant.secondary => Theme.of(context).colorScheme.primary,
            AppButtonVariant.text => Theme.of(context).colorScheme.primary,
          },
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
