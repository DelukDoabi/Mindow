import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';

/// A row of two glass stat pills displaying the open-items count and the
/// kg freed this week.
///
/// Both values are positive-framed (UX-DR5, UX-DR16): the open count uses
/// the label "en cours" and the freed weight uses "libérés cette semaine".
///
/// Loading / error states render a fixed-height placeholder so the layout
/// does not shift once the data arrives.
class StatPillRow extends ConsumerWidget {
  const StatPillRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projection = ref.watch(weeklyProgressionProvider);

    return projection.when(
      loading: () => const SizedBox(height: 56),
      error: (_, _) => _buildRow(0, 0, l10n),
      data: (p) => _buildRow(p.openCount, p.kgFreedThisWeek, l10n),
    );
  }

  Widget _buildRow(int openCount, int kgFreed, AppLocalizations l10n) {
    return Semantics(
      label:
          '$openCount ${l10n.statPillOpenCountLabel}, '
          '${l10n.statPillKgFreedValue(kgFreed)} ${l10n.statPillKgFreedLabel}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatPill(
              value: '$openCount',
              label: l10n.statPillOpenCountLabel,
            ),
            const SizedBox(width: AuroreSpacing.md),
            _StatPill(
              value: l10n.statPillKgFreedValue(kgFreed),
              label: l10n.statPillKgFreedLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuroreColors.glass,
        borderRadius: BorderRadius.circular(AuroreRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AuroreSpacing.lg,
          vertical: AuroreSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AuroreColors.ink,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AuroreColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
