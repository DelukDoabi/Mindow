import 'package:mindow/core/sync/domain_event.dart';

/// Emitted when AI Analysis assigns a Mental Weight to a Preoccupation (FR-6).
///
/// This is the second event in a Preoccupation's life: it carries the
/// AI-derived (or fallback) Category, Mental Weight in kg, Effort Score, and
/// Estimated Duration. The [aggregateId] IS the Preoccupation id (the same
/// aggregate as `preoccupation.captured`), so the projection folds it onto the
/// already-captured item.
///
/// The weight is FROZEN and VERSIONED: re-running analysis emits a fresh event
/// (carrying its own [eventId] and [weightModelVersion]) rather than rewriting
/// the log, keeping the North Star comparable over time (architecture
/// principles 1 & 3). Lives under `features/` so `core/sync` stays
/// business-agnostic.
class WeightAssignedEvent extends DomainEvent {
  /// Creates a weight-assignment event for aggregate [aggregateId].
  const WeightAssignedEvent({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    required this.mentalWeightKg,
    required this.category,
    required this.effortScore,
    required this.estimatedDurationMinutes,
    required this.weightModelVersion,
    super.schemaVersion,
  });

  /// The stable `event_type` discriminator (`domain.action`, past tense).
  static const String type = 'weight.assigned';

  /// The assigned Mental Weight in kilograms (integer, 1-20).
  final int mentalWeightKg;

  /// The assigned Category (one of the fixed nine).
  final String category;

  /// The assigned Effort Score (integer, 1-5).
  final int effortScore;

  /// The estimated time to resolve the Preoccupation, in minutes.
  final int estimatedDurationMinutes;

  /// Identifies the prompt/model that produced this weight, so weights stay
  /// comparable as the model evolves (or marks a `fallback-vN` floor).
  final String weightModelVersion;

  @override
  String get eventType => type;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'mental_weight_kg': mentalWeightKg,
    'category': category,
    'effort_score': effortScore,
    'estimated_duration_minutes': estimatedDurationMinutes,
    'weight_model_version': weightModelVersion,
  };
}

/// Decodes a [WeightAssignedEvent] from its stored [EventEnvelope].
///
/// Registered with the app's [DomainEventRegistry] so the replay engine can
/// turn persisted envelopes back into typed events for projection reducers.
DomainEvent decodeWeightAssigned(EventEnvelope envelope) => WeightAssignedEvent(
  eventId: envelope.eventId,
  aggregateId: envelope.aggregateId,
  occurredAt: envelope.createdAt,
  mentalWeightKg: (envelope.payload['mental_weight_kg'] as num).toInt(),
  category: envelope.payload['category'] as String,
  effortScore: (envelope.payload['effort_score'] as num).toInt(),
  estimatedDurationMinutes:
      (envelope.payload['estimated_duration_minutes'] as num).toInt(),
  weightModelVersion: envelope.payload['weight_model_version'] as String,
  schemaVersion: envelope.schemaVersion,
);
