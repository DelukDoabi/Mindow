import 'package:mindow/features/missions/domain/mission_validated_event.dart';

/// Ordered unlockables in the Mental Garden.
enum GardenElement {
  seedling,
  flower,
  shrub,
  tree,
  river,
  animals,
  landscape,
}

/// Immutable projection of the user's current garden progression.
class GardenState {
  const GardenState({
    required this.completedMissions,
    required this.currentElement,
    required this.nextUnlockAt,
  });

  factory GardenState.fromCompletedMissions(int completedMissions) {
    final safeCompleted = completedMissions < 0 ? 0 : completedMissions;
    final element = gardenElementForCompletedMissions(safeCompleted);
    return GardenState(
      completedMissions: safeCompleted,
      currentElement: element,
      nextUnlockAt: nextUnlockThreshold(safeCompleted),
    );
  }

  final int completedMissions;
  final GardenElement currentElement;

  /// Number of completed missions required to reach the next unlock.
  ///
  /// Returns `-1` when the final stage is already unlocked.
  final int nextUnlockAt;
}

const Map<GardenElement, int> _gardenUnlockThresholds = <GardenElement, int>{
  GardenElement.seedling: 0,
  GardenElement.flower: 1,
  GardenElement.shrub: 3,
  GardenElement.tree: 7,
  GardenElement.river: 12,
  GardenElement.animals: 18,
  GardenElement.landscape: 25,
};

GardenElement gardenElementForCompletedMissions(int completedMissions) {
  final completed = completedMissions < 0 ? 0 : completedMissions;
  var current = GardenElement.seedling;
  for (final entry in _gardenUnlockThresholds.entries) {
    if (completed >= entry.value) {
      current = entry.key;
    }
  }
  return current;
}

int nextUnlockThreshold(int completedMissions) {
  final completed = completedMissions < 0 ? 0 : completedMissions;
  final sortedThresholds = _gardenUnlockThresholds.values.toList(
    growable: false,
  )..sort();
  for (final threshold in sortedThresholds) {
    if (threshold > completed) return threshold;
  }
  return -1;
}

GardenState gardenStateFromMissionValidatedEvents(
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
  return GardenState.fromCompletedMissions(seenKeys.length);
}
