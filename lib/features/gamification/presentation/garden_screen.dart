import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/gamification/domain/garden_state.dart';
import 'package:mindow/features/gamification/garden_providers.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(gardenStateProvider);
    final textTheme = Theme.of(context).textTheme;

    return AuroreCanvas(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.gardenTitle,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AuroreSpacing.sm),
              Text(
                l10n.gardenSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AuroreColors.inkMuted,
                ),
              ),
              const SizedBox(height: AuroreSpacing.xl),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AuroreColors.glass,
                  borderRadius: BorderRadius.circular(AuroreRadii.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AuroreSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.gardenCurrentElement(
                          _gardenElementLabel(l10n, state.currentElement),
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AuroreSpacing.xs),
                      Text(
                        l10n.gardenCompletedMissions(state.completedMissions),
                        style: textTheme.bodyMedium,
                      ),
                      if (state.nextUnlockAt > 0) ...[
                        const SizedBox(height: AuroreSpacing.xs),
                        Text(
                          l10n.gardenNextUnlock(state.nextUnlockAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: AuroreColors.inkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _gardenElementLabel(AppLocalizations l10n, GardenElement element) {
  return switch (element) {
    GardenElement.seedling => l10n.gardenElementSeedling,
    GardenElement.flower => l10n.gardenElementFlower,
    GardenElement.shrub => l10n.gardenElementShrub,
    GardenElement.tree => l10n.gardenElementTree,
    GardenElement.river => l10n.gardenElementRiver,
    GardenElement.animals => l10n.gardenElementAnimals,
    GardenElement.landscape => l10n.gardenElementLandscape,
  };
}
