---
title: Mindow — Product Requirements Document
status: final
created: 2026-06-05
updated: 2026-06-05
---

# PRD: Mindow
*Working title — confirm.*

## 0. Document Purpose

This PRD is the source of truth for Mindow's MVP, written for the PM, stakeholders, and the downstream BMad workflow owners (UX, architecture, epics & stories). It is structured as a Glossary-anchored vocabulary, with features grouped and Functional Requirements (FRs) nested and globally numbered for stable downstream references. Assumptions are tagged inline as `[ASSUMPTION]` and indexed in §14. Technology choices (Flutter, Supabase, OpenAI, RevenueCat, FCM, PostHog, Sentry, Hive) are intentionally **not** in this PRD — they live in the companion `addendum.md` so this document stays at the capability level. The original product brief lives at `{project-root}/prd.md`; this PRD supersedes it as the managed artifact.

## 1. Vision

Mindow is a mobile and web app that helps people reduce their **mental load** — not by making them more productive, but by giving them back mental space. Users dump whatever is cluttering their mind into a single fast capture field; Mindow's AI understands each worry, weighs it, categorizes it, and turns the pile into one simple next action per day.

The core metaphor is a **mental backpack**: every open preoccupation has a weight in kilograms, the backpack shows the total load, and completing a Daily Mission visibly lightens it. Positive gamification — a growing Mental Garden, levels, achievements, streaks — rewards relief rather than throughput. Mindow is deliberately **not** a task manager: the user does not manage a to-do list, they offload what weighs on them and progressively recover lightness.

This matters because existing productivity tools optimize for getting more done, and frequently become a source of stress themselves. Mindow occupies the opposite position — a mental offload space that measures success in load relieved, with the North Star being **kilograms of mental load freed per user per month**.

**Anti-productivity positioning (load-bearing).** Mindow is intentionally *not* a productivity tool. Most apps in this space fail the mental-load problem because they add structure, options, and obligations — becoming a source of stress themselves. Mindow inverts that: we measure success in *load relieved*, never *throughput achieved*. Every design, feature, and copy decision must pass one filter: **does this relieve mental pressure, or add it?** When in doubt, remove. Downstream teams (UX, architecture, stories) should treat this filter as a gate, not a guideline.

## 2. Target User

### 2.1 Jobs To Be Done

- **Emotional:** "Stop carrying everything in my head so I feel lighter and less under pressure."
- **Functional:** "Capture a worry in under 3 seconds before I forget it, and trust that something useful happens to it."
- **Functional:** "Tell me the one thing to do today that will relieve me the most, so I don't have to prioritize."
- **Social (Couple Mode):** "Make the invisible household mental load visible and shared with my partner."
- **Contextual:** "Do this on my phone in spare moments, but also from web/desktop when I'm at a computer."

### 2.2 Non-Users (v1)

- Teams or organizations wanting shared project/task management (Mindow is personal, plus an optional two-person Couple Mode — not a team tool).
- Users seeking clinical mental-health treatment — Mindow is a wellbeing aid, not a medical or therapeutic service (see §9 Constraints & Guardrails).
- Power users wanting deep manual task organization, dependencies, sub-projects, or calendar scheduling.

### 2.3 Key User Journeys

*Named-persona narratives the product enables. Numbered UJ-1 … UJ-N. FRs reference journeys by ID inline.*

- **UJ-1. Camille empties her head on the school run and feels lighter.**
  - **Persona + context:** Camille, 42, two kids, juggling medical appointments, school admin, and the house. She carries a constant background hum of "things to remember."
  - **Entry state:** First-time user, just finished onboarding, lands on the Mental Backpack screen.
  - **Path:** She taps the single Brain Dump field and types "prendre rendez-vous chez le dentiste," taps "Déposer dans mon sac à dos." She repeats for "renouveler mon passeport" and "préparer les vacances." Each item appears immediately with a pending state, then resolves to a Category and Mental Weight.
  - **Climax:** The backpack now shows a total load (e.g., 18 kg) and the count of open preoccupations. For the first time the worries are *outside* her head and visibly held by the app.
  - **Resolution:** She closes the app reassured that nothing is lost and that tomorrow she'll get one clear action. Realizes the activation goal (account + ≥3 preoccupations).

