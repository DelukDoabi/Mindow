---
baseline_commit: 2085a57
---

# Story 4.3: Achievements & Streak

Status: ready-for-dev

## Story

As a user,
I want to unlock achievements,
So that milestones feel meaningful — never punishing.

## Acceptance Criteria

1. **Given** qualifying activity, **When** a condition is first met, **Then** the matching Achievement unlocks exactly once and persists (FR-17):
   - **First Victory** — 1 unique validated mission
   - **10 kg Freed** — ≥ 10 kg total from unique validated missions
   - **100 Preoccupations** — 100 unique preoccupations ever captured (`preoccupation.captured` unique aggregateIds)
   - **30-Day Streak** — current consecutive streak ≥ 30 days
2. **And** Streak = consecutive calendar days ending today-or-yesterday with ≥ 1 completed Mission; a missed day is silent and never penalized (UX-DR19).
3. **And** Achievement state is a pure deterministic projection from the event log — idempotent, consistent across devices, no mutable counters (NFR-7).
4. **And** GardenScreen surfaces the current streak count and the 4 achievements (locked/unlocked) in the existing progression hub.

## Context & Constraints

- **Event-sourced only**: Achievement and streak state MUST be derived projections from `mission.validated` and `preoccupation.captured` events already in the local outbox. No new event type is needed for MVP. No `UPDATE` to a streak counter.
- **Dedup rule**: validated missions deduplicated by `missionValidationKey(missionId, missionDate)` — same key as Garden/Level (keeps all three projections coherent).
- **Streak "today" anchor**: compare mission dates against device local time (profile timezone not yet implemented; document this as a known simplification for future hardening).
- **No punitive UX**: locked achievements render neutrally (greyed/muted) — NO red badges, NO "streak broken" wording, NO pressure copy. Copy must pass UX-DR16/UX-DR19.
- **Reuse established patterns**: mirror Garden/Level domain models and provider composition exactly.
- All l10n in FR/EN via ARB keys.
- `flutter analyze` must be clean; no new lints introduced.

## Resolved Decisions

| # | Question | Decision |
|---|----------|----------|
| 1 | "100 preoccupations" = captures or validations? | **Captures** — count unique `aggregateId` values from `preoccupation.captured` events. This measures engagement breadth (things deposited) not depth (missions completed). |
| 2 | Streak gap: if today not done, does yesterday's streak still count? | **Yes** — streak is computed from the most recent mission date. If it equals today OR yesterday (UTC-local), the streak is active. If earlier, streak = 0. A missed day silently resets to 0; no "broken" label is ever shown. |
| 3 | Multi-device consistency for achievements? | Achieved automatically: pure projection from event log which syncs via outbox → no extra work needed in MVP. |
| 4 | Should achievements emit their own event for notification purposes? | **No** for MVP — notification epic (5.x) will add that layer. Achievement unlock detection lives in the UI layer for now (watch for `isUnlocked` transition on widget rebuild). |
| 5 | Where to surface streak and achievements in UI? | On the existing **GardenScreen** (the progression hub). Add a streak section below the level card, and an achievements section below that. No new route needed. |

## Technical Notes For Dev

### Existing code to understand before starting

**`lib/features/gamification/domain/garden_state.dart`** — canonical dedup pattern:
```dart
// missionValidationKey(missionId: e.missionId, missionDate: e.missionDate) → dedup key
// Follow this exactly for validated-mission dedup in AchievementState
```

**`lib/features/gamification/garden_providers.dart`** — shared `missionValidatedEventsProvider`:
```dart
// Already replays all mission.validated events with projectionRevisionProvider watch.
// achievementStateProvider MUST watch this provider (don't duplicate the replay).
```

**`lib/features/gamification/level_providers.dart`** — composition pattern:
```dart
// levelStateProvider = Provider deriving from missionValidatedEventsProvider.
// achievementStateProvider follows the same composition: watch 2 providers, compute pure state.
```

**`lib/features/brain_dump/domain/preoccupation_captured_event.dart`**:
```dart
static const String type = 'preoccupation.captured';
// aggregateId IS the preoccupation ID (the UUID used for both eventId and aggregateId at capture).
// Count unique aggregateIds = unique preoccupations ever captured.
```

