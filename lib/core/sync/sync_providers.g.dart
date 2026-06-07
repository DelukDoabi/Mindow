// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide [EventStore] over the seeded outbox box.

@ProviderFor(eventStore)
final eventStoreProvider = EventStoreProvider._();

/// The app-wide [EventStore] over the seeded outbox box.

final class EventStoreProvider
    extends $FunctionalProvider<EventStore, EventStore, EventStore>
    with $Provider<EventStore> {
  /// The app-wide [EventStore] over the seeded outbox box.
  EventStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventStoreHash();

  @$internal
  @override
  $ProviderElement<EventStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventStore create(Ref ref) {
    return eventStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventStore>(value),
    );
  }
}

String _$eventStoreHash() => r'6e2c807ee97e52476058c7775faf47f7d9124bba';

/// The app-wide [SyncQueue].
///
/// No [ReconciliationClient] is wired yet (Story 2.2 is offline-first): the
/// durable outbox is the reconnect queue and `flush()` is a documented no-op
/// until the backend transport lands.

@ProviderFor(syncQueue)
final syncQueueProvider = SyncQueueProvider._();

/// The app-wide [SyncQueue].
///
/// No [ReconciliationClient] is wired yet (Story 2.2 is offline-first): the
/// durable outbox is the reconnect queue and `flush()` is a documented no-op
/// until the backend transport lands.

final class SyncQueueProvider
    extends $FunctionalProvider<SyncQueue, SyncQueue, SyncQueue>
    with $Provider<SyncQueue> {
  /// The app-wide [SyncQueue].
  ///
  /// No [ReconciliationClient] is wired yet (Story 2.2 is offline-first): the
  /// durable outbox is the reconnect queue and `flush()` is a documented no-op
  /// until the backend transport lands.
  SyncQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncQueueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncQueueHash();

  @$internal
  @override
  $ProviderElement<SyncQueue> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncQueue create(Ref ref) {
    return syncQueue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncQueue>(value),
    );
  }
}

String _$syncQueueHash() => r'cb3808aa76ae28a9a272974e235e1b59c9ca7011';
