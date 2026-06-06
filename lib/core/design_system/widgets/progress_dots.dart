import 'package:flutter/material.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';

/// Non-interactive onboarding progress indicator (UX-DR13).
///
/// The active dot is an Aurore-gradient stadium (elongated pill); inactive
/// dots are muted circles. Purely presentational — never tappable.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    required this.count,
    required this.activeIndex,
    super.key,
  });

  /// Total number of steps.
  final int count;

  /// Zero-based index of the current step.
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: AuroreSpacing.sm),
          _Dot(active: i == activeIndex),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    const diameter = AuroreSpacing.sm;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: active ? AuroreSpacing.xl : diameter,
      height: diameter,
      decoration: BoxDecoration(
        gradient: active ? AuroreColors.accentGradient : null,
        color: active ? null : AuroreColors.inkMuted.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AuroreRadii.pill),
      ),
    );
  }
}
