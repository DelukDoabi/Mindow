---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - _bmad-output/planning-artifacts/prds/prd-Mindow-2026-06-05/prd.md
  - _bmad-output/planning-artifacts/prds/prd-Mindow-2026-06-05/addendum.md
  - _bmad-output/planning-artifacts/ux-designs/ux-Mindow-2026-06-05/DESIGN.md
  - _bmad-output/planning-artifacts/ux-designs/ux-Mindow-2026-06-05/EXPERIENCE.md
workflowType: 'architecture'
project_name: 'Mindow'
user_name: 'boss'
date: '2026-06-05'
lastStep: 8
status: 'complete'
completedAt: '2026-06-06'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:** 24 FRs across 14 features, realizing 4 user journeys.
Core loop: Brain Dump (FR-4/5) → AI Analysis (FR-6) → Mental Backpack (FR-7/8/9)
→ Daily Mission (FR-10/11) → Validation (FR-12) → History/Gamification (FR-13/15/16/17).
Cross-cutting: Auth (FR-1/2/3), Notifications (FR-14), Monetization/entitlements
(FR-18/19), Premium AI (Decomposition FR-20, Coaching FR-21, Dashboard FR-22),
Couple Mode (FR-23/24).

**Non-Functional Requirements:** Offline-first capture (never lost), async AI with
pending state + fallback, cross-platform parity (iOS/Android/Web), i18n from launch,
multi-device sync consistency (load/streak/level/garden/history), observability
(crash-free + perf), bounded AI cost.

**Scale & Complexity:**
- Primary domain: full-stack, mobile-first (Flutter) + cloud backend + AI.
- Complexity level: medium-high — driven NOT by feature count but by three properties
  in tension: offline · intimate · shared. These collide in the sync/permission model.
- Estimated architectural components: ~9 (client app, local store/sync engine, auth,
  data/API, AI orchestration, missions engine, gamification, payments/entitlements,
  notifications) + observability/analytics.

### Technical Constraints & Dependencies

Candidate stack (addendum, non-binding, to validate): Flutter · Riverpod · GoRouter ·
Hive · Supabase (Auth/PostgreSQL/Storage/Realtime/Edge Functions) · OpenAI GPT-4o Mini ·
RevenueCat · FCM · PostHog · Sentry. Anti-productivity filter (§1) and tone-as-gate
(§10) are architectural constraints that descend to the data model and reconciliation
strategy — not just the UI. A badly-resolved merge conflict is as much a tone violation
as confetti.

Stack tensions to resolve before committing:
- Supabase Realtime is a freshness bonus for Couple Mode, NOT the sync source of truth.
  The real sync engine is the event model + Edge Functions.
- Hive on Web runs on IndexedDB (quotas, private browsing) — "worry never lost" is
  harder to guarantee on Web; accept degraded Web parity or budget the cost.
- Hive = local source of truth; Supabase = replica (offline-first for real, not a cache).

### Cross-Cutting Concerns Identified

Offline-first & event-sourced sync · async AI orchestration + cost guardrails ·
real-time shared state (Couple Mode) · i18n (UI + notifications + AI outputs) ·
multi-provider auth · subscription entitlements & paywall gating · push notifications ·
GDPR (consent/export/delete) on intimate data · observability · cross-platform parity.

### Architectural Principles Surfaced (Party Mode — Winston/Amelia/John/Sally)

1. **Frozen, versioned Mental Weight.** The kg weight is computed once at capture,
   cached and frozen on the Preoccupation; never silently recalculated. The prompt/model
   version is recorded. The North Star (AI-estimated kg) is only comparable month-over-
   month if calibration is versioned, not drifting per AI deploy. The AI is both judge
   and scorer (SM-C3 inflation risk lives in the architecture itself — the mechanism,
   not good intent, must prevent the number from lying).
2. **A weight shown to a human never worsens silently.** Any fallback weight is a FLOOR,
   not an estimate. Until the AI returns, weight is tenderly indeterminate (nullable),
   never falsely precise. Pending is a state of REST, not a loading spinner.
3. **Event-sourced, idempotent, converge-upward sync.** Validation/streak/garden/level/
   total-kg are DERIVED from an append-only event log, never mutated counters. Conflicts
   reconcile toward the higher state — a technical conflict must never produce an
   emotional regression (no merge-induced streak loss = no streak-guilt).
