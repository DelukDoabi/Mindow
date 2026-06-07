import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/replay_engine.dart';
import 'package:mindow/core/sync/upcasters/upcaster_registry.dart';

import 'support/counter_event.dart';

/// Root directory holding versioned fixture folders (`v1/`, `v2/`, ...).
/// `flutter test` runs with the package root as the working directory.
const String _fixturesRoot = 'test/core/sync/fixtures';

/// A single convergence fixture loaded from disk.
class _Fixture {
  _Fixture({
    required this.name,
    required this.schemaVersion,
    required this.envelopes,
    required this.expected,
  });

  final String name;
  final int schemaVersion;
  final List<EventEnvelope> envelopes;
  final int expected;
}

List<_Fixture> _loadFixtures(int version) {
  final dir = Directory('$_fixturesRoot/v$version');
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  return files.map((file) {
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final events = (json['events'] as List<dynamic>)
        .map((e) => EventEnvelope.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return _Fixture(
      name: file.uri.pathSegments.last,
      schemaVersion: (json['schema_version'] as num).toInt(),
      envelopes: events,
      expected: (json['expected'] as num).toInt(),
    );
  }).toList();
}

int _replay(List<EventEnvelope> envelopes) {
  const engine = ReplayEngine();
  return engine.replay<int>(
    initialState: 0,
    envelopes: envelopes,
    registry: counterRegistry(),
    reducer: counterReducer,
  );
}

void main() {
  group('convergence harness', () {
    test('every supported schema version has at least one fixture', () {
      for (final version in supportedSchemaVersions) {
        final dir = Directory('$_fixturesRoot/v$version');
        expect(
          dir.existsSync(),
          isTrue,
          reason: 'Missing fixture directory $_fixturesRoot/v$version',
        );
        final jsonFiles = dir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.json'),
        );
        expect(
          jsonFiles,
          isNotEmpty,
          reason: 'No .json fixtures in $_fixturesRoot/v$version',
        );
      }
    });

    for (final version in supportedSchemaVersions) {
      for (final fixture in _loadFixtures(version)) {
        group('v$version / ${fixture.name}', () {
          test('replays to the expected projection', () {
            expect(_replay(fixture.envelopes), fixture.expected);
          });

          test('is idempotent under duplicated events', () {
            final duplicated = [...fixture.envelopes, ...fixture.envelopes];
            expect(_replay(duplicated), fixture.expected);
          });

          test('is order-independent', () {
            final shuffled = [...fixture.envelopes]..shuffle();
            expect(_replay(shuffled), fixture.expected);
          });
        });
      }
    }
  });
}
