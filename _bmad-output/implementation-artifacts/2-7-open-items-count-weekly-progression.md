---
baseline_commit: 5a3582f
---

# Story 2.7: Open-items count & weekly progression

Status: done

## Story

As a user,
I want to see how many worries are open and my weekly progress,
So that I feel direction without pressure.

## Acceptance Criteria

1. **Given** Home, **When** it renders, **Then** two stat pills appear below the backpack:
   - Pill A: bold open-items count, muted label "en cours" (positive frame).
   - Pill B: bold kg freed this week (e.g. "0 kg"), muted label "libérés cette semaine".
   (FR-9, UX-DR5)
2. **And** the open-items count equals `openPreoccupationsProvider.length` and updates
   immediately when a preoccupation is added, edited, or deleted (same reactive chain). (FR-9)
3. **And** "kg freed this week" is 0 in Epic 2 (no validation flow yet); the provider stub
   is intentional — Epic 3 (Story 3.3 Validation) will fill it in. (FR-9)
4. **And** the pills are glass capsules (`AuroreColors.glass` fill, `AuroreRadii.pill` radius),
   bold value (`titleMedium` + `FontWeight.bold` + `AuroreColors.ink`), muted label
   (`labelSmall` + `AuroreColors.inkMuted`) — no tap action (Garden/Progress route not yet
   implemented). (UX-DR5)
5. **And** the pill row provides a `Semantics` node readable by VoiceOver/TalkBack. (UX-DR18)
6. **And** all new copy is French-source-of-truth localized with `@key` description entries. (NFR-5)

## Technical Context

### Existing providers / models (do NOT break)

| Symbol | Location |
|--------|----------|
| `openPreoccupationsProvider` | `brain_dump_providers.dart` |
| `mentalLoadProvider` | `mental_load_providers.dart` |
| `MentalLoadProjection` | `domain/mental_load_projection.dart` |
| `BackpackWidget` | `presentation/backpack_widget.dart` |

### Design tokens

```dart
AuroreColors.glass      // fill for stat pill capsule
AuroreColors.ink        // bold value text
AuroreColors.inkMuted   // muted label text
AuroreRadii.pill        // 999 — full pill shape
AuroreSpacing.lg=16  md=12  sm=8
```

### Riverpod 3 — test override pattern

```dart
weeklyProgressionProvider.overrideWithValue(AsyncValue.data(projection))
// Never use Override typed variable (sealed, @publicInCodegen)
```

### lint traps

- Doc comments: backticks only — never `[SymbolName]`.
- `avoid_redundant_argument_values`, `prefer_int_literals`, `unnecessary_underscores`.
- `directives_ordering`: alphabetical (stdlib → flutter → packages → local).
- `error: (_, _)` not `(_, __)`.

## Tasks

- [x] **Task 1 — `WeeklyProgressionProjection` domain model**
  - [x] Create `lib/features/mental_load/domain/weekly_progression_projection.dart`
  - [x] `const` constructor: `openCount: int`, `kgFreedThisWeek: int`.
  - [x] No Freezed, no Hive, no Flutter imports.

- [x] **Task 2 — `weeklyProgressionProvider`**
  - [x] Add to existing `lib/features/mental_load/mental_load_providers.dart`:
    ```dart
    import 'package:mindow/features/mental_load/domain/weekly_progression_projection.dart';
    @riverpod
    Future<WeeklyProgressionProjection> weeklyProgression(Ref ref) async {
      final items = await ref.watch(openPreoccupationsProvider.future);
      return WeeklyProgressionProjection(openCount: items.length, kgFreedThisWeek: 0);
    }
    ```
  - [x] Run `dart run build_runner build` to regenerate `mental_load_providers.g.dart`.

- [x] **Task 3 — ARB localization**
  - [x] `app_fr.arb`: `statPillOpenCountLabel`, `statPillKgFreedValue(int kg)`, `statPillKgFreedLabel`.
  - [x] `app_en.arb`: same keys with English values.
  - [x] Run `flutter gen-l10n`.

- [x] **Task 4 — `StatPillRow` widget**
  - [x] Create `lib/features/mental_load/presentation/stat_pill_row.dart`.
  - [x] `ConsumerWidget` watching `weeklyProgressionProvider`.
  - [x] Loading/error: `SizedBox(height: 56)` placeholder.
  - [x] Data: `Row` with two `_StatPill` capsules.
  - [x] Semantics wrapping.

- [x] **Task 5 — Wire into HomeScreen**
  - [x] Insert `StatPillRow` between `BackpackWidget` and `Expanded(list)`.

- [x] **Task 6 — Tests**
  - [x] `test/features/mental_load/domain/weekly_progression_projection_test.dart`
  - [x] `test/features/mental_load/presentation/stat_pill_row_test.dart`
  - [x] 137+ tests green.

- [x] **Task 7 — Format + analyze + commit**