4. **Optimistic, irreversible relief.** The −kg animation plays locally on tap, never
   waiting for the server. If the server later disputes, the weight is NOT put back.
5. **Invisible offline mechanics.** No "3 items pending", no broken-cloud icon — sync
   plumbing stays invisible; never transfer technical responsibility to the user.
6. **Synchronous crisis-content gate.** A safety classifier runs UPSTREAM of weighing,
   with a path that exits the gamification loop entirely. Product/ethical decision with
   a human owner — not "Autre" category.
7. **Per-worry permission model for Couple Mode.** Household sharing is decided per
   Preoccupation, not per household. Define "what does my partner see of my worries?"
   BEFORE the schema. No sync code until share scope is settled.

### Decisions to Nail Before Implementation

1. Worry state machine: captured → queued → syncing → synced → ai_pending →
   ai_done | ai_failed (client-generated UUID v4 for dedup).
2. Neutral fallback weight constant + Mental Weight → kg scale/calibration (FR-6, Q1).
3. Conflict-resolution matrix: manual override > AI; device A vs B; validate vs delete.
4. Idempotency key per validation/event (replay-safe; never double-counts kg).
5. Couple Mode share scope + Household entity & membership table (FR-23/24).
6. Bounded AI retry (max N, backoff) + per-user AI budget (§9.3 cost guardrail).

### Open Architectural Questions (carried from PRD)

1. Mental Weight → kg scale/calibration & whether it is a displayed truth or internal
   signal (Q1, FR-6) — North Star integrity.
2. AI Analysis latency target & failure fallback semantics (Q7, §8).
3. Crisis-content handling stance (Q3, §9.1) — duty of care.
4. Level/XP thresholds (Q2), notification opt-out granularity (Q4).

## Starter Template Evaluation

### Primary Technology Domain

Cross-platform Flutter application (iOS / Android / Web) with cloud backend (Supabase)
and async AI orchestration — per PRD addendum, mobile-first.

### Starter Options Considered

- **Very Good CLI** (`very_good create flutter_app`): opinionated architecture, flavors
  (dev/staging/prod), built-in l10n, 100% test coverage, CI workflows. Strong fit for
  the i18n-from-launch and testing-discipline NFRs — but defaults to Bloc, conflicting
  with the PRD-prescribed Riverpod.
- **`flutter create` (vanilla)** + manual feature-first wiring of Riverpod + GoRouter +
  Hive + Supabase: full control, exact PRD-stack compliance, but all scaffolding
  (flavors, l10n, CI, test harness) built by hand.
- **Community Riverpod starter** (e.g. Starter Architecture for Flutter): Riverpod +
  GoRouter pre-wired, close to PRD stack, but fewer batteries-included (no flavors/l10n/
  CI out of the box), community maintenance.

### Selected Starter: `flutter create` (vanilla) + feature-first manual wiring

**Rationale for Selection:**
The PRD prescribes Riverpod; Very Good CLI defaults to Bloc, so adopting it would either
overturn a PRD decision or fight the tool. Vanilla `flutter create` keeps exact stack
compliance, while we borrow Very Good CLI's *patterns* (flavors, l10n, test/CI discipline)
— directly serving the i18n-from-launch NFR and the offline/sync convergence test harness.

**Initialization Command:**

```bash
# Flutter 3.44.x stable
flutter create --org com.mindow --platforms ios,android,web \
  --project-name mindow mindow
```

**Architectural Decisions Provided / To Wire:**

**Language & Runtime:** Dart (bundled with Flutter 3.44 stable), null-safety, strict
analysis_options (very_good_analysis lints recommended).

**State Management:** Riverpod (flutter_riverpod) — PRD-prescribed.

**Routing:** GoRouter — PRD-prescribed.

**Local Storage / Offline:** Hive — local source of truth (offline-first), per context
analysis principle "Hive = source of truth, Supabase = replica".

**Backend Client:** supabase_flutter (Auth / PostgreSQL / Storage / Realtime / Edge Fns).

**Styling:** Custom Aurore design system (per UX DESIGN.md tokens) — no UI kit; Inter font.

