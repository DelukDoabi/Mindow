---
baseline_commit: 55f5dc8187b4b710bf262e3bfc4357141f05d343
---

# Story 3.1: Generate the Daily Mission

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want one recommended action per day,
So that I don't have to prioritize.

## Acceptance Criteria

1. **Given** >=1 open Preoccupation, **When** a new day begins, **Then** exactly one Daily Mission is selected to maximize estimated relief, shown with Estimated Duration and estimated kg gain (FR-10).
2. **And** `mission_date` / day-boundary is computed server-side from the user's frozen profile timezone (OD-2 resolved).
3. **And** with no open Preoccupations, a gentle empty state is shown (`Rien d'urgent aujourd'hui. Profite.`) instead of a Mission (UX-DR17).

## Tasks / Subtasks

- [ ] **Task 1 - Domain model + selection rule (AC: #1)**
  - [ ] Create `lib/features/missions/domain/daily_mission.dart` (plain Dart or `freezed`, aligned with current feature style) with fields at minimum: `id`, `preoccupationId`, `missionDate`, `estimatedKgGain`, `estimatedDurationMinutes`, `createdAt`.
  - [ ] Define a deterministic selection rule from open preoccupations: maximize `mentalWeightKg`; tie-break by lower `estimatedDurationMinutes`; then older `createdAt`; then stable id order.
  - [ ] Exclude pending/unweighed preoccupations (`mentalWeightKg == null`) from candidate set.

- [ ] **Task 2 - Server-side mission generation API (AC: #1, #2)**
  - [ ] Add Edge Function `supabase/functions/mission-generate/index.ts` with authenticated user context.
  - [ ] Compute server day boundary and `mission_date` from the user's frozen profile timezone (not device timezone).
  - [ ] Ensure idempotency for one mission per user/day: repeated calls on same day return the same mission.
  - [ ] If no eligible preoccupation exists, return an explicit empty-state payload (no mission object).

- [ ] **Task 3 - Client API seam + repository (AC: #1, #2, #3)**
  - [ ] Create `lib/features/missions/missions_client.dart` to call `mission-generate` via `SupabaseClient.functions.invoke`.
  - [ ] Create `lib/features/missions/missions_repository.dart` exposing `Future<DailyMissionResult> getTodayMission()`.
  - [ ] Keep failure mapping explicit (network/malformed/auth) and return a safe UX fallback: empty-state copy, not blocking errors.

- [ ] **Task 4 - Riverpod providers (AC: #1, #3)**
  - [ ] Create `lib/features/missions/missions_providers.dart` with:
    - [ ] repository provider
    - [ ] async `todayMissionProvider`
    - [ ] explicit invalidation hook for date changes or manual refresh
  - [ ] Ensure provider can be consumed by Home without coupling to `brain_dump` internals.

- [ ] **Task 5 - Home UI integration (AC: #1, #3)**
  - [ ] In `lib/features/brain_dump/presentation/home_screen.dart`, insert mission card section above the preoccupation list.
  - [ ] Mission-present state: show exactly one mission with content summary + estimated duration + estimated kg gain.
  - [ ] Mission-empty state: show gentle message (`Rien d'urgent aujourd'hui. Profite.`) with calm tone (no guilt framing).
  - [ ] Keep actions minimal in 3.1 (generation/display only); behavior actions are handled in Story 3.2.

- [ ] **Task 6 - Localization (AC: #3)**
  - [ ] Add French-source-of-truth ARB keys in `assets/l10n/app_fr.arb` for mission card title/body/labels and empty-state copy.
  - [ ] Mirror keys in `assets/l10n/app_en.arb`.
  - [ ] Run `flutter gen-l10n`.

- [ ] **Task 7 - Tests (AC: #1, #2, #3)**
  - [ ] Unit test: selection rule deterministic ordering and tie-breaks.
  - [ ] Unit test: pending items excluded from candidate set.
  - [ ] Unit test: empty candidates -> empty-state result.
  - [ ] Client/repository tests: maps edge-function payloads and failures correctly.
  - [ ] Widget test: Home renders mission card when mission exists.
  - [ ] Widget test: Home renders gentle empty-state when mission absent.
  - [ ] If feasible, add Deno function test for timezone/day-boundary behavior and idempotent same-day response.

- [ ] **Task 8 - Validate & wire-up**
  - [ ] `dart format lib test`
  - [ ] `flutter analyze` (0 issues)
  - [ ] `flutter test` (all green)

## Dev Notes

### Existing context to reuse

- Open preoccupations projection already exists and is updated reactively via `projectionRevisionProvider`:
  - `lib/features/brain_dump/brain_dump_providers.dart`
- Preoccupation analysis fields needed for mission optimization already exist:
  - `lib/features/brain_dump/domain/preoccupation.dart`
- Home screen already has a stable layout and mental-load widgets; mission card should be inserted without breaking capture flow:
  - `lib/features/brain_dump/presentation/home_screen.dart`

### Architecture constraints (must follow)

- Daily Mission lives in `features/missions` (feature-first structure).
- `mission_date` must be computed server-side from frozen profile timezone (OD-2).
- Keep event/projection invariants intact; do not mutate counters directly.
- Secrets and trust-sensitive logic remain server-side (Edge Function boundary).

### Suggested implementation boundary for 3.1

- In scope now:
  - generate/select one mission per day
  - display mission or gentle empty-state
- Explicitly out of scope for this story:
  - action handling (`Commencer`, `Plus tard`, `Deja fait`) -> Story 3.2
  - validation side effects/history write -> Story 3.3

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.1: Generate the Daily Mission]
- [Source: _bmad-output/planning-artifacts/epics.md#FR-10]
- [Source: _bmad-output/planning-artifacts/epics.md#OD-2]
- [Source: _bmad-output/planning-artifacts/architecture.md#Requirements to Structure Mapping]
- [Source: _bmad-output/planning-artifacts/architecture.md#Open Decisions Status]

## Dev Agent Record

### Agent Model Used

GPT-5.3-Codex (GitHub Copilot)

### Debug Log References

- Story created from sprint backlog entry `3-1-generate-the-daily-mission`.

### Completion Notes List

- Context package prepared for `dev-story` execution.

### File List

- `_bmad-output/implementation-artifacts/3-1-generate-the-daily-mission.md` (created)

## Change Log

| Date       | Version | Description                              | Author |
| ---------- | ------- | ---------------------------------------- | ------ |
| 2026-06-10 | 0.1     | Story created from Epic 3 backlog entry | Amelia |
