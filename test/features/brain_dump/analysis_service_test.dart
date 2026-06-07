import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/ai/ai_client.dart';
import 'package:mindow/core/ai/ai_failure.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/hive_registrar.g.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:mindow/features/brain_dump/analysis_service.dart';
import 'package:mindow/features/brain_dump/domain/analysis_constants.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/brain_dump/domain/weight_assigned_event.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';

/// A scripted [AiClient] that never touches the network.
///
/// Either returns a queued [AiAnalysisResult] or throws a queued [AiFailure],
/// one per call, and records how many times it was invoked.
class _FakeAiClient implements AiClient {
  _FakeAiClient(this._script);

  final List<Object> _script;
  int calls = 0;

  @override
  Future<AiAnalysisResult> analyze({
    required String content,
    required String languageCode,
  }) async {
    final step = _script[calls.clamp(0, _script.length - 1)];
    calls++;
    if (step is AiFailure) throw step;
    return step as AiAnalysisResult;
  }
}

void main() {
  late Directory tempDir;
  late Box<OutboxRecord> box;
  late EventStore store;
  late SyncQueue syncQueue;
  late OnboardingRepository onboarding;

  const success = AiAnalysisSuccess(
    category: 'Administratif',
    mentalWeightKg: 7,
    effortScore: 2,
    estimatedDurationMinutes: 15,
    weightModelVersion: 'gpt-4o-mini-2026-06',
  );

  setUpAll(() {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapters();
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('analysis_service_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OutboxRecord>('outbox');
    store = EventStore(box);
    syncQueue = SyncQueue(store: store);
    onboarding = OnboardingRepository();
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  AnalysisService buildService(
    _FakeAiClient aiClient, {
    void Function(String id)? onCrisis,
  }) => AnalysisService(
    aiClient: aiClient,
    onboardingRepository: onboarding,
    syncQueue: syncQueue,
    readPending: () => const <Preoccupation>[],
    onCrisis: onCrisis,
    backoff: (_) => Duration.zero,
  );

  WeightAssignedEvent? soleWeightEvent() {
    final weights = store
        .all()
        .where((r) => r.eventType == WeightAssignedEvent.type)
        .toList();
    if (weights.isEmpty) return null;
    final envelope = weights.single.toEnvelope();
    return decodeWeightAssigned(envelope) as WeightAssignedEvent;
  }

  test('skips analysis and emits no event when consent is denied', () async {
    final ai = _FakeAiClient(<Object>[success]);
    final service = buildService(ai);

    final outcome = await service.analyzePreoccupation(
      id: 'p1',
      content: 'call the dentist',
    );

    expect(outcome, AnalysisOutcome.skippedNoConsent);
    expect(ai.calls, 0);
    expect(store.all(), isEmpty);
  });

  test('emits one mapped weight event on success', () async {
    await onboarding.setAiConsent(granted: true);
    final ai = _FakeAiClient(<Object>[success]);
    final service = buildService(ai);

    final outcome = await service.analyzePreoccupation(
      id: 'p1',
      content: 'call the dentist',
    );

    expect(outcome, AnalysisOutcome.weighed);
    final event = soleWeightEvent();
    expect(event, isNotNull);
    expect(event!.aggregateId, 'p1');
    expect(event.mentalWeightKg, 7);
    expect(event.category, 'Administratif');
    expect(event.effortScore, 2);
    expect(event.estimatedDurationMinutes, 15);
    expect(event.weightModelVersion, 'gpt-4o-mini-2026-06');
  });

  test('routes to crisis and emits no event when crisis detected', () async {
    await onboarding.setAiConsent(granted: true);
    final ai = _FakeAiClient(<Object>[const AiCrisisDetected()]);
    final crisisIds = <String>[];
    final service = buildService(ai, onCrisis: crisisIds.add);

    final outcome = await service.analyzePreoccupation(
      id: 'p1',
      content: 'i want to disappear',
    );

    expect(outcome, AnalysisOutcome.crisis);
    expect(crisisIds, <String>['p1']);
    expect(store.all(), isEmpty);
  });

  test('falls back after exhausting the retry budget', () async {
    await onboarding.setAiConsent(granted: true);
    final ai = _FakeAiClient(<Object>[const AiNetworkFailure()]);
    final service = buildService(ai);

    final outcome = await service.analyzePreoccupation(
      id: 'p1',
      content: 'something',
    );

    expect(outcome, AnalysisOutcome.fallback);
    expect(ai.calls, kMaxAnalysisRetries);
    final event = soleWeightEvent();
    expect(event, isNotNull);
    expect(event!.category, kFallbackCategory);
    expect(event.mentalWeightKg, kFallbackWeightKg);
    expect(event.effortScore, kFallbackEffortScore);
    expect(event.estimatedDurationMinutes, kFallbackDurationMinutes);
    expect(event.weightModelVersion, kFallbackWeightModelVersion);
  });

  test('retries a transient failure then succeeds with one event', () async {
    await onboarding.setAiConsent(granted: true);
    final ai = _FakeAiClient(<Object>[const AiTimeoutFailure(), success]);
    final service = buildService(ai);

    final outcome = await service.analyzePreoccupation(
      id: 'p1',
      content: 'something',
    );

    expect(outcome, AnalysisOutcome.weighed);
    expect(ai.calls, 2);
    expect(
      store.all().where((r) => r.eventType == WeightAssignedEvent.type),
      hasLength(1),
    );
  });

  test('analyzePendingPreoccupations does nothing without consent', () async {
    final ai = _FakeAiClient(<Object>[success]);
    final service = AnalysisService(
      aiClient: ai,
      onboardingRepository: onboarding,
      syncQueue: syncQueue,
      readPending: () => <Preoccupation>[
        Preoccupation(
          id: 'p1',
          content: 'x',
          createdAt: DateTime.utc(2026, 6, 7),
        ),
      ],
      backoff: (_) => Duration.zero,
    );

    await service.analyzePendingPreoccupations();

    expect(ai.calls, 0);
    expect(store.all(), isEmpty);
  });
}
