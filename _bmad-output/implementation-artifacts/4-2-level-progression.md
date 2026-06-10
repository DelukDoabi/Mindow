---
baseline_commit: 3c1e9cd22ea8350a1f9d6d7f866af358eb323f3f
---

# Story 4.2: Level progression

Status: review

## Story

As a user,
I want to progress through levels,
So that consistency is rewarded.

## Acceptance Criteria

1. **Given** progression data, **When** I cross a Level threshold, **Then** my displayed Level updates (Explorateur -> Allegeur -> Esprit Clair -> Esprit Leger -> Maitre du Calme) (FR-15).
2. **And** Level is derived from the projection and consistent across sessions/devices (NFR-7).

## Context & Constraints

- Keep level progression event-sourced: derive state from replayed `mission.validated` events, never from mutable counters.
- Reuse existing projection conventions from `core/sync` (`ReplayEngine`, idempotent fold semantics, deterministic output).
- Preserve consistency with Story 4.1 gamification implementation already merged:
  - `lib/features/gamification/domain/garden_state.dart`
  - `lib/features/gamification/garden_providers.dart`
  - `lib/features/gamification/presentation/garden_screen.dart`
- Keep UX tone gentle and non-punitive (UX-DR16, UX-DR19): level copy should celebrate progress, never pressure inactivity.
- Ensure localization parity FR/EN for level names and status lines.
- Preserve Home and mission flows; level work must not regress story 3.x and 4.1 behavior.

## Technical Notes For Dev

- Existing source of truth for progress already exists in mission validation projections:
  - `mission.validated` event in `lib/features/missions/domain/mission_validated_event.dart`
  - victories projection in `lib/features/missions/missions_providers.dart`
- Garden state currently deduplicates mission completions by `(mission_id, mission_date)`.
- Level projection should follow the same dedup strategy so level and garden remain coherent.
- Prefer composition over duplication:
  - Either project from validated events directly in a level provider.
  - Or derive from an existing projected aggregate (if deterministic and replay-safe).

## Validation Notes (VS)

- Validation date: 2026-06-10
- Validation verdict: PASS (ready for dev), with clarifications applied below.
- Non-blocking gap found and resolved in-story:
  - Added explicit assumptions for progression metric and default threshold set so implementation is deterministic from day 1.

## Clarified Assumptions For Implementation

- Progression metric for this story: number of unique validated missions, deduplicated by `(mission_id, mission_date)`.
- Default threshold proposal (can be tuned later without schema impact):
  - Explorateur: 0+
  - Allegeur: 3+
  - Esprit Clair: 7+
  - Esprit Leger: 12+
  - Maitre du Calme: 20+
- Tie to existing 4.1 behavior: if mission count drives Garden and Level, both views stay coherent and avoid contradictory progress states.
- Localization display uses accented labels in UI copy, while domain identifiers remain stable enum symbols.

## Tasks / Subtasks

