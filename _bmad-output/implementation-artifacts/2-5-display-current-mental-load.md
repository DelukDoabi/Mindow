---
baseline_commit: 7bcfdc5
---

# Story 2.5: Display current Mental Load

Status: done

## Story

As a user,
I want to see my total mental load in kg,
So that I grasp what I'm carrying.

## Acceptance Criteria

1. **Given** open Preoccupations, **When** Home renders, **Then** the displayed Mental Load equals the sum of their assigned Mental Weight in kg (FR-7). Pending items (awaiting AI analysis, `mentalWeightKg == null`) contribute **0 kg** to the sum — they are visible in the list but not yet weighed.
2. **And** adding, editing, or deleting a Preoccupation updates the displayed load accordingly without requiring a page reload — the hero numeral reflects the latest projection the moment the `ProjectionRevision` bumps (same reactive chain used by the list, Stories 2.2–2.4).
3. **And** the kg figure is the single Aurore-gradient hero numeral (Inter Bold ~88, `accentGradient` fill warm→cool) with a non-gradient fallback fill (`AuroreColors.ink`) for contrast/accessibility (UX-DR3, UX-DR18). The `kg` unit suffix is smaller (labelMedium) and cool-accent tinted (`AuroreColors.cool`). A muted caption appears beneath ("sur tes épaules").
4. **And** the widget provides a `Semantics` label that reads the weight and context aloud for VoiceOver/TalkBack (UX-DR18), e.g. `"42 kg sur tes épaules"`.
5. **And** all new copy is French-source-of-truth localized with ARB `@key` description entries (NFR-5).

## Tasks / Subtasks

