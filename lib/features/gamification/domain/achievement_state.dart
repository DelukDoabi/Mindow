import 'package:mindow/features/missions/domain/mission_validated_event.dart';

/// The four milestones a user can unlock (FR-17).
enum Achievement {
  firstVictory,
  tenKgFreed,
  hundredPreoccupations,
  thirtyDayStreak,
}

/// Immutable projection of achievement and streak state.
///
/// Derived deterministically from the event log — no mutable counters (NFR-7).
class AchievementState {
  const AchievementState({
    required this.unlockedAchievements,
    required this.currentStreak,
    required this.totalValidatedMissions,
    required this.totalKgFreed,
    required this.totalCapturedPreoccupations,
  });

  /// Pure deterministic factory — no I/O, no side effects (AC #3).
  factory AchievementState.fromInputs({
    required List<MissionValidatedEvent> validatedEvents,
    required int capturedCount,
  }) {
    // Dedup validated events by missionValidationKey — same rule as Garden/Level.
    final seenKeys = <String>{};
    final uniqueEvents = <MissionValidatedEvent>[];
    for (final event in validatedEvents) {
      final key = missionValidationKey(
        missionId: event.missionId,
        missionDate: event.missionDate,
      );
      if (seenKeys.add(key)) {
        uniqueEvents.add(event);
      }
    }

    final totalMissions = uniqueEvents.length;
    final totalKg = uniqueEvents.fold(0, (sum, e) => sum + e.kgFreed);
    final missionDates = uniqueEvents.map((e) => e.missionDate).toSet();
    final streak = _computeStreak(missionDates);

    final unlocked = <Achievement>{};
    if (totalMissions >= 1) unlocked.add(Achievement.firstVictory);
    if (totalKg >= 10) unlocked.add(Achievement.tenKgFreed);
    if (capturedCount >= 100) unlocked.add(Achievement.hundredPreoccupations);
    if (streak >= 30) unlocked.add(Achievement.thirtyDayStreak);

    return AchievementState(
      unlockedAchievements: unlocked,
      currentStreak: streak,
      totalValidatedMissions: totalMissions,
      totalKgFreed: totalKg,
      totalCapturedPreoccupations: capturedCount,
    );
  }

  final Set<Achievement> unlockedAchievements;

  /// Consecutive calendar days ending today-or-yesterday with ≥ 1 completed mission.
  final int currentStreak;

  /// Deduplicated validated missions (by missionValidationKey).
  final int totalValidatedMissions;

  /// Total kg freed from unique validated missions.
  final int totalKgFreed;

  /// Count of unique preoccupations ever captured (unique aggregateIds).
  final int totalCapturedPreoccupations;

  bool isUnlocked(Achievement achievement) =>
      unlockedAchievements.contains(achievement);
}

/// Computes the current streak from a set of mission date strings (yyyy-MM-dd).
///
/// Streak = consecutive calendar days ending today-or-yesterday with ≥ 1 mission.
/// A missed day silently resets streak to 0; it is never penalized in the UI (UX-DR19).
/// NOTE: uses device local time; profile timezone not yet implemented.
int _computeStreak(Set<String> missionDates) {
  if (missionDates.isEmpty) return 0;

  // Parse all dates and sort descending.
  final parsed =
      missionDates
          .map(DateTime.tryParse)
          .whereType<DateTime>()
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList(growable: false)
        ..sort((a, b) => b.compareTo(a));

  if (parsed.isEmpty) return 0;

  final today = DateTime.now();
  final todayNorm = DateTime(today.year, today.month, today.day);
  final yesterday = todayNorm.subtract(const Duration(days: 1));
  final mostRecent = parsed.first;

  // If the most recent mission date is before yesterday, streak is broken.
  if (mostRecent.isBefore(yesterday)) return 0;

  // Count consecutive days backward from mostRecent.
  var streak = 1;
  var expected = mostRecent.subtract(const Duration(days: 1));
  for (var i = 1; i < parsed.length; i++) {
    if (parsed[i] == expected) {
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    } else if (parsed[i].isBefore(expected)) {
      break;
    }
    // parsed[i] == mostRecent (duplicate after dedup guard) is impossible here
    // but handled gracefully by the else-if above.
  }

  return streak;
}
