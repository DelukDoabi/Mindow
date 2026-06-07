# Story 2.2: Capture a Preoccupation (offline-first)

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want to capture a worry in under 3 seconds even offline,
so that nothing is lost from my mind.

## Acceptance Criteria

1. **Given** Home, **When** I tap the single capture input (reachable in ≤1 tap, UX-DR12) and submit non-empty text, **Then** an open Preoccupation appears immediately in pending state (FR-4, NFR-1) — the submit-to-visible path is local-only and never awaits the network or AI.
2. **And** capture is event-sourced: submitting emits exactly one `preoccupation.captured` `DomainEvent` (schema_version 1) written to the Hive outbox (`OutboxState.local`) as the local source of truth (NFR-3), with a client-generated UUID v4 `event_id` and `aggregate_id`, and `created_at` in UTC.
3. **And** capture succeeds offline: with no backend transport available the Preoccupation persists durably in the local outbox and surfaces no error banner (NFR-3, UX-DR17 offline); the durable outbox is the reconnect queue (network reconcile transport is out of scope for this story — see Dev Notes).
4. **And** the pending Preoccupation list is a derived projection replayed from the outbox event log (never a stored counter): re-capturing the same `event_id` is a no-op and the projection is order-deterministic (`received_at` asc, `event_id` tie-break), reusing the Story 2.1 `ReplayEngine`.
5. **And** the interaction never blocks on AI Analysis: no AI/categorisation/weighing call is made in this story; the captured item shows `null` Mental Weight (the architecture's "genuinely pending" signal) until Epic 2.3 weighs it.
6. **And** empty/whitespace-only input is rejected client-side (no event emitted), the input clears after a successful capture, and a soft, no-guilt confirmation is shown.

## Tasks / Subtasks

- [ ] **Task 1 — `preoccupation.captured` domain event** (AC: #2, #5)
  - [ ] Create `lib/features/brain_dump/domain/preoccupation_captured_event.dart`: a `class PreoccupationCapturedEvent extends DomainEvent` (from `package:mindow/core/sync/domain_event.dart`) with `eventType => 'preoccupation.captured'`, `schemaVersion = 1`, payload field `content` (String, the raw user text). `aggregateId` IS the preoccupation id.
  - [ ] Implement `toJson()` emitting the payload in snake_case (`content`) and a `factory PreoccupationCapturedEvent.fromJson(Map<String, dynamic>)` round-tripping it (mirror the freezed+`json_serializable` shape of `onboarding_answers.dart`, but `DomainEvent` is a plain abstract class — extend it, do not freeze the event base).
  - [ ] Keep `core/sync` business-agnostic: this event lives under `lib/features/**`, never in `lib/core/sync/**` (Story 2.1 CI invariant).

- [ ] **Task 2 — Register the event + app DomainEventRegistry** (AC: #4)
  - [ ] Create `lib/features/brain_dump/brain_dump_event_registry.dart` (or a `core/sync` app-registry composition root) that builds a `DomainEventRegistry` and registers `'preoccupation.captured' → PreoccupationCapturedEvent.fromJson` so replay can decode it.
  - [ ] Expose it via a `@Riverpod(keepAlive: true) DomainEventRegistry domainEventRegistry(Ref ref)` provider.

- [ ] **Task 3 — Runtime wiring of the Story 2.1 engine** (AC: #2, #3) — _resolves the deferred item from Story 2.1 review_
  - [ ] In `lib/app/bootstrap.dart`, after `Hive.registerAdapters()`, open the outbox box once for the app lifetime: `final outboxBox = await Hive.openBox<OutboxRecord>('outbox');` (keep it open; mirror the offline-first ordering comment already there).
  - [ ] Seed the box into Riverpod the same way `onboardingCompleteProvider` is seeded in `bootstrap.dart`: add an `outboxBoxProvider` (hand-written `Provider<Box<OutboxRecord>>` that throws unless overridden) and override it with the opened box in the `ProviderScope`.
  - [ ] Add `@Riverpod(keepAlive: true) EventStore eventStore(Ref ref)` (wraps the seeded box) and `@Riverpod(keepAlive: true) SyncQueue syncQueue(Ref ref)` (constructed with `store: eventStore`, `client: null` — no transport yet, `flush()` is a documented no-op per Story 2.1).
  - [ ] Do NOT build a Supabase `ReconciliationClient` here — leaving `client` null is the offline-first capture path and keeps the AC#3 "no error banner" guarantee. Document the seam.

- [ ] **Task 4 — Preoccupation read model + projection** (AC: #1, #4, #5)
  - [ ] Create `lib/features/brain_dump/domain/preoccupation.dart`: a `freezed` view model `{ String id; String content; DateTime createdAt; int? mentalWeightKg; }` where `mentalWeightKg == null` means pending (architecture format rule: null weight = genuinely unknown, distinct from any floor). Add `bool get isPending => mentalWeightKg == null;`. This is a derived projection only — NOT a Hive `TypeAdapter`, so it allocates NO new typeId.
  - [ ] Create the projection reducer + a `openPreoccupations` derivation: read `EventStore.all()` → envelopes → `ReplayEngine.replay` with a reducer folding `PreoccupationCapturedEvent` into a `Map<aggregateId, Preoccupation>` (content + createdAt, weight null). Open = not soft-deleted (no deletion event exists until Story 2.4, so all captured items are open here).
  - [ ] Expose `@riverpod Future<List<Preoccupation>> openPreoccupations(Ref ref)` (most-recent first) reading the projection through the repository.

- [ ] **Task 5 — Brain dump repository** (AC: #1, #2, #3, #6)
  - [ ] Create `lib/features/brain_dump/brain_dump_repository.dart` mirroring `OnboardingRepository`'s shape: constructor takes `SyncQueue` (+ the registry/replay deps it needs). Add `uuid` to `pubspec.yaml` and use `const Uuid().v4()` for ids.
  - [ ] `Future<void> capturePreoccupation(String content)`: trims input, rejects empty/whitespace (throws/returns without emitting — Task 6 validates at the UI), generates one UUID v4 used as BOTH `eventId` and `aggregateId`, builds `PreoccupationCapturedEvent`, and `await syncQueue.enqueue(event)` (local append, idempotent, never blocks on network/AI).
  - [ ] `Future<List<Preoccupation>> getOpenPreoccupations()`: returns the projection from Task 4.
  - [ ] Add `@riverpod BrainDumpRepository brainDumpRepository(Ref ref)`.

- [ ] **Task 6 — Home capture UI** (AC: #1, #6)
  - [ ] Replace the `_PlaceholderHome` in `lib/core/router/app_router.dart` with a real `HomeScreen` (new file `lib/features/brain_dump/presentation/home_screen.dart`), keeping the existing settings `IconButton` affordance and `AuroreCanvas`.
  - [ ] Add a single-line capture `TextField` (glass surface, Aurore tokens — reuse the design-system theme, no hard-coded colors) reachable with ≤1 tap, plus a submit affordance. On submit: validate non-empty, call `brainDumpRepository.capturePreoccupation`, clear the field, show a soft confirmation (e.g. `SnackBar`), and let the `openPreoccupations` provider refresh so the item appears in pending state immediately.
  - [ ] Render the pending items as a simple list (content + a muted "pending" affordance). The animated backpack / kg figure is Story 2.6 — keep visuals minimal here, just enough to satisfy "appears immediately in pending state".
  - [ ] Watch the async projection with `AsyncValue` (Riverpod), show the empty-state copy when there are none.

- [ ] **Task 7 — Localization (French = source of truth)** (AC: #1, #6)
  - [ ] Add ARB keys to `assets/l10n/app_fr.arb` then mirror in `assets/l10n/app_en.arb`: capture placeholder, submit label, success confirmation, pending label, and an empty-backpack state. Suggested FR (tone-gated, no guilt — confirm against UX): placeholder `"Qu'est-ce qui occupe ton esprit ?"`, submit `"Déposer"`, success `"C'est noté. Ton esprit s'allège."`. Provide `@key` descriptions for each.
  - [ ] Run `flutter gen-l10n` (ARB keys changed) and reference via `AppLocalizations.of(context)`.

- [ ] **Task 8 — Tests** (AC: all)
  - [ ] `test/features/brain_dump/domain/preoccupation_captured_event_test.dart`: `eventType == 'preoccupation.captured'`, `toJson`/`fromJson` round-trip (snake_case payload), and decode through the `DomainEventRegistry`.
  - [ ] `test/features/brain_dump/brain_dump_repository_test.dart`: capture appends one local outbox record (real Hive box in a temp dir, register adapters like `event_store_test.dart` does); idempotent re-enqueue with the same id is a no-op; empty/whitespace input emits nothing; `getOpenPreoccupations()` returns the captured item with `mentalWeightKg == null`.
  - [ ] `test/features/brain_dump/preoccupation_projection_test.dart`: projection ordering/idempotency via `ReplayEngine` (two captures, shuffled order converge identically; duplicate `event_id` counted once).
  - [ ] `test/features/brain_dump/presentation/home_screen_test.dart`: pump `HomeScreen` in `ProviderScope` + `MaterialApp` with localization delegates; capture input renders the FR placeholder; submitting non-empty text invokes the repository and clears the field; submitting empty text emits nothing; a captured item appears in the pending list; no error banner with a null reconciliation client (offline).

- [ ] **Task 9 — Validate & wire-up**
  - [ ] `dart run build_runner build` (no `--delete-conflicting-outputs`), then `flutter gen-l10n`, `flutter analyze` (0 issues), `flutter test` (all green), `dart format lib test`.
  - [ ] Confirm `lib/core/sync/**` still imports nothing from `lib/features/**` (Story 2.1 business-agnostic invariant holds).

## Dev Notes

### What exists today (read before coding)

- **Story 2.1 sync engine** under [lib/core/sync](../../lib/core/sync) is complete and test-injectable but NOT wired into the running app:
  - `domain_event.dart` — `abstract class DomainEvent` (`eventId`, `aggregateId`, `occurredAt` UTC, `schemaVersion`, abstract `eventType`/`toJson()`, `toEnvelope({receivedAt})`), `EventEnvelope` (snake-case wire keys), `DomainEventRegistry` (`register`/`isRegistered`/`decode` → throws `StateError` if unknown).
  - `event_store.dart` — `enum OutboxState { local, sent, acked }`, `OutboxRecord` (stores `payloadJson` = `jsonEncode(event.toJson())`), `EventStore(this._box)` over `Box<OutboxRecord>` with idempotent `append`, `markSent`, `markAcked`, `all()`, `pending()`. Hive typeIds: `OutboxState`=10, `OutboxRecord`=11 (registry CI-guarded, append-only).
  - `sync_queue.dart` — `SyncQueue({required store, ReconciliationClient? client, Clock clock})`; `enqueue(event) => _store.append(event)`; `flush()` is a no-op when `client == null`.
  - `replay_engine.dart` — `ReplayEngine.replay<S>({initialState, envelopes, registry, reducer})`, orders by `received_at` (nulls last) tie-break `event_id`, dedups by `event_id`.
  - `reconciliation_client.dart` — `abstract interface class ReconciliationClient { Future<Map<String, DateTime>> push(List<OutboxRecord>); }` (no concrete impl yet).
- **Bootstrap** [lib/app/bootstrap.dart](../../lib/app/bootstrap.dart) calls `Hive.registerAdapters()` but opens NO outbox box and exposes NO engine providers. It seeds `onboardingCompleteProvider` via a `ProviderScope` override — mirror that seeding pattern for the outbox box.
- **Home** is a `_PlaceholderHome` inside [lib/core/router/app_router.dart](../../lib/core/router/app_router.dart) at `Routes.home = '/'`. Replace it with the real `HomeScreen`. Keep the settings affordance and `AuroreCanvas`.
- **Repository pattern** to mirror: [lib/features/onboarding/onboarding_repository.dart](../../lib/features/onboarding/onboarding_repository.dart) (lazy Hive box + `@Riverpod(keepAlive: true)` provider).
- **Model pattern** to mirror: [lib/features/onboarding/onboarding_answers.dart](../../lib/features/onboarding/onboarding_answers.dart) (`freezed` + `json_serializable`).

### Technical guardrails (architecture)

- **Event naming:** `domain.action` past tense → `preoccupation.captured` (FR-4). Every event carries `event_id` (UUID v4, client-generated), `schema_version` (int), `created_at` (client, ISO-8601 UTC), `received_at` (server, set on ack — null locally). `user_id` is NOT in the client envelope (server-derived from JWT). [Source: architecture.md#Events, #Data Architecture]
- **Offline-first:** Hive is the local source of truth; the append-only event log is authoritative; derived state (open items, mental load) is ALWAYS a projection, never a stored/mutated counter. [Source: architecture.md#Data Architecture, #Communication Patterns]
- **Null weight = pending:** `null` Mental Weight means "genuinely unknown (pending)" and MUST be distinguishable from any fallback floor. Story 2.2 leaves weight null; Story 2.3 assigns it (frozen + versioned). [Source: architecture.md#Format Patterns]
- **Casing boundary:** snake_case on the wire/JSON, camelCase in Dart; conversion lives ONLY in `fromJson`/`toJson`. [Source: architecture.md#Naming Patterns]
- **Code-gen is fixed:** `freezed` for models, `riverpod_generator` (`@riverpod`) for providers — no hand-rolled provider mix (except the bootstrap-seeded `Provider` override pattern already used for env/onboarding). [Source: architecture.md#Naming Patterns]
- **Feature-first structure:** `lib/features/<feature>/{data,domain,presentation}/`; start FLAT and split when the folder grows. This story uses `lib/features/brain_dump/`. [Source: architecture.md#Structure Patterns]
- **Crisis-gate / AI:** explicitly OUT of scope — capture never calls AI (NFR-2 / AC#5). The AI pipeline + synchronous crisis-gate is Story 2.3. [Source: epics.md#Story 2.3]

### Scope boundaries (avoid over-engineering)

- **In scope:** local capture pipeline end-to-end — event → outbox → optimistic projection → Home UI, fully offline, no error banner, no AI.
- **Out of scope (do NOT build here):**
  - The Supabase reconcile network transport / concrete `ReconciliationClient` (`SyncQueue.client` stays null; the durable outbox is the reconnect queue). `flush()` partial-failure/retry semantics were deferred from Story 2.1 and remain deferred until the transport lands.
  - Persisting `Preoccupation` as its own Hive type — it is a derived projection, so NO new typeId is allocated (the outbox `OutboxRecord` is the only durable store).
  - Edit/delete (Story 2.4), AI weighing/category (Story 2.3), animated backpack + kg figure (Story 2.6), open-items count & weekly progression visuals (Story 2.7).
  - Envelope deserialization hardening at the backend boundary (deferred from Story 2.1 — there is no backend boundary in this story; inputs are engine-produced or test fixtures).

### Previous story intelligence (Story 2.1 review)

- Two patches were left as tracked action items in Story 2.1 and are NOT part of this story's scope (fixture-loader `existsSync` guard; upcaster future-version `StateError`). Do not bundle them unless they block 2.2.
- The **single-boundary pattern** is established: a nullable collaborator that throws/no-ops until wired (e.g. `SyncQueue` no-ops `flush()` with a null client). Reuse it — keep capture working with `client: null`.

### Project Structure Notes

- New feature folder `lib/features/brain_dump/` (FLAT first): `domain/preoccupation_captured_event.dart`, `domain/preoccupation.dart`, `brain_dump_repository.dart`, `brain_dump_event_registry.dart`, `presentation/home_screen.dart`. Tests mirror under `test/features/brain_dump/`.
- Engine providers (`eventStore`, `syncQueue`, `domainEventRegistry`, `outboxBoxProvider`) live in `lib/core/sync/` (composition root for the engine) — the only `core` files this story adds; they import the feature registry only at the bootstrap/composition layer, NOT inside the business-agnostic engine files.
- `uuid` is a new runtime dependency in `pubspec.yaml`.

### Lint / convention reminders

- `package:mindow/...` imports only; single quotes unless the string has an apostrophe → double quotes; imports sorted alphabetically (`dart:` then `package:flutter_test` before `package:mindow`).
- Test imports use `package:flutter_test/flutter_test.dart` (not `package:test/test.dart`).
- `analysis_options.yaml` excludes `*.g.dart`/`*.freezed.dart`/`lib/core/l10n/**`; `public_member_api_docs: false`.
- Run `dart format lib test` before commit; commit any generated `*.g.yaml` (none expected here — no new Hive type).
- Flutter SDK at `C:\src\flutter`; prepend `$env:Path = "C:\src\flutter\bin;" + $env:Path;` before every flutter/dart command. `build_runner` locally WITHOUT `--delete-conflicting-outputs`.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.2: Capture a Preoccupation (offline-first)]
- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture]
- [Source: _bmad-output/planning-artifacts/architecture.md#Implementation Patterns & Consistency Rules]
- [Source: _bmad-output/planning-artifacts/ux-designs/ux-Mindow-2026-06-05/EXPERIENCE.md] (Home capture interaction, offline tone)
- [Source: _bmad-output/planning-artifacts/ux-designs/ux-Mindow-2026-06-05/DESIGN.md] (glass input surface, Aurore tokens, tone gate)
- [Source: _bmad-output/implementation-artifacts/2-1-event-sourced-sync-engine-foundation.md] (engine APIs + deferred wiring)

## Dev Agent Record

### Agent Model Used

_TBD_

### Debug Log References

### Completion Notes List

### File List
