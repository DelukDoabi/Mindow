import 'package:flutter/material.dart';

/// Aurore color tokens. Source of truth: UX DESIGN.md (Aurore design system).
///
/// The canvas is a warm-to-cool dawn gradient; surfaces are translucent
/// "glass"; ink is a soft desaturated plum for comfortable long-form reading.
abstract final class AuroreColors {
  AuroreColors._();

  // Canvas gradient stops (warm dawn -> cool dusk).
  static const Color canvasWarm = Color(0xFFFDF4F0);
  static const Color canvasMid = Color(0xFFF6ECF2);
  static const Color canvasCool = Color(0xFFEDE9F4);

  // Accents.
  static const Color warm = Color(0xFFE8A87C);
  static const Color cool = Color(0xFFB98BB0);

  // Ink / text.
  static const Color ink = Color(0xFF5B5470);
  static const Color inkMuted = Color(0xFF8B8499);

  // Glass surfaces.
  static const Color glass = Color(0xCCFFFFFF);
  static const Color glassStrong = Color(0xF2FFFFFF);

  // Feedback.
  static const Color success = Color(0xFF7FB99A);
  static const Color danger = Color(0xFFD98B8B);

  /// The full-bleed background gradient applied behind every screen.
  static const LinearGradient canvasGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [canvasWarm, canvasMid, canvasCool],
  );
}
