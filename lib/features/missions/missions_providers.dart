import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/data/supabase_client.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/missions/domain/daily_mission.dart';
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

class DeferredMissionKeysNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void defer(String key) {
    state = <String>{...state, key};
  }
}

final deferredMissionKeysProvider =
    NotifierProvider<DeferredMissionKeysNotifier, Set<String>>(
      DeferredMissionKeysNotifier.new,
    );

class ValidationRequestedMissionIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void request(String preoccupationId) {
    state = preoccupationId;
  }
}

final validationRequestedMissionIdProvider =
    NotifierProvider<ValidationRequestedMissionIdNotifier, String?>(
      ValidationRequestedMissionIdNotifier.new,
    );

String missionUiKey(DailyMission mission) =>
    '${mission.missionDate}:${mission.preoccupationId}';

void deferMission(WidgetRef ref, DailyMission mission) {
  final key = missionUiKey(mission);
  ref.read(deferredMissionKeysProvider.notifier).defer(key);
}

bool isMissionDeferred(WidgetRef ref, DailyMission mission) {
  final key = missionUiKey(mission);
  return ref.watch(deferredMissionKeysProvider).contains(key);
}

void requestMissionValidation(WidgetRef ref, DailyMission mission) {
  ref
      .read(validationRequestedMissionIdProvider.notifier)
  .request(mission.preoccupationId);
}
