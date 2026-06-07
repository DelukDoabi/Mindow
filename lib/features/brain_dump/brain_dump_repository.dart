import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/replay_engine.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';
import 'package:mindow/features/brain_dump/domain/weight_assigned_event.dart';
import 'package:uuid/uuid.dart';

// Collaborators are kept in private fields; named parameters cannot be private
// initializing formals, so they are assigned in the initializer list.
// ignore_for_file: prefer_initializing_formals

/// Folds the event log into the open-preoccupations projection.
///
/// Keyed by `aggregateId` so a future edit/delete event (Story 2.4) can update
/// or remove the same entry. A [PreoccupationCapturedEvent] creates the entry
/// (Mental Weight `null` = pending); a [WeightAssignedEvent] folds the assigned
/// weight/category onto it. Because events replay in order, the LAST
/// `weight.assigned` wins (Resolved Decision #4). An orphan weight event whose
/// aggregate has not been captured is ignored.
Map<String, Preoccupation> _reducePreoccupations(
  Map<String, Preoccupation> state,
  DomainEvent event,
) {
  if (event is PreoccupationCapturedEvent) {
    return <String, Preoccupation>{
      ...state,
      event.aggregateId: Preoccupation(
        id: event.aggregateId,
        content: event.content,
        createdAt: event.occurredAt,
      ),
    };
  }
  if (event is WeightAssignedEvent) {
    final existing = state[event.aggregateId];
    if (existing == null) return state;
    return <String, Preoccupation>{
      ...state,
      event.aggregateId: existing.copyWith(
        mentalWeightKg: event.mentalWeightKg,
        category: event.category,
        effortScore: event.effortScore,
        estimatedDurationMinutes: event.estimatedDurationMinutes,
        weightModelVersion: event.weightModelVersion,
      ),
    };
  }
  return state;
}

/// Local, offline-first capture pipeline for Preoccupations (FR-4, NFR-3).
///
/// Writes go through the [SyncQueue] into the Hive outbox (the local source of
/// truth); reads are a derived projection replayed from that same log via the
/// [ReplayEngine]. No network or AI call happens here.
class BrainDumpRepository {
  /// Creates a repository over the sync engine collaborators.
  BrainDumpRepository({
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

  /// Captures [content] as a new Preoccupation.
  ///
  /// Trims the input and rejects empty/whitespace-only text (no event emitted).
  /// Otherwise generates one UUID v4 used as BOTH the `event_id` and the
  /// `aggregate_id`, and appends a [PreoccupationCapturedEvent] to the local
  /// outbox. Returns immediately — never blocks on the network or AI (NFR-1).
  Future<void> capturePreoccupation(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final id = _uuid.v4();
    await _syncQueue.enqueue(
      PreoccupationCapturedEvent(
        eventId: id,
        aggregateId: id,
        occurredAt: _clock(),
        content: trimmed,
      ),
    );
  }

  /// Returns the open Preoccupations, most recent first.
  ///
  /// Derived by replaying the outbox event log; idempotent and order-stable by
  /// construction (the engine dedups by `event_id` and orders deterministically).
  List<Preoccupation> getOpenPreoccupations() {
    final byId = _replayEngine.replay<Map<String, Preoccupation>>(
      initialState: const <String, Preoccupation>{},
      envelopes: _eventStore.all().map((record) => record.toEnvelope()),
      registry: _registry,
      reducer: _reducePreoccupations,
    );

    return byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