**i18n:** flutter_localizations + ARB files from project start (i18n-from-launch NFR).

**Flavors:** dev / staging / prod (borrowed from Very Good CLI pattern).

**Testing:** flutter_test + integration_test; event-replay convergence harness for
offline/sync (per Amelia). Target high coverage on domain/sync logic.

**Code Organization:** feature-first (auth, brain_dump, mental_load, missions,
gamification, ai, couple_mode) + shared core (sync engine, design system, l10n).

**Note:** Project initialization using this command should be the first implementation story.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Event-sourced data model with server-side reconciliation (idempotent, converge-up).
- Mental Weight frozen + versioned at capture.
- AI calls server-side only (Edge Functions); OpenAI key never on client.
- Synchronous crisis-content gate upstream of weighing.
- Household + per-worry sharing permission model (Couple Mode).

**Important Decisions (Shape Architecture):**
- Hive = local source of truth; Supabase = replica (offline-first).
- Riverpod + GoRouter + repository/SyncQueue pattern.
- Optimistic, irreversible relief animation.
- RLS per user + conditional partner visibility on shared=true.

**Deferred Decisions (Post-MVP):**
- Exact Level/XP thresholds (cosmetic, tunable post-launch).
- Notification opt-out granularity (global toggle ships MVP minimum).
- Reinforced AI-input anonymization (PRD Standard posture for MVP).

### Data Architecture
- **Local store:** Hive (offline-first, local source of truth). Client-generated UUID v4
  IDs for dedup. Worry state machine: captured → queued → syncing → synced → ai_pending
  → ai_done | ai_failed.
- **Backend:** Supabase PostgreSQL as replica. Append-only `events` log is authoritative;
  `mental_load`, `streak`, `level`, `garden`, `history` are DERIVED projections, never
  mutated counters.
- **Reconciliation:** Supabase Edge Function replays events, idempotent per event_id,
  converges toward higher state (no emotional regression).
- **Mental Weight:** computed once at capture, frozen on the row + `weight_model_version`
  (prompt+model). Never silently recalculated. Manual override > AI.
- **Couple Mode:** `households` + `household_members` tables; per-Preoccupation `shared`
  flag (per-worry permission, not per-household).

### Authentication & Security
- **Auth:** Supabase Auth — Apple, Google, Email (FR-2).
- **Authorization:** Row-Level Security keyed on user_id; partner can read a Preoccupation
  only when shared = true.
- **AI key safety:** OpenAI key lives server-side (Edge Function env), never shipped in
  the Flutter app (OWASP — secret management).
- **Privacy posture:** Standard (PRD §9.2); GDPR export + delete via Edge Functions
  (cascade erase of Preoccupations + derived data).

### API & Communication Patterns
- **Backend access:** Supabase client SDK (PostgREST + RLS) for CRUD; Edge Functions for
  AI orchestration, reconciliation, account export/delete, entitlement webhooks.
- **AI contract:** POST Preoccupation → Edge Function → GPT-4o Mini → { category,
  mentalWeight, effort, estimatedDuration }. Crisis-gate runs first.
- **Cost guardrails:** per-user rate limit, bounded retry (max N + backoff), near-duplicate
  caching (§9.3).
- **Realtime:** Supabase Realtime is a freshness channel for Couple Mode only, NOT the
  sync source of truth.

### Frontend Architecture
- **State:** Riverpod (flutter_riverpod) — PRD-prescribed.
- **Routing:** GoRouter — PRD-prescribed.
- **Offline-first:** repository pattern over an abstract SyncQueue (injectable clock/queue
  for testability). Hive-first reads/writes.
- **Relief UX:** −kg animation plays optimistically on tap; background reconciliation;
  weight never put back.
- **Design system:** custom Aurore tokens (DESIGN.md), Inter font; no third-party UI kit.

### Infrastructure & Deployment
- **Backend host:** Supabase (Postgres, Auth, Storage, Realtime, Edge Functions).
- **Flavors:** dev / staging / prod. CI: analyze + test + build; event-replay convergence
  harness as the reference sync test.
- **Observability:** Sentry (crash/perf), PostHog (funnels/retention + counter-metric
  watch SM-C1/C2/C3).
