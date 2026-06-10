---
baseline_commit: d1d71dd0ff033e04f8d26194703b451723ee0fb8
---

# Story 3.2: Act on the Daily Mission

Status: done

## Story

As a user,
I want to start, defer, or complete my mission,
So that I stay in control without guilt.

## Acceptance Criteria

1. **Given** a Daily Mission, **When** I tap Commencer / Plus tard / Deja fait, **Then** "Commencer" surfaces context, "Plus tard" defers penalty-free (item stays open, new mission next cycle), "Deja fait" triggers Validation (FR-11).
2. **And** the mission card shows one mission, primary "C'est fait ✓", secondary penalty-free defer (UX-DR8).

## Tasks / Subtasks

- [x] **Task 1 - Mission actions in Home (AC: #1, #2)**
  - [x] Add explicit mission actions in `home_screen.dart`: `Commencer`, `Plus tard`, `C'est fait ✓`.
  - [x] Keep `C'est fait ✓` as the primary CTA.
  - [x] Add a context surface (bottom sheet) for `Commencer`.

- [x] **Task 2 - Penalty-free defer state (AC: #1, #2)**
  - [x] Add mission UI state provider to mark a mission as deferred for the current `(mission_date, preoccupation_id)` key.
  - [x] Hide deferred mission from the card and show gentle empty state instead.
  - [x] Provide kind feedback copy after defer action.

- [x] **Task 3 - Validation trigger handoff (AC: #1)**
  - [x] Add provider state to store requested mission validation id.
  - [x] Wire `C'est fait ✓` to set validation-requested mission id.
  - [x] Show immediate user feedback that validation flow is starting (full validation behavior is Story 3.3).

- [x] **Task 4 - Localization (AC: #1, #2)**
  - [x] Add FR source keys for mission actions, feedback messages, and context sheet labels.
  - [x] Add EN mirrors.
  - [x] Regenerate l10n files.

- [x] **Task 5 - Tests (AC: #1, #2)**
  - [x] Update Home widget tests to verify action labels render.
  - [x] Add widget test for `Commencer` context sheet.
  - [x] Add widget test for penalty-free defer behavior and feedback.
  - [x] Add widget test for done action validation-trigger feedback.

## Dev Notes

### Scope boundary

- Story 3.2 focuses on action UX and handoff only.
- Actual validation side effects (closing preoccupation, load reduction, victory write) stay in Story 3.3.

### Implementation details

- `Commencer` opens a local mission context bottom sheet.
- `Plus tard` stores a deferred mission UI key and keeps tone guilt-free.
- `C'est fait ✓` writes to a provider used as a validation trigger handoff seam.

## Dev Agent Record

### Agent Model Used

GPT-5.3-Codex (GitHub Copilot)

### Debug Log References

- `flutter gen-l10n`
- `dart format lib/features/missions/missions_providers.dart lib/features/brain_dump/presentation/home_screen.dart test/features/brain_dump/presentation/home_screen_test.dart`
- `dart analyze lib/features/missions lib/features/brain_dump/presentation/home_screen.dart test/features/brain_dump/presentation/home_screen_test.dart` (0 errors, 1 info lint)
- `flutter test test/features/brain_dump/presentation/home_screen_test.dart` (all tests passed)

### Completion Notes List

- Added mission action row with explicit primary/secondary semantics in Home.
- Added mission context bottom sheet for `Commencer`.
- Added defer and validation trigger providers in `missions_providers.dart`.
- Added localized action labels and feedback messages in FR/EN and regenerated l10n code.
- Expanded Home widget tests to cover all 3.2 behaviors.

### File List

- `lib/features/brain_dump/presentation/home_screen.dart` (modified)
- `lib/features/missions/missions_providers.dart` (modified)
- `test/features/brain_dump/presentation/home_screen_test.dart` (modified)
- `assets/l10n/app_fr.arb` (modified)
- `assets/l10n/app_en.arb` (modified)
- `lib/core/l10n/app_localizations.dart` (modified)
- `lib/core/l10n/app_localizations_fr.dart` (modified)
- `lib/core/l10n/app_localizations_en.dart` (modified)
- `_bmad-output/implementation-artifacts/3-2-act-on-the-daily-mission.md` (created)

## Change Log

| Date       | Version | Description | Author |
| ---------- | ------- | ----------- | ------ |
| 2026-06-10 | 0.1     | Story created from Epic 3 backlog entry | Amelia |
| 2026-06-10 | 1.0     | Implemented Daily Mission actions, defer behavior, validation trigger handoff, localization, and widget tests | Amelia |
