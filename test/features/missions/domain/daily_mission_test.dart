import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/missions/domain/daily_mission.dart';

Preoccupation _item({
  required String id,
  required int? kg,
  required DateTime createdAt,
  int? duration,
}) => Preoccupation(
  id: id,
  content: id,
  createdAt: createdAt,
  mentalWeightKg: kg,
  estimatedDurationMinutes: duration,
);

void main() {
  group('selectDailyMissionCandidate', () {
    test('returns null when no candidate has a weight', () {
      final selected = selectDailyMissionCandidate(<Preoccupation>[
        _item(id: 'a', kg: null, createdAt: DateTime.utc(2026, 6)),
      ]);

      expect(selected, isNull);
    });

    test('prefers highest mental weight', () {
      final selected = selectDailyMissionCandidate(<Preoccupation>[
        _item(id: 'a', kg: 3, createdAt: DateTime.utc(2026, 6)),
        _item(id: 'b', kg: 7, createdAt: DateTime.utc(2026, 6)),
      ]);

      expect(selected?.id, 'b');
    });

    test('breaks ties by shortest duration then oldest creation then id', () {
      final selected = selectDailyMissionCandidate(<Preoccupation>[
        _item(
          id: 'z',
          kg: 8,
          duration: 30,
          createdAt: DateTime.utc(2026, 6, 3),
        ),
        _item(
          id: 'a',
          kg: 8,
          duration: 20,
          createdAt: DateTime.utc(2026, 6, 4),
        ),
        _item(
          id: 'b',
          kg: 8,
          duration: 20,
          createdAt: DateTime.utc(2026, 6, 2),
        ),
        _item(
          id: 'c',
          kg: 8,
          duration: 20,
          createdAt: DateTime.utc(2026, 6, 2),
        ),
      ]);

      expect(selected?.id, 'b');
    });
  });
}
