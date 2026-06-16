import 'package:flutter/material.dart';

/// Design tokens aligned with NewLevelHub-Web-Frontend `src/styles/theme.css`.
abstract final class AppColors {
  // Backgrounds
  static const page = Color(0xFFF7F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const raised = Color(0xFFF1F3F0);
  static const hover = Color(0xFFEBEDE9);
  static const active = Color(0xFFECFDF5);

  // Borders
  static const border = Color(0xFFE6E8E3);
  static const borderStrong = Color(0xFFCDD1C9);
  static const borderFaint = Color(0xFFEEF0EB);

  // Text
  static const textPrimary = Color(0xFF14201A);
  static const textSecondary = Color(0xFF4A5550);
  static const textMuted = Color(0xFF6F7973);
  static const textSubtle = Color(0xFF9BA39D);
  static const textOnBrand = Color(0xFFFFFFFF);

  // Brand (default emerald — Variant A)
  static const brand = Color(0xFF059669);
  static const brandHover = Color(0xFF047857);
  static const brandSubtle = Color(0xFFECFDF5);
  static const brandText = Color(0xFF047857);

  /// Alias for [brand] — used by Material [ColorScheme.primary].
  static const primary = brand;
  static const primaryContainer = brandSubtle;
  static const onPrimary = textOnBrand;
  static const borderFocused = brand;

  // Status
  static const success = Color(0xFF059669);
  static const successBackground = Color(0xFFECFDF5);
  static const warning = Color(0xFFB45309);
  static const warningBackground = Color(0xFFFFFBEB);
  static const error = Color(0xFFB91C1C);
  static const errorBackground = Color(0xFFFEF2F2);
  static const onError = Color(0xFFFFFFFF);
  static const info = Color(0xFF0369A1);

  // Legacy aliases
  static const background = surface;
}
