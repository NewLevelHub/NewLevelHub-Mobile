import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand color palette derived from a company hex colour.
///
/// Light-mode formulas mirror `useBrandTheme.ts` on the web frontend.
class BrandPalette {
  const BrandPalette({
    required this.brand,
    required this.brandHover,
    required this.brandSubtle,
    required this.brandText,
  });

  final Color brand;
  final Color brandHover;
  final Color brandSubtle;
  final Color brandText;

  static const defaults = BrandPalette(
    brand: AppColors.brand,
    brandHover: AppColors.brandHover,
    brandSubtle: AppColors.brandSubtle,
    brandText: AppColors.brandText,
  );

  factory BrandPalette.fromHex(String hex) {
    final color = _parseHex(hex);
    final hsl = _hexToHsl(color);

    return BrandPalette(
      brand: color,
      brandHover: _darkenHex(color, 0.08),
      brandSubtle: _hslToColor(hsl.$1, 0.3, 0.95),
      brandText: _darkenHex(color, 0.08),
    );
  }

  static Color _parseHex(String hex) {
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) return AppColors.brand;
    return Color(int.parse('FF$normalized', radix: 16));
  }

  static (double h, double s, double l) _hexToHsl(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final max = [r, g, b].reduce((a, c) => a > c ? a : c);
    final min = [r, g, b].reduce((a, c) => a < c ? a : c);
    final l = (max + min) / 2;
    var h = 0.0;
    var s = 0.0;

    if (max != min) {
      final d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      if (max == r) {
        h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
      } else if (max == g) {
        h = ((b - r) / d + 2) / 6;
      } else {
        h = ((r - g) / d + 4) / 6;
      }
    }

    return (h * 360, s, l);
  }

  static Color _hslToColor(double h, double s, double l) {
    final hNorm = h / 360;

    double hue2rgb(double p, double q, double t) {
      var tVal = t;
      if (tVal < 0) tVal += 1;
      if (tVal > 1) tVal -= 1;
      if (tVal < 1 / 6) return p + (q - p) * 6 * tVal;
      if (tVal < 1 / 2) return q;
      if (tVal < 2 / 3) return p + (q - p) * (2 / 3 - tVal) * 6;
      return p;
    }

    final double r;
    final double g;
    final double b;

    if (s == 0) {
      r = g = b = l;
    } else {
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = hue2rgb(p, q, hNorm + 1 / 3);
      g = hue2rgb(p, q, hNorm);
      b = hue2rgb(p, q, hNorm - 1 / 3);
    }

    return Color.fromARGB(
      255,
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b * 255).round().clamp(0, 255),
    );
  }

  static Color _darkenHex(Color color, double amount) {
    final (h, s, l) = _hexToHsl(color);
    return _hslToColor(h, s, (l - amount).clamp(0.0, 1.0));
  }
}
