import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/gamification/domain/achievement_state.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';

/// Projection-level tests for [AchievementState] — exercises the deterministic
/// computation from event lists without touching Riverpod providers or Hive.
void main() {
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

  group('AchievementState.fromInputs — idempotent dedup', () {
    test(
      'duplicate (missionId, missionDate) pairs count validated missions once',
      () {
        final events = <MissionValidatedEvent>[
          event(id: 'e1', missionId: 'm1', missionDate: '2026-06-10'),
          event(
            id: 'e2',
            missionId: 'm1',
            missionDate: '2026-06-10',
          ), // duplicate key
          event(id: 'e3', missionId: 'm2', missionDate: '2026-06-11'),
        ];

        final state = AchievementState.fromInputs(
          validatedEvents: events,
          capturedCount: 0,
        );

        expect(state.totalValidatedMissions, 2);
      },
    );

    test(
      'duplicate (missionId, missionDate) pairs count kgFreed only once',
      () {
        final events = <MissionValidatedEvent>[
          event(id: 'e1', missionId: 'm1', missionDate: '2026-06-10'),
          event(
            id: 'e2',
            missionId: 'm1',
            missionDate: '2026-06-10',
          ), // duplicate — should not double kg
        ];

        final state = AchievementState.fromInputs(
          validatedEvents: events,
          capturedCount: 0,
        );

        expect(state.totalKgFreed, 5); // single event's kgFreed, not doubled
      },
    );

    test(
      'different missionDate with same missionId counts as separate missions',
      () {
        final events = <MissionValidatedEvent>[
          event(id: 'e1', missionId: 'm1', missionDate: '2026-06-10'),
          event(
            id: 'e2',
            missionId: 'm1',
            missionDate: '2026-06-11',
          ), // different date = different key
        ];

        final state = AchievementState.fromInputs(
          validatedEvents: events,
          capturedCount: 0,
        );

        expect(state.totalValidatedMissions, 2);
        expect(state.totalKgFreed, 10);
      },
    );
  });

  group('AchievementState.fromInputs — derived from validated + captured inputs', () {
    test('derives all unlock conditions correctly from mixed inputs', () {
      // 10 events × 5 kg = 50 kg, 100 captures → 3 achievements unlocked (not streak)
      final events = List.generate(
        10,
        (i) => event(
          id: 'e$i',
          missionId: 'm$i',
          missionDate:
              '2026-0${(i ~/ 30) + 1}-${(i % 28 + 1).toString().padLeft(2, '0')}',
        ),
      );

      final state = AchievementState.fromInputs(
        validatedEvents: events,
        capturedCount: 100,
      );

      expect(state.isUnlocked(Achievement.firstVictory), isTrue);
      expect(state.isUnlocked(Achievement.tenKgFreed), isTrue);
      expect(state.isUnlocked(Achievement.hundredPreoccupations), isTrue);
      // thirtyDayStreak: streak is 0 since dates are in the past with a gap
      expect(state.isUnlocked(Achievement.thirtyDayStreak), isFalse);
    });

    test(
      'capturedCount drives hundredPreoccupations independently of validated events',
      () {
        // No validated events → other achievements stay locked, captured drives its own
        final state99 = AchievementState.fromInputs(
          validatedEvents: [],
          capturedCount: 99,
        );
        final state100 = AchievementState.fromInputs(
          validatedEvents: [],
          capturedCount: 100,
        );

        expect(state99.isUnlocked(Achievement.hundredPreoccupations), isFalse);
        expect(state100.isUnlocked(Achievement.hundredPreoccupations), isTrue);
        // validated-based achievements stay locked
        expect(state100.isUnlocked(Achievement.firstVictory), isFalse);
      },
    );

    test('totalCapturedPreoccupations equals capturedCount input', () {
      final state = AchievementState.fromInputs(
        validatedEvents: [],
        capturedCount: 42,
      );
      expect(state.totalCapturedPreoccupations, 42);
    });
  });
}
