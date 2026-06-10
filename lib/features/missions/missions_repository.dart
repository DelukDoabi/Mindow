import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/missions/domain/daily_mission.dart';
import 'package:mindow/features/missions/missions_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyMissionResult {
  const DailyMissionResult({required this.missionDate, required this.mission});

  factory DailyMissionResult.empty() => DailyMissionResult(
    missionDate: DateTime.now().toUtc().toIso8601String().split('T').first,
    mission: null,
  );

  final String missionDate;
  final DailyMission? mission;

  bool get hasMission => mission != null;
}

/// App-level boundary for reading the Daily Mission.
class MissionsRepository {
  const MissionsRepository(this._client);

  final MissionsClient _client;

  Future<DailyMissionResult> getTodayMission({
    required List<Preoccupation> candidates,
    String? profileTimezone,
  }) async {
    try {
      final candidatePayload = candidates
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'content': item.content,
              'mental_weight_kg': item.mentalWeightKg,
              'estimated_duration_minutes': item.estimatedDurationMinutes,
              'created_at': item.createdAt.toUtc().toIso8601String(),
            },
          )
          .toList(growable: false);

      final payload = await _client.generateTodayMission(
        candidates: candidatePayload,
        profileTimezone: profileTimezone,
      );
      final missionDate = payload['mission_date'] as String?;
      if (missionDate == null) return DailyMissionResult.empty();

      final missionRaw = payload['mission'];
      if (missionRaw == null) {
        return DailyMissionResult(missionDate: missionDate, mission: null);
      }
      if (missionRaw is! Map) return DailyMissionResult.empty();

      return DailyMissionResult(
        missionDate: missionDate,
        mission: DailyMission.fromJson(Map<String, dynamic>.from(missionRaw)),
      );
    } on FunctionException {
      return DailyMissionResult.empty();
    } on MissionsClientUnavailableException {
      return DailyMissionResult.empty();
    } on MissionsClientMalformedResponseException {
      return DailyMissionResult.empty();
    } on Object {
      return DailyMissionResult.empty();
    }
  }
}
