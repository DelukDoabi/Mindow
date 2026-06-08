import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_updated_event.dart';

PreoccupationUpdatedEvent _event() => PreoccupationUpdatedEvent(
  eventId: 'upd-1',
  aggregateId: 'agg-7',
  occurredAt: DateTime.utc(2026, 6, 9, 9),
  content: 'schedule dentist appointment',
);

void main() {
  group('PreoccupationUpdatedEvent', () {
    test('exposes the stable event_type discriminator', () {
      expect(PreoccupationUpdatedEvent.type, 'preoccupation.updated');
      expect(_event().eventType, 'preoccupation.updated');
    });

    test('serializes the content payload', () {
      expect(_event().toJson(), <String, dynamic>{
        'content': 'schedule dentist appointment',
      });
    });

    test('round-trips through its envelope via the decoder', () {
      final envelope = _event().toEnvelope();
      final decoded = decodePreoccupationUpdated(envelope);

      expect(decoded, isA<PreoccupationUpdatedEvent>());
      final event = decoded as PreoccupationUpdatedEvent;
      expect(event.eventId, 'upd-1');
      expect(event.aggregateId, 'agg-7');
      expect(event.content, 'schedule dentist appointment');
      expect(event.occurredAt, DateTime.utc(2026, 6, 9, 9));
    });

    test('is decodable through a registry', () {
      final registry = DomainEventRegistry()
        ..register(
          PreoccupationUpdatedEvent.type,
          decodePreoccupationUpdated,
        );

      final decoded = registry.decode(_event().toEnvelope());

      expect(decoded, isA<PreoccupationUpdatedEvent>());
      expect(
        (decoded as PreoccupationUpdatedEvent).content,
        'schedule dentist appointment',
      );
    });
  });
}
