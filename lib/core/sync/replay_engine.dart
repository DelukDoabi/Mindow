import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/upcasters/upcaster_registry.dart';

/// Folds a [DomainEvent] into projection state of type [S].
///
/// Reducers are pure and business-agnostic from the engine's point of view —
/// every derived projection (load, streak, level, garden) is built by passing
/// its own reducer to [ReplayEngine.replay].
typedef EventReducer<S> = S Function(S state, DomainEvent event);

/// Replays a set of [EventEnvelope]s into projection state, deterministically.
///
/// Guarantees (NFR / AC-2):
///   * **Ordering** — by `received_at` ascending; not-yet-received (`null`)
///     events sort AFTER all received ones; ties (and the local tail) break by
///     `event_id` lexicographically. This makes replay order-independent of the
///     input sequence.
///   * **Idempotency** — a duplicated `event_id` is applied exactly once;
///     re-running the whole replay yields the same state.
///   * **Schema** — each envelope is upcast to [currentSchemaVersion] before it
///     is decoded and reduced.
class ReplayEngine {
  /// Creates an engine; pass an [UpcasterRegistry] once multiple schema
  /// versions exist.
  const ReplayEngine({this.upcasters = const UpcasterRegistry.empty()});

  /// Read-time schema migrations applied before decoding.
  final UpcasterRegistry upcasters;

  /// Replays [envelopes] from [initialState] using [registry] to decode and
  /// [reducer] to fold.
  S replay<S>({
    required S initialState,
    required Iterable<EventEnvelope> envelopes,
    required DomainEventRegistry registry,
    required EventReducer<S> reducer,
  }) {
    final ordered = envelopes.toList()..sort(_compare);
    final seen = <String>{};
    var state = initialState;
    for (final envelope in ordered) {
      if (!seen.add(envelope.eventId)) continue;
      final upcast = upcasters.upcast(envelope);
      state = reducer(state, registry.decode(upcast));
    }
    return state;
  }

  /// Orders by `received_at` (nulls last), tie-break by `event_id`.
  static int _compare(EventEnvelope a, EventEnvelope b) {
    final ra = a.receivedAt;
    final rb = b.receivedAt;
    if (ra != null && rb != null) {
      final byTime = ra.compareTo(rb);
      if (byTime != 0) return byTime;
    } else if (ra == null && rb != null) {
      return 1;
    } else if (ra != null && rb == null) {
      return -1;
    }
    return a.eventId.compareTo(b.eventId);
  }
}
