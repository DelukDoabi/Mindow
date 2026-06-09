import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/mental_load/domain/weekly_progression_projection.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';
import 'package:mindow/features/mental_load/presentation/stat_pill_row.dart';

WeeklyProgressionProjection _proj({int openCount = 0, int kgFreed = 0}) =>
    WeeklyProgressionProjection(openCount: openCount, kgFreedThisWeek: kgFreed);

/// Pumps [StatPillRow] with a fixed provider value.
///
/// Uses `overrideWithValue(AsyncValue<T>)` to set provider state
/// synchronously, avoiding async timing issues.
Future<void> pumpPillRow(
  WidgetTester tester, {
  required AsyncValue<WeeklyProgressionProjection> value,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [weeklyProgressionProvider.overrideWithValue(value)],
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(child: StatPillRow()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('StatPillRow', () {
    testWidgets('displays open count from projection', (tester) async {
      await pumpPillRow(
        tester,
        value: AsyncValue.data(_proj(openCount: 5)),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays label "en cours"', (tester) async {
      await pumpPillRow(
        tester,
        value: AsyncValue.data(_proj(openCount: 3)),
      );
      expect(find.text('en cours'), findsOneWidget);
    });

    testWidgets('displays kg freed value as "{n} kg"', (tester) async {
      await pumpPillRow(
        tester,
        value: AsyncValue.data(_proj(kgFreed: 12)),
      );
      expect(find.text('12 kg'), findsOneWidget);
    });

    testWidgets('displays label "libérés cette semaine"', (tester) async {
      await pumpPillRow(
        tester,
        value: AsyncValue.data(_proj()),
      );
      expect(find.text('libérés cette semaine'), findsOneWidget);
    });

    testWidgets('loading state renders fixed-height placeholder', (
      tester,
    ) async {
      await pumpPillRow(
        tester,
        value: const AsyncValue.loading(),
      );
      // No pill text labels during loading.
      expect(find.text('en cours'), findsNothing);
      expect(find.text('libérés cette semaine'), findsNothing);
      // A SizedBox of height 56 is present.
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.any((w) => w.height == 56), isTrue);
    });

    testWidgets('error state renders zero values', (tester) async {
      await pumpPillRow(
        tester,
        value: AsyncValue.error(Exception('fail'), StackTrace.empty),
      );
      expect(find.text('0'), findsOneWidget);
      expect(find.text('0 kg'), findsOneWidget);
    });

    testWidgets('semantics label contains open count and kg freed', (
      tester,
    ) async {
      await pumpPillRow(
        tester,
        value: AsyncValue.data(_proj(openCount: 7, kgFreed: 4)),
      );
      final semantics = tester.getSemantics(find.byType(StatPillRow));
      expect(semantics.label, contains('7'));
      expect(semantics.label, contains('4 kg'));
    });
  });
}
