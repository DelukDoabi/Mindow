import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/hive_registrar.g.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:mindow/features/brain_dump/brain_dump_repository.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';
import 'package:mindow/features/brain_dump/domain/weight_assigned_event.dart';

void main() {
  late Directory tempDir;
  late Box<OutboxRecord> box;
  late EventStore store;
  late BrainDumpRepository repository;
  late DateTime clockNow;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapters();
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('brain_dump_repo_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OutboxRecord>('outbox');
    store = EventStore(box);
    // A monotonic clock so captures get strictly increasing timestamps even
    // when they happen within the same millisecond under test.
    clockNow = DateTime.utc(2026, 6, 7, 10);
    repository = BrainDumpRepository(
      syncQueue: SyncQueue(store: store),
      eventStore: store,
      registry: DomainEventRegistry()
        ..register(
          PreoccupationCapturedEvent.type,
          decodePreoccupationCaptured,
        )
        ..register(WeightAssignedEvent.type, decodeWeightAssigned),
      clock: () => clockNow = clockNow.add(const Duration(seconds: 1)),
    );
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  group('capturePreoccupation', () {
    test('appends a local capture event to the outbox', () async {
      await repository.capturePreoccupation('call the dentist');

      final records = store.all();
      expect(records, hasLength(1));
      expect(records.single.state, OutboxState.local);
      expect(records.single.eventType, PreoccupationCapturedEvent.type);
      expect(
        records.single.toEnvelope().payload['content'],
        'call the dentist',
      );
    });

    test('trims surrounding whitespace before persisting', () async {
      await repository.capturePreoccupation('   pay the rent   ');

      expect(
        store.all().single.toEnvelope().payload['content'],
        'pay the rent',
      );
    });

    test('rejects empty or whitespace-only input without emitting', () async {
      await repository.capturePreoccupation('');
      await repository.capturePreoccupation('   ');

      expect(store.all(), isEmpty);
    });

    test('uses the same id for event_id and aggregate_id', () async {
      await repository.capturePreoccupation('breathe');

      final record = store.all().single;
      expect(record.eventId, record.toEnvelope().aggregateId);
    });
  });

  group('getOpenPreoccupations', () {
    test('returns captured items most recent first', () async {
      await repository.capturePreoccupation('first');
      await repository.capturePreoccupation('second');

      final open = repository.getOpenPreoccupations();
      expect(open, hasLength(2));
      expect(open.map((p) => p.content), ['second', 'first']);
    });

    test('leaves Mental Weight unset so items read as pending', () async {
      await repository.capturePreoccupation('worry');

      final item = repository.getOpenPreoccupations().single;
      expect(item.mentalWeightKg, isNull);
      expect(item.isPending, isTrue);
    });

    test('is empty before any capture', () {
      expect(repository.getOpenPreoccupations(), isEmpty);
    });
  });

  group('weight.assigned projection fold', () {
    var weightSeq = 0;
    Future<void> assignWeight(
      String aggregateId, {
      required int kg,
      required String category,
      String version = 'gpt-4o-mini-2026-06',
    }) => store.append(
      WeightAssignedEvent(
        // Monotonic, lexicographically ordered event ids so replay order (which
        // breaks ties by event_id for unsynced events) matches emission order.
        eventId: 'w-${(weightSeq++).toString().padLeft(4, '0')}',
        aggregateId: aggregateId,
        occurredAt: clockNow = clockNow.add(const Duration(seconds: 1)),
        mentalWeightKg: kg,
        category: category,
        effortScore: 2,
        estimatedDurationMinutes: 15,
        weightModelVersion: version,
      ),
    );

    test('sets the weight and category and clears pending', () async {
      await repository.capturePreoccupation('call the dentist');
      final id = store.all().single.eventId;

      await assignWeight(id, kg: 7, category: 'Administratif');

      final item = repository.getOpenPreoccupations().single;
      expect(item.isPending, isFalse);
      expect(item.mentalWeightKg, 7);
      expect(item.category, 'Administratif');
      expect(item.effortScore, 2);
      expect(item.estimatedDurationMinutes, 15);
      expect(item.weightModelVersion, 'gpt-4o-mini-2026-06');
    });

    test('a fallback weight leaves the item non-pending as Autre', () async {
      await repository.capturePreoccupation('something');
      final id = store.all().single.eventId;

      await assignWeight(id, kg: 3, category: 'Autre', version: 'fallback-v1');

      final item = repository.getOpenPreoccupations().single;
      expect(item.isPending, isFalse);
      expect(item.category, 'Autre');
      expect(item.weightModelVersion, 'fallback-v1');
    });

    test('latest weight.assigned wins', () async {
      await repository.capturePreoccupation('worry');
      final id = store.all().single.eventId;

      await assignWeight(id, kg: 3, category: 'Autre');
      await assignWeight(id, kg: 12, category: 'Travail');

      final item = repository.getOpenPreoccupations().single;
      expect(item.mentalWeightKg, 12);
      expect(item.category, 'Travail');
    });

    test('an orphan weight event (no aggregate) is ignored', () async {
      await assignWeight('ghost', kg: 9, category: 'Santé');

      expect(repository.getOpenPreoccupations(), isEmpty);
    });
  });
}
