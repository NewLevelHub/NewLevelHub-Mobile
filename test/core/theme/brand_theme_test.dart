import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/theme/brand_theme.dart';

void main() {
  group('BrandPalette.fromHex', () {
    test('returns palette for default brand hex', () {
      final palette = BrandPalette.fromHex('#059669');

      expect(palette.brand, const Color(0xFF059669));
      expect(palette.brandHover, isNot(palette.brand));
      expect(palette.brandSubtle, isNot(palette.brand));
      expect(palette.brandText, isNot(palette.brand));
    });

    test('derives palette from custom company colour', () {
      final palette = BrandPalette.fromHex('#4F46E5');

      expect(palette.brand, const Color(0xFF4F46E5));
      expect(palette.brandHover, isNot(palette.brand));
      expect(palette.brandSubtle, isNot(palette.brand));
    });
  });
}
