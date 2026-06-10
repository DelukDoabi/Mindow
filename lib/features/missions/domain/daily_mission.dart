import 'package:mindow/features/brain_dump/domain/preoccupation.dart';

/// A single recommended action for the current mission day.
class DailyMission {
  const DailyMission({
    required this.id,
    required this.preoccupationId,
    required this.preoccupationContent,
    required this.missionDate,
    required this.estimatedKgGain,
    required this.estimatedDurationMinutes,
    required this.createdAt,
  });

  factory DailyMission.fromJson(Map<String, dynamic> json) => DailyMission(
    id: json['id'] as String,
    preoccupationId: json['preoccupation_id'] as String,
    preoccupationContent: json['preoccupation_content'] as String,
    missionDate: json['mission_date'] as String,
    estimatedKgGain: (json['estimated_kg_gain'] as num).toInt(),
    estimatedDurationMinutes: (json['estimated_duration_minutes'] as num)
        .toInt(),
    createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
  );

  final String id;
  final String preoccupationId;
  final String preoccupationContent;
  final String missionDate;
  final int estimatedKgGain;
  final int estimatedDurationMinutes;
  final DateTime createdAt;
}

/// Picks the best candidate preoccupation for today's mission.
///
/// Rule (deterministic):
/// 1) highest mental weight first
/// 2) then shortest estimated duration
/// 3) then oldest creation time
/// 4) then stable id order
Preoccupation? selectDailyMissionCandidate(List<Preoccupation> items) {
  final candidates = items
      .where((item) => item.mentalWeightKg != null)
      .toList(growable: false);
  if (candidates.isEmpty) return null;

  final sorted = [...candidates]
    ..sort((a, b) {
      final weightCompare = b.mentalWeightKg!.compareTo(a.mentalWeightKg!);
      if (weightCompare != 0) return weightCompare;

      final durationA = a.estimatedDurationMinutes ?? 30;
      final durationB = b.estimatedDurationMinutes ?? 30;
      final durationCompare = durationA.compareTo(durationB);
      if (durationCompare != 0) return durationCompare;

      final createdCompare = a.createdAt.compareTo(b.createdAt);
      if (createdCompare != 0) return createdCompare;

      return a.id.compareTo(b.id);
    });

  return sorted.first;
}
