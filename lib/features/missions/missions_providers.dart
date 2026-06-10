import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/data/supabase_client.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/missions/missions_client.dart';
import 'package:mindow/features/missions/missions_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final missionsClientProvider = Provider<MissionsClient>((ref) {
  SupabaseClient? client;
  try {
    client = ref.watch(supabaseClientProvider);
  } on Object {
    client = null;
  }
  return MissionsClient(client);
});

final missionsRepositoryProvider = Provider<MissionsRepository>(
  (ref) => MissionsRepository(ref.watch(missionsClientProvider)),
);

final todayMissionProvider = FutureProvider<DailyMissionResult>((ref) async {
  final preoccupations = await ref.watch(openPreoccupationsProvider.future);
  return ref
      .watch(missionsRepositoryProvider)
      .getTodayMission(
        candidates: preoccupations,
      );
});

void refreshTodayMission(WidgetRef ref) {
  ref.invalidate(todayMissionProvider);
}
