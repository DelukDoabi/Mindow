import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/gamification/domain/level_state.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';

void main() {
  test('maps completed missions to expected level tiers', () {
    expect(levelTierForCompletedMissions(0), LevelTier.explorateur);
    expect(levelTierForCompletedMissions(3), LevelTier.allegeur);
    expect(levelTierForCompletedMissions(7), LevelTier.espritClair);
    expect(levelTierForCompletedMissions(12), LevelTier.espritLeger);
    expect(levelTierForCompletedMissions(20), LevelTier.maitreDuCalme);
  });

  test('returns next unlock threshold and terminal marker', () {
    expect(nextLevelUnlockThreshold(0), 3);
    expect(nextLevelUnlockThreshold(3), 7);
    expect(nextLevelUnlockThreshold(7), 12);
    expect(nextLevelUnlockThreshold(12), 20);
    expect(nextLevelUnlockThreshold(20), -1);
    expect(nextLevelUnlockThreshold(99), -1);
  });

  test('builds level state from completed missions', () {
    const state = LevelState(
      completedMissions: 8,
      currentTier: LevelTier.espritClair,
      nextUnlockAt: 12,
    );

    expect(state.currentTier, LevelTier.espritClair);
    expect(state.nextUnlockAt, 12);
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
      MissionValidatedEvent(
        eventId: 'e4',
        aggregateId: 'p3',
        occurredAt: DateTime.utc(2026, 6, 12, 10),
        missionId: 'm3',
        missionDate: '2026-06-12',
        kgFreed: 3,
        timeInvestedMinutes: 8,
      ),
    ];

    final state = levelStateFromMissionValidatedEvents(events);

    expect(state.completedMissions, 3);
    expect(state.currentTier, LevelTier.allegeur);
    expect(state.nextUnlockAt, 7);
  });
}
