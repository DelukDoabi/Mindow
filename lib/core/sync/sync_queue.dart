import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/reconciliation_client.dart';

// Collaborators are kept in private fields; named parameters cannot be private
// initializing formals, so they are assigned in the initializer list.
// ignore_for_file: prefer_initializing_formals

/// Returns the current time. Injected so tests control time deterministically.
typedef Clock = DateTime Function();

/// The default wall clock, in UTC (the engine's canonical time zone).
DateTime systemUtcClock() => DateTime.now().toUtc();

/// Mediates between event producers and the local [EventStore], and pushes the
/// outbox to the backend when a [ReconciliationClient] is wired.
///
/// The [Clock] is injectable so ordering and acknowledgement timestamps are
/// deterministic under test. The transport is optional: with no client the
/// queue is a pure local outbox (offline-first / scaffold builds), and
/// [flush] is a no-op.
class SyncQueue {
  /// Creates a queue over [store], optionally with a [client] transport and a
  /// custom [clock].
  SyncQueue({
    required EventStore store,
    ReconciliationClient? client,
    Clock clock = systemUtcClock,
  }) : _store = store,
       _client = client,
       _clock = clock;

  final EventStore _store;
  final ReconciliationClient? _client;
  final Clock _clock;

  /// Appends [event] to the local outbox (idempotent by `event_id`).
  Future<void> enqueue(DomainEvent event) => _store.append(event);

  /// Pushes all not-yet-acked records to the backend and records their
  /// server-assigned `received_at`.
  ///
  /// No-op when no [ReconciliationClient] is wired. Records the server does not
  /// acknowledge fall back to the injected [Clock] so local ordering can still
  /// proceed; the authoritative timestamp is reconciled on the next push.
  Future<void> flush() async {
    final client = _client;
    if (client == null) return;

    final pending = _store.pending();
    if (pending.isEmpty) return;

    for (final record in pending) {
      await _store.markSent(record.eventId);
    }

    final acks = await client.push(pending);
    for (final record in pending) {
      await _store.markAcked(record.eventId, acks[record.eventId] ?? _clock());
    }
  }
}
