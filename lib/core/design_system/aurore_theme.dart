import 'package:flutter/material.dart';

import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/aurore_typography.dart';

/// Builds the Mindow [ThemeData] from Aurore tokens.
abstract final class AuroreTheme {
  AuroreTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AuroreColors.warm,
      onPrimary: Colors.white,
      secondary: AuroreColors.cool,
      onSecondary: Colors.white,
      surface: AuroreColors.glassStrong,
      onSurface: AuroreColors.ink,
      error: AuroreColors.danger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: AuroreTypography.textTheme(Brightness.light),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuroreRadii.pill),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AuroreSpacing.xl,
            vertical: AuroreSpacing.lg,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AuroreColors.glass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuroreRadii.lg),
        ),
      ),
    );
  }
}
