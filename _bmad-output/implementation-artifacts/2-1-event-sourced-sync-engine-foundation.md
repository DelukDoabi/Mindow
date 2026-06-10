---
baseline_commit: 20f28fd9b3abe67361633c15b4c923868e1cfbbe
---

# Story 2.1: Event-sourced sync engine foundation

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a developer,
I want the generic, business-agnostic event-sourced sync engine in place,
so that every feature can emit and replay domain events idempotently, offline-first.

## Acceptance Criteria

1. **Given** the foundation, **When** an event is emitted, **Then** it is written to a Hive outbox with lifecycle states `local → sent → acked`, and the local Hive store is the source of truth (NFR-3).
2. **And** replay is idempotent — re-applying the same `event_id` is a no-op — and events are processed ordered by `received_at` with `event_id` as the deterministic tie-break.
3. **And** a convergence harness driven by versioned fixtures (`test/core/sync/fixtures/v{schema_version}/`) runs as a CI gate that FAILS if any `schema_version` reachable by the engine has no fixture directory.
4. **And** `core/sync` stays business-agnostic (no Preoccupation/Mission/feature types leak in), and the shared event contract `supabase/functions/_shared/events.ts` ↔ `lib/core/sync/domain_event.dart` parity is CI-guarded.

## Tasks / Subtasks

