import 'package:mindow/core/sync/domain_event.dart';

/// Emitted when a Daily Mission is validated as done.
class MissionValidatedEvent extends DomainEvent {
  const MissionValidatedEvent({
    required super.eventId,
    required super.aggregateId,
    required super.occurredAt,
    required this.missionId,
    required this.missionDate,
    required this.kgFreed,
    required this.timeInvestedMinutes,
    super.schemaVersion,
  });

  /// Stable event discriminator.
  static const String type = 'mission.validated';

  final String missionId;
  final String missionDate;
  final int kgFreed;
  final int timeInvestedMinutes;

  @override
  String get eventType => type;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'mission_id': missionId,
    'mission_date': missionDate,
    'kg_freed': kgFreed,
    'time_invested_minutes': timeInvestedMinutes,
  };
}

String missionValidationKey({
  required String missionId,
  required String missionDate,
}) => '$missionId::$missionDate';

DomainEvent decodeMissionValidated(EventEnvelope envelope) =>
    MissionValidatedEvent(
      eventId: envelope.eventId,
      aggregateId: envelope.aggregateId,
      occurredAt: envelope.createdAt,
      missionId: envelope.payload['mission_id'] as String,
      missionDate: envelope.payload['mission_date'] as String,
      kgFreed: (envelope.payload['kg_freed'] as num).toInt(),
      timeInvestedMinutes: (envelope.payload['time_invested_minutes'] as num)
          .toInt(),
      schemaVersion: envelope.schemaVersion,
    );
