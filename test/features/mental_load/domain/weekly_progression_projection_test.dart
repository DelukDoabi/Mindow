import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/mental_load/domain/weekly_progression_projection.dart';

void main() {
  group('WeeklyProgressionProjection', () {
    test('stores openCount and kgFreedThisWeek', () {
      const p = WeeklyProgressionProjection(openCount: 3, kgFreedThisWeek: 15);
      expect(p.openCount, 3);
      expect(p.kgFreedThisWeek, 15);
    });

    test('zero values are valid', () {
      const p = WeeklyProgressionProjection(openCount: 0, kgFreedThisWeek: 0);
      expect(p.openCount, 0);
      expect(p.kgFreedThisWeek, 0);
    });

    test('large values are stored as-is', () {
      const p = WeeklyProgressionProjection(
        openCount: 999,
        kgFreedThisWeek: 500,
      );
      expect(p.openCount, 999);
      expect(p.kgFreedThisWeek, 500);
    });
  });
}
