import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';

void main() {
  group('Aurore tokens', () {
    test('canvas gradient runs warm -> cool', () {
      const gradient = AuroreColors.canvasGradient;
      expect(gradient.colors.first, AuroreColors.canvasWarm);
      expect(gradient.colors.last, AuroreColors.canvasCool);
    });

    test('accent colors match the Aurore palette', () {
      expect(AuroreColors.warm, const Color(0xFFE8A87C));
      expect(AuroreColors.cool, const Color(0xFFB98BB0));
      expect(AuroreColors.ink, const Color(0xFF5B5470));
    });

    test('spacing follows a 4-point grid', () {
      expect(AuroreSpacing.xs, 4);
      expect(AuroreSpacing.sm, 8);
      expect(AuroreSpacing.lg, 16);
      expect(AuroreSpacing.xxl, 32);
    });
  });
}
