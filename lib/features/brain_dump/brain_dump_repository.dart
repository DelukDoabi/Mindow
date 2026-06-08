import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/replay_engine.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_deleted_event.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_updated_event.dart';
import 'package:mindow/features/brain_dump/domain/weight_assigned_event.dart';
import 'package:uuid/uuid.dart';

// Collaborators are kept in private fields; named parameters cannot be private
// initializing formals, so they are assigned in the initializer list.
// ignore_for_file: prefer_initializing_formals

/// Folds the event log into the open-preoccupations projection.
///
/// Keyed by `aggregateId` so edit/delete events (Story 2.4) can update or
/// remove the same entry. A [PreoccupationCapturedEvent] creates the entry
/// (Mental Weight `null` = pending); a [WeightAssignedEvent] folds the assigned
/// weight/category onto it; a [PreoccupationUpdatedEvent] overwrites the content
/// (weight/category are preserved — latest `weight.assigned` wins); a
/// [PreoccupationDeletedEvent] tombstones the entry. Orphan events whose
/// aggregate has not been captured are silently ignored.
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
  if (event is PreoccupationUpdatedEvent) {
    final existing = state[event.aggregateId];
    if (existing == null) return state;
    return <String, Preoccupation>{
      ...state,
      event.aggregateId: existing.copyWith(content: event.content),
    };
  }
  if (event is PreoccupationDeletedEvent) {
    if (!state.containsKey(event.aggregateId)) return state;
    return Map<String, Preoccupation>.from(state)..remove(event.aggregateId);
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

  /// Deletes the Preoccupation identified by [id].
  ///
  /// Appends a [PreoccupationDeletedEvent] tombstone to the local outbox.
  /// The item disappears from the projection on the next rebuild (offline-first,
  /// NFR-3). If no Preoccupation with [id] exists in the projection, the event
  /// is still emitted (idempotent tombstone) but the reducer ignores it.
  Future<void> deletePreoccupation(String id) async {
    await _syncQueue.enqueue(
      PreoccupationDeletedEvent(
        eventId: _uuid.v4(),
        aggregateId: id,
        occurredAt: _clock(),
      ),
    );
  }

  /// Edits the content of the Preoccupation identified by [id].
  ///
  /// Trims [newContent] and rejects empty/whitespace-only text (no event
  /// emitted). Otherwise appends a [PreoccupationUpdatedEvent] to the local
  /// outbox. The existing Mental Weight and category are preserved on the
  /// projection until re-analysis (if triggered by the call site) emits a
  /// fresh `weight.assigned` that supersedes via latest-wins (FR-5, NFR-11).
  Future<void> updatePreoccupation(String id, String newContent) async {
    final trimmed = newContent.trim();
    if (trimmed.isEmpty) return;

    await _syncQueue.enqueue(
      PreoccupationUpdatedEvent(
        eventId: _uuid.v4(),
        aggregateId: id,
        occurredAt: _clock(),
        content: trimmed,
      ),
    );
  }
}
