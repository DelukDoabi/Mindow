import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/hive_registrar.g.dart';
import 'package:mindow/core/sync/reconciliation_client.dart';
import 'package:mindow/core/sync/sync_queue.dart';

import 'support/counter_event.dart';

CounterIncremented _event(String id) => CounterIncremented(
  eventId: id,
  aggregateId: 'agg',
  occurredAt: DateTime.utc(2026, 6, 7, 10),
  amount: 1,
);

/// A fake transport that records what it was asked to push and returns
/// canned acknowledgements.
class _FakeClient implements ReconciliationClient {
  _FakeClient(this._acks);

  final Map<String, DateTime> _acks;
  final List<List<OutboxRecord>> pushes = <List<OutboxRecord>>[];

  @override
  Future<Map<String, DateTime>> push(List<OutboxRecord> records) async {
    pushes.add(records);
    return _acks;
  }
}

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
    tempDir = await Directory.systemTemp.createTemp('sync_queue_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OutboxRecord>('outbox');
    store = EventStore(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('enqueue appends to the local outbox', () async {
    final queue = SyncQueue(store: store);
    await queue.enqueue(_event('e1'));

    expect(store.all().single.eventId, 'e1');
  });

  test('flush is a no-op without a client', () async {
    final queue = SyncQueue(store: store);
    await queue.enqueue(_event('e1'));
    await queue.flush();

    expect(store.all().single.state, OutboxState.local);
  });

  test('flush pushes pending records and stamps server received_at', () async {
    final receivedAt = DateTime.utc(2026, 6, 7, 12);
    final client = _FakeClient({'e1': receivedAt});
    final queue = SyncQueue(store: store, client: client);

    await queue.enqueue(_event('e1'));
    await queue.flush();

    expect(client.pushes.single.single.eventId, 'e1');
    final record = store.all().single;
    expect(record.state, OutboxState.acked);
    expect(record.receivedAt, receivedAt);
  });

  test('flush falls back to the injected clock for unacked records', () async {
    final fallback = DateTime.utc(2026, 6, 7, 13);
    final client = _FakeClient(const <String, DateTime>{});
    final queue = SyncQueue(
      store: store,
      client: client,
      clock: () => fallback,
    );

    await queue.enqueue(_event('e1'));
    await queue.flush();

    final record = store.all().single;
    expect(record.state, OutboxState.acked);
    expect(record.receivedAt, fallback);
  });

  test('flush does not re-push already acked records', () async {
    final client = _FakeClient({'e1': DateTime.utc(2026, 6, 7, 12)});
    final queue = SyncQueue(store: store, client: client);

    await queue.enqueue(_event('e1'));
    await queue.flush();
    await queue.flush();

    expect(client.pushes, hasLength(1));
  });
}
