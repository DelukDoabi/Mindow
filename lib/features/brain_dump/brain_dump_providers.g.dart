// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brain_dump_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [DomainEventRegistry], with every feature event decoder.
///
/// This composition root maps `event_type` discriminators to their decoders so
/// the replay engine can rebuild typed events. Future events (weight assigned,
/// deleted, ...) register here too, keeping `core/sync` business-agnostic.

@ProviderFor(domainEventRegistry)
final domainEventRegistryProvider = DomainEventRegistryProvider._();

/// The app's [DomainEventRegistry], with every feature event decoder.
///
/// This composition root maps `event_type` discriminators to their decoders so
/// the replay engine can rebuild typed events. Future events (weight assigned,
/// deleted, ...) register here too, keeping `core/sync` business-agnostic.

final class DomainEventRegistryProvider
    extends
        $FunctionalProvider<
          DomainEventRegistry,
          DomainEventRegistry,
          DomainEventRegistry
        >
    with $Provider<DomainEventRegistry> {
  /// The app's [DomainEventRegistry], with every feature event decoder.
  ///
  /// This composition root maps `event_type` discriminators to their decoders so
  /// the replay engine can rebuild typed events. Future events (weight assigned,
  /// deleted, ...) register here too, keeping `core/sync` business-agnostic.
  DomainEventRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'domainEventRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$domainEventRegistryHash();

  @$internal
  @override
  $ProviderElement<DomainEventRegistry> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DomainEventRegistry create(Ref ref) {
    return domainEventRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DomainEventRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DomainEventRegistry>(value),
    );
  }
}

String _$domainEventRegistryHash() =>
    r'2f1e381caa2b59872af215034f5ff3bc7d20319f';

/// The shared [BrainDumpRepository], wired to the sync engine.

@ProviderFor(brainDumpRepository)
final brainDumpRepositoryProvider = BrainDumpRepositoryProvider._();

/// The shared [BrainDumpRepository], wired to the sync engine.

final class BrainDumpRepositoryProvider
    extends
        $FunctionalProvider<
          BrainDumpRepository,
          BrainDumpRepository,
          BrainDumpRepository
        >
    with $Provider<BrainDumpRepository> {
  /// The shared [BrainDumpRepository], wired to the sync engine.
  BrainDumpRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brainDumpRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brainDumpRepositoryHash();

  @$internal
  @override
  $ProviderElement<BrainDumpRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrainDumpRepository create(Ref ref) {
    return brainDumpRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrainDumpRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrainDumpRepository>(value),
    );
  }
}

String _$brainDumpRepositoryHash() =>
    r'5c6d257bfb80176b5504fc20244faa3c05ef962e';

/// Monotonically-increasing revision counter — bumped every time a
/// [WeightAssignedEvent] (or any future mutation) lands in the local outbox.
///
/// Kept alive so [AnalysisService] can always bump it from its async
/// callbacks, even when the home screen is momentarily off-screen.

@ProviderFor(ProjectionRevision)
final projectionRevisionProvider = ProjectionRevisionProvider._();