- **Notifications:** Firebase Cloud Messaging (FCM).
- **Payments:** RevenueCat (Premium entitlements, cross-store purchase/restore; webhook
  → Edge Function updates subscription state).

### Decision Impact Analysis
**Implementation Sequence:**
1. Project init + flavors + design-system foundation.
2. Auth + profile + onboarding.
3. Event log + Hive store + SyncQueue + reconciliation Edge Function.
4. Brain Dump → AI Edge Function (with crisis-gate + frozen weight).
5. Mental Backpack (derived load) + Daily Mission + Validation (optimistic relief).
6. Gamification projections (streak/level/garden/history).
7. Notifications, monetization/entitlements.
8. Premium: Decomposition, Coaching, Dashboard, Couple Mode (Household + sharing).

**Cross-Component Dependencies:**
- Event log + reconciliation underpins backpack, missions, gamification, dashboard.
- AI Edge Function feeds weighing, decomposition, coaching, mission prioritization.
- Household/sharing depends on RLS + per-worry permission decided here.

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** ~20 areas where AI agents could diverge —
DB↔Dart casing boundary, code-gen choice, Hive typeId allocation, event payload
schema/versioning, ARB key naming, error taxonomy, migration ordering, time authority,
projection rebuild parity.

### Naming Patterns

**Database (PostgreSQL):**
- Tables: plural snake_case (`mental_items`, `daily_missions`, `garden_items`,
  `household_members`, `events`). Columns: snake_case; PK `id` (uuid); FK `<entity>_id`.
- Index: `idx_<table>_<column>`. Enums as text + CHECK; status values lower snake_case.
- **Unique idempotency:** `events.event_id` is PRIMARY KEY; inserts use
  `INSERT ... ON CONFLICT (event_id) DO NOTHING` (a duplicate is success, not error).

**Dart / Flutter:**
- Classes/types PascalCase; files snake_case; functions/vars camelCase.
- DB↔Dart casing conversion lives ONLY in the data layer (`fromJson`/`toJson`).
- **Code-gen is fixed (not optional):** `freezed` for all domain/data models;
  `riverpod_generator` (`@riverpod`) for providers — no hand-rolled provider mix; a
  single committed `build.yaml` governs `field_rename` so serialization never diverges.

**Events:** `domain.action` past-tense → `preoccupation.captured`, `weight.assigned`,
`mission.validated`, `mission.deferred`, `preoccupation.deleted`. Modeled as a single
`sealed class DomainEvent` (exhaustive — typos fail compile, not just replay). Every event
carries `event_id` (uuid, client-generated), `user_id`, `schema_version` (int),
`created_at` (client, ISO-8601 UTC), `received_at` (server, ISO-8601 UTC).

### Structure Patterns

- Feature-first: `lib/features/<feature>/{data,domain,presentation}/`.
- Shared core: `lib/core/{sync,ai,design_system,l10n,error,router}/`.
- **Hive typeId registry:** central `lib/core/sync/hive_registry.dart` reserves typeIds
  append-only; never reused even after a type is removed (prevents box corruption).
- Tests mirror lib under `test/`. Flavor entrypoints `main_dev/staging/prod.dart`.

### Format Patterns

- Date/time ISO-8601 UTC on the wire; convert to local only at render.
- JSON snake_case (DB) / camelCase (Dart). Booleans true/false.
- `null` mental_weight = genuinely unknown (pending), MUST be distinguishable from any
  fallback floor value.
- Subscription state sourced from RevenueCat entitlement, never inferred locally.

### Communication Patterns

- State: Riverpod immutable `copyWith`; `AsyncValue<T>`. Derived projections (load,
  streak, level, garden) computed from the event log, never stored as mutated counters.
- **Event schema evolution:** the log is append-only AND immutable. Never rewrite history.
  Add `schema_version`; apply pure upcasting functions (vN → vN+1) at READ/replay time only.
- Idempotency: replay is a no-op by `event_id`; validation keyed `(mission_id,
  mission_date)` — double validation == single.

## Project Structure & Boundaries

### Folder Granularity Rule (pragmatic)

A feature starts FLAT: `features/<feature>/` with files directly inside. It splits into
`{data,domain,presentation}/` ONLY when it exceeds ~5 files OR touches the sync engine.
No ritual empty folders. The split is mechanical, not aspirational.

