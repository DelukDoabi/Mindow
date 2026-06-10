import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/sync/replay_engine.dart';
import 'package:mindow/core/sync/sync_providers.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';
import 'package:mindow/features/gamification/domain/achievement_state.dart';
import 'package:mindow/features/gamification/garden_providers.dart';

/// Count of unique preoccupations ever captured (unique aggregateIds from
/// `preoccupation.captured` events). Reactive via projectionRevisionProvider.
final capturedPreoccupationsCountProvider = Provider<int>((ref) {
  ref.watch(projectionRevisionProvider);

  final uniqueAggregateIds = const ReplayEngine().replay<Set<String>>(
    initialState: <String>{},
    envelopes: ref
        .watch(eventStoreProvider)
        .all()
        .map((record) => record.toEnvelope()),
    registry: ref.watch(domainEventRegistryProvider),
    reducer: (state, event) {
      if (event is! PreoccupationCapturedEvent) return state;
      return <String>{...state, event.aggregateId};
    },
  );

  return uniqueAggregateIds.length;
});

/// Deterministic achievement and streak projection derived from the event log.
final achievementStateProvider = Provider<AchievementState>((ref) {
  final validatedEvents = ref.watch(missionValidatedEventsProvider);
  final capturedCount = ref.watch(capturedPreoccupationsCountProvider);
  return AchievementState.fromInputs(
    validatedEvents: validatedEvents,
    capturedCount: capturedCount,
  );
});
