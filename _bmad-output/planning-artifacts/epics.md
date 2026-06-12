---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/prds/prd-Mindow-2026-06-05/prd.md
  - _bmad-output/planning-artifacts/prds/prd-Mindow-2026-06-05/addendum.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-designs/ux-Mindow-2026-06-05/DESIGN.md
  - _bmad-output/planning-artifacts/ux-designs/ux-Mindow-2026-06-05/EXPERIENCE.md
workflowType: 'epics-and-stories'
project_name: 'Mindow'
user_name: 'boss'
date: '2026-06-06'
status: 'complete'
completedAt: '2026-06-06'
---

# Mindow - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Mindow, decomposing the requirements from the PRD, UX Design, and Architecture into implementable stories.

## Requirements Inventory

### Functional Requirements

FR-1: Guided onboarding flow — a first-time user can complete a multi-screen onboarding (welcome → context questions → mind-volume question → account creation). Realizes UJ-1.
FR-2: Account creation and authentication — a user can create an account and sign in via Apple, Google, or Email; returning users land on the Mental Backpack.
FR-3: Onboarding context capture — a user can provide age range, family situation, current stress level, and mind-volume bucket; stored on profile; questions are optional/skippable.
FR-4: Capture a Preoccupation — a user can create a Preoccupation via single free-text field in under 3 seconds; appears immediately pending; succeeds offline and queues for sync.
FR-5: Edit and delete a Preoccupation — a user can edit content (may re-trigger AI Analysis, debounced on minor edits) or delete; delete removes its Mental Weight from Mental Load.
FR-6: Classify and weigh a Preoccupation — the system assigns Category, Mental Weight (kg), Effort Score, and Estimated Duration via AI Analysis; pending state until return; safe fallback (Category "Autre", neutral weight) + retry on failure.
FR-7: Display current Mental Load — a user sees current Mental Load (sum of open Preoccupations' Mental Weight) in kg on the main screen; updates on add/complete/delete.
FR-8: Animated backpack visualization — the system renders the backpack with a heaviness band matching the load (léger 0-20 / modéré 20-50 / lourd 50-80 / très lourd 80+); completing a Mission visibly lightens it.
FR-9: Open-items count and weekly progression — a user sees the number of open Preoccupations and weekly progression (kg freed over trailing week).
FR-10: Generate the Daily Mission — the system selects exactly one Preoccupation per day, optimized to maximize estimated relief; shows Estimated Duration and estimated kg gain; empty/encouragement state when none open.
FR-11: Act on the Daily Mission — a user can respond with Commencer, Plus tard (defer, penalty-free), or Déjà fait (triggers Validation).
FR-12: Validate a completed Mission — closes the underlying Preoccupation, subtracts its Mental Weight, records a victory in History, plays kg-relief animation, triggers Garden growth and Streak/Achievement evaluation; freed kg contributes to North Star.
FR-13: View victory history — a user can view a chronological list of completed Preoccupations with date, kg freed, and time invested.
FR-14: Send engagement notifications — the system sends Daily Mission, Streak, Achievement, and mental-load-reduced notifications; localized; global opt-out (per-type desired).
FR-15: Level progression — a user progresses through Levels (Explorateur → Allégeur → Esprit Clair → Esprit Léger → Maître du Calme); derived from progression data; consistent across devices.
FR-16: Mental Garden growth — the system grows the Mental Garden by unlocking new elements as Missions are completed; state persists.
FR-17: Achievements — a user unlocks Achievements once when conditions are met (first victory, 10 kg freed, 100 preoccupations, 30-day streak); Streak = consecutive days with ≥1 completed Mission.
FR-18: Tiered access control — the system gates Premium features (Coaching, Decomposition, Advanced Dashboard, Couple Mode) behind active Premium while keeping all Free features fully usable; paywall on gated entry; revert to Free without data loss on expiry.
FR-19: Purchase and restore a subscription — a user can purchase Premium and restore across Apple Store and Google Play; state reflected in profile.
FR-20: Decompose a Preoccupation (Premium) — a Premium user can decompose one Preoccupation into multiple smaller Preoccupations via AI; reviewable, editable, discardable before creation; each accepted sub-action gets its own AI Analysis.
FR-21: Provide AI Coaching guidance (Premium) — a Premium user receives AI Coaching proposing next best actions based on Preoccupation patterns; references actual data; ≥1 concrete action; follows §9 wellbeing tone.
FR-22: View the Advanced Dashboard (Premium) — a Premium user views Mental Load evolution over time, category breakdown, average load, and total kg removed; consistent with History and current load.
FR-23: Form a Household and share load (Premium) — two Premium users link into a Household (invite + accept) and view a combined household Mental Load.
FR-24: Share and split Preoccupations collaboratively (Premium) — Household members mark Preoccupations shared (visible to the other member) and receive an intelligent split into collaborative Missions.

### NonFunctional Requirements

NFR-1: Capture speed — Brain Dump field reachable in ≤1 tap from the Mental Backpack; submit-to-visible under 3 seconds; never blocks on AI Analysis.
NFR-2: Async AI — AI Analysis runs asynchronously; Preoccupation usable immediately in pending state; resolves when analysis returns (target P95 ≤ a few seconds, confirm with architecture).
NFR-3: Offline-first capture — Brain Dump works offline; Preoccupations queue locally and sync (with deferred AI Analysis) on reconnect; no captured worry is ever lost.
NFR-4: Cross-platform parity — core flows (capture, backpack, mission, validation) behave consistently across iOS, Android, and Web.
NFR-5: Internationalization — multi-language from launch; all user-facing copy, notifications, and AI outputs localized to the user's language.
NFR-6: Reliability & observability — crash-free sessions tracked; errors and performance monitored so regressions are caught early.
NFR-7: Sync consistency — Mental Load, Streak, Level, Garden, and History stay consistent across a user's devices.
NFR-8: Safety (wellbeing, not medical) — no clinical claims/diagnosis; AI Coaching and copy supportive and non-judgmental; crisis/self-harm content surfaces support resources rather than a Mission (MVP stance to confirm).
NFR-9: Privacy (Standard posture) — Preoccupations sent to AI provider as-is; explicit consent to AI processing at onboarding; clear privacy notice; GDPR baseline.
NFR-10: GDPR data rights — data export and full account deletion (erase Preoccupations and derived data) ship in MVP.
NFR-11: Cost guardrails — AI cost per Preoccupation bounded; debounce re-analysis on trivial edits; bound Decomposition/Coaching frequency; per-user AI budget guardrails.
NFR-12: App-store compliance — subscription purchase/restore/management comply with Apple App Store and Google Play billing rules.
NFR-13: Accessibility — target WCAG 2.1 AA; VoiceOver/TalkBack labels with role+state; Dynamic Type; Reduce Motion; tap targets ≥44pt iOS / 48dp Android; color never the sole carrier of meaning.

### Additional Requirements

_From Architecture ([architecture.md](architecture.md)):_

- **Starter template (Epic 1, Story 1):** `flutter create --org com.mindow --platforms ios,android,web --project-name mindow mindow`, then wire flavors (dev/staging/prod via main_*.dart), Riverpod/freezed codegen (committed build.yaml, scoped generate_for), `core/` skeleton, and the `hive_registry` + typeId-collision CI guard.
- Feature-first project structure; `core/sync` is a generic, business-agnostic engine; each feature owns its DomainEvents + projections under its `domain/`.
- Event-sourced sync: append-only/immutable `events` log; Hive = local source of truth (outbox local → sent → acked); Postgres = replica; projections rebuildable & server-authoritative via a `reconcile` Edge Function.
- Frozen + versioned Mental Weight (weight never worsens silently; fallback = floor); read-time upcasting via `core/sync/upcasters/` (never mutate the log).
- Idempotent converge-up sync: replay no-op by `event_id`; validation keyed `(mission_id, mission_date)`.
- Supabase Auth (Apple/Google/Email); Postgres RLS strictly private per `user_id`.
- OpenAI key server-side ONLY — all AI runs in Edge Functions, never client-direct.
- Edge Functions: `ai-analyze` (crisis-gate FIRST, before Free/Premium branch), `ai-decompose`, `ai-coach`, `reconcile`, `account-export`, `account-delete`, `revenuecat-webhook`.
- Entitlement enforced in TWO places: client `core/entitlement/premium_guard` AND server `_shared/entitlement.ts` in every Premium Edge Function; crisis-gate independent of entitlement.
- `mission_date` / day-boundary computed server-side from the user's FROZEN profile timezone (OD-2 resolved).
- Shared event contract `supabase/functions/_shared/events.ts` ↔ Dart `domain_event.dart` (CI-guarded parity).
- Migrations forward-only `YYYYMMDDHHMMSS_*.sql`, one per PR.
- Convergence test harness (versioned event fixtures `v{schema_version}/`) as a CI gate.
- Couple Mode RLS: strict-private log + dedicated shared projections + Household authz guard.
- **Open decisions (track):** OD-1 — server-authoritative projection monotonicity invariant must be written before `reconcile` implementation; OD-3 — Couple Mode RLS shared-projection design to be frozen before FR-23/24.

_From Addendum ([addendum.md](prds/prd-Mindow-2026-06-05/addendum.md)):_

- Integrations: RevenueCat (subscriptions), FCM (notifications), PostHog (product analytics), Sentry (crash/error observability).
- Data model entities: users, mental_items, daily_missions, achievements, garden_items, subscriptions, + Household (new for Couple Mode).

### UX Design Requirements

_From [DESIGN.md](ux-designs/ux-Mindow-2026-06-05/DESIGN.md) and [EXPERIENCE.md](ux-designs/ux-Mindow-2026-06-05/EXPERIENCE.md):_

UX-DR1: Aurore design system foundation — implement design tokens (dawn-gradient canvas, warm/cool accents, ink/muted, glass surfaces; spacing 4/8/12/16/24/32; radii sm14/md20/lg24/pill; Inter typography scale) as the single source in `core/design_system`.
UX-DR2: Backpack component — hero metaphor on Home; peach gradient body, radial warm glow, handle/lid/pockets/buckle; heaviness reflects load band; tap opens item list.
UX-DR3: kg figure (display numeral) — single Aurore-gradient hero numeral with cool `kg` unit + muted caption; non-gradient fallback fill for contrast.
UX-DR4: Glass card — frosted white surface, hairline border, soft shadow; container for missions, steps, grouped content.
UX-DR5: Stat pill — glass capsule, bold value over muted label, always positive-framed; tap → Garden/Progress.
UX-DR6: Primary CTA — full-width Aurore-gradient button, white Semi Bold label, warm drop shadow; exactly one per screen.
UX-DR7: Secondary action — text-only `ink-muted` link (Plus tard, Passer), never a competing filled button.
UX-DR8: Mission card — one mission per day; primary "C'est fait ✓" releases weight; "Plus tard" defers penalty-free.
UX-DR9: Step row (Decomposition) — glass numbered row; tap toggles done; completed fills marker + checkmark, dims to ~62%, subtracts step weight; weight in cool accent.
UX-DR10: Weight tag — small cool-tinted chip showing kilo estimate; decorative-behavioral only, never editable in v1.
UX-DR11: Premium badge & Paywall — Aurore-gradient ✦ chip; tapping a gated entry always routes to Paywall (never a dead end), framed on the specific value in context, back returns cleanly.
UX-DR12: Input field — glass surface, muted placeholder, no hard border.
UX-DR13: Progress dots — active = Aurore-gradient stadium; inactive = muted circles; non-interactive.
UX-DR14: Weight-release signature animation — on completion the kg figure animates downward and the backpack lightens/rises (the core reward); honor Reduce Motion with an immediate state change.
UX-DR15: Bottom tab bar navigation — Sac à dos (Home) / Jardin (Progress) / À deux (Couple) / Réglages; no drawer; modals stack one level deep only.
UX-DR16: Tone-as-gate microcopy — French tutoiement, warm and first-name; every string ships only if it leaves the user feeling lighter; counters always paired with a positive frame, never the headline.
UX-DR17: State patterns — first launch, empty backpack (0 kg gentle prompt, no shame), cold open (cached weight, no blocking spinner), offline (silent local work, no error banner), no mission today (relief framing), deferred mission (no guilt), premium gate, sync error (only in Settings), completion (calm lightening, no confetti).
UX-DR18: Accessibility floor — VoiceOver/TalkBack role+state labels; kg figure announces weight and its change; Dynamic Type without truncation; Reduce Motion; tap targets ≥44pt/48dp; focus order title→weight→backpack→stats→input→CTA; color never the sole carrier of meaning.
UX-DR19: Banned patterns (negative constraints) — no streaks-as-pressure, overdue badges, red counters, push re-engagement guilt, confetti gamification, carousels, blocking modals over capture, rich task metadata at capture, productivity dashboards (except opt-in Advanced Dashboard).

### FR Coverage Map

- FR-1: Epic 1 — Guided onboarding flow
- FR-2: Epic 1 — Account creation and authentication (Apple/Google/Email)
- FR-3: Epic 1 — Onboarding context capture
- FR-4: Epic 2 — Capture a Preoccupation (offline-first)
- FR-5: Epic 2 — Edit and delete a Preoccupation
- FR-6: Epic 2 — Classify and weigh a Preoccupation (AI Analysis)
- FR-7: Epic 2 — Display current Mental Load (kg)
- FR-8: Epic 2 — Animated backpack visualization
- FR-9: Epic 2 — Open-items count and weekly progression
- FR-10: Epic 3 — Generate the Daily Mission
- FR-11: Epic 3 — Act on the Daily Mission
- FR-12: Epic 3 — Validate a completed Mission
- FR-13: Epic 3 — View victory history
- FR-14: Epic 5 — Send engagement notifications
- FR-15: Epic 4 — Level progression
- FR-16: Epic 4 — Mental Garden growth
- FR-17: Epic 4 — Achievements
- FR-18: Epic 6 — Tiered access control (Premium gating)
- FR-19: Epic 6 — Purchase and restore a subscription
- FR-20: Epic 7 — Decompose a Preoccupation (Premium)
- FR-21: Epic 7 — Provide AI Coaching guidance (Premium)
- FR-22: Epic 7 — View the Advanced Dashboard (Premium)
- FR-23: Epic 8 — Form a Household and share load (Premium)
- FR-24: Epic 8 — Share and split Preoccupations collaboratively (Premium)

## Epic List

### Epic 1: Foundation, Onboarding & Account

Users can install the app, understand the promise, consent to AI processing, and create an
account via Apple, Google, or Email — landing on their Mental Backpack. This epic also lays
the technical foundation (project scaffold, flavors, CI, Aurore design tokens, Supabase
wiring) as its first story, plus GDPR consent/export/delete groundwork.
**FRs covered:** FR-1, FR-2, FR-3

### Epic 2: Brain Dump & Mental Backpack

Users can capture a worry in under 3 seconds (even offline), have the AI weigh and
categorize it, and watch their mental backpack fill up in kilograms. Includes the
event-sourced sync engine, offline outbox, AI Analysis pipeline (crisis-gate first), and
the animated backpack with load bands, open-items count, and weekly progression.
**FRs covered:** FR-4, FR-5, FR-6, FR-7, FR-8, FR-9

### Epic 3: Daily Mission, Validation & History

Users receive one recommended action per day (computed server-side from their frozen
profile timezone), can act on it (Commencer / Plus tard / Déjà fait), and validate it with
the signature weight-release animation — freeing kg, closing the preoccupation, and
recording a victory in History.
**FRs covered:** FR-10, FR-11, FR-12, FR-13

### Epic 4: Gamification — Garden, Levels & Achievements

Users are gently rewarded for relief: the Mental Garden grows new elements, Levels
progress (Explorateur → Maître du Calme), and Achievements unlock — all derived as
projections from the event log, consistent across devices, never punishing inactivity.
**FRs covered:** FR-15, FR-16, FR-17

### Epic 5: Engagement Notifications

Users receive kind, localized re-engagement notifications (Daily Mission, Streak,
Achievement, mental-load-reduced) and can disable them (globally, ideally per type),
without any guilt-inducing pressure.
**FRs covered:** FR-14

### Epic 6: Monetization — Free & Premium

Users can subscribe to Premium and restore an existing subscription across Apple Store and
Google Play; Free features remain fully usable; gated entries route to a contextual paywall
(never a dead end). Establishes the dual-enforced entitlement guard (client + server) that
Premium epics depend on.
**FRs covered:** FR-18, FR-19

### Epic 7: Premium Power Features — Decomposition, Coaching & Dashboard

Premium users can decompose a heavy preoccupation into weighted steps, receive AI Coaching
based on their patterns, and view an Advanced Dashboard of mental-load evolution — all
behind the same Premium guard and AI Edge Functions.
**FRs covered:** FR-20, FR-21, FR-22

### Epic 8: Couple Mode

Two Premium partners can link into a Household, see their combined mental load, share
specific preoccupations, and receive an intelligent split into collaborative missions —
making the invisible household load visible and fair. (Depends on OD-3 Couple Mode RLS
design being frozen.)
**FRs covered:** FR-23, FR-24

### Epic 9: Play Store Publication — Android MVP Release

The app is signed with a production upload key, the existing Supabase project is verified
as production-ready (all Edge Functions deployed, secrets configured, RLS validated),
a CI/CD pipeline builds and submits the signed AAB to Google Play automatically, the
Play Store listing is complete and compliant, and the full user journey is validated on
a real device from the internal track before public launch.
**Note:** Supabase free tier = single project. The existing project (`knnnhrynruyyjofoxvet`)
is used as production. Dev and prod share the same instance; data isolation is enforced
by RLS (per `user_id`), which is the accepted MVP tradeoff.
**NFRs covered:** NFR-4 (cross-platform parity), NFR-6 (reliability & observability),
NFR-10 (GDPR — story 1-7 verified), NFR-12 (app-store compliance)
**Prerequisites:** All Epic 1–5 stories `done`; Epic 1 Story 1-7 GDPR validated.

## Epic 1: Foundation, Onboarding & Account

Users can install the app, understand the promise, consent to AI processing, and create an
account — landing on their Mental Backpack. Establishes the technical foundation and GDPR
groundwork.

### Story 1.1: Project scaffold & technical foundation

As a developer,
I want the Flutter project scaffolded with flavors, CI, design tokens and Supabase wiring,
So that all subsequent features build on a consistent, enforced foundation.

**Acceptance Criteria:**

**Given** an empty repo
**When** I run the scaffold
**Then** `flutter create --org com.mindow --platforms ios,android,web` produces a buildable app with `main_dev/staging/prod` entrypoints
**And** `build.yaml` (scoped `generate_for`), `analysis_options.yaml` (very_good_analysis + custom lints), and committed codegen run cleanly
**And** the Aurore design tokens (UX-DR1) live in `core/design_system` as the single source
**And** CI runs analyze + a `hive_registry` typeId-collision test + tests + per-flavor build
**And** Supabase client, Sentry, and PostHog are initialized in `bootstrap.dart` with public keys only (no secrets in client)

### Story 1.2: Welcome & promise screen

As a first-time user,
I want a calm welcome that states the promise,
So that I understand Mindow relieves load rather than adding tasks.

**Acceptance Criteria:**

**Given** a cold first launch
**When** the app opens
**Then** the welcome screen shows "Décharge ton esprit. On s'occupe du reste." on the dawn-gradient canvas with progress dots (UX-DR13)
**And** a "Passer" secondary action is always available (UX-DR7, UX-DR17 first-launch)
**And** copy passes the tone-as-gate (UX-DR16) and is localized (NFR-5)

### Story 1.3: Onboarding context & mind-volume capture

As a first-time user,
I want to optionally share my context,
So that the experience feels personalized without being gated.

**Acceptance Criteria:**

**Given** the welcome step is passed
**When** I reach the context screens
**Then** I can provide age range, family situation, stress level, and mind-volume bucket (0-10/10-20/20-50/50+) (FR-3)
**And** any question is skippable and progression still succeeds (FR-3 assumption)
**And** selected values persist and are retrievable on the profile

### Story 1.4: Account creation & authentication

As a new user,
I want to create an account via Apple, Google, or Email,
So that my data is saved and synced.

**Acceptance Criteria:**

**Given** the account screen
**When** I choose any of the three providers
**Then** an account is created and authenticated via Supabase Auth (FR-2)
**And** onboarding state persists so a completed user never sees onboarding again on that account (FR-1)
**And** sign-out then sign-in restores the same user's Preoccupations and progress

### Story 1.5: Returning-user routing

As a returning user,
I want to land directly on my Mental Backpack,
So that I'm not forced through onboarding again.

**Acceptance Criteria:**

**Given** an authenticated returning user
**When** the app opens
**Then** they land on the Mental Backpack (Home), not onboarding (FR-2)
**And** cached weight + last stats render immediately with no blocking spinner (UX-DR17 cold open)

### Story 1.6: AI processing consent & privacy notice

As a user,
I want clear consent and a privacy notice for AI processing,
So that I knowingly agree before my worries are sent to the AI.

**Acceptance Criteria:**

**Given** onboarding
**When** I reach the consent step
**Then** explicit consent to third-party AI processing is captured and a clear privacy notice is shown (NFR-9)
**And** consent state is stored on the profile and required before any AI Analysis runs

### Story 1.7: GDPR data export & account deletion

As a user,
I want to export my data and delete my account,
So that I keep control of my personal information.

**Acceptance Criteria:**

**Given** Settings
**When** I request an export
**Then** the `account-export` Edge Function returns my Preoccupations and derived data (NFR-10)
**And** when I delete my account, the `account-delete` Edge Function erases all Preoccupations and derived data (cascade), and I'm signed out

## Epic 2: Brain Dump & Mental Backpack

Users can capture a worry in under 3 seconds (even offline), have the AI weigh and
categorize it, and watch their mental backpack fill up in kilograms.

### Story 2.1: Event-sourced sync engine foundation

As a developer,
I want the generic sync engine in place,
So that features can emit and replay domain events idempotently, offline-first.

**Acceptance Criteria:**

**Given** the foundation
**When** an event is emitted
**Then** it is written to a Hive outbox (`local → sent → acked`) and is the local source of truth (NFR-3)
**And** replay is idempotent (no-op by `event_id`), ordered by `received_at` tie-break `event_id`
**And** the convergence harness with versioned fixtures (`v{schema_version}/`) runs as a CI gate, failing if a schema_version lacks fixtures
**And** `core/sync` stays business-agnostic; the shared event contract `_shared/events.ts` ↔ `domain_event.dart` parity is CI-guarded

### Story 2.2: Capture a Preoccupation (offline-first)

As a user,
I want to capture a worry in under 3 seconds even offline,
So that nothing is lost from my mind.

**Acceptance Criteria:**

**Given** Home
**When** I tap the single input (reachable ≤1 tap, UX-DR12) and submit non-empty text
**Then** an open Preoccupation appears immediately in pending state (FR-4, NFR-1)
**And** capture succeeds offline; the Preoccupation queues locally and syncs on reconnect with no error banner (NFR-3, UX-DR17 offline)
**And** the interaction never blocks on AI Analysis

### Story 2.3: AI Analysis pipeline with crisis-gate

As a user,
I want my worry weighed and categorized automatically,
So that the pile becomes meaningful without effort.

**Acceptance Criteria:**

**Given** a captured Preoccupation
**When** AI Analysis runs in the `ai-analyze` Edge Function
**Then** it returns exactly one Category (from the fixed nine), Mental Weight (kg, frozen+versioned), Effort Score, and Estimated Duration (FR-6)
**And** a synchronous crisis-content gate runs FIRST — before any Free/Premium branch — surfacing support resources rather than a normal pipeline result when crisis content is detected (NFR-8)
**And** until analysis returns, the Preoccupation shows pending and still counts toward open-items
**And** on failure it falls back to Category "Autre" + neutral weight (floor) and is flagged for bounded retry (NFR-11)

### Story 2.4: Edit and delete a Preoccupation

As a user,
I want to edit or delete a worry,
So that my backpack reflects reality.

**Acceptance Criteria:**

**Given** an existing Preoccupation
**When** I edit its content
**Then** AI Analysis may re-run (debounced on trivial edits, NFR-11) (FR-5)
**And** deleting an open Preoccupation removes its Mental Weight from the Mental Load and it can no longer be a Daily Mission

### Story 2.5: Display current Mental Load

As a user,
I want to see my total mental load in kg,
So that I grasp what I'm carrying.

**Acceptance Criteria:**

**Given** open Preoccupations
**When** Home renders
**Then** the displayed Mental Load equals the sum of their Mental Weight in kg (FR-7)
**And** adding, completing, or deleting a Preoccupation updates the displayed load accordingly
**And** the kg figure is the single Aurore-gradient hero numeral with a non-gradient fallback fill (UX-DR3, UX-DR18)

### Story 2.6: Animated backpack visualization

As a user,
I want an animated backpack reflecting my load,
So that relief feels physical.

**Acceptance Criteria:**

**Given** a Mental Load value
**When** Home renders the backpack
**Then** its heaviness band matches léger 0-20 / modéré 20-50 / lourd 50-80 / très lourd 80+ (FR-8, UX-DR2)
**And** the band changes when the load crosses 20/50/80 kg thresholds
**And** tapping the backpack opens the item list

### Story 2.7: Open-items count & weekly progression

As a user,
I want to see how many worries are open and my weekly progress,
So that I feel direction without pressure.

**Acceptance Criteria:**

**Given** Home
**When** it renders
**Then** the open-items count equals the number of open Preoccupations and weekly progression shows kg freed over the trailing week (FR-9)
**And** every counter is paired with a positive frame, never the headline (UX-DR16, stat pill UX-DR5)

## Epic 3: Daily Mission, Validation & History

Users receive one recommended action per day, act on it, and validate it with the
signature weight-release animation — freeing kg and recording a victory.

### Story 3.1: Generate the Daily Mission

As a user,
I want one recommended action per day,
So that I don't have to prioritize.

**Acceptance Criteria:**

**Given** ≥1 open Preoccupation
**When** a new day begins
**Then** exactly one Daily Mission is selected to maximize estimated relief, shown with Estimated Duration and estimated kg gain (FR-10)
**And** `mission_date` / day-boundary is computed server-side from the user's frozen profile timezone (OD-2)
**And** with no open Preoccupations, a gentle empty state is shown ("Rien d'urgent aujourd'hui. Profite.") instead of a Mission (UX-DR17)

### Story 3.2: Act on the Daily Mission

As a user,
I want to start, defer, or complete my mission,
So that I stay in control without guilt.

**Acceptance Criteria:**

**Given** a Daily Mission
**When** I tap Commencer / Plus tard / Déjà fait
**Then** "Commencer" surfaces context, "Plus tard" defers penalty-free (item stays open, new mission next cycle), "Déjà fait" triggers Validation (FR-11)
**And** the mission card shows one mission, primary "C'est fait ✓", secondary penalty-free defer (UX-DR8)

### Story 3.3: Validate a completed Mission

As a user,
I want validating a mission to visibly lighten my load,
So that I feel the relief.

**Acceptance Criteria:**

**Given** a Mission marked done
**When** Validation runs
**Then** the underlying Preoccupation closes, its Mental Weight subtracts from Mental Load, and a victory (date, kg freed, time invested) is recorded (FR-12)
**And** validation is idempotent keyed `(mission_id, mission_date)` — double validation == single
**And** the signature weight-release animation plays (kg animates down, backpack lightens), honoring Reduce Motion with an immediate state change (UX-DR14)
**And** Garden growth and Streak/Achievement evaluation are triggered; freed kg contributes to the North Star

### Story 3.4: View victory history

As a user,
I want a list of my victories,
So that I see how far I've come.

**Acceptance Criteria:**

**Given** completed Preoccupations
**When** I open History
**Then** I see a chronological list with date, kg freed, and time invested (FR-13)
**And** History reflects only completed Preoccupations and every Validation appears there

## Epic 4: Gamification — Garden, Levels & Achievements

Users are gently rewarded for relief through a growing garden, level progression, and
achievements — all projections of the event log, never punishing inactivity.

### Story 4.1: Mental Garden growth

As a user,
I want my garden to grow as I free load,
So that progress feels alive and gentle.

**Acceptance Criteria:**

**Given** a Validation event
**When** the garden projection updates
**Then** a Garden element can unlock/advance (flower, shrub, tree, river, animals, landscapes) (FR-16)
**And** the Garden state is a projection of the event log, persists, and reflects total completed Missions

### Story 4.2: Level progression

As a user,
I want to progress through levels,
So that consistency is rewarded.

**Acceptance Criteria:**

**Given** progression data
**When** I cross a Level threshold
**Then** my displayed Level updates (Explorateur → Allégeur → Esprit Clair → Esprit Léger → Maître du Calme) (FR-15)
**And** Level is derived from the projection and consistent across sessions/devices (NFR-7)

### Story 4.3: Achievements & streak

As a user,
I want to unlock achievements,
So that milestones feel meaningful — never punishing.

**Acceptance Criteria:**

**Given** qualifying activity
**When** a condition is first met
**Then** the matching Achievement unlocks exactly once and persists (first victory, 10 kg freed, 100 preoccupations, 30-day streak) (FR-17)
**And** Streak = consecutive days with ≥1 completed Mission; a missed day is silent and never penalized (UX-DR19)

## Epic 5: Engagement Notifications

Users receive kind, localized re-engagement notifications and can disable them, without any
guilt-inducing pressure.

### Story 5.1: Notification permission & FCM setup

As a user,
I want to grant notification permission,
So that I can receive gentle reminders.

**Acceptance Criteria:**

**Given** the app
**When** I grant permission
**Then** an FCM token is registered for my user and delivery is enabled
**And** declining permission leaves all core flows fully usable

### Story 5.2: Engagement notification types

As a user,
I want kind, relevant notifications,
So that I'm gently re-engaged.

**Acceptance Criteria:**

**Given** permission granted
**When** conditions occur
**Then** I can receive Daily Mission, Streak, Achievement, and mental-load-reduced notifications, localized to my language (FR-14, NFR-5)
**And** copy passes the tone-as-gate — no guilt, urgency, or red alarms (UX-DR16, UX-DR19)

### Story 5.3: Notification preferences

As a user,
I want to disable notifications,
So that I'm never pressured.

**Acceptance Criteria:**

**Given** Settings
**When** I toggle notifications off (globally, ideally per type)
**Then** I stop receiving disabled types (FR-14)
**And** at minimum a global toggle ships in MVP

## Epic 6: Monetization — Free & Premium

Users can subscribe to and restore Premium across stores; Free features stay fully usable;
gated entries route to a contextual paywall. Establishes the dual-enforced entitlement guard.

### Story 6.1: Entitlement guard & paywall

As a Free user,
I want Premium features clearly gated with a contextual paywall,
So that I understand the value without dead ends.

**Acceptance Criteria:**

**Given** a Free user
**When** they tap a Premium-gated entry (Coaching, Decomposition, Dashboard, Couple Mode)
**Then** they are routed to a contextual paywall, never the feature or a dead end (FR-18, UX-DR11)
**And** entitlement is enforced in two places: client `premium_guard` AND server `_shared/entitlement.ts` in every Premium Edge Function
**And** all Free features (Brain Dump unlimited, Daily Mission, gamification) remain fully usable

### Story 6.2: Purchase & restore a subscription

As a user,
I want to buy and restore Premium,
So that I can unlock and recover access across devices.

**Acceptance Criteria:**

**Given** the paywall
**When** I purchase via RevenueCat
**Then** Premium activates and unlocks Premium features within one app session (FR-19)
**And** Restore re-activates Premium for an entitled user on a new device/reinstall
**And** the `revenuecat-webhook` Edge Function updates the subscription projection; on expiry, access reverts to Free with no data loss

## Epic 7: Premium Power Features — Decomposition, Coaching & Dashboard

Premium users can decompose heavy worries, receive AI Coaching, and view an Advanced
Dashboard — all behind the same Premium guard and AI Edge Functions.

### Story 7.1: Decompose a Preoccupation

As a Premium user,
I want to break a heavy worry into steps,
So that the mountain becomes climbable.

**Acceptance Criteria:**

**Given** a Premium user on a heavy Preoccupation
**When** they tap "Découper"
**Then** the `ai-decompose` Edge Function returns a reviewable list of weighted sub-actions (FR-20)
**And** the user can accept, edit, or discard sub-actions before creation; accepted ones become open Preoccupations each with their own AI Analysis
**And** step rows render per UX-DR9 (numbered marker, completion dims + subtracts weight); server-side entitlement is checked

### Story 7.2: AI Coaching guidance

As a Premium user,
I want guidance based on my patterns,
So that I know where to start.

**Acceptance Criteria:**

**Given** a Premium user
**When** Coaching runs in `ai-coach`
**Then** it references the user's actual Preoccupations/Categories and proposes ≥1 concrete next action (FR-21)
**And** the tone follows §9 wellbeing guardrails (supportive, non-judgmental, non-clinical) (NFR-8)

### Story 7.3: Advanced Dashboard

As a Premium user,
I want extended statistics,
So that I can see my mental-load journey.

**Acceptance Criteria:**

**Given** a Premium user
**When** they open the Advanced Dashboard
**Then** it shows Mental Load over time, category breakdown, average load, and total kg removed (FR-22)
**And** figures are consistent with History and current Mental Load (NFR-7); this is the only productivity-style dashboard allowed (UX-DR19)

## Epic 8: Couple Mode

Two Premium partners link into a Household, see their combined load, and share/split
preoccupations collaboratively — making the invisible household load visible and fair.

### Story 8.1: Form a Household

As a Premium user,
I want to link with my partner,
So that we see our combined load.

**Acceptance Criteria:**

**Given** two Premium users
**When** one invites and the other accepts
**Then** they link into a Household and view a combined household Mental Load (FR-23)
**And** the event log stays strictly private per user; sharing is via dedicated shared projections + Household authz guard (OD-3)

### Story 8.2: Share & split Preoccupations collaboratively

As a Household member,
I want to share and split worries,
So that the invisible load becomes visible and fair.

**Acceptance Criteria:**

**Given** a Household
**When** a member marks a Preoccupation shared
**Then** it becomes visible to the other member (FR-24)
**And** the system proposes an assignment/split of shared Preoccupations into collaborative Missions across members

## Epic 9: Play Store Publication — Android MVP Release

The app reaches real Android users: a production upload keystore signs every release build,
the existing Supabase project is verified as production-ready (all Edge Functions deployed,
FCM + AI secrets configured, RLS validated), CI/CD automatically builds and submits the
signed AAB to Google Play on every version tag, the Play Store listing is complete and
compliant with Google's policies, and the end-to-end user journey is smoke-tested from the
Play Store internal track before public launch.

**Supabase constraint:** Free tier = 1 project. The existing project (`knnnhrynruyyjofoxvet`)
serves as production. Dev and prod share the same instance; data isolation is enforced
exclusively by RLS (`user_id`). This is the accepted MVP tradeoff.

**Prerequisites:** All Epic 1–5 stories `done`.

### Story 9.1: Android release signing & keystore CI integration

As a developer,
I want a production upload keystore wired into CI,
So that every release build is signed with the production key and is uploadable to Google Play.

**Acceptance Criteria:**

**Given** a production upload keystore generated with
`keytool -genkey -v -keystore mindow-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mindow`
**When** the CI pipeline builds the `prodRelease` flavor
**Then** `android/app/build.gradle.kts` uses a `signingConfigs.release` block that reads `storeFile`,
`storePassword`, `keyAlias`, and `keyPassword` from `android/key.properties` (gitignored)
**And** `android/key.properties` is populated from four GitHub Actions secrets:
`UPLOAD_KEYSTORE_B64`, `UPLOAD_KEYSTORE_PASSWORD`, `UPLOAD_KEY_ALIAS`, `UPLOAD_KEY_PASSWORD`
**And** the `buildTypes.release.signingConfig` no longer references `signingConfigs.debug`
(the TODO comment is removed from `build.gradle.kts`)
**And** `flutter build appbundle --flavor prod -t lib/main_prod.dart` exits 0 in CI and
produces `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
**And** the debug signing key is NOT used for any production build

### Story 9.2: Backend production readiness

As a developer,
I want the existing Supabase project verified and fully configured for production traffic,
So that real users are served by a fully operational backend from day one.

**Note:** Supabase free tier allows one project. The existing project (`knnnhrynruyyjofoxvet`)
serves as both dev and production. Data isolation is guaranteed by RLS (per `user_id`).

**Acceptance Criteria:**

**Given** the existing Supabase project
**When** all Edge Functions are deployed via the CI workflow
**Then** every function (`account-export`, `account-delete`, `send-notification`,
`ai-analyze`, `mission-generate`) is present and reachable on the project
**And** `FIREBASE_SERVICE_ACCOUNT_JSON` is set as a secret in the Supabase Dashboard
(Edge Functions → Secrets), enabling `send-notification` to authenticate to FCM
**And** `GEMINI_API_KEY` is set as a secret in the Supabase Dashboard, enabling `ai-analyze`
**And** RLS policies are verified: a test user's rows in `mental_items` are not accessible
by another user's JWT
**And** all existing migrations are confirmed applied (no pending migration files)

### Story 9.3: CI/CD Android release pipeline (tag-triggered)

As a developer,
I want a GitHub Actions workflow that automatically builds and uploads a signed AAB to
Google Play on every version tag,
So that releasing a new version is a single `git tag v1.0.0 && git push --tags` command.

**Acceptance Criteria:**

**Given** a Git tag matching `v*.*.*` is pushed to `main`
**When** the `deploy-android.yml` workflow triggers
**Then** it checks out the code, installs Flutter, injects `FIREBASE_OPTIONS_B64`, and
reconstructs `android/key.properties` from CI secrets
**And** runs `flutter build appbundle --flavor prod -t lib/main_prod.dart --release`
**And** uploads the resulting AAB to the Google Play **internal** track using the
`r0adkll/upload-google-play` action with a service account JSON secret `PLAY_SERVICE_ACCOUNT_JSON`
**And** the workflow fails fast if any required secret is missing or if the AAB build fails
**And** the `versionCode` increments automatically (tied to the CI run number or a
dedicated counter) so Play Store never rejects a duplicate version code
**And** the existing `ci.yml` (analyze + test) remains unchanged and still runs on every push

### Story 9.4: Play Store listing, content rating & compliance

As a product owner,
I want the Mindow app listing on Google Play to be complete, accurate, and compliant,
So that the app passes the pre-launch review and is approved for public distribution.

**Acceptance Criteria:**

**Given** the Mindow app is created in Google Play Console under the `com.mindow.mindow`
package name
**When** the store listing is filled in
**Then** the app title is «Mindow — Charge mentale» (≤30 chars), the short description
(≤80 chars) and full description (≤4000 chars) are localized in French and English,
and no prohibited terms are used
**And** at least 2 phone screenshots (1080×1920 or 16:9) and 1 feature graphic (1024×500)
are uploaded; screenshots show real in-app screens (backpack, mission, garden)
**And** a hosted privacy policy URL is set (required by Google; document must cover AI
processing disclosure and GDPR rights per NFR-9 and NFR-10)
**And** the content rating questionnaire is completed and the app is rated appropriate
for the intended audience
**And** the data safety form is filled: Preoccupation content (sent to AI provider) is
declared; FCM token (collected); account data (collected); all with correct data-handling
and sharing disclosures
**And** `targetSdk` in `build.gradle.kts` meets the current Google Play minimum (≥API 34)
**And** the app category is set to «Santé et remise en forme» or «Productivité»

### Story 9.5: Internal track smoke test & production readiness sign-off

As a developer,
I want to validate the complete user journey on a real Android device installed from the
Play Store internal track,
So that I'm confident the production build works end-to-end before promoting to public.

**Acceptance Criteria:**

**Given** the signed prod AAB is deployed to the Play Store internal track (via Story 9.3)
**When** I install the app on a physical Android device from the internal track
**Then** the full core journey completes without crash:
  - Cold launch → onboarding → account creation (Supabase prod auth)
  - Capture a Preoccupation → AI Analysis returns a weight (Edge Function reachable on prod)
  - Daily Mission generated → act on it → validate → weight-release animation plays
  - At least one notification received on the device within 2 minutes of the trigger
**And** GDPR Story 1-7 is verified on prod: requesting account deletion from Settings
triggers the `account-delete` Edge Function and erases the test user's data from the
prod database
**And** the crisis-gate is verified on prod: a preoccupation with explicit self-harm language
routes to the support resource screen and does NOT generate a Mission
**And** Sentry captures at least one test event (manual `Sentry.captureMessage` call during
QA, removed before public launch)
**And** PostHog receives `onboarding_complete` and `first_preoccupation_captured` events
on the prod instance
**And** when all ACs above pass, the story is marked `done` and the internal track build
is promoted to the **production** track in Google Play Console
