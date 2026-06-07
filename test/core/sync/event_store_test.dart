import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/hive_registrar.g.dart';

import 'support/counter_event.dart';

CounterIncremented _event(String id, {int amount = 1}) => CounterIncremented(
  eventId: id,
  aggregateId: 'agg',
  occurredAt: DateTime.utc(2026, 6, 7, 10),
  amount: amount,
);

void main() {
  late Directory tempDir;
  late Box<OutboxRecord> box;
  late EventStore store;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapters();
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('event_store_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OutboxRecord>('outbox');
    store = EventStore(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  group('EventStore.append', () {
    test('persists a local record keyed by event_id', () async {
      await store.append(_event('e1', amount: 3));

      final records = store.all();
      expect(records, hasLength(1));
      expect(records.single.eventId, 'e1');
      expect(records.single.state, OutboxState.local);
      expect(records.single.toEnvelope().payload['amount'], 3);
    });

    test('is idempotent for a repeated event_id', () async {
      await store.append(_event('e1', amount: 3));
      await store.append(_event('e1', amount: 99));

      expect(store.all(), hasLength(1));
      expect(store.all().single.toEnvelope().payload['amount'], 3);
    });
  });

  group('lifecycle transitions', () {
    test('markSent moves local → sent', () async {
      await store.append(_event('e1'));
      await store.markSent('e1');

      expect(store.all().single.state, OutboxState.sent);
    });

    test('markAcked stamps received_at in UTC and moves → acked', () async {
      await store.append(_event('e1'));
      final receivedAt = DateTime.utc(2026, 6, 7, 11, 30);
      await store.markAcked('e1', receivedAt);

      final record = store.all().single;
      expect(record.state, OutboxState.acked);
      expect(record.receivedAt, receivedAt);
      expect(record.receivedAt!.isUtc, isTrue);
    });

    test('markSent / markAcked are no-ops for unknown ids', () async {
      await store.markSent('ghost');
      await store.markAcked('ghost', DateTime.utc(2026));

      expect(store.all(), isEmpty);
    });
  });

  group('queries', () {
    test('pending returns local and sent but not acked', () async {
      await store.append(_event('local-1'));
      await store.append(_event('sent-1'));
      await store.append(_event('acked-1'));
      await store.markSent('sent-1');
      await store.markAcked('acked-1', DateTime.utc(2026));

      final pendingIds = store.pending().map((r) => r.eventId).toSet();
      expect(pendingIds, {'local-1', 'sent-1'});
    });
  });
}
