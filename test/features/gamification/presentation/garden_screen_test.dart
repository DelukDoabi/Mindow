import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/gamification/achievement_providers.dart';
import 'package:mindow/features/gamification/domain/achievement_state.dart';
import 'package:mindow/features/gamification/domain/garden_state.dart';
import 'package:mindow/features/gamification/domain/level_state.dart';
import 'package:mindow/features/gamification/garden_providers.dart';
import 'package:mindow/features/gamification/level_providers.dart';
import 'package:mindow/features/gamification/presentation/garden_screen.dart';

void main() {
  testWidgets('renders current element and progression values', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gardenStateProvider.overrideWithValue(
            const GardenState(
              completedMissions: 8,
              currentElement: GardenElement.tree,
              nextUnlockAt: 12,
            ),
          ),
          levelStateProvider.overrideWithValue(
            const LevelState(
              completedMissions: 8,
              currentTier: LevelTier.espritClair,
              nextUnlockAt: 12,
            ),
          ),
          achievementStateProvider.overrideWithValue(
            const AchievementState(
              unlockedAchievements: {},
              currentStreak: 3,
              totalValidatedMissions: 8,
              totalKgFreed: 40,
              totalCapturedPreoccupations: 12,
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: GardenScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Garden + level assertions (non-regression 4.1 / 4.2).
    expect(find.text('Jardin mental'), findsOneWidget);
    expect(find.text('Déblocage actuel : Arbre'), findsOneWidget);
    expect(find.text('Missions validées : 8'), findsOneWidget);
    expect(find.text('Prochain déblocage à 12 missions'), findsOneWidget);
    expect(find.text('Niveau actuel : Esprit Clair'), findsOneWidget);
    expect(find.text('Prochain niveau à 12 missions'), findsOneWidget);

    // Streak section (AC #4).
    expect(find.text('Série en cours : 3 jour(s)'), findsOneWidget);

    // Achievements section (AC #4).
    expect(find.text('Accomplissements'), findsOneWidget);
    expect(find.text('Première victoire'), findsOneWidget);
    expect(find.text('10 kg allégés'), findsOneWidget);
  });
}
