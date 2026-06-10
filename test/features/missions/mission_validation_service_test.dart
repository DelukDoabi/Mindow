import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/hive_registrar.g.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_deleted_event.dart';
import 'package:mindow/features/missions/domain/daily_mission.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';
import 'package:mindow/features/missions/mission_validation_service.dart';

void main() {
  late Directory tempDir;
  late Box<OutboxRecord> box;
  late EventStore store;
  late MissionValidationService service;
  late DateTime now;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapters();
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'mission_validation_service_test',
    );
    Hive.init(tempDir.path);
    box = await Hive.openBox<OutboxRecord>('outbox');
    store = EventStore(box);
    now = DateTime.utc(2026, 6, 10, 10);

    final registry = DomainEventRegistry()
      ..register(PreoccupationCapturedEvent.type, decodePreoccupationCaptured)
      ..register(PreoccupationDeletedEvent.type, decodePreoccupationDeleted)
      ..register(MissionValidatedEvent.type, decodeMissionValidated);

    service = MissionValidationService(
      syncQueue: SyncQueue(store: store),
      eventStore: store,
      registry: registry,
      clock: () => now = now.add(const Duration(seconds: 1)),
    );
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  DailyMission mission() => DailyMission(
    id: 'm1',
    preoccupationId: 'p1',
    preoccupationContent: 'Appeler le dentiste',
    missionDate: '2026-06-10',
    estimatedKgGain: 6,
    estimatedDurationMinutes: 15,
    createdAt: DateTime.utc(2026, 6, 10, 9),
  );

  test('emits mission.validated then preoccupation.deleted', () async {
    await service.validate(mission());

    final events = store.all().map((record) => record.toEnvelope()).toList();
    expect(events, hasLength(2));
    final types = events.map((event) => event.eventType).toSet();
    expect(types, {
      MissionValidatedEvent.type,
      PreoccupationDeletedEvent.type,
    });
    final deleteEvent = events.firstWhere(
      (event) => event.eventType == PreoccupationDeletedEvent.type,
    );
    expect(deleteEvent.aggregateId, 'p1');
  });

  test('is idempotent by mission_id + mission_date', () async {
    final first = await service.validate(mission());
    final second = await service.validate(mission());

    expect(first.wasAlreadyValidated, isFalse);
    expect(second.wasAlreadyValidated, isTrue);

    final validatedCount = store
        .all()
        .where((record) => record.eventType == MissionValidatedEvent.type)
        .length;
    expect(validatedCount, 1);
  });
}
