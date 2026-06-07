import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/hive_registrar.g.dart';
import 'package:mindow/core/sync/sync_providers.dart';
import 'package:mindow/features/brain_dump/presentation/home_screen.dart';

void main() {
  late Directory tempDir;
  late Box<OutboxRecord> box;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapters();
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('home_screen_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OutboxRecord>('outbox');
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpHome(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Text('settings'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [outboxBoxProvider.overrideWithValue(box)],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the localized empty backpack and capture affordance', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(
      find.text("Ton sac est léger. Dépose ce qui t'encombre."),
      findsOneWidget,
    );
    expect(find.text("Qu'est-ce qui occupe ton esprit ?"), findsOneWidget);
    expect(find.text('Déposer'), findsOneWidget);
  });

  // Drives the async submit (capture write, provider reload, SnackBar entrance)
  // with bounded pumps. `pumpAndSettle` cannot be used here: the reload briefly
  // shows an indeterminate progress indicator, which never lets the frame
  // scheduler go idle.
  Future<void> settleCapture(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // Lets the SnackBar auto-dismiss timer fire so none is left pending.
  Future<void> flushSnackBar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('captures a worry and shows it in pending state', (tester) async {
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'call the dentist');
    await tester.pump();
    await tester.tap(find.text('Déposer'));
    await settleCapture(tester);

    expect(find.text('call the dentist'), findsOneWidget);
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text("C'est noté. Ton esprit s'allège."), findsOneWidget);
    expect(box.length, 1);

    await flushSnackBar(tester);
  });

  testWidgets('clears the input after a successful capture', (tester) async {
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'breathe');
    await tester.pump();
    await tester.tap(find.text('Déposer'));
    await settleCapture(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isEmpty);

    await flushSnackBar(tester);
  });

  testWidgets('keeps submit disabled for whitespace-only input', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(box.length, 0);
  });
}
