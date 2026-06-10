import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/gamification/domain/garden_state.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';

void main() {
  test('maps completed missions to expected garden element thresholds', () {
    expect(gardenElementForCompletedMissions(0), GardenElement.seedling);
    expect(gardenElementForCompletedMissions(1), GardenElement.flower);
    expect(gardenElementForCompletedMissions(3), GardenElement.shrub);
    expect(gardenElementForCompletedMissions(7), GardenElement.tree);
    expect(gardenElementForCompletedMissions(12), GardenElement.river);
    expect(gardenElementForCompletedMissions(18), GardenElement.animals);
    expect(gardenElementForCompletedMissions(25), GardenElement.landscape);
  });

  test('deduplicates mission.validated events by mission id + date', () {
    final events = <MissionValidatedEvent>[
      MissionValidatedEvent(
        eventId: 'e1',
        aggregateId: 'p1',
        occurredAt: DateTime.utc(2026, 6, 10, 10),
        missionId: 'm1',
        missionDate: '2026-06-10',
        kgFreed: 4,
        timeInvestedMinutes: 10,
      ),
      MissionValidatedEvent(
        eventId: 'e2',
        aggregateId: 'p1',
        occurredAt: DateTime.utc(2026, 6, 10, 11),
        missionId: 'm1',
        missionDate: '2026-06-10',
        kgFreed: 4,
        timeInvestedMinutes: 10,
      ),
      MissionValidatedEvent(
        eventId: 'e3',
        aggregateId: 'p2',
        occurredAt: DateTime.utc(2026, 6, 11, 10),
        missionId: 'm2',
        missionDate: '2026-06-11',
        kgFreed: 6,
        timeInvestedMinutes: 20,
      ),
    ];

    final state = gardenStateFromMissionValidatedEvents(events);

    expect(state.completedMissions, 2);
    expect(state.currentElement, GardenElement.flower);
    expect(state.nextUnlockAt, 3);
  });
}
