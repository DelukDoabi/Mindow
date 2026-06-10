import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/ai/ai_client.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/hive_registrar.g.dart';
import 'package:mindow/core/sync/sync_providers.dart';
import 'package:mindow/features/brain_dump/presentation/home_screen.dart';
import 'package:mindow/features/mental_load/domain/weekly_progression_projection.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';
import 'package:mindow/features/missions/domain/daily_mission.dart';
import 'package:mindow/features/missions/mission_validation_service.dart';
import 'package:mindow/features/missions/missions_providers.dart';
import 'package:mindow/features/missions/missions_repository.dart';
import 'package:mindow/features/notifications/notification_providers.dart';
import 'package:mindow/features/notifications/notification_service.dart';

/// No-op [NotificationService] for widget tests — never touches Firebase.
class _NoopNotificationService implements NotificationService {
  @override
  Future<void> setupNotifications() async {}

  @override
  void dispose() {}
}

/// No-op [MissionValidationService] for widget tests.
///
/// The real service writes to the Hive outbox from an `unawaited` callback,
/// which blocks FakeAsync and causes the test to hang. Override it with a
/// synchronous stub so "C'est fait ✓" taps complete immediately.
class _NoopMissionValidationService implements MissionValidationService {
  @override
  Future<MissionValidationResult> validate(DailyMission mission) async =>
      MissionValidationResult(
        kgFreed: mission.estimatedKgGain,
        timeInvestedMinutes: mission.estimatedDurationMinutes,
        wasAlreadyValidated: false,
      );
}