**`lib/features/gamification/presentation/garden_screen.dart`** — currently shows garden element + level. Will receive a streak chip and an achievements list. Read the full file before editing.

### AchievementState domain model sketch

```dart
enum Achievement { firstVictory, tenKgFreed, hundredPreoccupations, thirtyDayStreak }

class AchievementState {
  const AchievementState({
    required this.unlockedAchievements,
    required this.currentStreak,
    required this.totalValidatedMissions,
    required this.totalKgFreed,
    required this.totalCapturedPreoccupations,
  });

  final Set<Achievement> unlockedAchievements;
  final int currentStreak;
  final int totalValidatedMissions;  // deduped
  final int totalKgFreed;            // summed from unique validated events
  final int totalCapturedPreoccupations; // unique aggregateIds

  bool isUnlocked(Achievement achievement) => unlockedAchievements.contains(achievement);

  static AchievementState fromInputs({
    required List<MissionValidatedEvent> validatedEvents,
    required int capturedCount,
  }) { /* ... deterministic, no side effects */ }
}
```

### Streak computation guide

```
1. Collect unique missionDate strings from deduplicated validated events → Set<String>
2. Parse each to DateTime, sort descending.
3. today = DateTime.now().toLocal() normalized to midnight.
4. If the most recent date < (today - 1 day): streak = 0 (gap detected).
5. Otherwise, count consecutive days backward from most recent:
   - streak = 1, expected = mostRecent - 1 day
   - For each subsequent unique date: if == expected → streak++, expected--; else break.
6. Return streak. NOTE: today's date may or may not be in the set; both are valid (streak is live or "yesterday complete").
```

### capturedPreoccupationsCountProvider pattern

Create in `achievement_providers.dart` — separate replay, follows `garden_providers.dart` structure:

```dart
// Must: ref.watch(projectionRevisionProvider) to stay reactive
// Must: ReplayEngine().replay over eventStoreProvider.all()
// Must: use domainEventRegistryProvider (so only registered events decode)
// Fold: if event is PreoccupationCapturedEvent → add aggregateId to Set<String>
// Return: set.length (count of unique captured preoccupations)
```

### achievementStateProvider

```dart
final achievementStateProvider = Provider<AchievementState>((ref) {
  final validatedEvents = ref.watch(missionValidatedEventsProvider);
  final capturedCount = ref.watch(capturedPreoccupationsCountProvider);
  return AchievementState.fromInputs(
    validatedEvents: validatedEvents,
    capturedCount: capturedCount,
  );
});
```

### GardenScreen additions (UX guidance)

Below the existing level card, add:
1. **Streak section** — a subtle text row: e.g., "Série en cours : 3 jours" (FR) / "Current streak: 3 days" (EN). If streak = 0, show "0 jour(s)" — not hidden, but no alarming language. Use `AuroreColors.inkMuted` for neutral tone.
2. **Achievements section** — titled "Accomplissements" / "Achievements". Render the 4 achievements as a vertical list of `DecoratedBox` cards. Each card: title + description + status label ("Débloqué" / "Unlocked" vs "Pas encore" / "Not yet"). Unlocked cards use normal ink; locked ones use `AuroreColors.inkMuted` for the title and description text. NO red, NO exclamation marks, NO lock icon that implies failure.

## Tasks / Subtasks