- [x] **Task 1 - Define level domain and thresholds (AC: #1, #2)**
  - [x] Add a `LevelTier` enum and immutable `LevelState` under `lib/features/gamification/domain/`.
  - [x] Define deterministic thresholds for tiers:
    - Explorateur
    - Allegeur
    - Esprit Clair
    - Esprit Leger
    - Maitre du Calme
  - [x] Expose helpers:
    - map completed progress to current tier
    - compute next tier threshold (or terminal state)

- [x] **Task 2 - Event-sourced level projection provider (AC: #1, #2)**
  - [x] Create a Riverpod provider under `lib/features/gamification/` that replays outbox events and folds `mission.validated` only.
  - [x] Use idempotent dedup keyed by `mission_id + mission_date`.
  - [x] Return a deterministic `LevelState` projection independent of runtime order noise.

- [x] **Task 3 - Surface level in gamification UI (AC: #1)**
  - [x] Update Garden/Progress UI to display current level and progress-to-next milestone.
  - [x] Keep visuals aligned with Aurore design language and existing Garden screen style.
  - [x] Ensure copy remains supportive and positive.

- [x] **Task 4 - Localization + formatting safety (AC: #1)**
  - [x] Add FR/EN l10n keys for:
    - Level title/subtitle label
    - Tier names
    - current level summary
    - next level hint
  - [x] Regenerate localization files.

- [x] **Task 5 - Tests (AC: #1, #2)**
  - [x] Add unit tests for threshold mapping and next-tier logic.
  - [x] Add projection tests for replay + dedup determinism.
  - [x] Add widget test for level rendering on Progress/Garden screen.
  - [x] Add at least one non-regression assertion that Story 4.1 garden rendering remains valid alongside level display.

## Suggested File Targets

- `lib/features/gamification/domain/level_state.dart` (create)
- `lib/features/gamification/level_providers.dart` (create)
- `lib/features/gamification/presentation/garden_screen.dart` (update)
- `assets/l10n/app_fr.arb` (update)
- `assets/l10n/app_en.arb` (update)
- `lib/core/l10n/app_localizations*.dart` (generated update)
- `test/features/gamification/domain/level_state_test.dart` (create)
- `test/features/gamification/level_projection_test.dart` (create)
- `test/features/gamification/presentation/garden_screen_test.dart` (update)

## Definition of Done Checklist

- [x] Level thresholds are deterministic and documented in domain code.
- [x] Level projection is event-sourced and idempotent.
- [x] Level UI appears in Progress/Garden and updates from projected data.
- [x] FR/EN localization complete and generated files updated.
- [x] New tests pass and no regressions introduced in relevant existing tests.

## Testing Standards Summary

- Unit tests (`flutter_test`):
  - Threshold mapping by boundary (just before and at each threshold).
  - Next-tier computation and terminal tier behavior.
- Projection tests:
  - Replay over mixed events folds `mission.validated` only.
  - Idempotent dedup by `(mission_id, mission_date)`.
- Widget tests:
  - Garden/Progress screen shows current level, localized level name, and next-level hint.
  - Existing garden element rendering assertions remain green (4.1 non-regression).
- Run targeted validations before handoff:
  - `flutter test test/features/gamification/domain test/features/gamification/presentation`
  - At least one Home smoke test around the stat/garden area to catch regressions.

## References

- `'_bmad-output/planning-artifacts/epics.md'` (Story 4.2 / FR-15)
- `'_bmad-output/planning-artifacts/architecture.md'` (event-sourced projection constraints)
- `'_bmad-output/planning-artifacts/ux-designs/ux-Mindow-2026-06-05/EXPERIENCE.md'` (tone and non-punitive progression)
- `'lib/features/gamification/domain/garden_state.dart'` (4.1 progression/dedup baseline)
- `'lib/features/gamification/garden_providers.dart'` (ReplayEngine + provider pattern)
- `'lib/features/missions/domain/mission_validated_event.dart'` (canonical progression event)
- `'lib/features/missions/missions_providers.dart'` (existing validated-mission projection patterns)

## Dev Agent Record

### Agent Model Used

GPT-5.3-Codex (GitHub Copilot)

### Debug Log References

- `flutter gen-l10n`
- `flutter test test/features/gamification/domain/garden_state_test.dart test/features/gamification/domain/level_state_test.dart test/features/gamification/level_projection_test.dart test/features/gamification/presentation/garden_screen_test.dart`
- `flutter test test/features/brain_dump/presentation/home_screen_test.dart --plain-name "shows the localized empty backpack and capture affordance"`

### Completion Notes List

- Added `LevelTier`/`LevelState` with deterministic thresholds and next-level helper.
- Added level projection derived from replayed `mission.validated` events with idempotent dedup by mission key.
- Refactored gamification providers to share validated mission events projection between Garden and Level.
- Updated Garden screen to show current level and next-level hint with gentle copy.
- Added FR/EN level localization keys and regenerated localization classes.
- Added domain/projection tests and updated Garden widget test to include level rendering while keeping existing garden assertions.

### File List

- `lib/features/gamification/domain/level_state.dart` (created)
- `lib/features/gamification/level_providers.dart` (created)
- `lib/features/gamification/garden_providers.dart` (modified)
- `lib/features/gamification/presentation/garden_screen.dart` (modified)
- `assets/l10n/app_en.arb` (modified)
- `assets/l10n/app_fr.arb` (modified)
- `lib/core/l10n/app_localizations.dart` (generated)
- `lib/core/l10n/app_localizations_en.dart` (generated)
- `lib/core/l10n/app_localizations_fr.dart` (generated)
- `test/features/gamification/domain/level_state_test.dart` (created)
- `test/features/gamification/level_projection_test.dart` (created)
- `test/features/gamification/presentation/garden_screen_test.dart` (modified)

## Change Log

| Date       | Version | Description | Author |
| ---------- | ------- | ----------- | ------ |
| 2026-06-10 | 0.1     | Story created from Epic 4 backlog entry | Amelia |
| 2026-06-10 | 0.2     | Story validated (VS) and clarified for deterministic implementation | Amelia |
| 2026-06-10 | 1.0     | Implemented level progression domain/projection/UI with l10n and tests | Amelia |
