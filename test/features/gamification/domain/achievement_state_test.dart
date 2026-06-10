import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/gamification/domain/achievement_state.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  MissionValidatedEvent event({
    required String id,
    required String missionId,
    required String missionDate,
    int kgFreed = 5,
  }) {
    return MissionValidatedEvent(
      eventId: id,
      aggregateId: missionId,
      occurredAt: DateTime.utc(2026, 6, 10, 10),
      missionId: missionId,
      missionDate: missionDate,
      kgFreed: kgFreed,
      timeInvestedMinutes: 15,
    );
  }

  /// Returns an ISO-8601 date string for today + [offsetDays] (local).
  String dateOffset(int offsetDays) {
    final d = DateTime.now().toLocal();
    final shifted = DateTime(d.year, d.month, d.day + offsetDays);
    final y = shifted.year.toString().padLeft(4, '0');
    final m = shifted.month.toString().padLeft(2, '0');
    final day = shifted.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  // ---------------------------------------------------------------------------
  // Streak tests
  // ---------------------------------------------------------------------------

  group('_computeStreak (via AchievementState.fromInputs)', () {
    test('streak is 0 with empty events', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [],
        capturedCount: 0,
      );
      expect(state.currentStreak, 0);
    });

    test('streak is 1 with a single event dated today', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: dateOffset(0)),
        ],
        capturedCount: 0,
      );
      expect(state.currentStreak, 1);
    });

    test('streak is 1 with a single event dated yesterday (active streak)', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: dateOffset(-1)),
        ],
        capturedCount: 0,
      );
      expect(state.currentStreak, 1);
    });

    test('streak is 0 when most recent date is before yesterday', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: dateOffset(-2)),
        ],
        capturedCount: 0,
      );
      expect(state.currentStreak, 0);
    });

    test('streak counts 3 consecutive days correctly', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: dateOffset(0)),
          event(id: 'e2', missionId: 'm2', missionDate: dateOffset(-1)),
          event(id: 'e3', missionId: 'm3', missionDate: dateOffset(-2)),
        ],
        capturedCount: 0,
      );
      expect(state.currentStreak, 3);
    });

    test('streak stops at gap after consecutive days', () {
      // Consecutive: today and yesterday; gap at -3 (skips -2).
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: dateOffset(0)),
          event(id: 'e2', missionId: 'm2', missionDate: dateOffset(-1)),
          event(id: 'e3', missionId: 'm3', missionDate: dateOffset(-3)),
        ],
        capturedCount: 0,
      );
      expect(state.currentStreak, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // Achievement unlock tests
  // ---------------------------------------------------------------------------

  group('Achievement.firstVictory', () {
    test('not unlocked with 0 validated missions', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [],
        capturedCount: 0,
      );
      expect(state.isUnlocked(Achievement.firstVictory), isFalse);
    });

    test('unlocked at 1 unique validated mission', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: '2026-01-01'),
        ],
        capturedCount: 0,
      );
      expect(state.isUnlocked(Achievement.firstVictory), isTrue);
    });
  });

  group('Achievement.tenKgFreed', () {
    test('not unlocked at 9 kg total', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: '2026-01-01'),
          event(
            id: 'e2',
            missionId: 'm2',
            missionDate: '2026-01-02',
            kgFreed: 4,
          ),
        ],
        capturedCount: 0,
      );
      expect(state.isUnlocked(Achievement.tenKgFreed), isFalse);
    });

    test('unlocked at exactly 10 kg total', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: '2026-01-01'),
          event(id: 'e2', missionId: 'm2', missionDate: '2026-01-02'),
        ],
        capturedCount: 0,
      );
      expect(state.isUnlocked(Achievement.tenKgFreed), isTrue);
    });

    test('dedup — same (missionId, missionDate) counted once for kgFreed', () {
      // Two events with same missionId+missionDate = 5 kg total (not 10 kg).
      final state = AchievementState.fromInputs(
        validatedEvents: [
          event(id: 'e1', missionId: 'm1', missionDate: '2026-01-01'),
          event(id: 'e2', missionId: 'm1', missionDate: '2026-01-01'),
        ],
        capturedCount: 0,
      );
      expect(state.totalKgFreed, 5);
      expect(state.isUnlocked(Achievement.tenKgFreed), isFalse);
    });
  });

  group('Achievement.hundredPreoccupations', () {
    test('not unlocked at 99 unique captures', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [],
        capturedCount: 99,
      );
      expect(state.isUnlocked(Achievement.hundredPreoccupations), isFalse);
    });

    test('unlocked at 100 unique captures', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [],
        capturedCount: 100,
      );
      expect(state.isUnlocked(Achievement.hundredPreoccupations), isTrue);
    });
  });

  group('Achievement.thirtyDayStreak', () {
    test('not unlocked at streak 29', () {
      // Build 29 consecutive days ending today.
      final events = List.generate(
        29,
        (i) => event(id: 'e$i', missionId: 'm$i', missionDate: dateOffset(-i)),
      );
      final state = AchievementState.fromInputs(
        validatedEvents: events,
        capturedCount: 0,
      );
      expect(state.currentStreak, 29);
      expect(state.isUnlocked(Achievement.thirtyDayStreak), isFalse);
    });

    test('unlocked at streak >= 30', () {
      final events = List.generate(
        30,
        (i) => event(id: 'e$i', missionId: 'm$i', missionDate: dateOffset(-i)),
      );
      final state = AchievementState.fromInputs(
        validatedEvents: events,
        capturedCount: 0,
      );
      expect(state.currentStreak, 30);
      expect(state.isUnlocked(Achievement.thirtyDayStreak), isTrue);
    });
  });
}
