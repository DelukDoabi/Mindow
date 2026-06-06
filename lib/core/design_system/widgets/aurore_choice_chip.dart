import 'package:flutter/material.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';

/// A soft, selectable Aurore pill chip (UX: `rounded/md`, glass / accent-glass).
///
/// Selected = warm-to-cool accent gradient with white ink; unselected = plain
/// glass with a faint border and `ink` text. Uses only Aurore tokens.
class AuroreChoiceChip extends StatelessWidget {
  const AuroreChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// The chip caption.
  final String label;

  /// Whether this chip is currently selected.
  final bool selected;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AuroreRadii.md),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AuroreSpacing.lg,
            vertical: AuroreSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? null : AuroreColors.glass,
            gradient: selected ? AuroreColors.accentGradient : null,
            borderRadius: BorderRadius.circular(AuroreRadii.md),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : AuroreColors.inkMuted.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: selected ? Colors.white : AuroreColors.ink,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
