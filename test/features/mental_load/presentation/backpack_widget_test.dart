import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/mental_load/domain/mental_load_projection.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';
import 'package:mindow/features/mental_load/presentation/backpack_widget.dart';

MentalLoadProjection _proj({required int kg}) =>
    MentalLoadProjection(totalKg: kg, hasPendingItems: false);

/// Pumps [BackpackWidget] with a fixed provider value.
///
/// Uses `overrideWithValue(AsyncValue<T>)` to set provider state
/// synchronously, avoiding async timing issues.
Future<void> pumpBackpack(
  WidgetTester tester, {
  required AsyncValue<MentalLoadProjection> value,
  VoidCallback? onTap,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mentalLoadProvider.overrideWithValue(value),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(child: BackpackWidget(onTap: onTap)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('BackpackWidget', () {
    testWidgets('0 kg → semantics label contains "léger"', (tester) async {
      await pumpBackpack(
        tester,
        value: AsyncValue.data(_proj(kg: 0)),
      );
      final semantics = tester.getSemantics(find.byType(BackpackWidget));
      expect(semantics.label, contains('léger'));
    });

    testWidgets('20 kg → semantics label contains "modéré"', (tester) async {
      await pumpBackpack(
        tester,
        value: AsyncValue.data(_proj(kg: 20)),
      );
      final semantics = tester.getSemantics(find.byType(BackpackWidget));
      expect(semantics.label, contains('modéré'));
    });

    testWidgets('50 kg → semantics label contains "lourd"', (tester) async {
      await pumpBackpack(
        tester,
        value: AsyncValue.data(_proj(kg: 50)),
      );
      final semantics = tester.getSemantics(find.byType(BackpackWidget));
      expect(semantics.label, contains('lourd'));
    });

    testWidgets('80 kg → semantics label contains "très lourd"', (
      tester,
    ) async {
      await pumpBackpack(
        tester,
        value: AsyncValue.data(_proj(kg: 80)),
      );
      final semantics = tester.getSemantics(find.byType(BackpackWidget));
      expect(semantics.label, contains('très lourd'));
    });

    testWidgets('loading state → no semantics label', (tester) async {
      await pumpBackpack(
        tester,
        value: const AsyncValue.loading(),
      );
      // Loading state renders a placeholder SizedBox — no Semantics widget.
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    });

    testWidgets('tap callback is invoked on tap', (tester) async {
      var tapped = false;
      await pumpBackpack(
        tester,
        value: AsyncValue.data(_proj(kg: 35)),
        onTap: () => tapped = true,
      );
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('CustomPaint is rendered in data state', (tester) async {
      await pumpBackpack(
        tester,
        value: AsyncValue.data(_proj(kg: 65)),
      );
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });
  });
}
