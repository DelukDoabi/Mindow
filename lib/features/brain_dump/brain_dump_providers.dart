import 'package:mindow/core/sync/domain_event.dart';
import 'package:mindow/core/sync/sync_providers.dart';
import 'package:mindow/features/brain_dump/brain_dump_repository.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';
import 'package:mindow/features/brain_dump/domain/preoccupation_captured_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'brain_dump_providers.g.dart';

/// The app's [DomainEventRegistry], with every feature event decoder.
///
/// This composition root maps `event_type` discriminators to their decoders so
/// the replay engine can rebuild typed events. Future events (weight assigned,
/// deleted, ...) register here too, keeping `core/sync` business-agnostic.
@Riverpod(keepAlive: true)
DomainEventRegistry domainEventRegistry(Ref ref) =>
    DomainEventRegistry()
      ..register(PreoccupationCapturedEvent.type, decodePreoccupationCaptured);

/// The shared [BrainDumpRepository], wired to the sync engine.
@riverpod
BrainDumpRepository brainDumpRepository(Ref ref) => BrainDumpRepository(
  syncQueue: ref.watch(syncQueueProvider),
  eventStore: ref.watch(eventStoreProvider),
  registry: ref.watch(domainEventRegistryProvider),
);

/// The open Preoccupations projection, most recent first.
///
/// Invalidate this after a capture so the freshly appended item appears.
@riverpod
Future<List<Preoccupation>> openPreoccupations(Ref ref) async =>
    ref.watch(brainDumpRepositoryProvider).getOpenPreoccupations();
