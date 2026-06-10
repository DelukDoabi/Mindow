import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/data/supabase_client.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/replay_engine.dart';
import 'package:mindow/core/sync/sync_providers.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/missions/domain/daily_mission.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';
import 'package:mindow/features/missions/mission_validation_service.dart';
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

final missionValidationServiceProvider = Provider<MissionValidationService>(
  (ref) => MissionValidationService(
    syncQueue: ref.watch(syncQueueProvider),
    eventStore: ref.watch(eventStoreProvider),
    registry: ref.watch(domainEventRegistryProvider),
  ),
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

  String? get requestedMissionId => state;

  set requestedMissionId(String? value) => state = value;
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
  ref.read(validationRequestedMissionIdProvider.notifier).requestedMissionId =
      mission.preoccupationId;
}

class MissionVictory {
  const MissionVictory({
    required this.missionId,
    required this.missionDate,
    required this.preoccupationId,
    required this.kgFreed,
    required this.timeInvestedMinutes,
    required this.validatedAt,
  });

  final String missionId;
  final String missionDate;
  final String preoccupationId;
  final int kgFreed;
  final int timeInvestedMinutes;
  final DateTime validatedAt;
}

List<MissionVictory> _victoriesFromOutbox(
  EventStore store,
  DomainEventRegistry registry,
) {
  final byKey = const ReplayEngine().replay<Map<String, MissionVictory>>(
    initialState: <String, MissionVictory>{},
    envelopes: store.all().map((record) => record.toEnvelope()),
    registry: registry,
    reducer: (state, event) {
      if (event is! MissionValidatedEvent) return state;
      final key = missionValidationKey(
        missionId: event.missionId,
        missionDate: event.missionDate,
      );
      if (state.containsKey(key)) return state;
      return <String, MissionVictory>{
        ...state,
        key: MissionVictory(
          missionId: event.missionId,
          missionDate: event.missionDate,
          preoccupationId: event.aggregateId,
          kgFreed: event.kgFreed,
          timeInvestedMinutes: event.timeInvestedMinutes,
          validatedAt: event.occurredAt,
        ),
      };
    },
  );

  final victories = byKey.values.toList(growable: false)
    ..sort((a, b) => b.validatedAt.compareTo(a.validatedAt));
  return victories;
}

final missionVictoriesProvider = Provider<List<MissionVictory>>((ref) {
  ref.watch(projectionRevisionProvider);
  return _victoriesFromOutbox(
    ref.watch(eventStoreProvider),
    ref.watch(domainEventRegistryProvider),
  );
});

final missionKgFreedThisWeekProvider = Provider<int>((ref) {
  final now = DateTime.now().toUtc();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  return ref
      .watch(missionVictoriesProvider)
      .where((victory) => !victory.validatedAt.isBefore(sevenDaysAgo))
      .fold<int>(0, (sum, victory) => sum + victory.kgFreed);
});