- [x] **Task 1 — Event store / Hive outbox** (AC: #1)
  - [x] Create `lib/core/sync/event_store.dart`: a persisted `OutboxRecord` wrapping a serialized `DomainEvent` envelope plus an `OutboxState { local, sent, acked }` enum and `receivedAt` (nullable until server-acked).
  - [x] Add the FIRST real Hive `TypeAdapter`(s) via `hive_ce_generator`: create `lib/core/sync/hive_adapters.dart` with `@GenerateAdapters([AdapterSpec<OutboxRecord>(), AdapterSpec<OutboxState>()])`, run `build_runner`, and register through the generated `hive_registrar.g.dart` `HiveRegistrar` extension.
  - [x] Append the new typeId(s) to `lib/core/sync/hive_registry.dart` (start at `firstAvailableTypeId = 10`; e.g. `OutboxState` = 10, `OutboxRecord` = 11) — append-only, never reuse.
  - [x] Expose an `EventStore` API: `append(DomainEvent)` → writes a `local` record; `markSent(eventId)`, `markAcked(eventId, receivedAt)`; query helpers (`pending()`, `all()`). Hive box is opened in bootstrap (or lazily, test-injectable).
  - [x] `append` of an already-present `event_id` is a no-op (idempotent write).

- [x] **Task 2 — Replay engine** (AC: #2)
  - [x] Create `lib/core/sync/replay_engine.dart`: replays a list/stream of records into a caller-supplied reducer, ordered by `received_at` ascending, tie-break by `event_id` (lexicographic).
  - [x] Idempotency: maintain a seen-`event_id` set so a duplicate event is skipped (no-op), never double-applied.
  - [x] Records still `local` (no `received_at`) order AFTER acked records or by a documented rule — define and test the ordering of not-yet-received events explicitly.
  - [x] Keep the reducer generic (`T Function(T state, DomainEvent event)`) — no feature types.

- [x] **Task 3 — Sync queue with injectable clock** (AC: #1, #2)
  - [x] Create `lib/core/sync/sync_queue.dart`: an abstract queue over the `EventStore` with an injectable `Clock` (or `DateTime Function()`), so tests control time and ordering deterministically.
  - [x] No network here yet — reconciliation transport (`reconciliation_client.dart`) is stubbed/abstract; Story 2.2+ wires Supabase. Document the seam.

- [x] **Task 4 — Schema versioning & upcasters** (AC: #3)
  - [x] Create `lib/core/sync/upcasters/upcaster_registry.dart`: pure `vN → vN+1` upcasting functions applied at READ/replay time only (never rewrite stored history).
  - [x] Define `currentSchemaVersion` and make the set of supported versions enumerable so the fixture gate can assert coverage.

- [x] **Task 5 — Convergence harness + versioned fixtures (CI gate)** (AC: #3)
  - [x] Create `test/core/sync/fixtures/v1/` with at least one fixture (input event stream + expected converged projection) using a TEST-ONLY fake event (e.g. `CounterIncremented`) so the engine stays business-agnostic.
  - [x] Create `test/core/sync/convergence_harness_test.dart`: loads every `v{n}/` fixture, replays through the engine + upcasters, asserts convergence, and asserts idempotency (replaying twice == once) and order-independence (shuffled input converges identically).
  - [x] Add a gate assertion: for every supported `schema_version` (1..currentSchemaVersion), a `v{n}/` fixture directory MUST exist, else the test FAILS.
  - [x] Wire the harness into CI: add a dedicated step in `.github/workflows/ci.yml` (alongside the existing "Hive registry gate") so the convergence gate runs explicitly.

- [x] **Task 6 — Shared event contract parity (CI gate)** (AC: #4)
  - [x] Create `supabase/functions/_shared/events.ts`: the envelope contract mirroring `domain_event.dart` — `event_id`, `aggregate_id` (or `user_id` per architecture), `event_type`, `schema_version`, `created_at`, `received_at`. Document the snake_case (wire) ↔ camelCase (Dart) boundary.
  - [x] Create `test/core/sync/event_contract_parity_test.dart`: parses both `domain_event.dart` field names and `_shared/events.ts` field names and asserts the envelope keys match (a drift fails CI). Keep it tolerant of comments/formatting.

- [x] **Task 7 — Validate & wire-up**
  - [x] `dart run build_runner build` (no `--delete-conflicting-outputs`), `flutter analyze` (0 issues), `flutter test` (all green incl. new gates), `dart format lib test`.
  - [x] Confirm `core/sync` imports nothing from `lib/features/**` (business-agnostic).

### Review Findings

_Code review 2026-06-07 (commit `7ad00ae`). Layers: Blind Hunter, Edge Case Hunter, Acceptance Auditor — all completed._

- [x] [Review][Patch] Fixture loader throws at test-collection time when a `v{n}` dir is missing [test/core/sync/convergence_harness_test.dart:_loadFixtures] — `_loadFixtures` now guards with `existsSync()` and returns `[]` when the fixture directory is absent, preserving the dedicated coverage-gate failure message.
- [x] [Review][Patch] `UpcasterRegistry.upcast` silently passes through future-versioned envelopes [lib/core/sync/upcasters/upcaster_registry.dart] — `upcast` now fails loudly with `StateError` when `envelope.schemaVersion > currentSchemaVersion`; covered by a dedicated unit test.
- [x] [Review][Defer] Outbox box never opened in app / no EventStore provider [lib/app/bootstrap.dart] — deferred to Story 2.2: no event producer exists before 2.2, so the box-open + Riverpod provider wiring lands with the first emitter (`preoccupation.captured`); the engine stays test-injectable until then.
- [x] [Review][Defer] `SyncQueue.flush()` partial-failure / retry semantics [lib/core/sync/sync_queue.dart] — deferred, revisit when the real reconciliation transport lands in Story 2.2.
- [x] [Review][Defer] Harden `EventEnvelope.fromJson` / `OutboxRecord.toEnvelope` against malformed/foreign JSON [lib/core/sync/domain_event.dart, lib/core/sync/event_store.dart] — deferred, validate at the real backend boundary introduced in Story 2.2 (current inputs are engine-produced or test fixtures).
- [x] [Review][Defer] Contract-parity regex robustness vs. comments/strings [test/core/sync/event_contract_parity_test.dart] — deferred, minor test-only hardening.

## Dev Notes

### What exists today (read before coding)

- `lib/core/sync/domain_event.dart` — already defines the **abstract** `DomainEvent` envelope: `eventId`, `aggregateId`, `occurredAt` (UTC), `schemaVersion` (default 1), abstract `eventType`, abstract `toJson()`. Architecture calls for an `abstract sealed` base eventually, BUT concrete events are per-feature and land in later stories (e.g. `preoccupation.captured` in 2.2). For 2.1 keep the base business-agnostic; use a TEST-ONLY fake event for the harness. Do NOT add feature events here. [Source: lib/core/sync/domain_event.dart]
- `lib/core/sync/hive_registry.dart` — append-only typeId registry, `firstAvailableTypeId = 10`, 0–9 reserved, guarded by `test/core/sync/hive_registry_test.dart` (the existing CI gate). This story adds the FIRST real entries. NEVER reuse/renumber. [Source: lib/core/sync/hive_registry.dart]
- `supabase/functions/_shared/events.ts` — does NOT exist yet; create it in Task 6. `_shared/cors.ts` exists. The GDPR functions (`account-export`, `account-delete`) are deployed and unrelated to the engine internals. [Source: supabase/functions/]
- Hive migration is DONE: use `hive_ce` / `hive_ce_flutter` / `hive_ce_generator`. Adapters use `@GenerateAdapters` (no per-field annotations) + the generated `HiveRegistrar` extension to register all adapters in one call. typeId max 65439; supports Sets, Freezed, constructor defaults. [Source: pubspec.yaml, /memories/repo/mindow.md]

### Architecture constraints (MUST follow)

- **`core/sync` is GENERIC ENGINE ONLY — business-agnostic.** No feature model may leak in. [Source: architecture.md#Complete Project Directory Structure]
- **Local store = Hive, offline-first, local source of truth.** Backend `events` log is authoritative server-side; client outbox is `local → sent → acked`. [Source: architecture.md#Data Architecture]
- **Idempotency:** `events.event_id` is the idempotency key; server uses `INSERT ... ON CONFLICT (event_id) DO NOTHING` (duplicate = success, not error). Client replay is a no-op by `event_id`. [Source: architecture.md#Naming Patterns, #Communication Patterns]
- **Ordering:** replay ordered by `received_at`, tie-break `event_id`. [Source: architecture.md#Complete Project Directory Structure — replay_engine.dart]
- **Event envelope fields:** `event_id` (uuid, client-generated), `user_id`, `schema_version` (int), `created_at` (client ISO-8601 UTC), `received_at` (server ISO-8601 UTC). Note the doc uses `user_id`; the Dart base currently uses `aggregateId`. RECONCILE in this story: keep the Dart envelope and the `events.ts` contract aligned (decide whether the aggregate id is `aggregateId`/`aggregate_id` and whether `user_id` is a separate field — document the mapping in both files and assert it in the parity test). [Source: architecture.md#Naming Patterns]
- **Schema evolution:** log is append-only AND immutable; never rewrite history. Add `schema_version`; apply pure upcasting (`vN → vN+1`) at READ/replay time only. [Source: architecture.md#Communication Patterns]
- **Time authority:** ISO-8601 UTC on the wire; convert to local only at render. Use an injectable clock in the queue for deterministic tests. [Source: architecture.md#Format Patterns]
- **Derived projections** (load, streak, level, garden) are computed from the event log, never stored as mutated counters — the replay engine is the substrate for all of them. [Source: architecture.md#Communication Patterns]
- **Code-gen is fixed:** `freezed` for domain/data models, `riverpod_generator` for providers. If `OutboxRecord` benefits from `freezed`, use it (hive_ce_generator supports Freezed). A single committed `build.yaml` governs `field_rename`. [Source: architecture.md#Naming Patterns]

### Project Structure Notes

Target files for this story (create under `lib/core/sync/`, business-agnostic):
- `event_store.dart` (Hive outbox `local → sent → acked`)
- `sync_queue.dart` (injectable clock; transport seam stubbed)
- `replay_engine.dart` (ordered by `received_at`, tie-break `event_id`; idempotent)
- `reconciliation_client.dart` (abstract/stub — real Supabase wiring deferred to 2.2+)
- `upcasters/upcaster_registry.dart` (read-time schema migrations)
- `hive_adapters.dart` (+ generated `hive_adapters.g.dart`, `hive_registrar.g.dart`)
- update `hive_registry.dart` (append typeIds)

Tests mirror lib under `test/core/sync/`:
- `convergence_harness_test.dart` + `fixtures/v1/...`
- `event_contract_parity_test.dart`
- `event_store_test.dart`, `replay_engine_test.dart` (unit)

Server contract: `supabase/functions/_shared/events.ts` (NEW).

No conflicts with the flat-vs-split rule: `core/sync` already exists as a dedicated module (it "touches the sync engine", so the split is justified). [Source: architecture.md#Folder Granularity Rule]

### Testing standards

- `flutter_test`; the convergence harness is the reference sync test and a CI gate. Mirror lib structure under `test/`. Use injected clock/queue for determinism (no real time, no network). [Source: architecture.md#Infrastructure & Deployment, #Frontend Architecture]
- Keep all engine tests free of feature types — use a local fake event in the test tree.
- Run the existing Hive registry gate plus the two new gates (convergence, parity) locally before commit.

### Previous story intelligence (Epic 1)

- **build_runner:** omit `--delete-conflicting-outputs` (flag removed → warns ignored). ~160s. This story DOES change generated output (first adapters) so build_runner MUST run. [Source: /memories/repo/mindow.md]
- **Strict very_good_analysis lints:** `package:mindow/...` imports only; single quotes unless the string contains an apostrophe → use DOUBLE quotes; `cascade_invocations` (`ref.x();ref.y()` → `ref..x()..y()`); `avoid_redundant_argument_values`; `prefer_const_declarations`; `sort_pub_dependencies`. Run `dart format lib test` before commit. [Source: /memories/repo/mindow.md]
- **Commit hang workaround:** write the message to `.git/COMMIT_MSG_x.txt` then `git commit -F`. Always `git push` after commit. [Source: /memories/repo/mindow.md]
- **hive_registry.dart is CI-guarded — do NOT edit casually; only append.** [Source: lib/core/sync/hive_registry.dart]
- **Single-boundary pattern** (repository holding nullable client; `_requireClient()` throws on invoke when null, never on build) is the established way to keep Supabase out of widgets — `reconciliation_client.dart` should follow the same injectable, offline-tolerant shape. [Source: lib/features/auth/auth_repository.dart pattern]

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.1: Event-sourced sync engine foundation]
- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture]
- [Source: _bmad-output/planning-artifacts/architecture.md#Communication Patterns]
- [Source: _bmad-output/planning-artifacts/architecture.md#Naming Patterns]
- [Source: _bmad-output/planning-artifacts/architecture.md#Complete Project Directory Structure]
- [Source: lib/core/sync/domain_event.dart]
- [Source: lib/core/sync/hive_registry.dart]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (GitHub Copilot)

### Debug Log References

- `dart run build_runner build` — wrote 3 outputs (`hive_adapters.g.dart`, `hive_adapters.g.yaml`, `hive_registrar.g.dart`) in 106s. typeIds assigned `OutboxState` = 10, `OutboxRecord` = 11 (matches the `hive_registry.dart` CI gate).
- `flutter analyze` — No issues found.
- `flutter test` — All 57 tests passed (27 in `test/core/sync`).
- `flutter test test/core/sync/convergence_harness_test.dart test/core/sync/upcaster_registry_test.dart` — All tests passed (8 + 1), validating both review patches.

### Completion Notes List

- **Envelope reconciliation decision:** the Dart side keeps `aggregateId` ↔ wire `aggregate_id`. The authoritative `user_id` is NOT part of the client-emitted envelope — the backend derives it from the authenticated JWT and stamps it alongside `received_at` on insert. Documented in both `domain_event.dart` and `supabase/functions/_shared/events.ts`; the 7 envelope keys (`event_id`, `aggregate_id`, `event_type`, `schema_version`, `created_at`, `received_at`, `payload`) are the single source of truth, parity-gated.
- **Storage stability:** `OutboxRecord` stores the payload as a JSON-encoded `String` (`payloadJson`) rather than a nested `Map`, sidestepping Hive nested-map typing quirks while keeping `EventEnvelope.payload` a `Map`.
- **Replay ordering of local events:** not-yet-received (`receivedAt == null`) events sort AFTER all received ones; ties (and the local tail) break by `event_id` lexicographically. Explicitly tested.
- **Transport seam:** `ReconciliationClient` is an abstract interface only; `SyncQueue.flush()` is a no-op when no client is wired (offline-first / scaffold builds). The concrete Supabase wiring is deferred to Story 2.2+. `SyncQueue` uses an injectable `Clock` (default `systemUtcClock`) used as the `received_at` fallback when the backend does not acknowledge a record.
- **Schema versioning:** `currentSchemaVersion = 1`; `supportedSchemaVersions` drives the convergence fixture-coverage gate (every `v{n}/` must have ≥1 fixture). No upcasters needed yet (`UpcasterRegistry.empty()`).
- **Review patch closure:** `_loadFixtures` now returns an empty list for missing `v{n}` directories (preventing collection-time `FileSystemException`), and `UpcasterRegistry.upcast` now rejects future schema versions with a loud `StateError`.
- **Three CI gates added** to `.github/workflows/ci.yml`: convergence gate, contract parity gate (alongside the pre-existing Hive registry gate).
- **`.g.yaml` committed** to pin typeId/field-index assignments for offline data stability.
- `Hive.registerAdapters()` is now called in `lib/app/bootstrap.dart` right after `Hive.initFlutter()`.

### File List

**Created (lib):**
- `lib/core/sync/event_store.dart`
- `lib/core/sync/sync_queue.dart`
- `lib/core/sync/replay_engine.dart`
- `lib/core/sync/reconciliation_client.dart`
- `lib/core/sync/hive_adapters.dart`
- `lib/core/sync/upcasters/upcaster_registry.dart`
- `lib/core/sync/hive_adapters.g.dart` (generated)
- `lib/core/sync/hive_adapters.g.yaml` (generated)
- `lib/core/sync/hive_registrar.g.dart` (generated)

**Modified (lib):**
- `lib/core/sync/domain_event.dart` (added `EventEnvelope`, `eventEnvelopeKeys`, `DomainEventRegistry`, `toEnvelope`)
- `lib/core/sync/hive_registry.dart` (appended typeIds 10, 11)
- `lib/app/bootstrap.dart` (register adapters)
- `lib/core/sync/upcasters/upcaster_registry.dart` (rejects future schema versions with `StateError`)

**Created (server):**
- `supabase/functions/_shared/events.ts`

**Created (tests):**
- `test/core/sync/event_store_test.dart`
- `test/core/sync/replay_engine_test.dart`
- `test/core/sync/sync_queue_test.dart`
- `test/core/sync/convergence_harness_test.dart`
- `test/core/sync/event_contract_parity_test.dart`
- `test/core/sync/upcaster_registry_test.dart`
- `test/core/sync/support/counter_event.dart`
- `test/core/sync/fixtures/v1/basic_convergence.json`
- `test/core/sync/fixtures/v1/mixed_ordering.json`

**Modified (tests):**
- `test/core/sync/convergence_harness_test.dart` (`_loadFixtures` handles missing directories safely)

**Modified (CI):**
- `.github/workflows/ci.yml` (convergence + parity gates)

## Change Log

| Date       | Version | Description                                              | Author |
| ---------- | ------- | -------------------------------------------------------- | ------ |
| 2026-06-07 | 0.1     | Story created                                            | Bob    |
| 2026-06-07 | 1.0     | Event-sourced sync engine foundation implemented (review) | Amelia |
| 2026-06-10 | 1.1     | Closed review patches: missing fixture-dir guard + future schema fail-loud | Amelia |