- [ ] **Task 1 — Achievement domain model (AC: #1, #3)**
  - [ ] Create `lib/features/gamification/domain/achievement_state.dart`
  - [ ] Define `Achievement` enum (4 values: `firstVictory`, `tenKgFreed`, `hundredPreoccupations`, `thirtyDayStreak`)
  - [ ] Define immutable `AchievementState` class with: `unlockedAchievements`, `currentStreak`, `totalValidatedMissions`, `totalKgFreed`, `totalCapturedPreoccupations`, `isUnlocked()` helper
  - [ ] Implement `AchievementState.fromInputs({validatedEvents, capturedCount})` — pure deterministic factory: dedup validated events by `missionValidationKey`, sum kgFreed, compute streak, evaluate all 4 unlock conditions
  - [ ] Implement `_computeStreak(Set<String> missionDates)` top-level function — sort descending, check today-or-yesterday anchor, count consecutive days backward

- [ ] **Task 2 — Achievement projection providers (AC: #3)**
  - [ ] Create `lib/features/gamification/achievement_providers.dart`
  - [ ] Add `capturedPreoccupationsCountProvider` — `Provider<int>` watching `projectionRevisionProvider`, replays all events from `eventStoreProvider`, folds only `PreoccupationCapturedEvent` into `Set<String>` (unique aggregateIds), returns `set.length`
  - [ ] Add `achievementStateProvider` — `Provider<AchievementState>` deriving from `missionValidatedEventsProvider` + `capturedPreoccupationsCountProvider`

- [ ] **Task 3 — GardenScreen UI update (AC: #4)**
  - [ ] Read `lib/features/gamification/presentation/garden_screen.dart` fully before editing
  - [ ] Add `achievementStateProvider` watch to `GardenScreen.build`
  - [ ] Add streak section below the level card: display `l10n.achievementsStreakLabel(achievementState.currentStreak)`
  - [ ] Add achievements section below streak: title row + 4 achievement cards in a `Column`
  - [ ] Each card: use `DecoratedBox` with `AuroreColors.glass` background (matching existing style), display achievement title + description + locked/unlocked status label; locked cards render text in `AuroreColors.inkMuted`
  - [ ] Add `_achievementTitle(l10n, Achievement)` and `_achievementDescription(l10n, Achievement)` private helpers (pattern mirrors `_levelTierLabel` / `_gardenElementLabel`)

- [ ] **Task 4 — Localization (FR/EN)**
  - [ ] Add to `assets/l10n/app_fr.arb`:
    - `achievementsTitle`: "Accomplissements"
    - `achievementsStreakLabel` (int placeholder `count`): "Série en cours : {count} jour(s)"
    - `achievementFirstVictoryTitle`: "Première victoire"
    - `achievementFirstVictoryDesc`: "Valide ta première mission"
    - `achievementTenKgTitle`: "10 kg allégés"
    - `achievementTenKgDesc`: "Libère au moins 10 kg de charge mentale"
    - `achievementHundredPreoccupationsTitle`: "100 préoccupations"
    - `achievementHundredPreoccupationsDesc`: "Dépose 100 préoccupations dans ton sac à dos"
    - `achievementThirtyDayStreakTitle`: "Série de 30 jours"
    - `achievementThirtyDayStreakDesc`: "Valide une mission chaque jour pendant 30 jours d'affilée"
    - `achievementUnlocked`: "Débloqué"
    - `achievementLocked`: "Pas encore débloqué"
  - [ ] Add matching entries to `assets/l10n/app_en.arb` (with `@` descriptors)
  - [ ] Run `flutter gen-l10n` to regenerate `lib/core/l10n/app_localizations*.dart`

- [ ] **Task 5 — Tests**
  - [ ] Create `test/features/gamification/domain/achievement_state_test.dart`:
    - Streak 0 with empty events
    - Streak 1 with one event dated today
    - Streak 1 with one event dated yesterday (streak still active, "not yet today" is fine)
    - Streak breaks when most recent date is before yesterday
    - Streak counts consecutive days correctly (3-day streak from 3 consecutive dates)
    - Streak skips non-consecutive earlier dates after the gap
    - `firstVictory`: unlocks at 1 unique validated mission, not unlocked at 0
    - `tenKgFreed`: unlocks at exactly 10 total kgFreed, not at 9
    - `tenKgFreed`: dedup — same (missionId, missionDate) only counted once
    - `hundredPreoccupations`: unlocks at 100 unique capturedCount, not at 99
    - `thirtyDayStreak`: unlocks at streak ≥ 30, not at 29
  - [ ] Create `test/features/gamification/achievement_projection_test.dart`:
    - `capturedPreoccupationsCountProvider` counts unique aggregateIds from `preoccupation.captured` only (ignores other event types)
    - `achievementStateProvider` derives correctly from both validated and captured inputs
    - Idempotent dedup for validated events: duplicate `(missionId, missionDate)` pairs do not double-count kgFreed
  - [ ] Update `test/features/gamification/presentation/garden_screen_test.dart`:
    - Override `achievementStateProvider` with a stub state; verify streak section renders
    - Verify achievements section shows at least the achievements title
    - Ensure existing 4.1 garden and 4.2 level assertions still pass (non-regression)

## Suggested File Targets

- `lib/features/gamification/domain/achievement_state.dart` (CREATE)
- `lib/features/gamification/achievement_providers.dart` (CREATE)
- `lib/features/gamification/presentation/garden_screen.dart` (UPDATE — add streak + achievements sections)
- `assets/l10n/app_fr.arb` (UPDATE — append achievement/streak keys)
- `assets/l10n/app_en.arb` (UPDATE — append achievement/streak keys with @descriptors)
- `lib/core/l10n/app_localizations*.dart` (GENERATED — run flutter gen-l10n)
- `test/features/gamification/domain/achievement_state_test.dart` (CREATE)
- `test/features/gamification/achievement_projection_test.dart` (CREATE)
- `test/features/gamification/presentation/garden_screen_test.dart` (UPDATE)

## Definition of Done Checklist

- [ ] `AchievementState.fromInputs` correctly evaluates all 4 unlock conditions
- [ ] Streak computation handles: empty, single day (today), single day (yesterday), gap → 0, consecutive run
- [ ] `capturedPreoccupationsCountProvider` reactive to outbox changes (via `projectionRevisionProvider`)
- [ ] GardenScreen surfaces streak count and 4 achievements with no punitive copy
- [ ] Locked achievements render in muted style — no red indicators, no failure language
- [ ] FR/EN localization complete and `flutter gen-l10n` output committed
- [ ] All new tests pass; no regressions in existing gamification or home tests
- [ ] `flutter analyze` clean

## Testing Standards Summary

- Unit tests (`flutter_test`) in `achievement_state_test.dart`:
  - Boundary values for each unlock condition (N-1 = locked, N = unlocked)
  - Streak edge cases: today vs yesterday anchor, gap detection, consecutive counting
- Projection tests in `achievement_projection_test.dart`:
  - Provider computed values match expected from stubbed event lists
  - Dedup is idempotent (same key twice → counted once)
- Widget tests (garden_screen_test update):
  - Override `achievementStateProvider` with a canned `AchievementState`
  - Assert streak label and achievements title render
  - Run existing 4.1/4.2 test assertions to confirm no regressions
- Targeted run before handoff:
  - `flutter test test/features/gamification/`
  - `flutter test test/features/brain_dump/presentation/home_screen_test.dart --plain-name "shows the localized empty backpack and capture affordance"`

## Dev Agent Gotchas (from prior Epic 4 stories)

- **Strict lints**: `avoid_escaping_inner_quotes` — apostrophes in FR strings → use double-quoted ARB values. `cascade_invocations` applies. Run `dart format lib test` before commit.
- **`missionValidatedEventsProvider` is in `garden_providers.dart`** — import from there, don't re-declare it.
- **`projectionRevisionProvider` is in `sync_providers.dart`** — both new providers must watch it for reactivity.
- **Widget test / Hive interaction**: if the widget test for GardenScreen opens any Hive box (it currently doesn't, but check), you'll need `await Hive.close()` in tearDown. If you override all providers with stubs you avoid Hive entirely — prefer that.
- **`use_build_context_synchronously`**: guard any `context.go` / snackBar after `await` with `if (context.mounted)`.
- **No `StateProvider`** in this repo — use `NotifierProvider<Notifier<T>, T>` for any mutable seams needed.
- **`build_runner` not needed** — no code-gen annotations added by this story (no Hive adapters, no `@riverpod`). Skip it.

## References

- `_bmad-output/planning-artifacts/epics.md` — Story 4.3 / FR-17 / UX-DR19
- `_bmad-output/planning-artifacts/architecture.md` — event-sourced projection constraints, NFR-7
- `lib/features/gamification/domain/garden_state.dart` — dedup pattern baseline
- `lib/features/gamification/domain/level_state.dart` — dedup pattern baseline
- `lib/features/gamification/garden_providers.dart` — `missionValidatedEventsProvider`, provider composition
- `lib/features/gamification/level_providers.dart` — composition pattern
- `lib/features/gamification/presentation/garden_screen.dart` — UI to extend
- `lib/features/missions/domain/mission_validated_event.dart` — event shape + `missionValidationKey`
- `lib/features/brain_dump/domain/preoccupation_captured_event.dart` — event shape (aggregateId = preoccupation ID)
- `lib/core/sync/sync_providers.dart` — `projectionRevisionProvider`, `eventStoreProvider`, `domainEventRegistryProvider`
