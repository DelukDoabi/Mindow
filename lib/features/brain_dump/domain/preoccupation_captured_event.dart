import 'package:mindow/core/sync/domain_event.dart';

/// Emitted when the user captures a new Preoccupation (FR-4).
///
/// This is the first real feature [DomainEvent]: a worry the user puts down.
/// It carries only the raw [content]; the AI-derived Mental Weight and Category
/// are assigned later (Story 2.3) via separate events, so capture never blocks
/// on analysis (NFR-2). The [aggregateId] IS the preoccupation id — a single
/// client-generated UUID v4 reused as the [eventId] for the first event in the
/// aggregate's life.
///
/// Lives under `features/` (never in `core/sync`) so the engine stays
/// business-agnostic.
class PreoccupationCapturedEvent extends DomainEvent {
  /// Creates a capture event for [content] on aggregate [aggregateId].
  const PreoccupationCapturedEvent({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    required this.content,
    super.schemaVersion,
  });

  /// The stable `event_type` discriminator (`domain.action`, past tense).
  static const String type = 'preoccupation.captured';

  /// The raw worry text the user typed.
  final String content;

  @override
  String get eventType => type;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'content': content};
}

/// Decodes a [PreoccupationCapturedEvent] from its stored [EventEnvelope].
///
/// Registered with the app's [DomainEventRegistry] so the replay engine can
/// turn persisted envelopes back into typed events for projection reducers.
DomainEvent decodePreoccupationCaptured(EventEnvelope envelope) =>
    PreoccupationCapturedEvent(
      eventId: envelope.eventId,
      aggregateId: envelope.aggregateId,
      occurredAt: envelope.createdAt,
      content: envelope.payload['content'] as String,
      schemaVersion: envelope.schemaVersion,
    );
