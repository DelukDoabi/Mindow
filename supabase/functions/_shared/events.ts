// Canonical event envelope contract for the event-sourced sync engine.
//
// This MUST stay in parity with `lib/core/sync/domain_event.dart`
// (`EventEnvelope` / `eventEnvelopeKeys`). The Dart test
// `test/core/sync/event_contract_parity_test.dart` fails CI if the key sets
// drift apart.
//
// Wire format is snake_case; the Dart side maps to camelCase.
//
// NOTE on `user_id`: the client never sends `user_id`. The backend derives it
// from the authenticated JWT and stamps it (alongside `received_at`) on insert.
// It is therefore NOT part of this client-emitted envelope contract.

/**
 * The serialized envelope around a domain event, as stored in the `events`
 * log and exchanged with the reconciliation function.
 */
export interface EventEnvelope {
  /** Globally unique id for this event (idempotency key). */
  event_id: string;
  /** Id of the aggregate this event mutates. */
  aggregate_id: string;
  /** Stable discriminator used for routing/decoding. */
  event_type: string;
  /** Envelope schema version, used for upcasting. */
  schema_version: number;
  /** Client creation time, ISO-8601 UTC. */
  created_at: string;
  /** Server receipt time, ISO-8601 UTC, or null until acknowledged. */
  received_at: string | null;
  /** The event-specific payload. */
  payload: Record<string, unknown>;
}

/**
 * The canonical, ordered set of envelope keys on the wire. Single source of
 * truth the Dart parity test compares against `eventEnvelopeKeys`.
 */
export const EVENT_ENVELOPE_KEYS = [
  "event_id",
  "aggregate_id",
  "event_type",
  "schema_version",
  "created_at",
  "received_at",
  "payload",
] as const;
