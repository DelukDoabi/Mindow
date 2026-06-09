---
baseline_commit: 7d55a56
---

# Story 2.6: Animated Backpack Visualization

Status: review

## Story

As a user,
I want an animated backpack reflecting my load,
So that relief feels physical.

## Acceptance Criteria

1. **Given** a Mental Load value, **When** Home renders the backpack, **Then** its heaviness band
   matches the rules: léger 0–19 kg / modéré 20–49 kg / lourd 50–79 kg / très lourd 80+ kg (FR-8, UX-DR2).
2. **And** the visual transitions smoothly to the new band whenever `totalKg` crosses a threshold
   (20 / 50 / 80 kg) — ~600 ms ease-in-out animation; Reduce Motion = immediate state change, no
   animation (UX-DR14, UX-DR18).
3. **And** tapping the backpack scrolls the Home screen to bring the item list into view (UX-DR2,
   NFR-1 ≤1 tap to list).
4. **And** the backpack is drawn as a `CustomPainter` with: peach gradient body (`AuroreColors.warm`
   → lighter warm), radial warm glow behind the body, handle arcs, lid rect, two pocket rects,
   and a buckle; body "sag" (vertical squish + shadow depth) increases continuously with
   `bandValue` (0.0 = léger … 3.0 = très lourd) (UX-DR2).
5. **And** a `Semantics` node wraps the backpack: label = `backpackSemanticLabel(band)` key
   (e.g. "Sac à dos modéré"), button role, tap hint = "Voir les préoccupations" (UX-DR18).
6. **And** all new copy is French-source-of-truth localized with `@key` description entries (NFR-5).

## Technical Context (carry as facts)

### Existing files not to break

| File | Key facts |
|------|-----------|
| `lib/features/mental_load/domain/mental_load_projection.dart` | `totalKg: int`, `hasPendingItems: bool`, `MentalLoadProjection.fromPreoccupations()` |
| `lib/features/mental_load/mental_load_providers.dart` | `@riverpod Future<MentalLoadProjection> mentalLoad(Ref ref)` — auto-rebuilds on `projectionRevisionProvider.bump()` |
| `lib/features/mental_load/presentation/mental_load_hero.dart` | `ConsumerWidget`, `MentalLoadHero` — already on HomeScreen between title and list |
| `lib/features/brain_dump/presentation/home_screen.dart` | layout: title → `MentalLoadHero` → Expanded(list); uses `ScrollController` |

### Design system tokens (never hardcode colors or spacing)

```dart
// Colors
AuroreColors.warm     // #E8A87C — warm peach
AuroreColors.cool     // #B98BB0 — cool purple
AuroreColors.ink      // #5B5470 — dark ink
AuroreColors.inkMuted // #8B8499 — muted ink
AuroreColors.accentGradient // LinearGradient warm→cool

// Spacing
AuroreSpacing.xs=4  sm=8  md=12  lg=16  xl=24  xxl=32

// Radii
AuroreRadii.sm=14  md=20  lg=24
```

Import paths (exact — do NOT use `flutter_gen`):
```dart
import 'package:mindow/core/design_system/aurore_colors.dart';
import 'package:mindow/core/design_system/aurore_spacing.dart';
import 'package:mindow/core/design_system/aurore_radii.dart';  // verify exists
import 'package:mindow/core/l10n/app_localizations.dart';
```

### Riverpod 3 constraints (critical)

- `mentalLoadProvider` is a `@riverpod Future<MentalLoadProjection>` — watch as `AsyncValue`.
- **Widget tests**: use `mentalLoadProvider.overrideWithValue(AsyncValue.data(projection))` — NEVER
  pass an `Override` typed variable (sealed class, `@publicInCodegen`).
- `overrideWith((ref) async => value)` causes async timing issues — use `overrideWithValue`.

### Very_good_analysis lint rules (do NOT violate)

- `comment_references`: doc comments use backticks only — NEVER `[SymbolName]`.
- `prefer_initializing_formals`: use `this.field` in constructor params.
- `avoid_redundant_argument_values`: never `null` for optional nullable params explicitly.
- `unnecessary_underscores`: `_` not `__`.
- `directives_ordering`: alphabetical imports; stdlib → flutter → packages → local.
- `prefer_const_constructors`.

### Reduce Motion

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
```

When `true`: skip animation, jump directly to target state.

### Flutter animation pattern (for `ConsumerStatefulWidget`)

```dart
class BackpackWidget extends ConsumerStatefulWidget { ... }

