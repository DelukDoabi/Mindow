# Story 1.2: Welcome & promise screen

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a first-time user,
I want a calm welcome that states the promise,
so that I understand Mindow relieves load rather than adding tasks.

## Acceptance Criteria

1. **Given** a cold first launch **When** the app opens **Then** the welcome screen shows the promise headline **"Décharge ton esprit. On s'occupe du reste."** on the dawn-gradient canvas with non-interactive progress dots (UX-DR13).
2. **Given** the welcome screen **When** it is displayed **Then** a **"Passer"** secondary action is always available, rendered as a text-only `ink-muted` link — never a competing filled button (UX-DR7, UX-DR17 first-launch).
3. **Given** the welcome screen **When** any visible string is shown **Then** the copy passes the tone-as-gate (French *tutoiement*, warm, leaves the user feeling lighter — no guilt/urgency) (UX-DR16) and every string is sourced from localization (NFR-5), present in both `en` and `fr`.
4. **Given** the welcome screen **When** the user taps the primary CTA (**"Commencer"**) or **"Passer"** **Then** navigation advances out of the welcome step (to the next onboarding destination; until later onboarding stories exist, both route to the placeholder home `/`).
5. **Given** the welcome screen **When** it renders **Then** the progress dots reflect step position (first dot active as an Aurore-gradient stadium; the rest muted circles) and are non-interactive (UX-DR13).

## Tasks / Subtasks

