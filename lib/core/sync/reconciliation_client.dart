import 'package:mindow/core/sync/event_store.dart';

/// The transport seam between the local outbox and the backend event log.
///
/// Story 2.1 defines the contract only; the concrete Supabase implementation
/// (calling the reconciliation Edge Function) is wired in Story 2.2+. Keeping
/// this abstract lets `SyncQueue` be fully unit-tested with a fake and lets the
/// app boot offline-first with no client at all.
// Intentionally a single-method seam; a concrete transport lands in Story 2.2+.
// ignore: one_member_abstracts
abstract interface class ReconciliationClient {
  /// Pushes [records] to the backend event log and returns the server-assigned
  /// `received_at` timestamps keyed by `event_id`.
  ///
  /// The backend is idempotent (`INSERT ... ON CONFLICT (event_id) DO
  /// NOTHING`), so re-pushing an already-stored event is a success, not an
  /// error. Records the server does not return are simply left pending.
  Future<Map<String, DateTime>> push(List<OutboxRecord> records);
}
