import 'package:mindow/core/sync/domain_event.dart';

/// Emitted when the user deletes an existing Preoccupation (FR-5).
///
/// This is a pure tombstone event: it carries no payload beyond the aggregate
/// id, which is sufficient to remove the entry from the open-preoccupations
/// projection. Appended to the local outbox immediately (offline-first, NFR-3);
/// the item disappears from the list the moment the projection is rebuilt.
///
/// Architecture note: `preoccupation.deleted` is an explicitly named event type
/// in the event vocabulary (architecture.md#Naming Patterns). The Mental Weight
/// of the deleted item is no longer included in the Mental Load (FR-5) because
/// the projection reducer removes the aggregate entry entirely.
///
/// Lives under `features/` so `core/sync` stays business-agnostic (Story 2.1
/// CI invariant).
class PreoccupationDeletedEvent extends DomainEvent {
  /// Creates a delete tombstone event for aggregate [aggregateId].
  const PreoccupationDeletedEvent({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    super.schemaVersion,
  });

  /// The stable `event_type` discriminator (`domain.action`, past tense).
  static const String type = 'preoccupation.deleted';

  @override
  String get eventType => type;

  /// No payload — the aggregate id alone is the tombstone signal.
  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};
}

/// Decodes a [PreoccupationDeletedEvent] from its stored [EventEnvelope].
///
/// Registered with the app's [DomainEventRegistry] so the replay engine can
/// turn persisted envelopes back into typed events for projection reducers.
DomainEvent decodePreoccupationDeleted(EventEnvelope envelope) =>
    PreoccupationDeletedEvent(
      eventId: envelope.eventId,
      aggregateId: envelope.aggregateId,
      occurredAt: envelope.createdAt,
      schemaVersion: envelope.schemaVersion,
    );
