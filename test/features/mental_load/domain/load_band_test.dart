import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/mental_load/domain/load_band.dart';

void main() {
  group('LoadBand.fromKg', () {
    test('0 kg → leger', () => expect(LoadBand.fromKg(0), LoadBand.leger));
    test('1 kg → leger', () => expect(LoadBand.fromKg(1), LoadBand.leger));
    test('19 kg → leger', () => expect(LoadBand.fromKg(19), LoadBand.leger));
    test('20 kg → modere', () => expect(LoadBand.fromKg(20), LoadBand.modere));
    test('35 kg → modere', () => expect(LoadBand.fromKg(35), LoadBand.modere));
    test('49 kg → modere', () => expect(LoadBand.fromKg(49), LoadBand.modere));
    test('50 kg → lourd', () => expect(LoadBand.fromKg(50), LoadBand.lourd));
    test('65 kg → lourd', () => expect(LoadBand.fromKg(65), LoadBand.lourd));
    test('79 kg → lourd', () => expect(LoadBand.fromKg(79), LoadBand.lourd));
    test(
      '80 kg → tresLourd',
      () => expect(LoadBand.fromKg(80), LoadBand.tresLourd),
    );
    test(
      '200 kg → tresLourd',
      () => expect(LoadBand.fromKg(200), LoadBand.tresLourd),
    );
  });

  group('LoadBand.animationValue', () {
    test('leger → 0.0', () => expect(LoadBand.leger.animationValue, 0.0));
    test('modere → 1.0', () => expect(LoadBand.modere.animationValue, 1.0));
    test('lourd → 2.0', () => expect(LoadBand.lourd.animationValue, 2.0));
    test(
      'tresLourd → 3.0',
      () => expect(LoadBand.tresLourd.animationValue, 3.0),
    );
  });
}