### Complete Project Directory Structure

```
mindow/
├── README.md
├── pubspec.yaml
├── analysis_options.yaml          # very_good_analysis + custom lints
├── build.yaml                     # scoped codegen: generate_for targets only
├── l10n.yaml
├── .gitignore
├── .github/
│   └── workflows/
│       └── ci.yml                 # analyze + typeId-collision test + test + build (3 flavors)
├── lib/
│   ├── main_dev.dart / main_staging.dart / main_prod.dart
│   ├── app/
│   │   ├── app.dart               # ProviderScope, MaterialApp.router
│   │   ├── bootstrap.dart         # Hive/Supabase/Sentry init
│   │   └── env.dart               # public keys only — no secrets
│   ├── core/
│   │   ├── sync/                  # GENERIC ENGINE ONLY — business-agnostic
│   │   │   ├── hive_registry.dart        # central typeId allocation (CI-guarded)
│   │   │   ├── domain_event.dart         # abstract sealed base + schema_version
│   │   │   ├── event_store.dart          # Hive outbox (local → sent → acked)
│   │   │   ├── sync_queue.dart           # injectable clock
│   │   │   ├── replay_engine.dart        # ordered by received_at, tie-break event_id
│   │   │   ├── reconciliation_client.dart
│   │   │   └── upcasters/                # read-time schema_version migrations
│   │   │       └── upcaster_registry.dart
│   │   ├── entitlement/                   # Free/Premium boundary (architectural)
│   │   │   ├── entitlement_service.dart   # reads subscription projection
│   │   │   └── premium_guard.dart         # router + provider guard
│   │   ├── ai/
│   │   │   ├── ai_client.dart             # calls Edge Functions only
│   │   │   └── ai_failure.dart
│   │   ├── error/failure.dart             # sealed Failure taxonomy
│   │   ├── design_system/                 # Aurore tokens, theme, widgets
│   │   ├── l10n/                           # generated
│   │   ├── router/app_router.dart          # GoRouter (+ premium_guard)
│   │   └── data/supabase_client.dart       # PostgREST + RLS
│   ├── features/
│   │   ├── onboarding/                     # flat until it grows
│   │   ├── auth/
│   │   ├── brain_dump/
│   │   │   └── domain/events/              # feature OWNS its DomainEvents + projection
│   │   ├── mental_load/
│   │   │   └── domain/                     # mental_load_projection lives HERE
│   │   ├── missions/domain/                # mission events + projection
│   │   ├── history/
│   │   ├── gamification/domain/            # streak/level/garden projections HERE
│   │   ├── notifications/
│   │   ├── subscription/                   # RevenueCat entitlements + projection
│   │   ├── decomposition/      # Premium (guarded)
│   │   ├── coaching/           # Premium (guarded)
│   │   ├── dashboard/          # Premium (guarded)
│   │   └── couple_mode/        # Premium (guarded) + Household authz boundary
│   └── shared/widgets/
├── assets/
│   ├── fonts/ (Inter)  ├── images/  └── l10n/  # app_en.arb, app_fr.arb ...
├── test/                                   # mirrors lib/ for unit tests
│   ├── helpers/
│   │   ├── fake_clock.dart
│   │   └── sync/                           # REUSABLE convergence harness lives here
│   │       ├── convergence_harness.dart    # the engine (importable by any test)
│   │       └── fixtures/events/v{n}/*.json # versioned per schema_version
│   ├── core/sync/convergence_test.dart     # the GATE: fails if a schema_version
│   │                                       #   has no matching fixtures/ folder
│   └── features/.../                        # cross-feature sync tests NOT mirrored
├── integration_test/flows/                 # Camille first deposit, Lucas daily mission...
└── supabase/
    ├── migrations/                         # YYYYMMDDHHMMSS_*.sql (forward-only)
    ├── functions/
    │   ├── _shared/                        # SHARED event contracts + schema_version
    │   │   ├── events.ts                   # canonical event types (Dart↔Deno parity)
    │   │   └── entitlement.ts              # server-side Premium gate helper
    │   ├── ai-analyze/                     # crisis-gate FIRST, before Free/Premium branch
    │   ├── ai-decompose/                   # Premium: server entitlement check
    │   ├── ai-coach/                       # Premium: server entitlement check
    │   ├── reconcile/                      # server-authoritative projections
    │   ├── account-export/  ├── account-delete/   # GDPR
    │   └── revenuecat-webhook/             # → subscription projection
    └── seed.sql
```

