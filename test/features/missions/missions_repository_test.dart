import 'package:flutter_test/flutter_test.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/missions/missions_client.dart';
import 'package:mindow/features/missions/missions_repository.dart';

class _FakeMissionsClient extends MissionsClient {
  _FakeMissionsClient({this.response, this.shouldThrow = false}) : super(null);

  final Map<String, dynamic>? response;
  final bool shouldThrow;

  @override
  Future<Map<String, dynamic>> generateTodayMission({
    required List<Map<String, dynamic>> candidates,
    String? profileTimezone,
  }) async {
    if (shouldThrow) {
      throw const MissionsClientUnavailableException();
    }
    return response ??
        <String, dynamic>{'mission_date': '2026-06-10', 'mission': null};
  }
}

void main() {
  final candidates = <Preoccupation>[
    Preoccupation(
      id: 'p1',
      content: 'call dentist',
      createdAt: DateTime.utc(2026, 6),
      mentalWeightKg: 6,
      estimatedDurationMinutes: 15,
    ),
  ];

  test('returns mission when payload contains one', () async {
    final repository = MissionsRepository(
      _FakeMissionsClient(
        response: <String, dynamic>{
          'mission_date': '2026-06-10',
          'mission': <String, dynamic>{
            'id': 'm1',
            'preoccupation_id': 'p1',
            'preoccupation_content': 'call dentist',
            'mission_date': '2026-06-10',
            'estimated_kg_gain': 6,
            'estimated_duration_minutes': 15,
            'created_at': '2026-06-10T08:00:00.000Z',
          },
        },
      ),
    );

    final result = await repository.getTodayMission(candidates: candidates);

    expect(result.hasMission, isTrue);
    expect(result.mission?.preoccupationId, 'p1');
    expect(result.mission?.estimatedKgGain, 6);
  });

  test('returns empty result when payload has no mission', () async {
    final repository = MissionsRepository(
      _FakeMissionsClient(
        response: <String, dynamic>{
          'mission_date': '2026-06-10',
          'mission': null,
        },
      ),
    );

    final result = await repository.getTodayMission(candidates: candidates);

    expect(result.hasMission, isFalse);
    expect(result.missionDate, '2026-06-10');
  });

  test('returns empty fallback when client throws', () async {
    final repository = MissionsRepository(
      _FakeMissionsClient(shouldThrow: true),
    );

    final result = await repository.getTodayMission(candidates: candidates);

    expect(result.hasMission, isFalse);
  });
}
