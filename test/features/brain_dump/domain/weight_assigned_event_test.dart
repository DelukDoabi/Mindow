import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/features/brain_dump/domain/weight_assigned_event.dart';

WeightAssignedEvent _event() => WeightAssignedEvent(
  eventId: 'w1',
  aggregateId: 'p1',
  occurredAt: DateTime.utc(2026, 6, 7, 10),
  mentalWeightKg: 7,
  category: 'Administratif',
  effortScore: 2,
  estimatedDurationMinutes: 15,
  weightModelVersion: 'gpt-4o-mini-2026-06',
);

void main() {
  group('WeightAssignedEvent', () {
    test('exposes the stable event_type discriminator', () {
      expect(WeightAssignedEvent.type, 'weight.assigned');
      expect(_event().eventType, 'weight.assigned');
    });

    test('serializes the payload in snake_case', () {
      expect(_event().toJson(), <String, dynamic>{
        'mental_weight_kg': 7,
        'category': 'Administratif',
        'effort_score': 2,
        'estimated_duration_minutes': 15,
        'weight_model_version': 'gpt-4o-mini-2026-06',
      });
    });

    test('round-trips through its envelope via the decoder', () {
      final envelope = _event().toEnvelope();
      final decoded = decodeWeightAssigned(envelope);

      expect(decoded, isA<WeightAssignedEvent>());
      final event = decoded as WeightAssignedEvent;
      expect(event.eventId, 'w1');
      expect(event.aggregateId, 'p1');
      expect(event.mentalWeightKg, 7);
      expect(event.category, 'Administratif');
      expect(event.effortScore, 2);
      expect(event.estimatedDurationMinutes, 15);
      expect(event.weightModelVersion, 'gpt-4o-mini-2026-06');
      expect(event.occurredAt, DateTime.utc(2026, 6, 7, 10));
    });

    test('is decodable through a registry', () {
      final registry = DomainEventRegistry()
        ..register(WeightAssignedEvent.type, decodeWeightAssigned);

      final decoded = registry.decode(_event().toEnvelope());

      expect(decoded, isA<WeightAssignedEvent>());
      expect((decoded as WeightAssignedEvent).mentalWeightKg, 7);
    });
  });
}
