import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_deleted_event.dart';

PreoccupationDeletedEvent _event() => PreoccupationDeletedEvent(
  eventId: 'del-1',
  aggregateId: 'agg-42',
  occurredAt: DateTime.utc(2026, 6, 9, 8),
);

void main() {
  group('PreoccupationDeletedEvent', () {
    test('exposes the stable event_type discriminator', () {
      expect(PreoccupationDeletedEvent.type, 'preoccupation.deleted');
      expect(_event().eventType, 'preoccupation.deleted');
    });

    test('serializes to an empty payload (tombstone)', () {
      expect(_event().toJson(), const <String, dynamic>{});
    });

    test('round-trips through its envelope via the decoder', () {
      final envelope = _event().toEnvelope();
      final decoded = decodePreoccupationDeleted(envelope);

      expect(decoded, isA<PreoccupationDeletedEvent>());
      final event = decoded as PreoccupationDeletedEvent;
      expect(event.eventId, 'del-1');
      expect(event.aggregateId, 'agg-42');
      expect(event.occurredAt, DateTime.utc(2026, 6, 9, 8));
    });

    test('is decodable through a registry', () {
      final registry = DomainEventRegistry()
        ..register(
          PreoccupationDeletedEvent.type,
          decodePreoccupationDeleted,
        );

      final decoded = registry.decode(_event().toEnvelope());

      expect(decoded, isA<PreoccupationDeletedEvent>());
      expect(decoded.aggregateId, 'agg-42');
    });
  });
}
