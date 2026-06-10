import 'package:mindow/features/missions/domain/mission_validated_event.dart';

enum LevelTier {
  explorateur,
  allegeur,
  espritClair,
  espritLeger,
  maitreDuCalme,
}

class LevelState {
  const LevelState({
    required this.completedMissions,
    required this.currentTier,
    required this.nextUnlockAt,
  });

  factory LevelState.fromCompletedMissions(int completedMissions) {
    final safeCompleted = completedMissions < 0 ? 0 : completedMissions;
    return LevelState(
      completedMissions: safeCompleted,
      currentTier: levelTierForCompletedMissions(safeCompleted),
      nextUnlockAt: nextLevelUnlockThreshold(safeCompleted),
    );
  }

  final int completedMissions;
  final LevelTier currentTier;

  /// Number of completed missions required to reach the next level.
  ///
  /// Returns `-1` when the top level is already reached.
  final int nextUnlockAt;
}

const Map<LevelTier, int> _levelUnlockThresholds = <LevelTier, int>{
  LevelTier.explorateur: 0,
  LevelTier.allegeur: 3,
  LevelTier.espritClair: 7,
  LevelTier.espritLeger: 12,
  LevelTier.maitreDuCalme: 20,
};

LevelTier levelTierForCompletedMissions(int completedMissions) {
  final completed = completedMissions < 0 ? 0 : completedMissions;
  var current = LevelTier.explorateur;
  for (final entry in _levelUnlockThresholds.entries) {
    if (completed >= entry.value) {
      current = entry.key;
    }
  }
  return current;
}

int nextLevelUnlockThreshold(int completedMissions) {
  final completed = completedMissions < 0 ? 0 : completedMissions;
  final sortedThresholds = _levelUnlockThresholds.values.toList(growable: false)
    ..sort();
  for (final threshold in sortedThresholds) {
    if (threshold > completed) return threshold;
  }
  return -1;
}

LevelState levelStateFromMissionValidatedEvents(
  Iterable<MissionValidatedEvent> events,
) {
  final seenKeys = <String>{};
  for (final event in events) {
    seenKeys.add(
      missionValidationKey(
        missionId: event.missionId,
        missionDate: event.missionDate,
      ),
    );
  }
  return LevelState.fromCompletedMissions(seenKeys.length);
}
