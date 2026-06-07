# Deferred Work

## Deferred from: code review of 2-1-event-sourced-sync-engine-foundation (2026-06-07)

- **Outbox box never opened in app / no EventStore provider** — AC#1's runtime wiring: nothing opens `Box<OutboxRecord>` at app startup and no Riverpod provider exposes `EventStore`/`SyncQueue` (engine is test-injectable only). Deferred to Story 2.2: no event producer exists before 2.2, so the box-open (in `bootstrap.dart` after `registerAdapters()`) + provider wiring lands with the first emitter (`preoccupation.captured`).
- **`SyncQueue.flush()` partial-failure / retry semantics** — `flush()` marks records `sent` then awaits `client.push()`; if push throws, records stay `sent` (re-picked up by the next `pending()`/flush, which is offline-tolerant) but the exception propagates with no backoff/retry policy. Revisit when the real reconciliation transport is wired in Story 2.2.
- **Harden envelope deserialization at the backend boundary** — `EventEnvelope.fromJson` and `OutboxRecord.toEnvelope` assume well-formed JSON (missing keys, non-Map payload, non-numeric `schema_version`, malformed ISO-8601, malformed `payloadJson`). Current inputs are engine-produced or test fixtures; add contextual `FormatException` validation at the real (untrusted) backend boundary introduced in Story 2.2.
- **Contract-parity regex robustness** — `event_contract_parity_test.dart` extracts keys via a `dotAll` regex over the `EVENT_ENVELOPE_KEYS` block; a quoted string inside a comment within the array literal could be captured. Minor test-only hardening (strip comments before extracting keys).
