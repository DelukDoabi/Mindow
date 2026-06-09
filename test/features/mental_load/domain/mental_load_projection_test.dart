import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/mental_load/domain/mental_load_projection.dart';

Preoccupation _captured({
  required String id,
  int? weight,
}) => Preoccupation(
  id: id,
  content: 'test preoccupation $id',
  createdAt: DateTime.utc(2026, 6, 9),
  mentalWeightKg: weight,
);

void main() {
  group('MentalLoadProjection.fromPreoccupations', () {
    test('empty list → totalKg 0, hasPendingItems false', () {
      final p = MentalLoadProjection.fromPreoccupations([]);
      expect(p.totalKg, 0);
      expect(p.hasPendingItems, isFalse);
    });

    test('all pending → totalKg 0, hasPendingItems true', () {
      final p = MentalLoadProjection.fromPreoccupations([
        _captured(id: 'a'),
        _captured(id: 'b'),
      ]);
      expect(p.totalKg, 0);
      expect(p.hasPendingItems, isTrue);
    });

    test(
      'mixed pending + assigned → sum of assigned only; hasPendingItems true',
      () {
        final p = MentalLoadProjection.fromPreoccupations([
          _captured(id: 'a', weight: 10),
          _captured(id: 'b'),
          _captured(id: 'c', weight: 7),
        ]);
        expect(p.totalKg, 17);
        expect(p.hasPendingItems, isTrue);
      },
    );

    test('all assigned → full sum; hasPendingItems false', () {
      final p = MentalLoadProjection.fromPreoccupations([
        _captured(id: 'a', weight: 5),
        _captured(id: 'b', weight: 8),
        _captured(id: 'c', weight: 3),
      ]);
      expect(p.totalKg, 16);
      expect(p.hasPendingItems, isFalse);
    });

    test('zero-weight assigned item included in sum', () {
      final p = MentalLoadProjection.fromPreoccupations([
        _captured(id: 'a', weight: 0),
        _captured(id: 'b', weight: 4),
      ]);
      expect(p.totalKg, 4);
      expect(p.hasPendingItems, isFalse);
    });

    test('large total accumulates correctly', () {
      final items = List.generate(
        10,
        (i) => _captured(id: 'i$i', weight: 10),
      );
      final p = MentalLoadProjection.fromPreoccupations(items);
      expect(p.totalKg, 100);
      expect(p.hasPendingItems, isFalse);
    });
  });
}
