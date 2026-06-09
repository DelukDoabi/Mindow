import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';

/// Displays the user's current Mental Load total as a large gradient numeral
/// with a caption and an optional pending indicator.
///
/// Watches `mentalLoadProvider` and shows:
/// - Loading: a subtle placeholder that matches the hero's vertical footprint.
/// - Error: gracefully hidden (zero displayed, no crash).
/// - Data: the `totalKg` numeral in the accent gradient + `~` when any item is
///   still awaiting AI analysis.
class MentalLoadHero extends ConsumerWidget {
  const MentalLoadHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loadAsync = ref.watch(mentalLoadProvider);

    return Semantics(
      label: loadAsync.whenOrNull(
        data: (load) => l10n.mentalLoadSemanticLabel(load.totalKg),
      ),
      excludeSemantics: true,
      child: loadAsync.when(
        loading: () => const _HeroPlaceholder(),
        error: (_, _) => const _HeroContent(totalKg: 0, hasPendingItems: false),
        data: (load) => _HeroContent(
          totalKg: load.totalKg,
          hasPendingItems: load.hasPendingItems,
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.totalKg,
    required this.hasPendingItems,
  });

  final int totalKg;
  final bool hasPendingItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AuroreColors.accentGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                '$totalKg',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AuroreColors.ink,
                  fontSize: 88,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: AuroreSpacing.xs),
            Text(
              hasPendingItems ? '${l10n.weightKgLabel}~' : l10n.weightKgLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AuroreColors.cool,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AuroreSpacing.xs),
        Text(
          l10n.mentalLoadCaption,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AuroreColors.inkMuted,
          ),
        ),
      ],
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Matches approximate height of _HeroContent to prevent layout shifts.
    return const SizedBox(height: 112);
  }
}
