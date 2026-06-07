import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';

PreoccupationCapturedEvent _event() => PreoccupationCapturedEvent(
  eventId: 'e1',
  aggregateId: 'e1',
  occurredAt: DateTime.utc(2026, 6, 7, 10),
  content: 'call the dentist',
);

void main() {
  group('PreoccupationCapturedEvent', () {
    test('exposes the stable event_type discriminator', () {
      expect(PreoccupationCapturedEvent.type, 'preoccupation.captured');
      expect(_event().eventType, 'preoccupation.captured');
    });

    test('serializes only the content payload', () {
      expect(_event().toJson(), <String, dynamic>{
        'content': 'call the dentist',
      });
    });

    test('round-trips through its envelope via the decoder', () {
      final envelope = _event().toEnvelope();
      final decoded = decodePreoccupationCaptured(envelope);

      expect(decoded, isA<PreoccupationCapturedEvent>());
      final event = decoded as PreoccupationCapturedEvent;
      expect(event.eventId, 'e1');
      expect(event.aggregateId, 'e1');
      expect(event.content, 'call the dentist');
      expect(event.occurredAt, DateTime.utc(2026, 6, 7, 10));
    });

    test('is decodable through a registry', () {
      final registry = DomainEventRegistry()
        ..register(
          PreoccupationCapturedEvent.type,
          decodePreoccupationCaptured,
        );

      final decoded = registry.decode(_event().toEnvelope());

      expect(decoded, isA<PreoccupationCapturedEvent>());
      expect(
        (decoded as PreoccupationCapturedEvent).content,
        'call the dentist',
      );
    });
  });
}