- [x] **Task 1 — `MentalLoadProjection` domain model** (AC: #1)
  - [x] Create `lib/features/mental_load/domain/mental_load_projection.dart`: a plain Dart class (no Freezed, no Hive — it is a derived read-model, never persisted).
    - `final int totalKg` — sum of assigned `mentalWeightKg` values; pending items contribute 0.
    - `final bool hasPendingItems` — true if at least one open Preoccupation is still `isPending`. Drives the `~` suffix hint (see Task 3).
    - `const MentalLoadProjection({required this.totalKg, required this.hasPendingItems})`.
    - `factory MentalLoadProjection.fromPreoccupations(List<Preoccupation> items)` — extracts both values in a single pass so the provider stays thin.
    - No `@freezed`, no `part`, no imports beyond the `Preoccupation` model.

- [x] **Task 2 — `mentalLoadProvider` Riverpod provider** (AC: #1, #2)
  - [x] Create `lib/features/mental_load/mental_load_providers.dart`:
    - Import `openPreoccupationsProvider` from `brain_dump_providers.dart` and `MentalLoadProjection`.
    - `part 'mental_load_providers.g.dart';`
    - `@riverpod Future<MentalLoadProjection> mentalLoad(Ref ref) async { final items = await ref.watch(openPreoccupationsProvider.future); return MentalLoadProjection.fromPreoccupations(items); }`
    - Watching `openPreoccupationsProvider.future` means the provider auto-rebuilds whenever `openPreoccupationsProvider` rebuilds (which happens on `projectionRevisionProvider.bump()` or `ref.invalidate(openPreoccupationsProvider)`). No extra wiring needed.
  - [x] Run `dart run build_runner build` to generate `mental_load_providers.g.dart`.

- [x] **Task 3 — `MentalLoadHero` widget** (AC: #3, #4)
  - [x] Create `lib/features/mental_load/presentation/mental_load_hero.dart`: a `ConsumerWidget` that watches `mentalLoadProvider`.
  - [x] Loading state: `CircularProgressIndicator()` (same as the list loading state).
  - [x] Error state: show `"-- kg"` in plain ink color (no gradient) with the same caption.
  - [x] Data state:
    ```
    Semantics(
      label: l10n.mentalLoadSemanticLabel(totalKg),  // e.g. "42 kg sur tes épaules"
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // gradient numeral row
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AuroreColors.accentGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  '$totalKg',
                  style: textTheme.displayLarge?.copyWith(
                    color: Colors.white,  // ShaderMask replaces this with the gradient
                    fontSize: 88,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AuroreSpacing.xs),
              Text(
                l10n.weightKgLabel,          // reuse existing "kg" label
                style: textTheme.labelMedium?.copyWith(
                  color: AuroreColors.cool,
                ),
              ),
              if (hasPendingItems) ...[
                const SizedBox(width: AuroreSpacing.xs),
                Text(
                  '~',
                  style: textTheme.labelSmall?.copyWith(
                    color: AuroreColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
          // caption
          Text(
            l10n.mentalLoadCaption,          // "sur tes épaules"
            style: textTheme.labelSmall?.copyWith(
              color: AuroreColors.inkMuted,
            ),
          ),
        ],
      ),
    )
    ```
  - [x] The non-gradient fallback is automatic: if `ShaderMask.createShader` is unavailable (Impeller edge case), `Colors.white` shows against the dawn canvas — which is insufficient. So set `color: AuroreColors.ink` in the `Text` style as the pre-shader color: Flutter's `ShaderMask` with `BlendMode.srcIn` takes the child's **alpha** channel and fills it with the shader. If the shader call fails, the child text renders in `AuroreColors.ink` (which meets contrast). This is the "non-gradient fallback fill" required by UX-DR3/UX-DR18.
  - [x] Keep the widget stateless (all state in the provider). No animation in this story (Story 2.6 adds animation).

- [x] **Task 4 — Wire hero into Home screen** (AC: #1, #2, #3)
  - [x] In `lib/features/brain_dump/presentation/home_screen.dart`, add `import 'package:mindow/features/mental_load/presentation/mental_load_hero.dart';`.
  - [x] In `_HomeScreenState.build`, insert `MentalLoadHero()` between the welcome title and the `Expanded` list:
    ```dart
    Text(l10n.homeWelcomeTitle, ...),
    const SizedBox(height: AuroreSpacing.lg),
    const MentalLoadHero(),    // ← NEW
    const SizedBox(height: AuroreSpacing.lg),
    Expanded(...)
    ```
  - [x] No changes to existing `_PreoccupationList`, `_EmptyBackpack`, `_CategoryChip`, crisis listener, or input/CTA logic.

- [x] **Task 5 — Localization** (AC: #4, #5, NFR-5)
  - [x] Add to `assets/l10n/app_fr.arb` (French = source of truth):
    - `"mentalLoadCaption": "sur tes épaules"` with description `"Muted caption displayed below the kg hero numeral on Home"`.
    - `"mentalLoadSemanticLabel": "{totalKg} kg sur tes épaules"` with placeholder `totalKg` (type `int`) and description `"VoiceOver/TalkBack accessibility label for the Mental Load hero numeral"`.
  - [x] Mirror both keys to `assets/l10n/app_en.arb`:
    - `"mentalLoadCaption": "on your shoulders"`.
    - `"mentalLoadSemanticLabel": "{totalKg} kg on your shoulders"`.
  - [x] Run `flutter gen-l10n` to regenerate `lib/core/l10n/*`.
  - [x] `mentalLoadSemanticLabel` takes a `totalKg` parameter — use the ICU plural-compatible format `{totalKg}` (integer param). Check existing ARB for the pattern (e.g. see how other parametrized strings are declared).

- [x] **Task 6 — Tests** (AC: all)
  - [x] `test/features/mental_load/domain/mental_load_projection_test.dart`:
    - Empty list → `totalKg == 0`, `hasPendingItems == false`.
    - All pending → `totalKg == 0`, `hasPendingItems == true`.
    - Mixed pending + assigned → `totalKg` equals sum of assigned only; `hasPendingItems == true`.
    - All assigned, no pending → `totalKg` equals full sum; `hasPendingItems == false`.
    - Negative or zero weight (e.g. AI returns 0) → included in sum as-is (0).
  - [x] `test/features/mental_load/mental_load_providers_test.dart` (lightweight, no Hive — mock `openPreoccupationsProvider`):
    - Provider returns correct `MentalLoadProjection` when `openPreoccupationsProvider` resolves with items.
    - *(If mocking providers is complex with Riverpod generator setup, skip this file and cover via widget test below.)*
  - [x] Widget test `test/features/mental_load/presentation/mental_load_hero_test.dart`:
    - Widget renders numeral when provider resolves.
    - Shows `CircularProgressIndicator` while loading.
    - Semantics tree contains the full accessibility label.
    - `hasPendingItems = true` → `~` indicator visible.
    - `hasPendingItems = false` → no `~`.

## Dev Notes

### Architecture Patterns and Constraints

- **`features/mental_load/` is a new feature directory.** The architecture explicitly designates `lib/features/mental_load/domain/` as the home for the mental_load projection. Create the full directory tree: `lib/features/mental_load/domain/`, `lib/features/mental_load/presentation/`.
- **`MentalLoadProjection` is a pure derived read-model — no Hive, no Freezed.** It is computed from `openPreoccupationsProvider` on every rebuild. It does NOT live in Hive and does NOT get a `typeId`. [Source: architecture.md — `mental_load` is a DERIVED projection, never a mutated counter]
- **Reactive chain (no polling).** `mentalLoadProvider` watches `openPreoccupationsProvider.future`. Since `openPreoccupationsProvider` depends on `projectionRevisionProvider`, every `bump()` (triggered by capture, edit, delete, or weight assignment) propagates transitively to `mentalLoadProvider`. No separate wiring needed.
- **`ShaderMask` for gradient text.** Flutter has no native gradient text. The canonical approach is `ShaderMask` with `BlendMode.srcIn`: the shader fills the child's alpha channel. The child `Text` must use `color: AuroreColors.ink` (not `Colors.white`) so the fallback is visible and accessible without the gradient.
- **Existing `weightKgLabel` ARB key reuse.** The "kg" unit label is already in `app_fr.arb` / `app_en.arb` as `weightKgLabel`. Reuse it instead of adding a new key.
- **`comment_references` lint trap.** Doc comments MUST NOT use `[SomeType]` or `[ref.xxx]` unless the type is imported. Use backticks: `` `mentalLoadProvider` ``, `` `ProjectionRevision` ``. [Source: Story 2.3 → fix commit `3564048`; CI failure record]
- **`prefer_initializing_formals` lint.** If any new class has private fields assigned in the initializer (`_field = param`), add `// ignore_for_file: prefer_initializing_formals`. Check if `MentalLoadHero` or `MentalLoadProjection` triggers this. [Source: Story 2.3 Dev Notes]
- **No animation in this story.** Smooth count-up animation and the backpack weight-release animation are Story 2.6. In 2.5 the numeral updates instantly on rebuild.
- **`pumpAndSettle` forbidden in widget tests with indeterminate spinners.** Use bounded `pump(Duration(...))` calls instead. [Source: Story 2.3 Dev Notes]
- **Codegen sequence:** after creating `mental_load_providers.dart`, run `dart run build_runner build` (no `--delete-conflicting-outputs` locally). Then `flutter gen-l10n` after ARB changes. Then `dart format lib test`. Then `flutter analyze`.

### Source Tree to Create / Modify

**NEW (create):**
- `lib/features/mental_load/domain/mental_load_projection.dart`
- `lib/features/mental_load/mental_load_providers.dart`
- `lib/features/mental_load/mental_load_providers.g.dart` ← generated by build_runner
- `lib/features/mental_load/presentation/mental_load_hero.dart`
- `test/features/mental_load/domain/mental_load_projection_test.dart`
- `test/features/mental_load/presentation/mental_load_hero_test.dart`

**MODIFIED:**
- `lib/features/brain_dump/presentation/home_screen.dart` — add `MentalLoadHero` between title and list
- `assets/l10n/app_fr.arb` — add `mentalLoadCaption`, `mentalLoadSemanticLabel`
- `assets/l10n/app_en.arb` — mirror both keys
- `lib/core/l10n/*` ← regenerated by `flutter gen-l10n` (do NOT hand-edit)

### Existing Code to Reuse (Verified Signatures)

- **`openPreoccupationsProvider`** (`AsyncValue<List<Preoccupation>>`): `lib/features/brain_dump/brain_dump_providers.dart`. Watch `.future` to derive from it.
- **`projectionRevisionProvider`**: already drives `openPreoccupationsProvider` — no extra wiring needed.
- **`AuroreColors.accentGradient`** (`LinearGradient`): `lib/core/design_system/aurore_colors.dart` — `colors: [warm, cool]`, begin: `Alignment.centerLeft`, end: `Alignment.centerRight`. Use `accentGradient.createShader(bounds)` inside `ShaderMask.shaderCallback`.
- **`AuroreColors.cool`** (`Color(0xFFB98BB0)`): use for `kg` unit suffix.
- **`AuroreColors.inkMuted`**: use for caption and `~` pending indicator.
- **`AuroreColors.ink`**: fallback fill for the numeral (passed as `color:` to `Text` inside `ShaderMask` so it renders accessibly if the shader is not applied).
- **`AuroreSpacing.*`**: `xs=4`, `sm=8`, `md=12`, `lg=16`, `xl=24`.
- **`weightKgLabel`** (ARB): already localized `"kg"` / `"kg"` — reuse, do NOT add a second `kg` key.
- **Riverpod `@riverpod` + `part '…g.dart'` pattern**: mirror `brain_dump_providers.dart` exactly.
- **`Preoccupation.isPending`** getter: `mentalWeightKg == null` — already defined in `lib/features/brain_dump/domain/preoccupation.dart`.

### Key Implementation Details

#### `MentalLoadProjection` — pure derivation, single pass

```dart
// lib/features/mental_load/domain/mental_load_projection.dart
import 'package:mindow/features/brain_dump/domain/preoccupation.dart';

/// Derived read-model summarising the user's current Mental Load.
///
/// Computed on every `openPreoccupationsProvider` rebuild; never persisted
/// to Hive and allocated no `typeId`. A [Preoccupation] is "pending" when its
/// Mental Weight has not yet been assigned by AI analysis — pending items count
/// as open (they are visible in the list) but contribute 0 kg to the sum.
class MentalLoadProjection {
  /// Creates a Mental Load projection.
  const MentalLoadProjection({
    required this.totalKg,
    required this.hasPendingItems,
  });

  /// Computes the projection from a list of open [Preoccupation]s.
  factory MentalLoadProjection.fromPreoccupations(
    List<Preoccupation> items,
  ) {
    var totalKg = 0;
    var hasPending = false;
    for (final item in items) {
      if (item.isPending) {
        hasPending = true;
      } else {
        totalKg += item.mentalWeightKg!;
      }
    }
    return MentalLoadProjection(
      totalKg: totalKg,
      hasPendingItems: hasPending,
    );
  }

  /// Sum of assigned Mental Weights across all open Preoccupations (kg).
  ///
  /// Pending items (awaiting AI analysis) contribute 0 to this sum.
  final int totalKg;

  /// Whether at least one open Preoccupation is awaiting AI analysis.
  ///
  /// Shown as a `~` suffix on the hero numeral.
  final bool hasPendingItems;
}
```

#### `mentalLoadProvider` — thin derivation layer

```dart
// lib/features/mental_load/mental_load_providers.dart
import 'package:mindow/features/brain_dump/brain_dump_providers.dart';
import 'package:mindow/features/mental_load/domain/mental_load_projection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mental_load_providers.g.dart';

/// The current Mental Load, derived from `openPreoccupationsProvider`.
///
/// Rebuilds automatically whenever `openPreoccupationsProvider` rebuilds,
/// which in turn rebuilds whenever `projectionRevisionProvider` bumps —
/// capture, edit, delete, and weight-assignment all propagate here.
@riverpod
Future<MentalLoadProjection> mentalLoad(Ref ref) async {
  final items = await ref.watch(openPreoccupationsProvider.future);
  return MentalLoadProjection.fromPreoccupations(items);
}
```

#### `MentalLoadHero` widget — gradient numeral

```dart
// lib/features/mental_load/presentation/mental_load_hero.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/l10n/app_localizations.dart';
import 'package:mindow/features/mental_load/mental_load_providers.dart';

/// Hero display of the user's current Mental Load.
///
/// Shows the total assigned kg as a single Aurore-gradient numeral (UX-DR3).
/// Pending items contribute 0 kg and are flagged with a `~` suffix.
/// Rebuilds reactively whenever the Mental Load projection changes.
class MentalLoadHero extends ConsumerWidget {
  const MentalLoadHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(mentalLoadProvider);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return projection.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _buildNumeral(
        context: context,
        l10n: l10n,
        textTheme: textTheme,
        totalKg: 0,
        hasPendingItems: false,
        applyGradient: false,
      ),
      data: (p) => _buildNumeral(
        context: context,
        l10n: l10n,
        textTheme: textTheme,
        totalKg: p.totalKg,
        hasPendingItems: p.hasPendingItems,
        applyGradient: true,
      ),
    );
  }

  Widget _buildNumeral({
    required BuildContext context,
    required AppLocalizations l10n,
    required TextTheme textTheme,
    required int totalKg,
    required bool hasPendingItems,
    required bool applyGradient,
  }) {
    final numeralStyle = (textTheme.displayLarge ?? const TextStyle()).copyWith(
      fontSize: 88,
      fontWeight: FontWeight.bold,
      // AuroreColors.ink is the non-gradient fallback fill (UX-DR3, UX-DR18).
      // ShaderMask replaces this with the gradient when applyGradient is true.
      color: AuroreColors.ink,
    );

    Widget numeralText = Text('$totalKg', style: numeralStyle);
    if (applyGradient) {
      numeralText = ShaderMask(
        shaderCallback: (bounds) =>
            AuroreColors.accentGradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: numeralText,
      );
    }

    return Semantics(
      label: l10n.mentalLoadSemanticLabel(totalKg),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              numeralText,
              const SizedBox(width: AuroreSpacing.xs),
              Text(
                l10n.weightKgLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: AuroreColors.cool,
                ),
              ),
              if (hasPendingItems) ...[
                const SizedBox(width: AuroreSpacing.xs),
                Text(
                  '~',
                  style: textTheme.labelSmall?.copyWith(
                    color: AuroreColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
          Text(
            l10n.mentalLoadCaption,
            style: textTheme.labelSmall?.copyWith(
              color: AuroreColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### ARB parametrized string pattern

Look at existing parametrized strings in `app_fr.arb` / `app_en.arb` for the `{param}` ICU syntax. `mentalLoadSemanticLabel` uses `{totalKg}` (integer). The `@mentalLoadSemanticLabel` descriptor declares it with `"placeholders": {"totalKg": {"type": "int"}}`.

#### Home screen insertion point

```dart
// lib/features/brain_dump/presentation/home_screen.dart
// Add this import at top (alphabetical, after existing imports):
import 'package:mindow/features/mental_load/presentation/mental_load_hero.dart';

// In _HomeScreenState.build, after the welcome title:
Text(l10n.homeWelcomeTitle, style: textTheme.headlineMedium),
const SizedBox(height: AuroreSpacing.lg),
const MentalLoadHero(),                         // ← INSERT HERE
const SizedBox(height: AuroreSpacing.lg),
Expanded(
  child: preoccupations.when(...)
),
```

### Testing Standards Summary

- Unit tests mirror `lib/` under `test/` (new `test/features/mental_load/` tree).
- Use `package:flutter_test`, `package:mindow/...` imports. Alphabetical import order (`dart:` first).
- No real Hive or network in unit tests. Widget tests use `ProviderScope` with override for `mentalLoadProvider`.
- Widget tests: avoid `pumpAndSettle` with indeterminate spinners — use `pump(Duration(seconds: 1))` or `pumpWidget` without settling.
- `dart format lib test` before every commit. `dart run build_runner build`, `flutter gen-l10n`, `flutter analyze` (0 issues).
- Do NOT use `[TypeName]` in doc comments — use backticks.

### Scope Boundaries

**In scope (2.5):**
- `MentalLoadProjection` domain model and factory.
- `mentalLoadProvider` Riverpod provider.
- `MentalLoadHero` widget (gradient numeral, `~` pending indicator, accessibility label, caption).
- Home screen wiring (insert hero between title and list).
- Localization of two new keys.

**Out of scope (later stories):**
- Animated count-up / weight-release animation (Story 2.6).
- Backpack visualization and heaviness bands (Story 2.6).
- Open-items count pill and weekly progression pill (Story 2.7).
- Server-side projection reconciliation (deferred from Story 2.1).

### References

- [Source: epics.md#Story 2.5: Display current Mental Load] — user story + ACs
- [Source: epics.md#FR-7] — sum of open Preoccupations' Mental Weight in kg; updates on add/complete/delete
- [Source: epics.md#UX-DR3] — single Aurore-gradient hero numeral, cool `kg` unit, muted caption, non-gradient fallback
- [Source: epics.md#UX-DR18] — VoiceOver/TalkBack role+state labels; kg figure announces weight; Dynamic Type; ≥44pt targets
- [Source: epics.md#NFR-5] — i18n, French source of truth
- [Source: ux-designs/DESIGN.md] — Display: Inter Bold ~88, gradient fill (accent-warm → accent-cool); `kg` figure = single display numeral + cool `kg` unit baseline-aligned + muted caption "sur tes épaules"
- [Source: ux-designs/EXPERIENCE.md] — VoiceOver: kg figure announces weight and its change; gradient-filled numerals retain non-gradient fallback fill
- [Source: architecture.md#Code Organization] — feature-first; `mental_load` feature is distinct from `brain_dump`
- [Source: architecture.md#Requirements to Structure Mapping] — Mental Backpack (FR-7/8/9) → `features/mental_load/domain` (projection here)
- [Source: architecture.md#Data Architecture] — `mental_load` is DERIVED projection, never mutated counter
- [Source: lib/features/brain_dump/brain_dump_providers.dart] — `openPreoccupationsProvider`, `projectionRevisionProvider`
- [Source: lib/features/brain_dump/domain/preoccupation.dart] — `Preoccupation.isPending`, `mentalWeightKg`
- [Source: lib/core/design_system/aurore_colors.dart] — `accentGradient`, `cool`, `inkMuted`, `ink`
- [Source: Story 2.3] — `comment_references` lint trap; `prefer_initializing_formals`; `pumpAndSettle` forbidden
- [Source: Story 2.4] — `ProjectionRevision.bump()` wiring pattern; `ShaderMask` not yet used but referenced in UX spec

### Resolved Decisions

1. **Pending items contribute 0 kg** (not excluded from the count display): the sum only counts items with an assigned weight. Pending items are flagged with `~` to set expectation without creating a confusing "invisible" weight. This matches the UX caption intent.
2. **`MentalLoadProjection` is a plain class, not Freezed**: it's trivial (2 fields + 1 factory) and doesn't need Freezed's copy/equality/toString machinery. Fewer generated files = less build complexity.
3. **Provider in `features/mental_load/`** (not `brain_dump_providers.dart`): architecture demands feature separation. The provider imports `openPreoccupationsProvider` from brain_dump but lives in its own feature.
4. **`MentalLoadHero` as a `ConsumerWidget`** (not a plain `StatelessWidget` accepting values): the widget owns its provider watch, keeping home_screen clean and the hero independently reusable.
5. **No `keepAlive: true`** on `mentalLoadProvider`: it is a UI-lifetime provider (screen-driven). When the screen is off-screen it can be disposed; on return it recomputes cheaply.
6. **Gradient text via `ShaderMask`**: Flutter has no native gradient-text API. `ShaderMask` with `BlendMode.srcIn` is the standard pattern. Child `Text.color = AuroreColors.ink` serves as the non-gradient fallback.

## Dev Agent Record

### Agent Model Used

_to be filled by dev agent_

### Debug Log References

_to be filled by dev agent_

### Completion Notes List

_to be filled by dev agent_

### File List

_to be filled by dev agent_

## Change Log

| Date       | Version | Description                              | Author |
| ---------- | ------- | ---------------------------------------- | ------ |
| 2026-06-09 | 0.1     | Story drafted, ready-for-dev             | boss   |
