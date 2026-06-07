import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:mindow/core/sync/event_store.dart';
import 'package:mindow/core/sync/sync_queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_providers.g.dart';

/// The opened outbox [Box], seeded synchronously at bootstrap.
///
/// The box must be opened (async Hive I/O) before the first frame, so — like
/// `onboardingCompleteProvider` — this hand-written [Provider] is overridden in
/// `bootstrap.dart` with the already-open box. Accessing it without that
/// override is a programming error.
final outboxBoxProvider = Provider<Box<OutboxRecord>>(
  (ref) => throw UnimplementedError('outboxBoxProvider seeded in bootstrap'),
);

/// The app-wide [EventStore] over the seeded outbox box.
@Riverpod(keepAlive: true)
EventStore eventStore(Ref ref) => EventStore(ref.watch(outboxBoxProvider));

/// The app-wide [SyncQueue].
///
/// No `ReconciliationClient` is wired yet (Story 2.2 is offline-first): the
/// durable outbox is the reconnect queue and `flush()` is a documented no-op
/// until the backend transport lands.
@Riverpod(keepAlive: true)
SyncQueue syncQueue(Ref ref) => SyncQueue(store: ref.watch(eventStoreProvider));