class _BackpackWidgetState extends ConsumerState<BackpackWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _bandAnimation; // 0.0 (léger) → 3.0 (très lourd)
  double _targetBandValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bandAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _animateToBand(double newBandValue, {required bool reduceMotion}) {
    final current = _bandAnimation.value;
    if (reduceMotion) {
      _bandAnimation = AlwaysStoppedAnimation(newBandValue);
      setState(() {});
      return;
    }
    _bandAnimation = Tween<double>(begin: current, end: newBandValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## Tasks / Subtasks

- [x] **Task 1 — `LoadBand` domain model** (AC: #1)
  - [x] Create `lib/features/mental_load/domain/load_band.dart`:
    ```dart
    /// Visual heaviness band derived from `MentalLoadProjection.totalKg`.
    ///
    /// Boundaries (inclusive lower, exclusive upper):
    /// - `leger`:     0–19 kg
    /// - `modere`:   20–49 kg
    /// - `lourd`:    50–79 kg
    /// - `tresLourd`: 80+ kg
    enum LoadBand {
      leger,
      modere,
      lourd,
      tresLourd;

      /// Returns the band for [totalKg].
      factory LoadBand.fromKg(int totalKg) {
        if (totalKg < 20) return LoadBand.leger;
        if (totalKg < 50) return LoadBand.modere;
        if (totalKg < 80) return LoadBand.lourd;
        return LoadBand.tresLourd;
      }

      /// Maps the band to a continuous [0.0, 3.0] value for animation.
      double get animationValue => switch (this) {
        LoadBand.leger     => 0.0,
        LoadBand.modere    => 1.0,
        LoadBand.lourd     => 2.0,
        LoadBand.tresLourd => 3.0,
      };
    }
    ```
  - [x] No Riverpod, no Freezed, no Flutter imports — pure Dart.

- [x] **Task 2 — `BackpackPainter`** (AC: #4)
  - [x] Create `lib/features/mental_load/presentation/backpack_painter.dart`:
    - `class BackpackPainter extends CustomPainter`
    - Constructor: `const BackpackPainter({required this.bandValue, required this.warmColor, required this.glowColor})`
      - `bandValue`: `double` in [0.0, 3.0] — drives squish, shadow depth, glow intensity.
      - `warmColor`: `Color` (pass `AuroreColors.warm`).
      - `glowColor`: `Color` (pass `AuroreColors.warm.withValues(alpha: 0.18)`).
    - `@override bool shouldRepaint(BackpackPainter old) => old.bandValue != bandValue;`
    - `@override void paint(Canvas canvas, Size size)` — draw the backpack:

    **Body (main rectangle):**
    ```
    verticalSag = bandValue * 0.06  // 0% at léger → 18% squish at très lourd
    bodyWidth   = size.width * 0.68
    bodyHeight  = size.height * (0.62 - verticalSag)
    bodyTop     = size.height * 0.22
    bodyRect    = RRect centered horizontally, radii=14
    fill        = LinearGradient(warm → Color.lerp(warm, Colors.white, 0.35))
                  tileMode: TileMode.clamp, from topCenter to bottomCenter
    ```

    **Radial glow (behind body):**
    ```
    glowRadius  = size.width * (0.40 + bandValue * 0.04)
    glowCenter  = Offset(size.width/2, bodyTop + bodyHeight * 0.45)
    paint       = RadialGradient(glowColor → transparent).createShader(...)
    blendMode   = BlendMode.screen (or src)
    draw BEFORE body
    ```

    **Handle (two arcs at top of body):**
    ```
    Two symmetric arcs meeting at top center.
    strokeWidth = 4, color = AuroreColors.warm darkened (Color.lerp(warm, Colors.black, 0.12))
    ```

    **Lid (rounded rect cap above body):**
    ```
    lidRect: slightly wider than body, height ~10% of size.height, bottom touching bodyTop
    fill same gradient but lighter (Color.lerp(warm, Colors.white, 0.5))
    ```

    **Two pockets (lower half of body):**
    ```
    Small RRects symmetrically placed at bottom-left and bottom-right of body.
    width = bodyWidth * 0.25, height = bodyHeight * 0.22
    fill = Color.lerp(warm, Colors.black, 0.08)  // slightly darker warm
    ```

    **Buckle (center, between pockets):**
    ```
    Small Rect (12×6 logical units scaled to size)
    fill = AuroreColors.inkMuted
    ```

    **Shadow (below body, depth grows with bandValue):**
    ```
    shadowBlur  = 4 + bandValue * 10
    shadowColor = AuroreColors.warm.withValues(alpha: 0.18 + bandValue * 0.10)
    Offset(0, 2 + bandValue * 4)
    Draw as ellipse or use canvas.drawShadow on body path
    ```

  - [x] Use only `dart:ui` and `package:flutter/painting.dart` imports (no Riverpod, no ARB).

- [x] **Task 3 — `BackpackWidget`** (AC: #2, #3, #5)
  - [x] Create `lib/features/mental_load/presentation/backpack_widget.dart`:
    - `class BackpackWidget extends ConsumerStatefulWidget`
    - Constructor param: `final VoidCallback? onTap` (optional).
    - State mixin: `SingleTickerProviderStateMixin`.
    - `AnimationController` duration `600ms`, `CurvedAnimation` with `Curves.easeInOut`.
    - Watch `mentalLoadProvider`. On `data` state:
      - Compute `LoadBand band = LoadBand.fromKg(load.totalKg)`.
      - If `band.animationValue != _targetBandValue`: call `_animateToBand(band.animationValue, reduceMotion: ...)`.
      - Store `_targetBandValue` as instance field.
    - Loading state: `SizedBox(height: 180, width: 180)` (no spinner — UX-DR17 "no blocking spinner").
    - Error state: same `SizedBox(height: 180, width: 180)` (silent, per UX-DR17).
    - Data state: `AnimatedBuilder(animation: _bandAnimation, builder: (context, _) { ... })`.
    - Inner widget tree:
      ```
      Semantics(
        label: l10n.backpackSemanticLabel(bandName),  // e.g. "Sac à dos modéré"
        button: true,
        onTap: widget.onTap,
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            height: 180,
            width: 180,
            child: CustomPaint(
              painter: BackpackPainter(
                bandValue: _bandAnimation.value,
                warmColor: AuroreColors.warm,
                glowColor: AuroreColors.warm.withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
      )
      ```
    - Import ordering (alphabetical): `dart:ui` → `flutter/material.dart` → `flutter_riverpod` →
      `mindow/core/...` → `mindow/features/mental_load/...`.

- [x] **Task 4 — ARB localization** (AC: #5, #6)
  - [x] Add to `assets/l10n/app_fr.arb`:
    ```json
    "backpackSemanticLabel": "Sac à dos {band}",
    "@backpackSemanticLabel": {
      "description": "Accessibility label for the backpack widget, describing its load band.",
      "placeholders": {
        "band": { "type": "String" }
      }
    },
    "loadBandLeger": "léger",
    "@loadBandLeger": { "description": "Load band: light (0–19 kg)" },
    "loadBandModere": "modéré",
    "@loadBandModere": { "description": "Load band: moderate (20–49 kg)" },
    "loadBandLourd": "lourd",
    "@loadBandLourd": { "description": "Load band: heavy (50–79 kg)" },
    "loadBandTresLourd": "très lourd",
    "@loadBandTresLourd": { "description": "Load band: very heavy (80+ kg)" }
    ```
  - [x] Add identical structure to `assets/l10n/app_en.arb` with English values:
    - `backpackSemanticLabel`: `"Backpack {band}"`
    - `loadBandLeger`: `"light"`, `loadBandModere`: `"moderate"`, `loadBandLourd`: `"heavy"`, `loadBandTresLourd`: `"very heavy"`
  - [x] Run `flutter gen-l10n` after edits.

- [x] **Task 5 — Wire into `HomeScreen`** (AC: #3)
  - [x] Modify `lib/features/brain_dump/presentation/home_screen.dart`:
    - Add import: `'package:mindow/features/mental_load/presentation/backpack_widget.dart'`
    - Add a `ScrollController _scrollController` to `_HomeScreenState` and attach to the `ListView`.
    - Insert `BackpackWidget` between `MentalLoadHero` and the `Expanded` list:
      ```dart
      const MentalLoadHero(),
      const SizedBox(height: AuroreSpacing.lg),
      BackpackWidget(
        onTap: () => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        ),
      ),
      const SizedBox(height: AuroreSpacing.lg),
      Expanded(...)
      ```
    - If `HomeScreen` is already a `StatefulWidget`, add `_scrollController` to its state; otherwise convert to `StatefulWidget` first.

- [x] **Task 6 — Tests** (AC: #1–#5)
  - [x] Create `test/features/mental_load/domain/load_band_test.dart`:
    - Test group `LoadBand.fromKg`:
      - `0 → léger`, `19 → léger`
      - `20 → modéré`, `49 → modéré`
      - `50 → lourd`, `79 → lourd`
      - `80 → très lourd`, `200 → très lourd`
    - Test group `animationValue`:
      - `léger → 0.0`, `modéré → 1.0`, `lourd → 2.0`, `très lourd → 3.0`
  - [x] Create `test/features/mental_load/presentation/backpack_widget_test.dart`:
    - Use `ProviderScope(overrides: [mentalLoadProvider.overrideWithValue(AsyncValue.data(...))])`.
    - Test: `(0 kg)` → semantics label contains "léger" (French locale).
    - Test: `(20 kg)` → semantics label contains "modéré".
    - Test: `(50 kg)` → semantics label contains "lourd".
    - Test: `(80 kg)` → semantics label contains "très lourd".
    - Test: loading state → no semantics label found (`AsyncValue.loading()`).
    - Test: tap callback invoked on `GestureDetector` tap.
    - Helper: `pumpBackpack({required AsyncValue<MentalLoadProjection> value, VoidCallback? onTap})`
      — wraps in `ProviderScope + MaterialApp + Localizations`.
  - [x] Run `flutter test --coverage` → target 100% on new files.

- [x] **Task 7 — Format & analyze**
  - [x] `dart format lib test`
  - [x] `flutter analyze` → 0 issues

---

## Dev Notes

### HomeScreen conversion to StatefulWidget

If `HomeScreen` is currently a `StatelessWidget` (check before editing): convert to
`StatefulWidget` + `State<HomeScreen>` with `_scrollController` as `late final`. This is the
minimal change needed; do not reorganize other code.

Check current HomeScreen type:
```
grep_search: "class HomeScreen"
```

### `_animateToBand` implementation in BackpackWidget

```dart
void _animateToBand(double newBandValue, {required bool reduceMotion}) {
  if (_targetBandValue == newBandValue) return;   // idempotent
  _targetBandValue = newBandValue;
  final current = _bandAnimation.value;
  if (reduceMotion) {
    _controller.stop();
    _bandAnimation = AlwaysStoppedAnimation(newBandValue);
    setState(() {});
    return;
  }
  _bandAnimation = Tween<double>(begin: current, end: newBandValue).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );
  _controller
    ..reset()
    ..forward();
}
```

Call site in `build` (data branch):
```dart
final band = LoadBand.fromKg(load.totalKg);
final reduceMotion = MediaQuery.of(context).disableAnimations;
// Schedule post-frame to avoid setState during build:
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) _animateToBand(band.animationValue, reduceMotion: reduceMotion);
});
```

### BackpackPainter coordinate guide (all relative to `size`)

```
size = 180×180 dp (fixed SizedBox)
bodyWidth  ≈ 0.68 * 180 = 122 dp
bodyLeft   = (180 - 122) / 2 = 29 dp
bodyTop    ≈ 0.22 * 180 = 40 dp
bodyHeight ≈ (0.62 - sag) * 180   → 112 dp at léger → 79 dp at très lourd
lidHeight  ≈ 18 dp
handleY    = bodyTop - 10 dp
```

### ARB key ordering

ARB files must keep keys in alphabetical order (very_good_analysis `prefer_single_quotes`
does not apply here, but consistent ordering helps diffing). Insert new keys adjacent to
`mentalLoad*` keys already present.

### `withValues` vs `withOpacity`

Use `color.withValues(alpha: x)` (Dart double, range 0.0–1.0). Do NOT use deprecated
`withOpacity`.

### Test pump helper pattern (re-use from story 2.5)

```dart
Future<void> pumpBackpack(
  WidgetTester tester, {
  required AsyncValue<MentalLoadProjection> value,
  VoidCallback? onTap,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [mentalLoadProvider.overrideWithValue(value)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Scaffold(body: BackpackWidget(onTap: onTap)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
```

### `MentalLoadProjection` helper for tests

```dart
MentalLoadProjection _proj({required int kg, bool pending = false}) =>
    MentalLoadProjection(totalKg: kg, hasPendingItems: pending);
```
