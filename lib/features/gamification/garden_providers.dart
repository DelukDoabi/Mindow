import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/replay_engine.dart';
import 'package:mindow/core/sync/sync_providers.dart';
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/gamification/domain/garden_state.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';

final gardenStateProvider = Provider<GardenState>((ref) {
  ref.watch(projectionRevisionProvider);

  final validatedEvents = const ReplayEngine().replay<List<MissionValidatedEvent>>(
    initialState: <MissionValidatedEvent>[],
    envelopes: ref
        .watch(eventStoreProvider)
        .all()
        .map((record) => record.toEnvelope()),
    registry: ref.watch(domainEventRegistryProvider),
    reducer: (state, event) {
      if (event is! MissionValidatedEvent) return state;
      return <MissionValidatedEvent>[...state, event];
    },
  );

  return gardenStateFromMissionValidatedEvents(validatedEvents);
});
