import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Named text styles used across Auth, Users, and shared screens.
abstract final class AppTextStyles {
  static TextStyle display(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle title(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle subtitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: AppColors.textPrimary,
        );
  }

  static TextStyle bodySecondary(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: AppColors.textSecondary,
        );
  }

  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: AppColors.textMuted,
        );
  }

  static TextStyle label(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle fieldError(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: AppColors.error,
        );
  }
}