class _NoopAiClient implements AiClient {
  @override
  Future<AiAnalysisResult> analyze({
    required String content,
    required String languageCode,
  }) async => const AiCrisisDetected();
}

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
    // The fire-and-forget analysis trigger opens the `onboarding` box (consent
    // check) on a background microtask, so close EVERY Hive box before deleting
    // the temp dir, and tolerate a lingering handle on Windows.
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // The OS will reclaim the temp dir; a lingering handle must not fail the
      // test whose assertions already passed.
    }
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    DailyMissionResult mission = const DailyMissionResult(
      missionDate: '2026-06-10',
      mission: null,
    ),
    List<MissionVictory> victories = const <MissionVictory>[],
  }) async {
    // The default test viewport (800×600) is too short for the full Home
    // layout (hero + backpack + stat pills + list + capture bar). Use a
    // taller viewport that reflects real phone proportions.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
        overrides: [
          outboxBoxProvider.overrideWithValue(box),
          aiClientProvider.overrideWithValue(_NoopAiClient()),
          weeklyProgressionProvider.overrideWithValue(
            const AsyncValue.data(
              WeeklyProgressionProjection(openCount: 0, kgFreedThisWeek: 0),
            ),
          ),
          todayMissionProvider.overrideWithValue(AsyncValue.data(mission)),
          missionVictoriesProvider.overrideWithValue(victories),
          missionValidationServiceProvider
              .overrideWithValue(_NoopMissionValidationService()),
          notificationServiceProvider
              .overrideWithValue(_NoopNotificationService()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    // The open-preoccupations read is a synchronous replay over the in-memory
    // box, so the initial load resolves on a microtask and pumpAndSettle is
    // safe here.
    await tester.pumpAndSettle();
  }

  // Submits the current input and drives the rebuild to the point where the
  // freshly captured item and its success SnackBar are on screen.
  //
  // The capture write persists through a real Hive box: that is real file I/O
  // which the fake test clock never advances, so the tap is performed inside
  // `runAsync` to let it complete. Afterwards a bounded pump rebuilds the list
  // and shows the SnackBar without fully settling (the SnackBar is asserted on
  // and would otherwise auto-dismiss before the checks run).
  Future<void> capture(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.text('Déposer'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
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

  // Lets the SnackBar auto-dismiss timer fire so none is left pending.
  Future<void> flushSnackBar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('captures a worry and shows it in pending state', (tester) async {
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'call the dentist');
    await tester.pump();
    await capture(tester);

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
    await capture(tester);

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

  testWidgets('renders mission card when a mission exists', (tester) async {
    await pumpHome(
      tester,
      mission: DailyMissionResult(
        missionDate: '2026-06-10',
        mission: DailyMission(
          id: 'm1',
          preoccupationId: 'p1',
          preoccupationContent: 'Appeler le dentiste',
          missionDate: '2026-06-10',
          estimatedKgGain: 6,
          estimatedDurationMinutes: 15,
          createdAt: DateTime.utc(2026, 6, 10),
        ),
      ),
    );

    expect(find.text('Mission du jour'), findsOneWidget);
    expect(find.text('Appeler le dentiste'), findsOneWidget);
    expect(find.text('Durée estimée : 15 min'), findsOneWidget);
    expect(find.text('Soulagement estimé : 6 kg'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('Plus tard'), findsOneWidget);
    expect(find.text("C'est fait ✓"), findsOneWidget);
  });

  testWidgets('start action opens mission context sheet', (tester) async {
    await pumpHome(
      tester,
      mission: DailyMissionResult(
        missionDate: '2026-06-10',
        mission: DailyMission(
          id: 'm1',
          preoccupationId: 'p1',
          preoccupationContent: 'Appeler le dentiste',
          missionDate: '2026-06-10',
          estimatedKgGain: 6,
          estimatedDurationMinutes: 15,
          createdAt: DateTime.utc(2026, 6, 10),
        ),
      ),
    );

    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.text('Ta mission du jour'), findsOneWidget);
    expect(find.text('Estime: 15 min'), findsOneWidget);
  });

  testWidgets('defer action hides current mission and shows feedback', (
    tester,
  ) async {
    await pumpHome(
      tester,
      mission: DailyMissionResult(
        missionDate: '2026-06-10',
        mission: DailyMission(
          id: 'm1',
          preoccupationId: 'p1',
          preoccupationContent: 'Appeler le dentiste',
          missionDate: '2026-06-10',
          estimatedKgGain: 6,
          estimatedDurationMinutes: 15,
          createdAt: DateTime.utc(2026, 6, 10),
        ),
      ),
    );

    await tester.tap(find.text('Plus tard'));
    await tester.pump();

    expect(
      find.text('Pas de souci. On te reproposera quelque chose plus tard.'),
      findsOneWidget,
    );
    expect(find.text("Rien d'urgent aujourd'hui. Profite."), findsOneWidget);
  });

  testWidgets('done action does not crash the mission section', (tester) async {
    await pumpHome(
      tester,
      mission: DailyMissionResult(
        missionDate: '2026-06-10',
        mission: DailyMission(
          id: 'm1',
          preoccupationId: 'p1',
          preoccupationContent: 'Appeler le dentiste',
          missionDate: '2026-06-10',
          estimatedKgGain: 6,
          estimatedDurationMinutes: 15,
          createdAt: DateTime.utc(2026, 6, 10),
        ),
      ),
    );

    await tester.tap(find.text("C'est fait ✓"));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders gentle mission empty state when no mission exists', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text("Rien d'urgent aujourd'hui. Profite."), findsOneWidget);
  });

  testWidgets('opens empty victory history sheet', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text("Voir l'historique"));
    await tester.pumpAndSettle();

    expect(find.text('Historique des victoires'), findsOneWidget);
    expect(find.text("Aucune victoire pour l'instant."), findsOneWidget);
  });

  testWidgets('renders victory rows in chronological history', (tester) async {
    await pumpHome(
      tester,
      victories: <MissionVictory>[
        MissionVictory(
          missionId: 'm2',
          missionDate: '2026-06-10',
          preoccupationId: 'p2',
          kgFreed: 4,
          timeInvestedMinutes: 10,
          validatedAt: DateTime.utc(2026, 6, 10, 9),
        ),
        MissionVictory(
          missionId: 'm1',
          missionDate: '2026-06-09',
          preoccupationId: 'p1',
          kgFreed: 6,
          timeInvestedMinutes: 15,
          validatedAt: DateTime.utc(2026, 6, 9, 18),
        ),
      ],
    );

    await tester.tap(find.text("Voir l'historique"));
    await tester.pumpAndSettle();

    expect(find.text('2026-06-10'), findsOneWidget);
    expect(find.text('4 kg libérés · 10 min'), findsOneWidget);
    expect(find.text('2026-06-09'), findsOneWidget);
    expect(find.text('6 kg libérés · 15 min'), findsOneWidget);
  });
}
