import 'package:flutter/material.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';

/// A full-bleed Aurore canvas: paints the dawn [AuroreColors.canvasGradient]
/// behind a transparent [Scaffold]. The single source for screen backgrounds.
class AuroreCanvas extends StatelessWidget {
  const AuroreCanvas({required this.child, super.key});

  /// The scaffold body laid over the gradient.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AuroreColors.canvasGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
      ),
    );
  }
}
