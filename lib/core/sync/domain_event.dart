/// Base contract for every event in the event-sourced sync engine (Epic 2).
///
/// Events are immutable facts. They carry a [schemaVersion] so older persisted
/// events can be upcast as the model evolves. Concrete events are defined per
/// feature and registered with the sync engine; this base only fixes the
/// envelope shape that the engine and reducers depend on.
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
  final String aggregateId;

  /// Wall-clock time the event was created on the originating device (UTC).
  final DateTime occurredAt;

  /// Envelope schema version, used for upcasting persisted events.
  final int schemaVersion;

  /// Stable discriminator used for (de)serialization and routing.
  String get eventType;

  /// Serializes the event payload for persistence and transport.
  Map<String, dynamic> toJson();
}
