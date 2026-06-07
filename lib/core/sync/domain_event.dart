/// Base contract and serialization envelope for the event-sourced sync engine
/// (Epic 2).
///
/// Events are immutable facts. They carry a `schemaVersion` so older persisted
/// events can be upcast as the model evolves. Concrete events are defined per
/// feature and registered with the sync engine; this file only fixes the
/// envelope shape that the engine, the outbox, and reducers depend on.
///
/// Wire/persistence format is snake_case (see [eventEnvelopeKeys]); the Dart
/// side is camelCase. The shared TypeScript contract
/// `supabase/functions/_shared/events.ts` MUST stay in parity with
/// [eventEnvelopeKeys] (guarded by `event_contract_parity_test.dart`).
library;

/// Base contract for every event in the event-sourced sync engine.
abstract class DomainEvent {
  const DomainEvent({
    required this.eventId,
    required this.aggregateId,
    required this.occurredAt,
    this.schemaVersion = 1,
  });

  /// Globally unique id for this event (idempotency key for sync).
  final String eventId;

  /// Id of the aggregate this event mutates.
  ///
  /// On the wire this maps to `aggregate_id`. The authoritative `user_id` is
  /// NOT part of this client envelope — the backend derives it from the
  /// authenticated JWT and stamps it alongside `received_at` on insert.
  final String aggregateId;

  /// Wall-clock time the event was created on the originating device (UTC).
  ///
  /// On the wire this maps to `created_at`.
  final DateTime occurredAt;

  /// Envelope schema version, used for upcasting persisted events.
  final int schemaVersion;

  /// Stable discriminator used for (de)serialization and routing.
  String get eventType;

  /// Serializes the event-specific payload for persistence and transport.
  Map<String, dynamic> toJson();

  /// Wraps this event in a serializable [EventEnvelope].
  ///
  /// [receivedAt] is the server-assigned receipt time; it is `null` until the
  /// backend has acknowledged the event.
  EventEnvelope toEnvelope({DateTime? receivedAt}) => EventEnvelope(
    eventId: eventId,
    aggregateId: aggregateId,
    eventType: eventType,
    schemaVersion: schemaVersion,
    createdAt: occurredAt.toUtc(),
    payload: toJson(),
    receivedAt: receivedAt,
  );
}

/// The canonical, ordered set of envelope keys on the wire (snake_case).
///
/// This is the single source of truth the parity test compares against
/// `supabase/functions/_shared/events.ts`.
const List<String> eventEnvelopeKeys = <String>[
  'event_id',
  'aggregate_id',
  'event_type',
  'schema_version',
  'created_at',
  'received_at',
  'payload',
];

/// The serializable, business-agnostic envelope around a [DomainEvent].
///
/// This is the currency the replay engine and the outbox operate on: it carries
/// the routing metadata ([eventType], [schemaVersion]) plus the raw [payload],
/// so the engine never needs to know any concrete feature event type.
class EventEnvelope {
  const EventEnvelope({
    required this.eventId,
    required this.aggregateId,
    required this.eventType,
    required this.schemaVersion,
    required this.createdAt,
    required this.payload,
    this.receivedAt,
  });

  /// Reconstructs an envelope from its wire/persistence JSON form.
  factory EventEnvelope.fromJson(Map<String, dynamic> json) => EventEnvelope(
    eventId: json['event_id'] as String,
    aggregateId: json['aggregate_id'] as String,
    eventType: json['event_type'] as String,
    schemaVersion: (json['schema_version'] as num).toInt(),
    createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    receivedAt: json['received_at'] == null
        ? null
        : DateTime.parse(json['received_at'] as String).toUtc(),
    payload: Map<String, dynamic>.from(json['payload'] as Map),
  );

  /// Globally unique id for this event (idempotency key).
  final String eventId;

  /// Id of the aggregate this event mutates (`aggregate_id` on the wire).
  final String aggregateId;

  /// Stable discriminator used for routing/decoding.
  final String eventType;

  /// Envelope schema version, used for upcasting.
  final int schemaVersion;

  /// Client creation time, UTC (`created_at` on the wire).
  final DateTime createdAt;

  /// Server receipt time, UTC, or `null` until acknowledged
  /// (`received_at` on the wire).
  final DateTime? receivedAt;

  /// The event-specific payload (a [DomainEvent.toJson] map).
  final Map<String, dynamic> payload;

  /// Serializes to the snake_case wire/persistence form (see
  /// [eventEnvelopeKeys]).
  Map<String, dynamic> toJson() => <String, dynamic>{
    'event_id': eventId,
    'aggregate_id': aggregateId,
    'event_type': eventType,
    'schema_version': schemaVersion,
    'created_at': createdAt.toUtc().toIso8601String(),
    'received_at': receivedAt?.toUtc().toIso8601String(),
    'payload': payload,
  };

  /// Returns a copy with selected fields replaced (used by upcasters).
  EventEnvelope copyWith({
    int? schemaVersion,
    Map<String, dynamic>? payload,
    DateTime? receivedAt,
  }) => EventEnvelope(
    eventId: eventId,
    aggregateId: aggregateId,
    eventType: eventType,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    createdAt: createdAt,
    payload: payload ?? this.payload,
    receivedAt: receivedAt ?? this.receivedAt,
  );
}

/// Decodes an [EventEnvelope] back into a concrete [DomainEvent].
typedef DomainEventDecoder = DomainEvent Function(EventEnvelope envelope);

/// Maps `event_type` discriminators to their concrete [DomainEvent] decoders.
///
/// The registry itself is business-agnostic; concrete feature events register
/// their decoders here (in later stories). The replay engine uses it to turn
/// stored envelopes back into typed events for the reducer.
class DomainEventRegistry {
  /// Creates an empty registry.
  DomainEventRegistry();

  final Map<String, DomainEventDecoder> _decoders =
      <String, DomainEventDecoder>{};

  /// Registers [decoder] for the given [eventType].
  void register(String eventType, DomainEventDecoder decoder) {
    _decoders[eventType] = decoder;
  }

  /// Whether a decoder is registered for [eventType].
  bool isRegistered(String eventType) => _decoders.containsKey(eventType);

  /// Decodes [envelope] into a [DomainEvent].
  ///
  /// Throws a [StateError] if no decoder is registered for the envelope's
  /// `event_type` — a programming error (a feature forgot to register).
  DomainEvent decode(EventEnvelope envelope) {
    final decoder = _decoders[envelope.eventType];
    if (decoder == null) {
      throw StateError(
        'No DomainEvent decoder registered for "${envelope.eventType}".',
      );
    }
    return decoder(envelope);
  }
}