### Architectural Boundaries

**API:** Client ↔ Supabase (PostgREST + RLS); Client ↔ Edge Functions (AI, reconcile,
GDPR). OpenAI key ONLY in Edge env. RevenueCat → webhook → subscription projection.

**Event contract (critical):** `supabase/functions/_shared/events.ts` and Dart
`core/sync/domain_event.dart` are the two sides of ONE versioned contract. CI guards
parity. Old events migrate via read-time `core/sync/upcasters/` (never by mutating the
append-only log).

**Entitlement boundary:** Enforced in TWO places — `core/entitlement/premium_guard`
(client UI/router) AND `_shared/entitlement.ts` (server, in every Premium Edge Function).
Never UI-only. The crisis-gate in `ai-analyze` runs BEFORE any entitlement branch —
safety is not a Premium feature.

**Component:** Each feature owns its DomainEvents + projections in its `domain/`.
`core/sync` provides only the generic engine (store, outbox, replay, registry, upcasters).
Cross-feature reads go through Riverpod providers, never internal data layers.

**Data:** Hive = local source of truth; Postgres = replica; `events` append-only/immutable;
projections rebuildable & server-authoritative via `reconcile`. RLS event log strictly
private; Couple Mode via dedicated shared projections + Household authz guard.

### Requirements to Structure Mapping

Feature → folder mapping; projections now under each feature's `domain/`:

- Brain Dump (FR-4/5) → `features/brain_dump` (owns capture events).
- AI Analysis (FR-6) → `ai-analyze` (crisis-gate first) + `core/ai`.
- Mental Backpack (FR-7/8/9) → `features/mental_load/domain` (projection here).
- Daily Mission (FR-10/11) → `features/missions`; mission_date computed server-side from
  frozen profile timezone (**OD-2 resolved**).
- Gamification (FR-15/16/17) → `features/gamification/domain` (streak/level/garden).
- Premium (FR-20/21/22/23/24) → guarded features + server-checked Edge Functions.

### Open Decisions Status

- **OD-2 — RESOLVED:** `mission_date` and day-boundary computed server-side from the
  user's FROZEN profile timezone (streak fairness, anti-travel-cheat, couple sync).
- **OD-1 — pending:** server-authoritative projections require a written monotonicity
  invariant before freeze.
- **OD-3 — pending (preferred):** Couple Mode strict-private log + shared projections.

### Development Workflow Integration

- **Dev:** `flutter run -t lib/main_dev.dart --flavor dev`.
- **Codegen:** scoped `build.yaml` (`generate_for`) + targeted `--build-filter` to avoid
  full-tree rebuilds.
- **CI:** analyze + typeId-collision test + unit/convergence tests + per-flavor build.
- **Deploy:** stores per flavor; `supabase db push` + `supabase functions deploy`, CI-gated.

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:** Flutter 3.44 stable + Riverpod (riverpod_generator) + GoRouter
+ Hive + Supabase (Postgres/RLS/Edge/Realtime) + OpenAI-via-Edge + RevenueCat + FCM +
PostHog + Sentry form a consistent, mutually-compatible stack. No contradictory decisions.
The frozen+versioned Mental Weight, append-only event log, and read-time upcasting are
internally consistent.

**Pattern Consistency:** Naming (DB plural snake_case / Dart camelCase), codegen (freezed +
riverpod_generator, committed build.yaml), sealed `DomainEvent`/`Failure` taxonomies,
outbox + bounded retry, ARB key grammar — all align with the chosen stack and with each
other.

**Structure Alignment:** Feature-first + generic `core/sync` engine + per-feature
projections supports the event-sourced + offline-first decisions. Entitlement and crisis
boundaries are now explicit. `_shared/` event contracts keep Dart↔Deno parity.

### Requirements Coverage Validation

**Feature Coverage:** All 14 features (4.1–4.14) map to concrete folders/Edge Functions.

