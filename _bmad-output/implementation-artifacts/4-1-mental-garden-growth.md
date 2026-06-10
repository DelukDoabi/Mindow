---
baseline_commit: 4cef6f2226adc7736847a5d8072323a455cbaa8b
---

# Story 4.1: Mental Garden growth

Status: review

## Story

As a user,
I want my garden to grow as I free load,
So that progress feels alive and gentle.

## Acceptance Criteria

1. **Given** a Validation event, **When** the garden projection updates, **Then** a Garden element can unlock/advance (flower, shrub, tree, river, animals, landscapes) (FR-16).
2. **And** the Garden state is a projection of the event log, persists, and reflects total completed Missions.

## Context & Constraints

- Garden progression MUST be derived from event-sourced data (`mission.validated`), not mutable counters.
- Keep parity with existing sync architecture: replay/idempotent projection semantics from `core/sync`.
- UI tone must stay gentle and positive (UX-DR16/UX-DR19): no pressure wording, no punitive feedback.
- Cross-session consistency required (NFR-7): same user sees same garden state across relaunch/sync.

## Tasks / Subtasks

- [x] **Task 1 - Garden domain model and thresholds (AC: #1, #2)**
  - [x] Create `GardenStage` / `GardenState` domain types under `lib/features/gamification/domain/`.
  - [x] Define deterministic unlock thresholds based on total validated missions (MVP constants, easily adjustable).
  - [x] Include explicit mapping to visual elements: flower, shrub, tree, river, animals, landscapes.

- [x] **Task 2 - Event-sourced garden projection (AC: #1, #2)**
  - [x] Add projection builder that replays outbox events and folds only `mission.validated` into garden state.
  - [x] Ensure idempotent behavior inherited from validation key strategy (`mission_id`, `mission_date`).
  - [x] Expose Riverpod provider for current garden state.

- [x] **Task 3 - Garden UI surface (AC: #1)**
  - [x] Add minimal Garden screen in `lib/features/gamification/presentation/` using Aurore design language.
  - [x] Render current unlocked stage/element with positive microcopy.
  - [x] Wire navigation entrypoint (placeholder tab route or Home entry) without breaking existing flows.

- [x] **Task 4 - Persistence and sync resilience (AC: #2)**
  - [x] Verify garden state reconstructs from event history after app restart.
  - [x] Verify projection remains consistent when pending events later reconcile.

- [x] **Task 5 - Localization + tests**
  - [x] Add FR/EN strings for Garden title, stage labels, and positive status copy.
  - [x] Add unit tests for threshold mapping and projection folding.
  - [x] Add widget test for garden rendering per derived stage.

## Suggested File Targets

- `lib/features/gamification/domain/garden_state.dart` (create)
- `lib/features/gamification/garden_providers.dart` (create)
- `lib/features/gamification/presentation/garden_screen.dart` (create)
- `lib/core/router/app_router.dart` (update: route wiring)
- `assets/l10n/app_fr.arb` (update)
- `assets/l10n/app_en.arb` (update)
- `lib/core/l10n/app_localizations*.dart` (generated update)
- `test/features/gamification/domain/garden_state_test.dart` (create)
- `test/features/gamification/garden_projection_test.dart` (create)
- `test/features/gamification/presentation/garden_screen_test.dart` (create)

## Dev Agent Record

### Agent Model Used

GPT-5.3-Codex (GitHub Copilot)

### Debug Log References

- `flutter test test/features/gamification/domain/garden_state_test.dart test/features/gamification/presentation/garden_screen_test.dart`
- `flutter test test/features/gamification/domain/garden_state_test.dart test/features/gamification/presentation/garden_screen_test.dart test/features/brain_dump/presentation/home_screen_test.dart --plain-name "shows the localized empty backpack and capture affordance"`

### Completion Notes List

- Added garden domain projection model with deterministic unlock thresholds and next unlock metadata.
- Added event-sourced provider replaying outbox through `ReplayEngine` and folding only `mission.validated` events.
- Added Garden screen and route (`/garden`) with Home entrypoint by tapping stat pills.
- Added FR/EN localization keys and regenerated app localizations.
- Added unit + widget tests for thresholds/projection and Garden rendering.

### File List

- `assets/l10n/app_en.arb`
- `assets/l10n/app_fr.arb`
- `lib/core/l10n/app_localizations.dart`
- `lib/core/l10n/app_localizations_en.dart`
- `lib/core/l10n/app_localizations_fr.dart`
- `lib/core/router/app_router.dart`
- `lib/features/brain_dump/presentation/home_screen.dart`
- `lib/features/gamification/domain/garden_state.dart`
- `lib/features/gamification/garden_providers.dart`
- `lib/features/gamification/presentation/garden_screen.dart`
- `lib/features/mental_load/presentation/stat_pill_row.dart`
- `test/features/gamification/domain/garden_state_test.dart`
- `test/features/gamification/presentation/garden_screen_test.dart`

## Change Log

| Date       | Version | Description | Author |
| ---------- | ------- | ----------- | ------ |
| 2026-06-10 | 0.1     | Story created from Epic 4 backlog entry | Amelia |
| 2026-06-10 | 1.0     | Implemented Garden growth projection, UI route, l10n, and tests | Amelia |