- [x] **Task 1: Reusable Aurore canvas + progress dots widgets** (AC: #1, #5)
  - [x] Add `lib/core/design_system/widgets/aurore_canvas.dart` — a reusable widget that paints `AuroreColors.canvasGradient` full-bleed behind a transparent `Scaffold` body (extract the gradient pattern currently inline in `app_router.dart`'s placeholder home so it is the single source).
  - [x] Add `lib/core/design_system/widgets/progress_dots.dart` — a non-interactive widget taking `count` and `activeIndex`; active dot = Aurore-gradient stadium (elongated pill, radius `AuroreRadii.pill`), inactive = `ink-muted` circles. Uses only Aurore tokens (no hard-coded colors/sizes).
- [x] **Task 2: Localized copy (en + fr)** (AC: #1, #2, #3)
  - [x] Add keys to `assets/l10n/app_en.arb` and `assets/l10n/app_fr.arb`: `onboardingWelcomeHeadline`, `onboardingWelcomeBody`, `onboardingWelcomeCta`, `onboardingSkip`.
  - [x] French (source of truth for tone): headline = `"Décharge ton esprit. On s'occupe du reste."`, cta = `"Commencer"`, skip = `"Passer"`, body = a calm reassurance line in *tutoiement* (e.g. `"Dépose tout ce qui occupe ton esprit. Mindow t'aide à porter moins, un objet à la fois."`).
  - [x] English: faithful, equally calm translations.
  - [x] Run `flutter gen-l10n`; confirm generated delegates compile.
- [x] **Task 3: Welcome screen** (AC: #1–#5)
  - [x] Create `lib/features/onboarding/welcome_screen.dart` as a `ConsumerWidget` (feature starts FLAT per granularity rule). Compose: `AuroreCanvas` → SafeArea → top-right `"Passer"` text link → centered promise headline (Aurore display type) + body → `ProgressDots(count: 3, activeIndex: 0)` → primary filled CTA `"Commencer"`.
  - [x] All strings via `AppLocalizations.of(context)`; no literals in the widget.
  - [x] "Passer" and "Commencer" both call `context.go(Routes.home)` (placeholder forward nav until Story 1.3 adds the context step).
- [x] **Task 4: Routing** (AC: #1, #4)
  - [x] Add `Routes.welcome = '/welcome'` and a `GoRoute` for it in `lib/core/router/app_router.dart`; set `initialLocation` to `Routes.welcome`.
  - [x] Replace the inline placeholder-home gradient with the new `AuroreCanvas` widget (keep the placeholder home route).
  - [x] Leave the `redirect` hook untouched (real first-launch vs returning-user routing is Stories 1.4/1.5).
- [x] **Task 5: Widget test** (AC: #1, #2, #3, #5)
  - [x] Add `test/features/onboarding/welcome_screen_test.dart` pumping `WelcomeScreen` inside a `ProviderScope` + `MaterialApp` with `AppLocalizations` delegates (locale `fr`). Assert: headline text present, `"Passer"` present and tappable, `"Commencer"` present, exactly 3 progress dots with index 0 active.
  - [x] `flutter analyze` clean; `flutter test` green.

## Dev Notes

### Previous story intelligence (Story 1.1)

- **Scaffold is committed** (commit `0fe00ce`): Flutter 3.44.1 / Dart 3.12.1, app at repo root, package `mindow`, flavors dev/staging/prod, `MaterialApp.router` wired with `AuroreTheme.light()`, GoRouter via `appRouterProvider`, generated l10n in `lib/core/l10n/`.
- **Design tokens already exist** in `lib/core/design_system/`: `AuroreColors` (incl. `canvasGradient`, `warm`, `cool`, `ink`, `inkMuted`), `AuroreSpacing` (4/8/12/16/24/32), `AuroreRadii` (sm14/md20/lg24/pill), `AuroreTypography` (Inter via `google_fonts`), `AuroreTheme.light()`. **Reuse these — never hard-code colors/sizes.**
- **Existing placeholder home** lives in `lib/core/router/app_router.dart` as `_PlaceholderHome` and paints the gradient inline. Task 1 extracts that gradient into `AuroreCanvas`; refactor `_PlaceholderHome` to use it.
- **l10n pattern** is established: ARB files in `assets/l10n/`, generated to `lib/core/l10n/`, `synthetic-package` must NOT be re-added to `l10n.yaml`. Add keys, then `flutter gen-l10n`.
- **Lints:** `very_good_analysis` baseline. Use `package:` imports (not relative) for files under `lib/`. Sort directives. Run `dart format lib test` before committing (CI checks formatting).
- **Tests that fetch the network fail in `flutter test`** — `GoogleFonts.inter*` triggered a network fetch in unit tests, so token tests assert raw token values instead of building the theme. For the widget test, building `WelcomeScreen` under a `MaterialApp` is fine (GoogleFonts degrades gracefully in widget tests), but if a font-fetch error surfaces, wrap the pump in `GoogleFonts.config.allowRuntimeFetching = false` and ignore missing-font glyphs.

### Architecture patterns and constraints (MUST follow)

- **Feature-first, start FLAT:** onboarding begins as `lib/features/onboarding/` with files directly inside; it splits into `{data,domain,presentation}/` only when it exceeds ~5 files or touches the sync engine. Do NOT pre-create `presentation/` subfolders for this single screen. [Source: architecture.md#Folder-Granularity-Rule, #Project-Structure]
- **Riverpod via codegen only:** any provider uses `@riverpod` (`riverpod_generator`). This story likely needs NO new provider (the screen is stateless/presentational); if local UI state is needed, prefer a `StatefulWidget`/`ConsumerStatefulWidget` over an ad-hoc provider. NO hand-rolled `Provider`/`StateProvider`. [Source: architecture.md#Frontend-Architecture]
- **Design system is the single source of truth:** all colors, spacing, radii, and type come from `core/design_system`. No literal hex or magic numbers in feature/widget code. [Source: DESIGN.md; epics.md#UX-DR1]
- **Routing:** GoRouter only, exposed via `appRouterProvider`. Navigate with `context.go(...)`/`context.push(...)`. The `premium_guard` and first-launch/returning-user redirect logic are added later (Epic 6, Stories 1.4/1.5) — do not implement gating here. [Source: architecture.md#Project-Structure, #Architectural-Boundaries]
- **No backend in this story:** the welcome screen reads/writes nothing. Onboarding answers, persistence, and consent come in Stories 1.3/1.6. Keep this screen purely presentational. [Source: epics.md#Story-1.2]
- **i18n from launch:** every user-facing string is a localized key; both `en` and `fr` must be present (fr is the tone source of truth). [Source: epics.md#NFR-5, #UX-DR16]

### UX specifics (Aurore)

- **Canvas:** dawn gradient `#FDF4F0 → #F6ECF2 → #EDE9F4` (already `AuroreColors.canvasGradient`). [Source: DESIGN.md]
- **Promise headline (AC source of truth):** `"Décharge ton esprit. On s'occupe du reste."` — large Inter display type, ink color. (The HTML mockup's "Allège ta charge mentale" is an earlier variant; the **epic AC string wins**.) [Source: epics.md#Story-1.2; screens-aurore.html SCREEN 2]
- **Primary CTA:** filled pill button `"Commencer"` (theme already styles `FilledButton` with `AuroreRadii.pill`). [Source: DESIGN.md#Buttons; screens-aurore.html]
- **Secondary action "Passer":** text-only link in `ink-muted`, top area, always visible — never a second filled button. [Source: DESIGN.md; epics.md#UX-DR7]
- **Progress dots:** 3 dots, first active; active = Aurore-gradient stadium (elongated pill), inactive = muted circles; non-interactive. [Source: DESIGN.md; epics.md#UX-DR13]
- **State pattern (first launch):** promise sequence with "Passer" always available; no shame, no urgency. [Source: EXPERIENCE.md; epics.md#UX-DR17]

### Source tree components to touch (this story)

```
mindow/
├── assets/l10n/app_en.arb            # UPDATE — add onboarding welcome keys
├── assets/l10n/app_fr.arb            # UPDATE — add onboarding welcome keys (fr tone source)
├── lib/
│   ├── core/
│   │   ├── design_system/widgets/
│   │   │   ├── aurore_canvas.dart    # NEW — reusable gradient canvas
│   │   │   └── progress_dots.dart    # NEW — reusable non-interactive dots
│   │   └── router/app_router.dart    # UPDATE — add /welcome route + initialLocation; use AuroreCanvas
│   └── features/
│       └── onboarding/
│           └── welcome_screen.dart   # NEW — the welcome/promise screen (flat)
└── test/features/onboarding/
    └── welcome_screen_test.dart      # NEW — widget test
```

[Source: architecture.md#Complete-Project-Directory-Structure]

### Testing standards summary

- Frameworks: `flutter_test` for widget tests; mirror `lib/` under `test/`. [Source: architecture.md#Structure-Patterns]
- This story's required test: a widget test for `WelcomeScreen` asserting the localized headline, the always-present "Passer" link, the "Commencer" CTA, and the 3-dot progress indicator with index 0 active.
- Pump with `localizationsDelegates: AppLocalizations.localizationsDelegates` and `locale: const Locale('fr')` so the French copy is asserted.
- Keep the Hive registry gate test from Story 1.1 green (do not modify `hive_registry.dart` — this story adds no Hive types).

### Project Structure Notes

- Aligns with the architecture tree: feature code under `features/onboarding/` (flat), reusable presentational widgets under `core/design_system/widgets/`.
- Deliberate variances: onboarding kept FLAT (no `presentation/` subfolder yet) per the Folder Granularity Rule; routing remains ungated (first-launch detection is a later story).
- No conflicts detected with Story 1.1's scaffold.

### References

- [Source: epics.md#Story-1.2] — acceptance criteria (BDD)
- [Source: epics.md#UX-DR7] — secondary action styling
- [Source: epics.md#UX-DR13] — progress dots
- [Source: epics.md#UX-DR16] — tone-as-gate microcopy
- [Source: epics.md#UX-DR17] — first-launch state pattern
- [Source: epics.md#NFR-5] — localization
- [Source: architecture.md#Project-Structure] — feature-first layout, router, granularity rule
- [Source: DESIGN.md] — Aurore tokens, buttons, secondary action, progress dots
- [Source: EXPERIENCE.md] — first-launch onboarding sequence
- [Source: prd.md#FR-1] — onboarding flow (welcome is screen 1)
- [Source: screens-aurore.html SCREEN 2] — visual reference (orb illustration, dots, CTA, skip)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8

### Debug Log References

- `flutter gen-l10n` — regenerated delegates with the 4 new `onboarding*` keys; compiles clean.
- `flutter analyze` — "No issues found!" (after fixing two `avoid_redundant_argument_values` on the new gradient and one `prefer_single_quotes` in the test).
- `flutter test` — 10/10 passed (6 pre-existing + 4 new welcome-screen widget tests).
- `dart format lib test` — applied.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Added reusable `AuroreCanvas` (single-source gradient background) and `ProgressDots` (non-interactive, UX-DR13) under `core/design_system/widgets/`; refactored the Story 1.1 placeholder home to consume `AuroreCanvas`.
- Added `AuroreColors.accentGradient` token (warm→cool) for the active progress dot — keeps the "Aurore-gradient" reference in the design system rather than inline.
- Welcome screen is purely presentational (no provider/state); both "Commencer" and "Passer" call `context.go(Routes.home)` as the forward placeholder until Story 1.3 introduces the context-capture step.
- Router now starts at `Routes.welcome` (`/welcome`); the `redirect` hook is intentionally untouched (first-launch vs returning-user routing is Stories 1.4/1.5).
- All copy localized in `en` + `fr`; French is the tone source of truth (tutoiement, no guilt/urgency — UX-DR16). Headline matches the epic AC string exactly (the mockup's "Allège ta charge mentale" variant was not used).

### File List

- `lib/core/design_system/aurore_colors.dart` (UPDATE — added `accentGradient`)
- `lib/core/design_system/widgets/aurore_canvas.dart` (NEW)
- `lib/core/design_system/widgets/progress_dots.dart` (NEW)
- `lib/features/onboarding/welcome_screen.dart` (NEW)
- `lib/core/router/app_router.dart` (UPDATE — welcome route, initialLocation, AuroreCanvas)
- `assets/l10n/app_en.arb` (UPDATE — 4 onboarding keys)
- `assets/l10n/app_fr.arb` (UPDATE — 4 onboarding keys)
- `lib/core/l10n/app_localizations*.dart` (REGENERATED)
- `test/features/onboarding/welcome_screen_test.dart` (NEW)
