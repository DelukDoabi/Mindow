import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/replay_engine.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_deleted_event.dart';
import 'package:mindow/features/missions/domain/daily_mission.dart';
import 'package:mindow/features/missions/domain/mission_validated_event.dart';
import 'package:uuid/uuid.dart';

// Collaborators are kept in private fields; named parameters cannot be private
// initializing formals, so they are assigned in the initializer list.
// ignore_for_file: prefer_initializing_formals

class MissionValidationResult {
  const MissionValidationResult({
    required this.kgFreed,
    required this.timeInvestedMinutes,
    required this.wasAlreadyValidated,
  });

  final int kgFreed;
  final int timeInvestedMinutes;
  final bool wasAlreadyValidated;
}

/// Handles validation side effects for a completed daily mission.
class MissionValidationService {
  MissionValidationService({
    required SyncQueue syncQueue,
    required EventStore eventStore,
    required DomainEventRegistry registry,
    ReplayEngine replayEngine = const ReplayEngine(),
    Uuid uuid = const Uuid(),
    Clock clock = systemUtcClock,
  }) : _syncQueue = syncQueue,
       _eventStore = eventStore,
       _registry = registry,
       _replayEngine = replayEngine,
       _uuid = uuid,
       _clock = clock;

  final SyncQueue _syncQueue;
  final EventStore _eventStore;
  final DomainEventRegistry _registry;
  final ReplayEngine _replayEngine;
  final Uuid _uuid;
  final Clock _clock;

  Future<MissionValidationResult> validate(DailyMission mission) async {
    final key = missionValidationKey(
      missionId: mission.id,
      missionDate: mission.missionDate,
    );
    if (_validatedKeys().contains(key)) {
      return MissionValidationResult(
        kgFreed: mission.estimatedKgGain,
        timeInvestedMinutes: mission.estimatedDurationMinutes,
        wasAlreadyValidated: true,
      );
    }

    final firstTimestamp = _clock();
    await _syncQueue.enqueue(
      MissionValidatedEvent(
        eventId: _uuid.v4(),
        aggregateId: mission.preoccupationId,
        occurredAt: firstTimestamp,
        missionId: mission.id,
        missionDate: mission.missionDate,
        kgFreed: mission.estimatedKgGain,
        timeInvestedMinutes: mission.estimatedDurationMinutes,
      ),
    );

    await _syncQueue.enqueue(
      PreoccupationDeletedEvent(
        eventId: _uuid.v4(),
        aggregateId: mission.preoccupationId,
        occurredAt: firstTimestamp.add(const Duration(milliseconds: 1)),
      ),
    );

    return MissionValidationResult(
      kgFreed: mission.estimatedKgGain,
      timeInvestedMinutes: mission.estimatedDurationMinutes,
      wasAlreadyValidated: false,
    );
  }

  Set<String> _validatedKeys() {
    return _replayEngine.replay<Set<String>>(
      initialState: <String>{},
      envelopes: _eventStore.all().map((record) => record.toEnvelope()),
      registry: _registry,
      reducer: (state, event) {
        if (event is! MissionValidatedEvent) return state;
        return <String>{
          ...state,
          missionValidationKey(
            missionId: event.missionId,
            missionDate: event.missionDate,
          ),
        };
      },
    );
  }
}