- **UJ-2. Lucas clears his single Daily Mission in three minutes.**
  - **Persona + context:** Lucas, 29, young professional, wants to stop keeping everything in his head.
  - **Entry state:** Authenticated, returning user, opens the app after a notification "Une mission de 3 minutes t'attend."
  - **Path:** He sees the Daily Mission: "Prendre rendez-vous chez le dentiste — 3 minutes — gain estimé −5 kg." He taps "Commencer," makes the call, returns and taps "Déjà fait."
  - **Climax:** A "−5 kg" animation plays and the backpack visibly lightens; the victory is added to History and his Mental Garden grows a new element.
  - **Resolution:** Streak incremented; he feels a small win and is told he's lighter than 7 days ago.
  - **Edge case:** If he taps "Plus tard," the mission is deferred and a new mission is offered the next day; the item stays in the backpack.

- **UJ-3. Sofia breaks an overwhelming project into doable pieces (Premium).**
  - **Persona + context:** Sofia, 38, entrepreneur, too many ideas and responsibilities, wants to externalize her memory.
  - **Entry state:** Premium subscriber, opens a single heavy preoccupation "préparer mon déménagement."
  - **Path:** She triggers **Decomposition**; the AI returns sub-actions ("réserver camion," "faire cartons cuisine," "changer adresse banque," "prévenir assurance"). She reviews and accepts them.
  - **Climax:** The single overwhelming item becomes several smaller preoccupations, each with its own Mental Weight and eligible to become Daily Missions.
  - **Resolution:** The mountain feels climbable; her backpack reflects the redistributed, more actionable load.

- **UJ-4. Camille and her partner see the household load together (Premium).**
  - **Persona + context:** Camille and her partner activate **Couple Mode** to surface the shared invisible load.
  - **Entry state:** Both Premium-linked into one Household.
  - **Path:** They see a combined household Mental Load, share specific preoccupations, and the app proposes an intelligent split into collaborative missions.
  - **Climax:** The previously invisible mental load is now visible and distributed — neither partner is silently carrying it all.
  - **Resolution:** Missions are assigned; both contribute to lowering the household load.

## 3. Glossary

*Downstream workflows and readers must use these terms exactly. FRs, UJs, and SMs use Glossary terms verbatim.*

- **Mindow** — The product; a mental-load offload coach assisted by AI.
- **Preoccupation** (a.k.a. Mental Item) — A single worry/thought the user deposits. Has content, Category, Mental Weight, Effort Score, Estimated Duration, and a status (open / completed). Belongs to one User; may be created directly or produced by Decomposition.
- **Brain Dump** — The single-field fast-capture action that creates a Preoccupation in under 3 seconds.
- **Category** — One classification of a Preoccupation from a fixed set: Administratif, Famille, Santé, Travail, Finance, Maison, Personnel, Voyage, Autre.
- **Mental Weight** — The AI-estimated *psychological* load a Preoccupation places on the user, expressed in kilograms (kg) — not a measure of task size or time. A routine errand (e.g., a dentist appointment) is light; a looming, ambiguous worry (e.g., "je suis inquiet pour mes impôts") is heavy even if the action is short. The unit of the North Star. Assigned at AI Analysis time. `[ASSUMPTION: exact scale and kg calibration finalized with architecture; the source brief shows per-item weights like 7 and mission gains like −5 kg.]`
- **Effort Score** — AI-assigned difficulty of *acting* on a Preoccupation (how hard it is to start/complete), distinct from its Mental Weight (how much it weighs on the mind).
- **Estimated Duration** — AI-assigned minutes required to act on a Preoccupation.
- **AI Analysis** — The automatic step, run on each Brain Dump, that produces Category, Mental Weight, Effort Score, and Estimated Duration.
- **Mental Load** — The sum of the Mental Weight of all open Preoccupations for a User (or Household in Couple Mode). Displayed in kg.
- **Mental Backpack** — The main screen visualization of current Mental Load as an animated backpack whose heaviness reflects total kg.
- **Daily Mission** — The single Preoccupation the app selects each day as the recommended next action, shown with Estimated Duration and estimated kg gain.
- **Validation** — The act of marking a Daily Mission done, which closes the underlying Preoccupation and subtracts its Mental Weight from the Mental Load (kg freed).
- **Mental Garden** — The gamified visualization that grows new elements (flower, shrub, tree, river, animals, landscapes) as Missions are completed.
- **Level** — The user's progression tier: Explorateur → Allégeur → Esprit Clair → Esprit Léger → Maître du Calme.
- **Achievement** — A one-time unlockable milestone (e.g., first victory, 10 kg freed, 100 preoccupations deposited, 30-day streak).
- **Streak** — Number of consecutive days with at least one completed Mission.
- **North Star** — Kilograms of Mental Load freed per User per month (AI-estimated, summed on Validation).
- **Decomposition** *(Premium)* — AI breakdown of one large Preoccupation into smaller Preoccupations.
- **Coaching** *(Premium)* — AI-generated guidance proposing the next best actions based on the user's Preoccupation patterns.
- **Advanced Dashboard** *(Premium)* — Extended statistics on Mental Load evolution and category breakdown.
- **Couple Mode** *(Premium)* — A two-user **Household** sharing a combined Mental Load, shared Preoccupations, and collaborative Missions.
- **Household** — The shared unit in Couple Mode linking two Users.
- **Free** / **Premium** — The two subscription tiers; both live at launch.

