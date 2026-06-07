import 'package:mindow/core/sync/domain_event.dart';

/// The schema version the engine currently reduces against.
///
/// Every persisted event with a lower `schema_version` is upcast to this
/// version at read/replay time. Bump this when the envelope/payload contract
/// changes, register the `vN → vN+1` [Upcaster], and add a matching
/// `test/core/sync/fixtures/v{N}/` directory (enforced by the convergence
/// gate).
const int currentSchemaVersion = 1;

/// All schema versions the engine must be able to read, oldest first.
List<int> get supportedSchemaVersions =>
    List<int>.generate(currentSchemaVersion, (i) => i + 1);

/// A pure transform that migrates an envelope from one schema version to the
/// next (`vN → vN+1`). It must NOT mutate stored history — upcasting happens
/// only on the way into the reducer.
typedef Upcaster = EventEnvelope Function(EventEnvelope envelope);

/// Applies `vN → vN+1` upcasters until an envelope reaches
/// [currentSchemaVersion].
///
/// The append-only event log is immutable; upcasting is read-only and produces
/// a transient, up-to-date envelope for the reducer.
class UpcasterRegistry {
  /// Creates a registry from a map of `sourceVersion → upcaster`.
  const UpcasterRegistry(this._upcasters);

  /// A registry with no upcasters (valid while only one schema version
  /// exists).
  const UpcasterRegistry.empty() : _upcasters = const <int, Upcaster>{};

  /// Keyed by the source `schema_version`: `v → (v → v+1)`.
  final Map<int, Upcaster> _upcasters;

  /// Upcasts [envelope] up to [currentSchemaVersion].
  ///
  /// Throws a [StateError] if a step is missing or an upcaster fails to advance
  /// the version — both are programming errors that must fail loudly.
  EventEnvelope upcast(EventEnvelope envelope) {
    var current = envelope;
    while (current.schemaVersion < currentSchemaVersion) {
      final from = current.schemaVersion;
      final upcaster = _upcasters[from];
      if (upcaster == null) {
        throw StateError('No upcaster registered from schema v$from.');
      }
      final next = upcaster(current);
      if (next.schemaVersion <= from) {
        throw StateError(
          'Upcaster from schema v$from did not advance the version.',
        );
      }
      current = next;
    }
    return current;
  }
}
