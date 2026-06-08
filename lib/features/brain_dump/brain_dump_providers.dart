import 'package:mindow/core/ai/ai_client.dart';
import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/sync_providers.dart';
import 'package:mindow/features/brain_dump/analysis_service.dart';
import 'package:mindow/features/brain_dump/brain_dump_repository.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';
import 'package:mindow/features/brain_dump/domain/weight_assigned_event.dart';
import 'package:mindow/features/onboarding/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'brain_dump_providers.g.dart';

/// The app's [DomainEventRegistry], with every feature event decoder.
///
/// This composition root maps `event_type` discriminators to their decoders so
/// the replay engine can rebuild typed events. Future events (weight assigned,
/// deleted, ...) register here too, keeping `core/sync` business-agnostic.
@Riverpod(keepAlive: true)
DomainEventRegistry domainEventRegistry(Ref ref) => DomainEventRegistry()
  ..register(PreoccupationCapturedEvent.type, decodePreoccupationCaptured)
  ..register(WeightAssignedEvent.type, decodeWeightAssigned);

/// The shared [BrainDumpRepository], wired to the sync engine.
@riverpod
BrainDumpRepository brainDumpRepository(Ref ref) => BrainDumpRepository(
  syncQueue: ref.watch(syncQueueProvider),
  eventStore: ref.watch(eventStoreProvider),
  registry: ref.watch(domainEventRegistryProvider),
);

/// Monotonically-increasing revision counter — bumped every time a
/// [WeightAssignedEvent] (or any future mutation) lands in the local outbox.
///
/// Kept alive so [AnalysisService] can always bump it from its async
/// callbacks, even when the home screen is momentarily off-screen.
@Riverpod(keepAlive: true)
class ProjectionRevision extends _$ProjectionRevision {
  @override
  int build() => 0;

  /// Increments the revision, causing every watcher to rebuild.
  void bump() => state = state + 1;
}

/// The open Preoccupations projection, most recent first.
///
/// Re-runs whenever a new preoccupation is captured (via `ref.invalidate` from
/// the widget) OR whenever [ProjectionRevision] is bumped by [AnalysisService]
/// after a weight is assigned — the two triggers together ensure the list is
/// always current without polling.
@riverpod
Future<List<Preoccupation>> openPreoccupations(Ref ref) async {
  ref.watch(projectionRevisionProvider);
  return ref.read(brainDumpRepositoryProvider).getOpenPreoccupations();
}

/// Ids of Preoccupations whose analysis tripped the crisis-gate (AC2).
///
/// The Home screen `listen`s to this and surfaces the calm support view; the
/// item itself stays a pending entry (no weight, no auto-delete).
@riverpod
class CrisisAlerts extends _$CrisisAlerts {
  @override
  List<String> build() => const <String>[];

  /// Records that [id] tripped the crisis-gate.
  void push(String id) {
    if (state.contains(id)) return;
    state = <String>[...state, id];
  }

  /// Dismisses the alert for [id] once the support view has been shown.
  void dismiss(String id) =>
      state = state.where((alertId) => alertId != id).toList();
}

/// The consent-gated AI Analysis orchestrator.
///
/// Wires the [AnalysisService] to the projection (pending reader + refresh) and
/// to the crisis-alert surface. Kept alive so the in-flight guard survives
/// across captures.
@Riverpod(keepAlive: true)
AnalysisService analysisService(Ref ref) => AnalysisService(
  aiClient: ref.watch(aiClientProvider),
  onboardingRepository: ref.watch(onboardingRepositoryProvider),
  syncQueue: ref.watch(syncQueueProvider),
  readPending: () => ref
      .read(brainDumpRepositoryProvider)
      .getOpenPreoccupations()
      .where((preoccupation) => preoccupation.isPending)
      .toList(),
  onCrisis: (id) => ref.read(crisisAlertsProvider.notifier).push(id),
  onProjectionChanged: () =>
      ref.read(projectionRevisionProvider.notifier).bump(),
);