**Functional Requirements Coverage:** FR-1…FR-24 are architecturally supported (capture,
AI analysis with crisis-gate, Mental Backpack projection, daily mission, validation,
history, gamification, notifications, monetization, decomposition, coaching, dashboard,
couple mode). Couple Mode (FR-23/24) is **conditionally** covered — depends on OD-3.

**Non-Functional Requirements Coverage:** Capture speed (local-first Hive write), async AI
(Edge Functions), offline-first (Hive source of truth + outbox sync), cross-platform parity
(single Flutter codebase, 3 flavors), i18n (ARB + per-locale AI copy), reliability/
observability (Sentry + PostHog + CI gates), sync consistency (idempotent converge-up +
server-authoritative reconcile) — all addressed.

### Implementation Readiness Validation

**Decision Completeness:** Critical decisions documented with versions; OD-1 and OD-3
remain open (see gaps).

**Structure Completeness:** Full directory tree, boundaries, and requirements→structure
mapping are specific and complete.

**Pattern Completeness:** ~20 conflict points addressed; naming, communication, process,
migration, i18n, enforcement patterns specified with examples.

### Gap Analysis Results

**Critical Gaps:**
- **OD-1 (monotonicity proof):** server-authoritative projection authority asserts the
  Mental Weight never worsens silently, but the monotonicity invariant is not yet written.
  Must be specified before implementation of `reconcile`.

**Important Gaps:**
- **OD-3 (Couple Mode RLS):** strict-private log + shared projections is the preferred
  path but not yet frozen. Blocks Couple Mode (FR-23/24) implementation only.

**Nice-to-Have Gaps:**
- A canonical event-catalog doc (every DomainEvent + schema_version) would help agents.
- A worked upcaster example (vN → vN+1) would reduce ambiguity.

### Validation Issues Addressed

- **OD-2 (mission_date timezone) — RESOLVED** in step 6: server-side from frozen profile
  timezone (streak fairness, anti-travel-cheat, couple sync).
- Entitlement leakage risk — RESOLVED: dual enforcement (client `premium_guard` + server
  `_shared/entitlement.ts`), crisis-gate independent of entitlement.

### Architecture Completeness Checklist

**Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**Architectural Decisions**
- [x] Critical decisions documented with versions
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed

**Implementation Patterns**
- [x] Naming conventions established
- [x] Structure patterns defined
- [x] Communication patterns specified
- [x] Process patterns documented

**Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY WITH MINOR GAPS — all 16 checklist items are `[x]`, but one
Critical Gap (OD-1 monotonicity proof) and one Important Gap (OD-3 Couple Mode RLS) remain
open. These do not block starting the foundation/scaffold, but OD-1 must close before the
`reconcile` Edge Function and OD-3 before Couple Mode.

**Confidence Level:** High — the foundational decisions are coherent and well-specified;
remaining gaps are bounded and localized.

**Key Strengths:**
- Event-sourced, idempotent, converge-up sync with offline-first as a first-class concern.
- Frozen+versioned Mental Weight protects user trust (weight never worsens silently).
- Explicit entitlement and crisis-safety boundaries, enforced server-side.
- Pragmatic folder-granularity rule avoids ritual structure.

**Areas for Future Enhancement:**
- Promote to multi-package monorepo if `core/sync` or design_system outgrow single-package.
- Event catalog + upcaster examples as living documentation.

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented.
- Use implementation patterns consistently across all components.
- Respect project structure and boundaries (generic `core/sync`, per-feature projections).
- Refer to this document for all architectural questions; close OD-1 before `reconcile`.

**First Implementation Priority:**
`flutter create --org com.mindow --platforms ios,android,web --project-name mindow mindow`
then wire flavors, Riverpod/freezed codegen (build.yaml), `core/` skeleton, and the
`hive_registry` + typeId-collision CI guard.
- **Replay ordering:** deterministic by `received_at`, tie-break `event_id`. Business
  reasoning uses `created_at`; convergence ordering uses `received_at`.

### Process Patterns

