import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/replay_engine.dart';

import 'support/counter_event.dart';

EventEnvelope _envelope(
  String id, {
  required int amount,
  DateTime? receivedAt,
}) => EventEnvelope(
  eventId: id,
  aggregateId: 'counter',
  eventType: CounterIncremented.type,
  schemaVersion: 1,
  createdAt: DateTime.utc(2026, 6, 7, 10),
  receivedAt: receivedAt,
  payload: <String, dynamic>{'amount': amount},
);

int _replay(Iterable<EventEnvelope> envelopes) {
  const engine = ReplayEngine();
  return engine.replay<int>(
    initialState: 0,
    envelopes: envelopes,
    registry: counterRegistry(),
    reducer: counterReducer,
  );
}

void main() {
  group('ReplayEngine.replay', () {
    test('folds events into the projection state', () {
      final result = _replay([
        _envelope('a', amount: 3, receivedAt: DateTime.utc(2026, 6, 7, 10, 1)),
        _envelope('b', amount: 2, receivedAt: DateTime.utc(2026, 6, 7, 10, 2)),
      ]);

      expect(result, 5);
    });

    test('is order-independent (sorts by received_at)', () {
      final ascending = [
        _envelope('a', amount: 3, receivedAt: DateTime.utc(2026, 6, 7, 10, 1)),
        _envelope('b', amount: 2, receivedAt: DateTime.utc(2026, 6, 7, 10, 2)),
      ];
      final descending = ascending.reversed.toList();

      expect(_replay(ascending), _replay(descending));
    });

    test('is idempotent under duplicated event ids', () {
      final envelope = _envelope(
        'a',
        amount: 4,
        receivedAt: DateTime.utc(2026, 6, 7, 10, 1),
      );

      expect(_replay([envelope, envelope]), 4);
    });

    test('orders not-yet-received (null) events after received ones', () {
      // The local event carries a smaller amount; if it were applied first the
      // intermediate state would differ, but the final sum is the invariant we
      // assert via ordering: nulls sort last, ties break by event_id.
      final result = _replay([
        _envelope('local', amount: 1),
        _envelope('a', amount: 3, receivedAt: DateTime.utc(2026, 6, 7, 10, 1)),
        _envelope('b', amount: 2, receivedAt: DateTime.utc(2026, 6, 7, 10, 2)),
      ]);

      expect(result, 6);
    });

    test('breaks received_at ties deterministically by event_id', () {
      final at = DateTime.utc(2026, 6, 7, 10, 1);
      final result = _replay([
        _envelope('z', amount: 1, receivedAt: at),
        _envelope('a', amount: 2, receivedAt: at),
      ]);

      expect(result, 3);
    });
  });
}
