import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:mindow/core/sync/domain_event.dart';

/// Lifecycle of a record in the local outbox.
///
/// `local` → freshly appended, not yet pushed; `sent` → handed to the backend
/// but not yet acknowledged; `acked` → the backend confirmed receipt and
/// stamped a `received_at`. The Hive outbox is the offline-first local source
/// of truth (NFR-3).
enum OutboxState {
  /// Appended locally, not yet pushed to the backend.
  local,

  /// Pushed to the backend, awaiting acknowledgement.
  sent,

  /// Acknowledged by the backend (carries a `received_at`).
  acked,
}

/// A single persisted entry in the local event outbox.
///
/// Flattens an [EventEnvelope] (with the `payloadJson` stored as an encoded
/// JSON string for storage stability) plus the outbox [state]. Business-agnostic:
/// it never references any concrete feature event type.
class OutboxRecord {
  const OutboxRecord({
    required this.eventId,
    required this.aggregateId,
    required this.eventType,
    required this.schemaVersion,
    required this.createdAt,
    required this.payloadJson,
    this.state = OutboxState.local,
    this.receivedAt,
  });

  /// Globally unique id for this event (also the outbox key).
  final String eventId;

  /// Id of the aggregate this event mutates.
  final String aggregateId;

  /// Stable `event_type` discriminator.
  final String eventType;

  /// Envelope schema version at the time of persistence.
  final int schemaVersion;

  /// Client creation time, UTC.
  final DateTime createdAt;

  /// The event-specific payload, JSON-encoded for storage stability.
  final String payloadJson;

  /// The outbox lifecycle state.
  final OutboxState state;

  /// Server receipt time, UTC, or `null` until acknowledged.
  final DateTime? receivedAt;

  /// Rebuilds the in-memory [EventEnvelope] (decoding [payloadJson]).
  EventEnvelope toEnvelope() => EventEnvelope(
    eventId: eventId,
    aggregateId: aggregateId,
    eventType: eventType,
    schemaVersion: schemaVersion,
    createdAt: createdAt,
    receivedAt: receivedAt,
    payload: Map<String, dynamic>.from(jsonDecode(payloadJson) as Map),
  );

  /// Returns a copy with the lifecycle fields replaced.
  OutboxRecord copyWith({OutboxState? state, DateTime? receivedAt}) =>
      OutboxRecord(
        eventId: eventId,
        aggregateId: aggregateId,
        eventType: eventType,
        schemaVersion: schemaVersion,
        createdAt: createdAt,
        payloadJson: payloadJson,
        state: state ?? this.state,
        receivedAt: receivedAt ?? this.receivedAt,
      );
}

/// The append-only local event outbox, backed by a Hive box keyed by
/// `event_id`.
///
/// The box is injected so it can be opened in bootstrap for the app and in a
/// temporary directory for tests. Keying by `event_id` makes [append]
/// idempotent for free.
class EventStore {
  /// Creates a store over an already-open `box`.
  const EventStore(this._box);

  final Box<OutboxRecord> _box;

  /// Appends [event] as a `local` record.
  ///
  /// Idempotent: appending an already-present `event_id` is a no-op, so a
  /// retried emit never duplicates the log.
  Future<void> append(DomainEvent event) async {
    if (_box.containsKey(event.eventId)) return;
    await _box.put(
      event.eventId,
      OutboxRecord(
        eventId: event.eventId,
        aggregateId: event.aggregateId,
        eventType: event.eventType,
        schemaVersion: event.schemaVersion,
        createdAt: event.occurredAt.toUtc(),
        payloadJson: jsonEncode(event.toJson()),
      ),
    );
  }

  /// Marks the record as `sent`. No-op if the id is unknown.
  Future<void> markSent(String eventId) async {
    final record = _box.get(eventId);
    if (record == null) return;
    await _box.put(eventId, record.copyWith(state: OutboxState.sent));
  }

  /// Marks the record as `acked` and stamps the server [receivedAt]. No-op if
  /// the id is unknown.
  Future<void> markAcked(String eventId, DateTime receivedAt) async {
    final record = _box.get(eventId);
    if (record == null) return;
    await _box.put(
      eventId,
      record.copyWith(state: OutboxState.acked, receivedAt: receivedAt.toUtc()),
    );
  }

  /// All records currently in the outbox.
  List<OutboxRecord> all() => _box.values.toList(growable: false);

  /// Records not yet acknowledged by the backend (`local` or `sent`).
  List<OutboxRecord> pending() => _box.values
      .where((r) => r.state != OutboxState.acked)
      .toList(growable: false);
}