## 4. Features

### 4.1 Onboarding & Account

**Description:** A short onboarding introduces the value proposition, captures lightweight context to personalize the experience, and creates an account. Realizes UJ-1. Screen 1 is a welcome ("Décharge ton esprit. On s'occupe du reste."). Screen 2 collects age range, family situation, and current stress level. Screen 3 asks how many subjects currently occupy the user's mind (buckets: 0-10, 10-20, 20-50, 50+). Screen 4 creates the account via Apple, Google, or Email. Onboarding text is available in all launch languages. `[ASSUMPTION: onboarding answers personalize copy/defaults but are not hard gates; they are stored on the user profile.]`

**Functional Requirements:**

#### FR-1: Guided onboarding flow

A first-time user can complete a multi-screen onboarding (welcome → context questions → mind-volume question → account creation). Realizes UJ-1.

**Consequences (testable):**
- The welcome, context, mind-volume, and account screens display in order on first launch.
- Onboarding can be completed end-to-end without external help in the selected language.
- Onboarding state persists; a user who completed it is never shown it again on that account.

#### FR-2: Account creation and authentication

A user can create an account and sign in via Apple, Google, or Email.

**Consequences (testable):**
- All three providers (Apple, Google, Email) successfully create and authenticate an account.
- A returning user is recognized and lands on the Mental Backpack, not onboarding.
- Sign-out and sign-in restore the same user's Preoccupations and progress.

#### FR-3: Onboarding context capture

A user can provide age range, family situation, current stress level, and current mind-volume bucket; these are stored on the profile.

**Consequences (testable):**
- Selected values are persisted and retrievable on the user profile.
- Skipping an optional context question still allows progression. `[ASSUMPTION: context questions are optional/skippable.]`

### 4.2 Brain Dump

**Description:** The heart of Mindow — a single field to capture a Preoccupation in under 3 seconds. Placeholder: "Qu'est-ce qui occupe ton esprit ?" CTA: "Déposer dans mon sac à dos." Captures free text such as "Prendre rendez-vous chez le dentiste" or "Je suis inquiet pour mes impôts." Realizes UJ-1. The new Preoccupation appears immediately with a pending state while AI Analysis runs asynchronously.

**Functional Requirements:**

#### FR-4: Capture a Preoccupation

A user can create a Preoccupation by typing free text into a single field and confirming. Realizes UJ-1.

**Consequences (testable):**
- The Brain Dump field is reachable in ≤1 tap from the Mental Backpack screen.
- Submitting non-empty text creates an open Preoccupation that appears in the backpack immediately.
- The capture interaction (open field → submit) completes in under 3 seconds of user effort.
- Capture succeeds offline; the Preoccupation is queued and AI Analysis runs when connectivity returns. *(See NFRs.)*

#### FR-5: Edit and delete a Preoccupation

A user can edit the content of, or delete, an existing Preoccupation.

**Consequences (testable):**
- Editing content can re-trigger AI Analysis. `[ASSUMPTION: editing content re-runs AI Analysis; minor edits may be debounced.]`
- Deleting an open Preoccupation removes its Mental Weight from the Mental Load.
- A deleted Preoccupation no longer appears in the backpack or can be selected as a Daily Mission.

### 4.3 AI Analysis

**Description:** On each Brain Dump (and on meaningful edits), the AI classifies the Preoccupation and assigns weights. Output shape: `{ category, mentalWeight, effort, estimatedDuration }`. Category is one of the fixed nine. Realizes UJ-1, UJ-2.

**Functional Requirements:**

#### FR-6: Classify and weigh a Preoccupation

The system can assign a Category, Mental Weight (kg), Effort Score, and Estimated Duration to each Preoccupation via AI Analysis.

