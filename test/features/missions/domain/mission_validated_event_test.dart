import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';

MissionValidatedEvent _event() => MissionValidatedEvent(
  eventId: 'mv-1',
  aggregateId: 'p1',
  occurredAt: DateTime.utc(2026, 6, 10, 9),
  missionId: 'm1',
  missionDate: '2026-06-10',
  kgFreed: 6,
  timeInvestedMinutes: 15,
);

void main() {
  group('MissionValidatedEvent', () {
    test('exposes stable event type', () {
      expect(MissionValidatedEvent.type, 'mission.validated');
      expect(_event().eventType, 'mission.validated');
    });

    test('serializes payload fields', () {
      expect(_event().toJson(), <String, dynamic>{
        'mission_id': 'm1',
        'mission_date': '2026-06-10',
        'kg_freed': 6,
        'time_invested_minutes': 15,
      });
    });

    test('decodes from envelope', () {
      final decoded = decodeMissionValidated(_event().toEnvelope());
      expect(decoded, isA<MissionValidatedEvent>());
      final event = decoded as MissionValidatedEvent;
      expect(event.missionId, 'm1');
      expect(event.missionDate, '2026-06-10');
      expect(event.kgFreed, 6);
      expect(event.timeInvestedMinutes, 15);
      expect(event.aggregateId, 'p1');
    });

    test('builds deterministic mission validation key', () {
      expect(
        missionValidationKey(
          missionId: 'mission-42',
          missionDate: '2026-06-10',
        ),
        'mission-42::2026-06-10',
      );
    });

    test('is decodable through registry', () {
      final registry = DomainEventRegistry()
        ..register(MissionValidatedEvent.type, decodeMissionValidated);

      final decoded = registry.decode(_event().toEnvelope());

      expect(decoded, isA<MissionValidatedEvent>());
      expect((decoded as MissionValidatedEvent).missionId, 'm1');
    });
  });
}
