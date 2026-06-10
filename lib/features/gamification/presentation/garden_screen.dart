import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/widgets/aurore_canvas.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/gamification/achievement_providers.dart';
import 'package:mindow/features/gamification/domain/achievement_state.dart';
import 'package:mindow/features/gamification/domain/garden_state.dart';
import 'package:mindow/features/gamification/domain/level_state.dart';
import 'package:mindow/features/gamification/garden_providers.dart';
import 'package:mindow/features/gamification/level_providers.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gardenState = ref.watch(gardenStateProvider);
    final levelState = ref.watch(levelStateProvider);
    final achievementState = ref.watch(achievementStateProvider);
    final textTheme = Theme.of(context).textTheme;

    return AuroreCanvas(
      child: SafeArea(
        child: SingleChildScrollView(
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
                          _gardenElementLabel(l10n, gardenState.currentElement),
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AuroreSpacing.xs),
                      Text(
                        l10n.gardenCompletedMissions(
                          gardenState.completedMissions,
                        ),
                        style: textTheme.bodyMedium,
                      ),
                      if (gardenState.nextUnlockAt > 0) ...[
                        const SizedBox(height: AuroreSpacing.xs),
                        Text(
                          l10n.gardenNextUnlock(gardenState.nextUnlockAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: AuroreColors.inkMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: AuroreSpacing.md),
                      Text(
                        l10n.levelCurrentTier(
                          _levelTierLabel(l10n, levelState.currentTier),
                        ),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (levelState.nextUnlockAt > 0) ...[
                        const SizedBox(height: AuroreSpacing.xs),
                        Text(
                          l10n.levelNextUnlock(levelState.nextUnlockAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: AuroreColors.inkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // --- Streak section (AC #4, UX-DR19: no punitive language) ---
              const SizedBox(height: AuroreSpacing.lg),
              Text(
                l10n.achievementsStreakLabel(achievementState.currentStreak),
                style: textTheme.bodyMedium?.copyWith(
                  color: AuroreColors.inkMuted,
                ),
              ),
              // --- Achievements section (AC #4) ---
              const SizedBox(height: AuroreSpacing.lg),
              Text(
                l10n.achievementsTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AuroreSpacing.sm),
              Column(
                children: Achievement.values.map((achievement) {
                  return _AchievementCard(
                    title: _achievementTitle(l10n, achievement),
                    description: _achievementDescription(l10n, achievement),
                    isUnlocked: achievementState.isUnlocked(achievement),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _levelTierLabel(AppLocalizations l10n, LevelTier tier) {
  return switch (tier) {
    LevelTier.explorateur => l10n.levelTierExplorateur,
    LevelTier.allegeur => l10n.levelTierAllegeur,
    LevelTier.espritClair => l10n.levelTierEspritClair,
    LevelTier.espritLeger => l10n.levelTierEspritLeger,
    LevelTier.maitreDuCalme => l10n.levelTierMaitreDuCalme,
  };
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

String _achievementTitle(AppLocalizations l10n, Achievement achievement) {
  return switch (achievement) {
    Achievement.firstVictory => l10n.achievementFirstVictoryTitle,
    Achievement.tenKgFreed => l10n.achievementTenKgTitle,
    Achievement.hundredPreoccupations =>
      l10n.achievementHundredPreoccupationsTitle,
    Achievement.thirtyDayStreak => l10n.achievementThirtyDayStreakTitle,
  };
}

String _achievementDescription(AppLocalizations l10n, Achievement achievement) {
  return switch (achievement) {
    Achievement.firstVictory => l10n.achievementFirstVictoryDesc,
    Achievement.tenKgFreed => l10n.achievementTenKgDesc,
    Achievement.hundredPreoccupations =>
      l10n.achievementHundredPreoccupationsDesc,
    Achievement.thirtyDayStreak => l10n.achievementThirtyDayStreakDesc,
  };
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String title;
  final String description;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final contentColor = isUnlocked ? null : AuroreColors.inkMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: AuroreSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AuroreColors.glass,
          borderRadius: BorderRadius.circular(AuroreRadii.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AuroreSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: contentColor,
                      ),
                    ),
                    const SizedBox(height: AuroreSpacing.xs),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(color: contentColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AuroreSpacing.sm),
              Text(
                isUnlocked ? l10n.achievementUnlocked : l10n.achievementLocked,
                style: textTheme.labelSmall?.copyWith(
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