**Consequences (testable):**
- Every analyzed Preoccupation has exactly one Category from the fixed set.
- Mental Weight, Effort Score, and Estimated Duration are populated with values in their defined ranges. `[ASSUMPTION: Mental Weight scale and kg mapping to be finalized with architecture; brief shows per-item weights like 7 and mission gains like −5 kg.]`
- Until AI Analysis returns, the Preoccupation shows a pending/processing state and still counts toward open-item count.
- If AI Analysis fails, the Preoccupation is retained with a safe default/fallback and flagged for retry. `[ASSUMPTION: failed analysis falls back to a default Category "Autre" and a neutral Mental Weight, with retry.]`

### 4.4 Mental Backpack

**Description:** The main screen. Shows current Mental Load in kg, an animated backpack whose heaviness reflects the load (0-20 kg léger, 20-50 kg modéré, 50-80 kg lourd, 80+ kg très lourd), the number of open Preoccupations, and weekly progression. Realizes UJ-1, UJ-2.

**Functional Requirements:**

#### FR-7: Display current Mental Load

A user can see their current Mental Load (sum of open Preoccupations' Mental Weight) in kilograms on the main screen.

**Consequences (testable):**
- Displayed Mental Load equals the sum of Mental Weight across the user's open Preoccupations.
- Adding, completing, or deleting a Preoccupation updates the displayed load accordingly.

#### FR-8: Animated backpack visualization

The system can render the backpack with a heaviness state matching the current Mental Load band (léger / modéré / lourd / très lourd).

**Consequences (testable):**
- The visualization band changes when the load crosses 20 / 50 / 80 kg thresholds.
- Completing a Mission produces a visible lightening of the backpack.

#### FR-9: Open-items count and weekly progression

A user can see the number of open Preoccupations and their weekly progression on the main screen.

**Consequences (testable):**
- Open-items count equals the number of the user's open Preoccupations.
- Weekly progression reflects kg freed over the trailing week.

### 4.5 Daily Mission

**Description:** Each day the app selects exactly one Preoccupation as the Daily Mission and presents it with Estimated Duration and estimated kg gain. The AI prioritizes which Preoccupation maximizes relief. Actions: Commencer, Plus tard, Déjà fait. Realizes UJ-2.

**Functional Requirements:**

#### FR-10: Generate the Daily Mission

The system can select one Preoccupation per day as the Daily Mission, optimized to maximize estimated relief. Realizes UJ-2.

**Consequences (testable):**
- Exactly one Daily Mission is presented per day when at least one open Preoccupation exists.
- The Mission shows the underlying Preoccupation, its Estimated Duration, and estimated kg gain.
- When no open Preoccupations exist, the user is shown an appropriate empty/encouragement state rather than a Mission.

#### FR-11: Act on the Daily Mission

A user can respond to the Daily Mission with Commencer, Plus tard, or Déjà fait. Realizes UJ-2.

**Consequences (testable):**
- "Déjà fait" triggers Validation (FR-12).
- "Plus tard" defers the Mission; the Preoccupation remains open and a Mission is offered again next cycle.
- "Commencer" surfaces the action context and still allows later Validation.

### 4.6 Validation

**Description:** When a Mission is marked done, an animation plays (e.g., "−5 kg"), the backpack visibly lightens, the Preoccupation closes, a victory is recorded in History, the Mental Garden grows, and the Streak may increment. Realizes UJ-2.

**Functional Requirements:**

#### FR-12: Validate a completed Mission

A user can validate a Daily Mission as done, closing the underlying Preoccupation and freeing its Mental Weight. Realizes UJ-2.

**Consequences (testable):**
- Validation subtracts the Preoccupation's Mental Weight from Mental Load and marks it completed.
- Validation records a victory entry (date, kg freed, time invested) in History.
- Validation plays the kg-relief animation and triggers Mental Garden growth and Streak/Achievement evaluation.
- Freed kg contributes to the North Star (AI-estimated, per decision).

### 4.7 History

**Description:** A list of victories — completed Preoccupations with date, mental gain (kg), and time invested. Realizes UJ-2.

**Functional Requirements:**

#### FR-13: View victory history

A user can view a chronological list of completed Preoccupations with date, kg freed, and time invested.

**Consequences (testable):**
- Every Validation appears in History with its date, kg freed, and time invested.
- History reflects only completed Preoccupations.

### 4.8 Notifications

**Description:** Re-engagement and encouragement notifications, e.g., "Tu peux libérer 4 kg aujourd'hui.", "Une mission de 3 minutes t'attend.", "Ton esprit est plus léger qu'il y a 7 jours." Types: Daily Mission, Streak, Achievement, Mental-load-reduced. Realizes UJ-2.

**Functional Requirements:**

#### FR-14: Send engagement notifications

The system can send Daily Mission, Streak, Achievement, and mental-load-reduced notifications. Realizes UJ-2.

**Consequences (testable):**
- A user who grants permission can receive each notification type.
- A user can disable notifications (globally and ideally by type) and stops receiving disabled types. `[ASSUMPTION: per-type opt-out is desired; at minimum a global toggle ships in MVP.]`
- Notification copy is localized to the user's language.

### 4.9 Gamification

**Description:** Positive, relief-oriented gamification. Three mechanics: **Levels** (Explorateur → Allégeur → Esprit Clair → Esprit Léger → Maître du Calme), the **Mental Garden** (each completed Mission grows an element: flower, shrub, tree, river, animals, landscapes), and **Achievements** (first victory, 10 kg freed, 100 preoccupations deposited, 30-day streak). Realizes UJ-2.

**Functional Requirements:**

#### FR-15: Level progression

A user can progress through Levels as they free mental load / complete Missions. Realizes UJ-2.

**Consequences (testable):**
- Crossing a Level threshold updates the user's displayed Level.
- Level is derived from progression data and is consistent across sessions/devices. `[ASSUMPTION: exact Level thresholds (XP basis) to be defined; brief lists the five tiers.]`

#### FR-16: Mental Garden growth

The system can grow the Mental Garden by unlocking new elements as Missions are completed. Realizes UJ-2.

**Consequences (testable):**
- Each Validation can unlock/advance a Garden element.
- The Garden state persists and reflects total completed Missions.

#### FR-17: Achievements

A user can unlock Achievements when conditions are met (e.g., first victory, 10 kg freed, 100 preoccupations deposited, 30-day streak).

**Consequences (testable):**
- Each Achievement unlocks exactly once when its condition is first met.
- Unlocked Achievements persist and are viewable.
- Streak is computed as consecutive days with ≥1 completed Mission.

### 4.10 Monetization & Subscriptions

**Description:** Two tiers live at launch. **Free**: unlimited Brain Dump, Daily Mission, gamification. **Premium**: Coaching, Decomposition, Advanced Dashboard, Couple Mode. Subscriptions are managed across Apple Store and Google Play. Realizes UJ-3, UJ-4.

**Functional Requirements:**

#### FR-18: Tiered access control

The system can gate Premium features (Coaching, Decomposition, Advanced Dashboard, Couple Mode) behind an active Premium subscription while keeping all Free features fully usable.

**Consequences (testable):**
- A Free user can use Brain Dump (unlimited), Daily Mission, and all gamification without limit.
- A Free user attempting a Premium feature is shown a paywall, not the feature.
- A Premium user has access to all Premium features; on expiry, access reverts to Free without data loss.

#### FR-19: Purchase and restore a subscription

A user can purchase a Premium subscription and restore an existing one across Apple Store and Google Play.

**Consequences (testable):**
- A successful purchase activates Premium and unlocks Premium features within one app session.
- Restore re-activates Premium for an entitled user on a new device/reinstall.
- Subscription state is reflected in the user's profile.

### 4.11 Premium — AI Decomposition

**Description:** Premium. The user submits one large Preoccupation (e.g., "Préparer mon déménagement") and the AI returns sub-actions that become individual Preoccupations. Realizes UJ-3.

**Functional Requirements:**

#### FR-20: Decompose a Preoccupation

A Premium user can decompose one Preoccupation into multiple smaller Preoccupations via AI. Realizes UJ-3.

**Consequences (testable):**
- Decomposition returns a reviewable list of sub-actions for the input Preoccupation.
- Accepted sub-actions become open Preoccupations, each with its own AI Analysis (Category, Mental Weight, Effort Score, Estimated Duration).
- The user can accept, edit, or discard suggested sub-actions before they are created. `[ASSUMPTION: user reviews/edits before creation rather than auto-creating all.]`

### 4.12 Premium — AI Coaching

**Description:** Premium. The AI surfaces guidance based on the user's Preoccupation patterns, e.g., "Tu sembles accumuler plusieurs sujets administratifs. Commencer par les impôts pourrait réduire significativement ta charge mentale."

**Functional Requirements:**

#### FR-21: Provide AI Coaching guidance

A Premium user can receive AI Coaching that proposes next best actions based on their Preoccupation patterns.

**Consequences (testable):**
- Coaching references the user's actual Preoccupations/Categories.
- Coaching proposes at least one concrete next action the user can act on.
- Coaching tone follows the wellbeing guardrails in §9 (supportive, non-judgmental, non-clinical).

### 4.13 Premium — Advanced Dashboard

**Description:** Premium. Extended statistics: Mental Load evolution over time, category breakdown, average Mental Load, total Mental Load removed.

**Functional Requirements:**

#### FR-22: View the Advanced Dashboard

A Premium user can view advanced statistics on Mental Load evolution, category breakdown, average load, and total load removed.

**Consequences (testable):**
- The dashboard shows Mental Load over time, a Category breakdown, average Mental Load, and total kg removed.
- Figures are consistent with History and current Mental Load.

### 4.14 Premium — Couple Mode

**Description:** Premium. Two users form a Household with a combined Mental Load, shared Preoccupations, intelligent split, and collaborative Missions. Realizes UJ-4. Couple Mode is **not** a collaboration/task tool — its purpose is *visibility and fairness*: surfacing the often-invisible mental load (scheduling, admin, emotional labor) one partner silently carries, so it can be seen and rebalanced.

**Functional Requirements:**

#### FR-23: Form a Household and share load

Two Premium users can link into a Household and view a combined household Mental Load. Realizes UJ-4.

**Consequences (testable):**
- Two users can establish a Household link (invite/accept). `[ASSUMPTION: link is via invite + accept; both must be Premium.]`
- The household view shows a combined Mental Load across both members' shared Preoccupations.

#### FR-24: Share and split Preoccupations collaboratively

Household members can share specific Preoccupations and receive an intelligent split into collaborative Missions. Realizes UJ-4.

**Consequences (testable):**
- A Preoccupation can be marked shared and becomes visible to the other Household member.
- The system proposes an assignment/split of shared Preoccupations into Missions across members.

## 5. Non-Goals (Explicit)

- Mindow is **not** a task/project manager — no dependencies, sub-projects, manual prioritization, deadlines, or calendar scheduling.
- Mindow is **not** a team/organization product — sharing is limited to a two-person Household in Couple Mode.
- Mindow is **not** a medical, diagnostic, or therapeutic service and makes no clinical claims (see §9).
- No voice capture, mobile widget, Apple Watch / Wear OS, or personal AI agent in MVP — these are explicitly Vision Future (`[NON-GOAL for MVP]`).
- No social network features, public sharing, or community feeds.

## 6. MVP Scope

### 6.1 In Scope

- Onboarding & Account (Apple / Google / Email), multi-language from launch.
- Brain Dump with offline capture.
- AI Analysis (Category, Mental Weight, Effort Score, Estimated Duration).
- Mental Backpack (load in kg, animated backpack, open-items count, weekly progression).
- Daily Mission (generation, Commencer / Plus tard / Déjà fait).
- Validation (kg relief animation, History entry, Garden growth, Streak).
- History of victories.
- Notifications (Daily Mission, Streak, Achievement, mental-load-reduced).
- Gamification (Levels, Mental Garden, Achievements).
- Monetization with **Free + Premium live at launch** (Apple Store + Google Play).
- Premium features: AI Decomposition, AI Coaching, Advanced Dashboard, Couple Mode.
- Platforms: iOS, Android, Web.

### 6.2 Out of Scope for MVP

- Voice assistant capture — deferred to v2 (Vision Future).
- Mobile home-screen widget — deferred to v2. `[NOTE FOR PM: emotionally load-bearing for re-engagement; revisit if timeline permits.]`
- Apple Watch / Wear OS quick add — deferred to v2.
- Personal AI agent ("Qu'est-ce qui me soulagerait le plus aujourd'hui ?") — deferred to v2.
- Households larger than two people — out of scope (Couple Mode is two-user).
- Reinforced privacy/anonymization of AI inputs — out of scope for MVP per Standard privacy posture (revisit if regulation or market demands).

## 7. Success Metrics

*Each SM cross-references the FR(s) it validates. Counter-metrics counterbalance specific primary metrics.*

**Primary**

- **SM-1 — North Star: Mental load freed.** Kilograms of Mental Load freed per user per month (AI-estimated Mental Weight summed on Validation). Target: positive and growing month over month. Validates FR-12, FR-6, FR-10.
- **SM-2 — Activation.** % of new users who create an account and add ≥3 Preoccupations. Validates FR-1, FR-2, FR-4. `[ASSUMPTION: activation target ≥ 60% of signups; confirm.]`
- **SM-3 — DAU/MAU.** Stickiness ratio. Target: > 30%. Validates FR-10, FR-14.

**Secondary**

- **SM-4 — Retention.** D1 / D7 / D30 retention curves trend upward release over release. Validates FR-10, FR-14, FR-15.
- **SM-5 — Streak engagement.** Median Streak length and % of users with a 7-day Streak. Validates FR-11, FR-12, FR-17.
- **SM-6 — Premium conversion.** % of active users converting to Premium; year-1 target 5,000 subscribers (of 50,000 users). Validates FR-18, FR-19.
- **SM-7 — NPS.** Net Promoter Score target > 50.

**Counter-metrics (do not optimize)**

- **SM-C1 — Capture without relief.** Preoccupations created per user vs. Missions validated. If capture climbs while Validation stays flat, Mindow is becoming a worry-hoarding inbox, not a relief tool. Counterbalances SM-1/SM-2. *Do not optimize for raw Preoccupation volume.*
- **SM-C2 — Notification-driven churn.** Notification opt-out and uninstall rate following notification volume. Guards against engagement tactics that add pressure — the opposite of the product's purpose. Counterbalances SM-3.
- **SM-C3 — Mental Weight inflation.** Average AI-assigned Mental Weight over time. Since the North Star is AI-estimated, rising average weight could inflate "kg freed" without real relief. Monitor for drift; do not tune the model to maximize kg. Counterbalances SM-1.

**Governance.** Counter-metrics are as load-bearing as primary metrics. If a counter-metric is in sustained violation (e.g., SM-C1 capture-to-validation ratio worsening over consecutive weeks), that takes precedence over primary-metric optimization — the product team should not keep pushing engagement features while relief health is degrading. This protects the anti-productivity positioning in §1.

## 8. Cross-Cutting NFRs

- **Capture speed.** Brain Dump must feel instant: field reachable in ≤1 tap from the Mental Backpack, submit-to-visible under 3 seconds, no blocking on AI Analysis.
- **Async AI.** AI Analysis runs asynchronously; the Preoccupation is usable immediately in a pending state and resolves when analysis returns. `[ASSUMPTION: target AI Analysis latency P95 ≤ a few seconds; confirm with architecture.]`
- **Offline-first capture.** Brain Dump works offline; Preoccupations queue locally and sync (with deferred AI Analysis) on reconnect. No captured worry is ever lost.
- **Cross-platform parity.** Core flows (capture, backpack, mission, validation) behave consistently across iOS, Android, and Web.
- **Internationalization.** Multi-language support from launch — all user-facing copy, notifications, and AI outputs localized to the user's language.
- **Reliability & observability.** Crash-free sessions tracked; errors and performance monitored so regressions are caught early.
- **Sync consistency.** Mental Load, Streak, Level, Garden, and History stay consistent across a user's devices.

## 9. Constraints & Guardrails

### 9.1 Safety (Wellbeing, not medical)

- Mindow is a wellbeing aid, **not** a medical/therapeutic product; it must avoid clinical claims and diagnosis.
- AI Coaching and copy must be supportive, encouraging, and non-judgmental — never inducing productivity guilt or pressure.
- `[ASSUMPTION: if a user expresses crisis/self-harm content, the app should surface appropriate support resources rather than a Mission. Confirm scope — this is a duty-of-care consideration for a mental-wellbeing app.]` `[NOTE FOR PM: decide MVP stance on crisis-content handling.]`

### 9.2 Privacy (Standard posture)

- Preoccupations may contain intimate content (health, finances). Per decision, MVP uses a **Standard** posture: preoccupations are sent to the AI provider as-is.
- Baseline GDPR: explicit consent to AI processing at onboarding, data export, and full account deletion (delete account → erase Preoccupations and derived data).
- A clear privacy notice explains that worry text is processed by a third-party AI provider.
- `[ASSUMPTION: data export + account deletion ship in MVP to satisfy GDPR baseline across launch markets.]`

### 9.3 Cost

- AI cost per Preoccupation must stay bounded (cost-efficient model for classification at MVP scale).
- AI usage should be designed to avoid runaway per-user cost (e.g., debounce re-analysis on trivial edits; bound Decomposition/Coaching frequency). `[ASSUMPTION: per-user AI budget guardrails defined with architecture.]`

## 10. Aesthetic & Tone

- **Feel:** calm, light, reassuring — the opposite of a busy productivity dashboard. Whitespace, soft motion, gentle color.
- **Core metaphors:** the Mental Backpack (weight lifting off) and the Mental Garden (growth from relief).
- **Voice:** warm, encouraging, second-person familiar (French *tutoiement*), e.g., "Décharge ton esprit. On s'occupe du reste." Never guilt-inducing, never pushy.
- **Gamification is positive-only (design principle, not a preference):** rewards relief and consistency, never punishes inactivity or shames missed days. No red "you lost your streak" friction, no guilt for missed days. A missed day is silent, never penalized.
- **Anti-references:** task-manager checklists, productivity "streak guilt," cluttered metric dashboards (except the opt-in Advanced Dashboard).
- **Tone is a gate, not a guideline.** Any feature, animation, or copy that would add pressure — even in service of an engagement metric — fails this section and §1's filter. When tone and a short-term metric conflict, tone wins.

## 11. Information Architecture

Top-level surfaces:

- **Onboarding** (first run only).
- **Mental Backpack (Home)** — current Mental Load, animated backpack, open-items count, weekly progression, entry to Brain Dump.
- **Daily Mission** — today's single mission with actions.
- **History** — victories list.
- **Garden / Progress** — Mental Garden, Levels, Achievements.
- **Advanced Dashboard** *(Premium)* — extended statistics.
- **Couple Mode / Household** *(Premium)* — shared load and collaborative missions.
- **Settings / Profile** — account, language, notifications, privacy (export/delete), subscription management.
- **Paywall** — surfaced when a Free user reaches a Premium feature.

`[ASSUMPTION: navigation pattern (e.g., bottom nav with Home/Mission/Garden/Profile) to be finalized in UX.]`

## 12. Compliance & Regulatory

- **GDPR (baseline):** lawful basis via explicit consent (incl. AI processing), data export, right to erasure (account deletion). Applies across launch markets given multi-language launch. `[NOTE FOR PM: confirm whether any non-EU launch market adds requirements (e.g., CCPA) — addendum if so.]`
- **App-store policies:** subscription handling must comply with Apple App Store and Google Play billing rules (purchase, restore, management).
- **Accessibility:** target WCAG 2.1 AA for a wellbeing audience. `[ASSUMPTION: AA is the bar; confirm.]`

## 13. Open Questions

1. Mental Weight scale and its exact mapping to kilograms (the brief shows per-item weights like 7 and mission gains like −5 kg) — needs a definition before architecture. (FR-6)
2. Level thresholds / XP basis for the five tiers. (FR-15)
3. Crisis-content handling stance for MVP (duty of care). (§9.1)
4. Per-type vs. global notification opt-out granularity in MVP. (FR-14)
5. Activation target % and Premium-conversion target % to confirm against the year-1 goals. (SM-2, SM-6)
6. Household linking flow specifics and whether both members must be Premium. (FR-23)
7. AI Analysis latency target and fallback behavior on failure. (FR-6, §8)
8. Non-EU launch markets and any additional privacy regimes. (§12)

## 14. Assumptions Index

- §4.1 / FR-1, FR-3 — Onboarding answers personalize but are not hard gates; context questions are optional/skippable.
- §4.2 / FR-5 — Editing content re-runs AI Analysis; trivial edits may be debounced.
- §4.3 / FR-6 — Mental Weight scale & kg mapping TBD; failed analysis falls back to Category "Autre" + neutral weight with retry.
- §4.8 / FR-14 — Per-type notification opt-out desired; at minimum a global toggle ships in MVP.
- §4.9 / FR-15 — Exact Level thresholds (XP basis) TBD.
- §4.11 / FR-20 — User reviews/edits Decomposition suggestions before creation.
- §4.14 / FR-23 — Household link via invite+accept; both members Premium.
- §7 / SM-2 — Activation target ≥ 60% (confirm).
- §8 — AI Analysis P95 latency target ≤ a few seconds (confirm).
- §9.1 — Crisis content should surface support resources (confirm MVP scope).
- §9.2 — Data export + account deletion ship in MVP for GDPR baseline.
- §9.3 — Per-user AI budget guardrails defined with architecture.
- §11 — Navigation pattern finalized in UX.
- §12 — WCAG 2.1 AA is the accessibility bar (confirm).
