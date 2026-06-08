import 'package:mindow/core/sync/domain_event.dart';

/// Emitted when the user edits the content of an existing Preoccupation (FR-5).
///
/// Carries the trimmed new [content]. The projection reducer folds this onto
/// the existing aggregate entry (preserving any already-assigned Mental Weight
/// and category — they are NOT cleared; re-analysis, if triggered, will emit a
/// fresh `weight.assigned` that supersedes via latest-wins). An orphan update
/// event (no prior `preoccupation.captured` for the same aggregate) is silently
/// ignored by the reducer (defensive guard, same pattern as `WeightAssignedEvent`).
///
/// If the trimmed new content differs from the original, the call site triggers
/// AI re-analysis asynchronously (debounced by content-equality; NFR-11 cost
/// guardrail). Empty or whitespace-only content is rejected before the event is
/// emitted.
///
/// Lives under `features/` so `core/sync` stays business-agnostic.
class PreoccupationUpdatedEvent extends DomainEvent {
  /// Creates an update event carrying [content] for aggregate [aggregateId].
  const PreoccupationUpdatedEvent({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    required this.content,
    super.schemaVersion,
  });

  /// The stable `event_type` discriminator (`domain.action`, past tense).
  static const String type = 'preoccupation.updated';

  /// The trimmed new content of the Preoccupation.
  final String content;

  @override
  String get eventType => type;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'content': content};
}

/// Decodes a [PreoccupationUpdatedEvent] from its stored [EventEnvelope].
///
/// Registered with the app's [DomainEventRegistry] so the replay engine can
/// turn persisted envelopes back into typed events for projection reducers.
DomainEvent decodePreoccupationUpdated(EventEnvelope envelope) =>
    PreoccupationUpdatedEvent(
      eventId: envelope.eventId,
      aggregateId: envelope.aggregateId,
      occurredAt: envelope.createdAt,
      content: envelope.payload['content'] as String,
      schemaVersion: envelope.schemaVersion,
    );
