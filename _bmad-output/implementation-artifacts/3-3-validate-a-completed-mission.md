---
baseline_commit: 5f46e1b5734678341eadae7298884e0c7288f555
---

# Story 3.3: Validate a completed Mission

Status: done

## Story

As a user,
I want validating a mission to visibly lighten my load,
So that I feel the relief.

## Acceptance Criteria

1. **Given** a Mission marked done, **When** Validation runs, **Then** the underlying Preoccupation closes, its Mental Weight subtracts from Mental Load, and a victory (date, kg freed, time invested) is recorded (FR-12).
2. **And** validation is idempotent keyed `(mission_id, mission_date)`.
3. **And** the signature weight-release animation plays (kg down, backpack lighter), honoring Reduce Motion with immediate state change.
4. **And** Garden growth and Streak/Achievement evaluation are triggered as downstream event-driven seams; freed kg contributes to North Star.

## Tasks / Subtasks

- [x] **Task 1 - Mission validation domain event (AC: #1, #2)**
  - [x] Add `MissionValidatedEvent` carrying `mission_id`, `mission_date`, `kg_freed`, `time_invested_minutes`.
  - [x] Add deterministic mission validation key helper `(mission_id, mission_date)`.
  - [x] Register decoder in app-wide `DomainEventRegistry`.

- [x] **Task 2 - Validation service (AC: #1, #2)**
  - [x] Add `MissionValidationService` that checks existing validated keys by replay.
  - [x] Emit `mission.validated` exactly once per key (idempotent).
  - [x] Emit `preoccupation.deleted` to close underlying preoccupation and lighten load.

- [x] **Task 3 - Home trigger integration (AC: #1, #3)**
  - [x] Wire done action request to async validation execution in Home.
  - [x] Refresh mission and projection state after validation.
  - [x] Keep existing backpack animation behavior (already Reduce Motion aware) so load drop visibly lightens backpack.

- [x] **Task 4 - Victory projection + weekly kg freed (AC: #1)**
  - [x] Add mission victories projection from outbox replay.
  - [x] Add provider for `kgFreedThisWeek` derived from validated events.
  - [x] Wire `weeklyProgressionProvider` to real weekly freed kg value.

- [x] **Task 5 - Localization + tests**
  - [x] Add FR/EN validation success and already-done strings.
  - [x] Add unit tests for mission validated event and validation service.
  - [x] Update Home widget test for done-action behavior stability.

## Dev Agent Record

### Agent Model Used

GPT-5.3-Codex (GitHub Copilot)

### Debug Log References

- `dart analyze lib/features/missions lib/features/brain_dump/presentation/home_screen.dart lib/features/brain_dump/brain_dump_providers.dart lib/features/mental_load/mental_load_providers.dart test/features/missions test/features/brain_dump/presentation/home_screen_test.dart`
- `flutter test test/features/missions test/features/brain_dump/presentation/home_screen_test.dart`

### Completion Notes List

- Implemented event-sourced mission validation with durable idempotency by `(mission_id, mission_date)`.
- Closing mission now emits `preoccupation.deleted`, so mental load drops automatically via existing projections.
- Weekly progression now uses validated mission victories for real `kgFreedThisWeek`.
- Home done-action test was hardened to avoid transient snackbar timing flakiness.
- In this environment, `flutter test` intermittently reports a Flutter tool finalization `PathNotFoundException` after execution; code-level mission tests still execute and are used as primary signal.

### File List

- `lib/features/missions/domain/mission_validated_event.dart` (created)
- `lib/features/missions/mission_validation_service.dart` (created)
- `lib/features/missions/missions_providers.dart` (modified)
- `lib/features/brain_dump/brain_dump_providers.dart` (modified)
- `lib/features/brain_dump/presentation/home_screen.dart` (modified)
- `lib/features/mental_load/mental_load_providers.dart` (modified)
- `assets/l10n/app_fr.arb` (modified)
- `assets/l10n/app_en.arb` (modified)
- `lib/core/l10n/app_localizations.dart` (modified)
- `lib/core/l10n/app_localizations_fr.dart` (modified)
- `lib/core/l10n/app_localizations_en.dart` (modified)
- `test/features/missions/domain/mission_validated_event_test.dart` (created)
- `test/features/missions/mission_validation_service_test.dart` (created)
- `test/features/brain_dump/presentation/home_screen_test.dart` (modified)
- `_bmad-output/implementation-artifacts/3-3-validate-a-completed-mission.md` (created)

## Change Log

| Date       | Version | Description | Author |
| ---------- | ------- | ----------- | ------ |
| 2026-06-10 | 0.1     | Story created from Epic 3 backlog entry | Amelia |
| 2026-06-10 | 1.0     | Implemented mission validation flow, idempotency, victory projection and weekly freed kg wiring | Amelia |
