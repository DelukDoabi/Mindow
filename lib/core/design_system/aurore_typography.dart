import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindow/core/design_system/aurore_colors.dart';

/// Aurore type scale, set in Inter.
///
/// NOTE: AC#3 calls for bundling Inter TTFs under `assets/fonts/`. Binary font
/// files cannot be generated in this environment, so Inter is loaded via the
/// `google_fonts` package instead. This is an intentional, documented
/// deviation — swap to bundled TTFs later by replacing `GoogleFonts.inter*`
/// calls with the bundled family name and adding a `fonts:` block to pubspec.
abstract final class AuroreTypography {
  AuroreTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final base = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    return base.apply(
      bodyColor: AuroreColors.ink,
      displayColor: AuroreColors.ink,
    );
  }
}