- **Error taxonomy:** domain returns `Result<T, Failure>` where `Failure` is a
  `sealed class` in `core/error/` (`NetworkFailure`, `ValidationFailure`, `AiFailure`,
  `SyncFailure`, `UnknownFailure`). UI matches exhaustively; raw codes go to Sentry only,
  user copy stays gentle (tone-as-gate).
- Loading: pending is a state of REST, not a blocking spinner. Capture/relief never block.
- **Outbox pattern:** Hive events have an explicit sync state machine
  (`local → sent → acked`). "Invisible offline mechanics" means hidden from the USER, not
  from the architecture. No fire-and-forget for an authoritative log.
- Retry centralized in `core/sync` + `core/ai` (bounded max N + backoff). No per-feature loops.

### Migration Patterns

- Supabase migrations named `YYYYMMDDHHMMSS_<description>.sql`; one migration per PR;
  forward-only. No destructive DROP of event data — projections rebuild via reconciliation.

### Internationalization Patterns

- **ARB key grammar:** `feature_component_variant_state` (e.g. `brain_dump_input_placeholder`,
  `coaching_card_empty_state_body`). No positional/numbered keys (`step1`) — name by intent.
- ICU `{count, plural, ...}` and gender variants mandatory (French needs them; English hides them).
- A custom lint forbids hardcoded string literals in widgets; documented exceptions =
  event keys / technical identifiers / logs (never translated).
- **AI-generated copy is NOT translated post-hoc:** generated directly in the target locale
  via a per-locale system prompt that encodes register (French tutoiement). A versioned
  **voice lexicon** (banned words "échec/retard/tu dois", on-tone/off-tone examples) is
  part of the prompt. Localized static fallbacks (in ARB, respecting the lexicon) cover
  AI off-tone / unavailable / offline.

### Enforcement Guidelines

**All AI Agents MUST:**
- Keep snake_case↔camelCase conversion in the data layer only.
- Treat derived state as projections of the event log; never increment counters directly.
- Use `freezed` + `riverpod_generator`; register every Hive typeId in the central registry.
- Make every event idempotent (`event_id` PK, `ON CONFLICT DO NOTHING`); add `schema_version`.
- Never put a once-shown weight back up; fallback weights are floors.
- Route all secrets/AI calls through Edge Functions; never embed the OpenAI key client-side.
- Never hardcode user-facing strings; never translate AI copy post-hoc.

**Pattern Enforcement:** very_good_analysis + custom lints + CI (`flutter analyze`,
`flutter test`). The event-replay convergence harness is the gate for any sync-touching
change — with **versioned fixtures** (multi-schema-version events) and a monotonicity
assertion (server projection never drops below client projection). Lints alone are theatre
for typeId collisions and payload-version regressions.

### Documentation Conventions (this doc)

- Decisions referenced by stable ADR-style IDs, not section titles.
- Canonical glossary at the top is the single source for "event", "brain dump",
  "classification". One assertion, one place — duplication that desyncs is worse than
  contradiction.

### Open Decisions Surfaced (carry to PM / final design)

- **OD-1 — Projection authority:** server-authoritative + disposable optimistic client
  (preferred) vs duplicated client/server logic. If server-authoritative, the convergence
  harness MUST prove server projection is monotonically ≥ client (no downward "jump" =
  no streak-guilt). [Needs verdict]
- **OD-2 — "Day" definition for Daily Mission:** `mission_date` derived from the user's
  timezone FROZEN on the profile (not the current device tz), computed server-side — same
  freezing principle as Mental Weight. Prevents idempotency breakage on cross-timezone
  travel. [Product decision — needs John/PM]
- **OD-3 — Couple Mode RLS:** strict-private event log (`user_id = auth.uid()`), sharing
  exclusively via first-class shared projections with their own RLS (preferred), vs
  recursive RLS consulting a materialized permission table. [Needs verdict]

### Pattern Examples

**Good:** `events` row `{event_id, user_id, schema_version:1, type:'mission.validated',
payload:{...}, created_at, received_at}` → reconciliation Edge Function folds into derived
`mental_load`; replay ordered by `received_at`.
**Anti-pattern:** `UPDATE users SET streak = streak + 1` (mutated counter — breaks
convergence, risks streak-guilt on conflict). `typeId: 0` reused across two adapters
(silent box corruption). Translating `brain_dump.created` (breaks event sourcing).