/// Monotonically-increasing revision counter — bumped every time a
/// [WeightAssignedEvent] (or any future mutation) lands in the local outbox.
///
/// Kept alive so [AnalysisService] can always bump it from its async
/// callbacks, even when the home screen is momentarily off-screen.
final class ProjectionRevisionProvider
    extends $NotifierProvider<ProjectionRevision, int> {
  /// Monotonically-increasing revision counter — bumped every time a
  /// [WeightAssignedEvent] (or any future mutation) lands in the local outbox.
  ///
  /// Kept alive so [AnalysisService] can always bump it from its async
  /// callbacks, even when the home screen is momentarily off-screen.
  ProjectionRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectionRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectionRevisionHash();

  @$internal
  @override
  ProjectionRevision create() => ProjectionRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$projectionRevisionHash() =>
    r'bafc4fcb8d6bdf4bee12a30043bd4b13eff26f05';

/// Monotonically-increasing revision counter — bumped every time a
/// [WeightAssignedEvent] (or any future mutation) lands in the local outbox.
///
/// Kept alive so [AnalysisService] can always bump it from its async
/// callbacks, even when the home screen is momentarily off-screen.

abstract class _$ProjectionRevision extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The open Preoccupations projection, most recent first.
///
/// Re-runs whenever a new preoccupation is captured (via `ref.invalidate` from
/// the widget) OR whenever [ProjectionRevision] is bumped by [AnalysisService]
/// after a weight is assigned — the two triggers together ensure the list is
/// always current without polling.

@ProviderFor(openPreoccupations)
final openPreoccupationsProvider = OpenPreoccupationsProvider._();

/// The open Preoccupations projection, most recent first.
///
/// Re-runs whenever a new preoccupation is captured (via `ref.invalidate` from
/// the widget) OR whenever [ProjectionRevision] is bumped by [AnalysisService]
/// after a weight is assigned — the two triggers together ensure the list is
/// always current without polling.

final class OpenPreoccupationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Preoccupation>>,
          List<Preoccupation>,
          FutureOr<List<Preoccupation>>
        >
    with
        $FutureModifier<List<Preoccupation>>,
        $FutureProvider<List<Preoccupation>> {
  /// The open Preoccupations projection, most recent first.
  ///
  /// Re-runs whenever a new preoccupation is captured (via `ref.invalidate` from
  /// the widget) OR whenever [ProjectionRevision] is bumped by [AnalysisService]
  /// after a weight is assigned — the two triggers together ensure the list is
  /// always current without polling.
  OpenPreoccupationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openPreoccupationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openPreoccupationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Preoccupation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Preoccupation>> create(Ref ref) {
    return openPreoccupations(ref);
  }
}

String _$openPreoccupationsHash() =>
    r'0c89812e4a1dfd0b608959b859b512a030d5452b';

/// Ids of Preoccupations whose analysis tripped the crisis-gate (AC2).
///
/// The Home screen `listen`s to this and surfaces the calm support view; the
/// item itself stays a pending entry (no weight, no auto-delete).

@ProviderFor(CrisisAlerts)
final crisisAlertsProvider = CrisisAlertsProvider._();

/// Ids of Preoccupations whose analysis tripped the crisis-gate (AC2).
///
/// The Home screen `listen`s to this and surfaces the calm support view; the
/// item itself stays a pending entry (no weight, no auto-delete).
final class CrisisAlertsProvider
    extends $NotifierProvider<CrisisAlerts, List<String>> {
  /// Ids of Preoccupations whose analysis tripped the crisis-gate (AC2).
  ///
  /// The Home screen `listen`s to this and surfaces the calm support view; the
  /// item itself stays a pending entry (no weight, no auto-delete).
  CrisisAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crisisAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crisisAlertsHash();

  @$internal
  @override
  CrisisAlerts create() => CrisisAlerts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$crisisAlertsHash() => r'c1c571548e0730a9c08cb233bbf4445cb4340897';

/// Ids of Preoccupations whose analysis tripped the crisis-gate (AC2).
///
/// The Home screen `listen`s to this and surfaces the calm support view; the
/// item itself stays a pending entry (no weight, no auto-delete).

abstract class _$CrisisAlerts extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The consent-gated AI Analysis orchestrator.
///
/// Wires the [AnalysisService] to the projection (pending reader + refresh) and
/// to the crisis-alert surface. Kept alive so the in-flight guard survives
/// across captures.

@ProviderFor(analysisService)
final analysisServiceProvider = AnalysisServiceProvider._();

/// The consent-gated AI Analysis orchestrator.
///
/// Wires the [AnalysisService] to the projection (pending reader + refresh) and
/// to the crisis-alert surface. Kept alive so the in-flight guard survives
/// across captures.

final class AnalysisServiceProvider
    extends
        $FunctionalProvider<AnalysisService, AnalysisService, AnalysisService>
    with $Provider<AnalysisService> {
  /// The consent-gated AI Analysis orchestrator.
  ///
  /// Wires the [AnalysisService] to the projection (pending reader + refresh) and
  /// to the crisis-alert surface. Kept alive so the in-flight guard survives
  /// across captures.
  AnalysisServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analysisServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analysisServiceHash();

  @$internal
  @override
  $ProviderElement<AnalysisService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalysisService create(Ref ref) {
    return analysisService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalysisService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalysisService>(value),
    );
  }
}

String _$analysisServiceHash() => r'a1566512587e93f609b46772e44835dedc3b8c90';
