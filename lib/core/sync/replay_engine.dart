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
///     events sort AFTER all received ones; ties break by `created_at`
///     (event occurrence time); final tiebreaker is `event_id`
///     lexicographically. This ensures causal events (delete, update) issued
///     after a capture always replay in correct order even when all events are
///     still local.
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

  /// Orders by `received_at` (nulls last), tie-break by `created_at` (event
  /// occurrence time), then by `event_id` as a final deterministic tiebreaker.
  ///
  /// Using `created_at` before `event_id` ensures that causal events (delete,
  /// update) issued after a capture are always replayed in the correct order,
  /// even when all events are still local (null `received_at`) and random UUID
  /// v4 ids are used as `event_id`.
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
    final byCreatedAt = a.createdAt.compareTo(b.createdAt);
    if (byCreatedAt != 0) return byCreatedAt;
    return a.eventId.compareTo(b.eventId);
  }
}
