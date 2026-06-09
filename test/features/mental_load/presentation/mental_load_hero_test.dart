import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/mental_load/domain/mental_load_projection.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';
import 'package:mindow/features/mental_load/presentation/mental_load_hero.dart';

/// Pumps [MentalLoadHero] with a fixed provider value.
///
/// Using `overrideWithValue(AsyncValue<T>)` avoids async timing issues in
/// tests — the provider state is set synchronously, and `pumpAndSettle`
/// ensures localizations are fully loaded before assertions run.
Future<void> pumpHero(
  WidgetTester tester, {
  required AsyncValue<MentalLoadProjection> value,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mentalLoadProvider.overrideWithValue(value),
      ],
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MentalLoadHero()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MentalLoadHero', () {
    testWidgets('renders the kg numeral when data is available', (
      tester,
    ) async {
      await pumpHero(
        tester,
        value: const AsyncValue.data(
          MentalLoadProjection(totalKg: 42, hasPendingItems: false),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('shows ~ suffix when pending items exist', (tester) async {
      await pumpHero(
        tester,
        value: const AsyncValue.data(
          MentalLoadProjection(totalKg: 15, hasPendingItems: true),
        ),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.text('kg~'), findsOneWidget);
    });

    testWidgets('does not show ~ when no pending items', (tester) async {
      await pumpHero(
        tester,
        value: const AsyncValue.data(
          MentalLoadProjection(totalKg: 8, hasPendingItems: false),
        ),
      );

      expect(find.text('kg~'), findsNothing);
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('shows placeholder while loading', (tester) async {
      await pumpHero(
        tester,
        value: const AsyncValue<MentalLoadProjection>.loading(),
      );

      // Loading state shows a fixed-height SizedBox; no kg numeral is visible.
      expect(find.text('kg'), findsNothing);
      expect(find.text('kg~'), findsNothing);
    });

    testWidgets('exposes a semantic label with totalKg when data available', (
      tester,
    ) async {
      await pumpHero(
        tester,
        value: const AsyncValue.data(
          MentalLoadProjection(totalKg: 7, hasPendingItems: false),
        ),
      );

      expect(
        find.bySemanticsLabel('7 kg sur tes épaules'),
        findsOneWidget,
      );
    });

    testWidgets('renders 0 kg on error without crashing', (tester) async {
      await pumpHero(
        tester,
        value: AsyncValue<MentalLoadProjection>.error(
          Exception('network error'),
          StackTrace.empty,
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('caption is displayed in French', (tester) async {
      await pumpHero(
        tester,
        value: const AsyncValue.data(
          MentalLoadProjection(totalKg: 3, hasPendingItems: false),
        ),
      );

      expect(find.text('sur tes épaules'), findsOneWidget);
    });
  });
}
