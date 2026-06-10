import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/upcasters/upcaster_registry.dart';

void main() {
  group('UpcasterRegistry', () {
    test('throws when envelope schema is newer than engine schema', () {
      const registry = UpcasterRegistry.empty();
      final futureEnvelope = EventEnvelope(
        eventId: 'evt-1',
        aggregateId: 'agg-1',
        eventType: 'test.event',
        schemaVersion: currentSchemaVersion + 1,
        createdAt: DateTime.utc(2026),
        payload: const <String, dynamic>{'value': 1},
      );

      expect(
        () => registry.upcast(futureEnvelope),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('newer than current schema'),
          ),
        ),
      );
    });
  });
}
