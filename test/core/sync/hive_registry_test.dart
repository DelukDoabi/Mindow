import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/hive_registry.dart';

/// The CI gate for offline data integrity.
///
/// Hive persists each adapter's `typeId` inside every box, so a duplicated or
/// reused id silently corrupts existing user data on upgrade. These tests fail
/// the build before such a change can merge.
void main() {
  group('HiveRegistry', () {
    const registrations = HiveRegistry.registrations;

    test('typeIds are unique', () {
      final ids = registrations.map((r) => r.typeId).toList();
      final unique = ids.toSet();
      expect(
        unique.length,
        ids.length,
        reason:
            'Duplicate Hive typeId detected — reusing an id corrupts '
            'persisted boxes. typeIds must be unique and append-only.',
      );
    });

    test('adapter names are unique', () {
      final names = registrations.map((r) => r.name).toList();
      expect(
        names.toSet().length,
        names.length,
        reason: 'Duplicate adapter name in the Hive registry.',
      );
    });

    test('typeIds respect the reserved range (>= firstAvailableTypeId)', () {
      for (final r in registrations) {
        expect(
          r.typeId,
          greaterThanOrEqualTo(HiveRegistry.firstAvailableTypeId),
          reason:
              'typeId ${r.typeId} (${r.name}) uses a reserved id; '
              'application ids start at ${HiveRegistry.firstAvailableTypeId}.',
        );
      }
    });
  });
}
