import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
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
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: GardenScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Jardin mental'), findsOneWidget);
    expect(find.text('Déblocage actuel : Arbre'), findsOneWidget);
    expect(find.text('Missions validées : 8'), findsOneWidget);
    expect(find.text('Prochain déblocage à 12 missions'), findsOneWidget);
    expect(find.text('Niveau actuel : Esprit Clair'), findsOneWidget);
    expect(find.text('Prochain niveau à 12 missions'), findsOneWidget);
  });
}
