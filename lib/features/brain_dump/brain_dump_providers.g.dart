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
    r'aa028852039341d8adf3f530ea5c261dfca638bc';

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

/// The open Preoccupations projection, most recent first.
///
/// Invalidate this after a capture so the freshly appended item appears.

@ProviderFor(openPreoccupations)
final openPreoccupationsProvider = OpenPreoccupationsProvider._();

/// The open Preoccupations projection, most recent first.
///
/// Invalidate this after a capture so the freshly appended item appears.

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
  /// Invalidate this after a capture so the freshly appended item appears.
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
    r'6f7ef8cae632aefc7ac5b078d6362b87e4c06658';
