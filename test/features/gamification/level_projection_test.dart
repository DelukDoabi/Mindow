import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/gamification/domain/level_state.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';

void main() {
  MissionValidatedEvent event({
    required String id,
    required String missionId,
    required String missionDate,
  }) {
    return MissionValidatedEvent(
      eventId: id,
      aggregateId: missionId,
      occurredAt: DateTime.utc(2026, 6, 10, 10),
      missionId: missionId,
      missionDate: missionDate,
      kgFreed: 5,
      timeInvestedMinutes: 15,
    );
  }

  test(
    'produces deterministic tier from replayed validated mission events',
    () {
      final events = <MissionValidatedEvent>[
        event(id: 'e3', missionId: 'm3', missionDate: '2026-06-12'),
        event(id: 'e1', missionId: 'm1', missionDate: '2026-06-10'),
        event(id: 'e2', missionId: 'm2', missionDate: '2026-06-11'),
        event(id: 'e4', missionId: 'm2', missionDate: '2026-06-11'),
      ];

      final state = levelStateFromMissionValidatedEvents(events);

      expect(state.completedMissions, 3);
      expect(state.currentTier, LevelTier.allegeur);
      expect(state.nextUnlockAt, 7);
    },
  );
}
