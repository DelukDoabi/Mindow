---
baseline_commit: 8168dc0d1647e2f0948bea1df59e22f1488b2a53
---

# Story 3.4: View victory history

Status: done

## Story

As a user,
I want a list of my victories,
So that I see how far I've come.

## Acceptance Criteria

1. **Given** completed Preoccupations, **When** I open History, **Then** I see a chronological list with date, kg freed, and time invested (FR-13).
2. **And** History reflects only completed Preoccupations and every Validation appears there.

## Tasks / Subtasks

- [x] **Task 1 - History entry point in Home (AC: #1)**
  - [x] Add a dedicated CTA to open history from Home.
  - [x] Implement a bottom sheet for the history view.

- [x] **Task 2 - Chronological history rendering (AC: #1)**
  - [x] Render victories from `missionVictoriesProvider` (already sorted by `validatedAt` descending).
  - [x] Display date, kg freed, and invested minutes for each row.
  - [x] Add graceful empty state when no validation exists.

- [x] **Task 3 - Data consistency (AC: #2)**
  - [x] Reuse event-sourced projection based on `mission.validated` only.
  - [x] Keep idempotency behavior inherited from Story 3.3 (`mission_id`, `mission_date`).

- [x] **Task 4 - Localization + tests**
  - [x] Add FR/EN strings for history CTA/title/empty row summary.
  - [x] Add widget test for opening empty history.
  - [x] Add widget test for chronological row rendering.

## Dev Agent Record

### Agent Model Used

GPT-5.3-Codex (GitHub Copilot)

### Debug Log References

- `flutter gen-l10n`
- `dart analyze lib/features/brain_dump/presentation/home_screen.dart test/features/brain_dump/presentation/home_screen_test.dart lib/features/missions/missions_providers.dart`
- `flutter test test/features/missions`
- `flutter test test/features/brain_dump/presentation/home_screen_test.dart --plain-name "opens empty victory history sheet"`
- `flutter test test/features/brain_dump/presentation/home_screen_test.dart --plain-name "renders victory rows in chronological history"`

### Completion Notes List

- Added history access (`Voir l'historique`) on Home.
- Implemented History bottom sheet with chronological rows (date, kg freed, time invested).
- Reused mission validation event projection to ensure history contains only validated completions.
- Added FR/EN localized strings and regenerated l10n classes.
- Added dedicated widget tests for empty and populated history states.

### File List

- `lib/features/brain_dump/presentation/home_screen.dart` (modified)
- `test/features/brain_dump/presentation/home_screen_test.dart` (modified)
- `assets/l10n/app_fr.arb` (modified)
- `assets/l10n/app_en.arb` (modified)
- `lib/core/l10n/app_localizations.dart` (modified)
- `lib/core/l10n/app_localizations_fr.dart` (modified)
- `lib/core/l10n/app_localizations_en.dart` (modified)
- `_bmad-output/implementation-artifacts/3-4-view-victory-history.md` (created)

## Change Log

| Date       | Version | Description | Author |
| ---------- | ------- | ----------- | ------ |
| 2026-06-10 | 0.1     | Story created from Epic 3 backlog entry | Amelia |
| 2026-06-10 | 1.0     | Implemented History access and chronological victory list with localization and tests | Amelia |
