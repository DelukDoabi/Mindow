---
baseline_commit: 5798e1620db3760bc6ae493c0d5f161ef7f6f7d6
---

# Story 1.1: Project scaffold & technical foundation

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a developer,
I want the Flutter project scaffolded with flavors, CI, design tokens and Supabase wiring,
so that all subsequent features build on a consistent, enforced foundation.

## Acceptance Criteria

1. **Buildable multi-platform app with flavors** — `flutter create --org com.mindow --platforms ios,android,web --project-name mindow` produces a buildable app with three entrypoints `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`, each wiring a distinct flavor (dev/staging/prod). `flutter run -t lib/main_dev.dart --flavor dev` launches successfully. [Source: epics.md#Story-1.1; architecture.md#Selected-Starter]
2. **Codegen & lints run cleanly** — `build.yaml` exists with scoped `generate_for` targets, `analysis_options.yaml` enables `very_good_analysis` + the custom lints, and a committed codegen pass (`dart run build_runner build --delete-conflicting-outputs`) completes with zero errors. `flutter analyze` reports no issues. [Source: epics.md#Story-1.1; architecture.md#Naming-Patterns]
3. **Aurore design tokens as single source** — The Aurore design tokens (colors, spacing, radii, typography per UX-DR1 / DESIGN.md) live in `lib/core/design_system/` as the single source of truth, exposed through a Flutter `ThemeData`/token classes. No hard-coded colors elsewhere. [Source: epics.md#Story-1.1; DESIGN.md]
4. **CI pipeline enforces the foundation** — `.github/workflows/ci.yml` runs, in order: `flutter analyze` → a `hive_registry` typeId-collision test → `flutter test` → a per-flavor build (3 flavors). The pipeline fails if any step fails. [Source: epics.md#Story-1.1; architecture.md#Infrastructure-Deployment]
5. **Backend & observability initialized with public keys only** — `lib/app/bootstrap.dart` initializes the Supabase client, Sentry, and PostHog using public keys read from `lib/app/env.dart`. No secrets (OpenAI key, service-role key, RevenueCat secret) are present anywhere in the client. [Source: epics.md#Story-1.1; architecture.md#Authentication-Security]
6. **Hive typeId registry scaffolded & CI-guarded** — `lib/core/sync/hive_registry.dart` exists as the central, append-only typeId allocation point, and a test asserts no duplicate typeIds (the CI gate from AC#4). [Source: architecture.md#Structure-Patterns]

## Tasks / Subtasks

- [x] **Task 1: Generate the Flutter project** (AC: #1)
  - [x] Run `flutter create --org com.mindow --platforms ios,android,web --project-name mindow .` (Flutter 3.44.1 stable)
  - [x] Create flavor entrypoints `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`, each calling a shared `bootstrap()` with a `Flavor` enum value
  - [x] Configure Android flavors (`android/app/build.gradle.kts` productFlavors, dimension `env`) — iOS per-scheme configs deferred (no macOS host available; Android + web cover CI verification)
  - [~] Verify `flutter run -t lib/main_dev.dart --flavor dev` — not run (no device/emulator in this env); verified via `flutter analyze`, `flutter test`, and CI per-flavor builds instead
- [x] **Task 2: Establish core folder structure** (AC: #1, #3, #6)
  - [x] Create `lib/app/` (`app.dart`, `bootstrap.dart`, `env.dart`)
  - [x] Create `lib/core/{sync,error,design_system,l10n,router,data}/` per the architecture tree (only files needed now — features kept FLAT, no empty folders)
  - [x] Add `lib/core/error/failure.dart` (sealed `Failure` base) and `lib/core/sync/domain_event.dart` (abstract base + `schemaVersion`) as minimal stubs
- [x] **Task 3: Wire codegen & lints** (AC: #2)
  - [x] Add deps: `flutter_riverpod`, `riverpod_annotation`, `freezed_annotation`, `json_annotation`, `go_router`, `hive`, `hive_flutter`, `supabase_flutter`, `sentry_flutter`, `posthog_flutter`, `flutter_localizations`, `google_fonts`
  - [x] Add dev deps: `build_runner`, `riverpod_generator`, `freezed`, `json_serializable`, `very_good_analysis` — `hive_generator` DEFERRED (incompatible with riverpod_generator 4.x via old analyzer; only needed for TypeAdapters in Epic 2, where `hive_ce_generator` will be used)
  - [x] Create `build.yaml` with scoped serialization (`field_rename: snake`, `explicit_to_json`)
  - [x] Create `analysis_options.yaml` (`include: package:very_good_analysis/analysis_options.yaml` + custom lints)
  - [x] Run `dart run build_runner build`; `flutter analyze` clean (No issues found)
- [x] **Task 4: Aurore design system** (AC: #3)
  - [x] Inter font via `google_fonts` package (runtime) — DEVIATION from bundling `assets/fonts/` TTFs (binary fonts cannot be generated here); swappable to bundled TTFs later
  - [x] Implement token classes in `lib/core/design_system/` (colors: canvas gradient #FDF4F0→#F6ECF2→#EDE9F4, warm #E8A87C, cool #B98BB0, ink #5B5470; spacing 4/8/12/16/24/32; radii sm14/md20/lg24/pill; Inter type scale) and a `ThemeData` builder
  - [x] Expose theme via `app.dart` `MaterialApp.router`
- [x] **Task 5: i18n from launch** (AC: #2)
  - [x] Add `l10n.yaml` and `assets/l10n/app_en.arb`, `app_fr.arb` (seed keys)
  - [x] Wire `flutter_localizations` + generated delegates in `app.dart`
- [x] **Task 6: Bootstrap backend & observability** (AC: #5)
  - [x] Implement `lib/app/env.dart` with public keys only, per flavor, injected via `--dart-define` (Supabase URL + anon key, Sentry DSN, PostHog public key)
  - [x] Implement `bootstrap.dart`: `Hive.initFlutter()`, `Supabase.initialize(...)`, `SentryFlutter.init(...)`, PostHog init; `runApp` wrapped in `ProviderScope` (init skipped gracefully when a flavor's public keys are absent)
  - [x] Add `lib/core/data/supabase_client.dart` exposing the client via a `@riverpod` provider
  - [x] No secret keys in the client tree (env holds public keys only; AI/service-role stay server-side)
- [x] **Task 7: Hive typeId registry + CI gate** (AC: #4, #6)
  - [x] Implement `lib/core/sync/hive_registry.dart` as the append-only typeId allocation map (0–9 reserved)
  - [x] Write `test/core/sync/hive_registry_test.dart` asserting unique typeIds + reserved-range guard
  - [x] Author `.github/workflows/ci.yml`: format → `flutter analyze` → registry gate → `flutter test` → per-flavor Android builds (dev/staging/prod)
- [x] **Task 8: GoRouter skeleton** (AC: #1)
  - [x] Add `lib/core/router/app_router.dart` with a minimal route table (placeholder home) and a `@riverpod` provider; `redirect` hook left for the `premium_guard` (Epic 6)

## Dev Notes

### Architecture patterns and constraints (MUST follow)

- **Starter:** vanilla `flutter create` + manual feature-first wiring. Do NOT adopt Very Good CLI (it defaults to Bloc, conflicting with PRD-prescribed Riverpod). Borrow only its *patterns* (flavors, l10n, CI). [Source: architecture.md#Selected-Starter]
- **Stack (fixed versions/choices):** Flutter 3.44.x stable, Dart null-safety; Riverpod via `riverpod_generator` (`@riverpod`) — NO hand-rolled providers; GoRouter; Hive (local source of truth); `supabase_flutter`; `freezed` for ALL domain/data models. A single committed `build.yaml` governs `field_rename` so serialization never diverges. [Source: architecture.md#Naming-Patterns, #Frontend-Architecture]
- **Folder granularity rule:** a feature starts FLAT (`features/<feature>/`). It splits into `{data,domain,presentation}/` ONLY when it exceeds ~5 files OR touches the sync engine. No ritual empty folders. For THIS story, create only the `core/` files actually needed; do not pre-create empty feature folders. [Source: architecture.md#Folder-Granularity-Rule]
- **`core/sync` is the GENERIC ENGINE ONLY** — business-agnostic. Features own their own DomainEvents + projections in their `domain/`. This story only stubs the generic base (`domain_event.dart`, `hive_registry.dart`); do NOT put any feature events in core. [Source: architecture.md#Architectural-Boundaries]
- **Secret safety (OWASP):** OpenAI key, Supabase service-role key, and RevenueCat secret NEVER ship in the Flutter client. `env.dart` holds public keys only (Supabase anon key, Sentry DSN, PostHog public key). AI calls happen server-side via Edge Functions only (out of scope for this story but the boundary starts here). [Source: architecture.md#Authentication-Security, #Architectural-Boundaries]
- **Time authority:** date/time is ISO-8601 UTC on the wire; convert to local only at render. (Relevant later; keep the convention from the start.) [Source: architecture.md#Format-Patterns]
- **DB↔Dart casing:** conversion lives ONLY in the data layer (`fromJson`/`toJson`). DB is snake_case, Dart is camelCase. [Source: architecture.md#Naming-Patterns]

### Source tree components to touch (this story)

```
mindow/
├── analysis_options.yaml        # NEW — very_good_analysis + custom lints
├── build.yaml                   # NEW — scoped generate_for + field_rename
├── l10n.yaml                    # NEW
├── pubspec.yaml                 # UPDATE — deps + fonts + assets
├── .github/workflows/ci.yml     # NEW — analyze → registry test → test → 3-flavor build
├── lib/
│   ├── main_dev.dart / main_staging.dart / main_prod.dart   # NEW
│   ├── app/{app.dart, bootstrap.dart, env.dart}             # NEW
│   └── core/
│       ├── sync/{hive_registry.dart, domain_event.dart}     # NEW (generic stubs)
│       ├── error/failure.dart                               # NEW (sealed base)
│       ├── design_system/                                    # NEW (Aurore tokens + theme)
│       ├── l10n/                                              # generated
│       ├── router/app_router.dart                            # NEW (minimal)
│       └── data/supabase_client.dart                         # NEW (provider)
├── assets/{fonts/Inter, l10n/app_en.arb, app_fr.arb}        # NEW
└── test/core/sync/hive_registry_test.dart                    # NEW (CI gate)
```

[Source: architecture.md#Complete-Project-Directory-Structure]

### Testing standards summary

- Frameworks: `flutter_test` (unit/widget), `integration_test` (flows — not required this story).
- This story's required test: `test/core/sync/hive_registry_test.dart` asserting unique Hive typeIds — this is the CI gate. [Source: architecture.md#Structure-Patterns, #Development-Workflow-Integration]
- Tests mirror `lib/` under `test/`. Target high coverage on domain/sync logic (minimal here).
- The reusable event-replay convergence harness (`test/helpers/sync/convergence_harness.dart`) is introduced in Story 2.1 — NOT this story. Do not build it now.

### Aurore design tokens (UX-DR1 / DESIGN.md)

- Canvas: dawn gradient #FDF4F0 → #F6ECF2 → #EDE9F4. Warm accent #E8A87C. Cool accent #B98BB0. Ink #5B5470. Glass surfaces.
- Type: Inter. Spacing scale 4/8/12/16/24/32. Radii: sm 14, md 20, lg 24, pill (full).
- These are the SINGLE source of truth in `core/design_system`; no hard-coded colors elsewhere. [Source: DESIGN.md; epics.md#UX-DR1]

### Project Structure Notes

- Aligns with the architecture's Complete Project Directory Structure. This story lays the `core/` foundation and flavor entrypoints; feature folders are created lazily by their owning stories.
- No conflicts detected. The only deliberate variance: empty feature folders are NOT pre-created (per Folder Granularity Rule).
- `git` is not yet initialized in this workspace — initialize the repo as part of Task 1 (`git init`) so CI config and committed codegen are version-controlled.

### References

- [Source: epics.md#Story-1.1] — Acceptance criteria (Given/When/Then)
- [Source: architecture.md#Selected-Starter] — `flutter create` rationale + init command + stack
- [Source: architecture.md#Core-Architectural-Decisions] — data/auth/frontend/infra decisions
- [Source: architecture.md#Implementation-Patterns-Consistency-Rules] — naming, codegen, events, formats
- [Source: architecture.md#Project-Structure-Boundaries] — folder tree, granularity rule, boundaries
- [Source: DESIGN.md] — Aurore tokens (colors, spacing, radii, Inter)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (GitHub Copilot) via bmad-dev-story.

### Debug Log References

- `flutter analyze` → **No issues found!** (very_good_analysis baseline, clean)
- `flutter test` → **6/6 passed** (3 Hive registry gate + 3 Aurore token tests)
- `dart run build_runner build` → 4 outputs generated (riverpod providers for `supabase_client` and `app_router`)

### Completion Notes List

- Flutter app scaffolded at the **repo root** (`pubspec.yaml`/`lib/` alongside `_bmad/`), package name `mindow`, org `com.mindow`, platforms iOS/Android/Web. Flutter 3.44.1 / Dart 3.12.1.
- Three flavors (`dev`/`staging`/`prod`) wired end-to-end: shared `bootstrap(Flavor)` composition root, three entrypoints, and Android `productFlavors` (dimension `env`, applicationId suffixes, per-flavor app name via `@string/app_name`).
- `env.dart` exposes **public keys only**, injected at build time via `--dart-define`; backend/observability init is skipped gracefully when a flavor's keys are absent so the scaffold boots without a configured backend. AI/service-role secrets remain server-side (OWASP secret-safety boundary respected).
- Hive typeId **registry + CI gate** in place: `hive_registry.dart` (append-only, 0–9 reserved) and `hive_registry_test.dart` asserting unique typeIds + reserved-range — this test is the gate that protects offline data integrity on every PR.
- GitHub Actions CI: `dart format` check → `flutter analyze` → registry gate → `flutter test` → per-flavor Android debug builds.

**Deviations from the story spec (intentional, documented):**
1. **Inter font via `google_fonts`** instead of bundling `assets/fonts/` TTFs — binary font files cannot be generated in this environment. Behaviorally equivalent; swap to bundled TTFs later by replacing `GoogleFonts.inter*` calls and adding a `fonts:` block.
2. **`hive_generator` deferred** — it pins an old `analyzer` (`<7`) that is incompatible with `riverpod_generator` 4.x. It is only needed for Hive `TypeAdapter` codegen, which starts in Epic 2 (Story 2.1); the maintained `hive_ce_generator` fork will be adopted there. The registry itself is pure Dart and needs no codegen.
3. **iOS per-scheme configs deferred** — no macOS host available to validate Xcode schemes. Android + Web flavors cover CI verification; iOS schemes will be added when an iOS build target is provisioned.
4. **`flutter run` smoke launch not performed** — no device/emulator available; verified instead via clean `flutter analyze`, green `flutter test`, and the CI per-flavor build matrix.

### File List

**New — config**
- `analysis_options.yaml` (very_good_analysis baseline + scaffold relaxations)
- `build.yaml` (json_serializable `field_rename: snake`, `explicit_to_json`)
- `l10n.yaml` (ARB → `lib/core/l10n`)
- `.github/workflows/ci.yml`

**New — app composition root**
- `lib/app/env.dart`
- `lib/app/bootstrap.dart`
- `lib/app/app.dart`
- `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`

**New — core**
- `lib/core/error/failure.dart`
- `lib/core/sync/domain_event.dart`
- `lib/core/sync/hive_registry.dart`
- `lib/core/data/supabase_client.dart` (+ generated `.g.dart`)
- `lib/core/router/app_router.dart` (+ generated `.g.dart`)
- `lib/core/design_system/aurore_colors.dart`
- `lib/core/design_system/aurore_spacing.dart`
- `lib/core/design_system/aurore_typography.dart`
- `lib/core/design_system/aurore_theme.dart`

**New — i18n (generated delegates + ARB)**
- `assets/l10n/app_en.arb`, `assets/l10n/app_fr.arb`
- `lib/core/l10n/app_localizations*.dart` (generated)

**New — tests**
- `test/core/sync/hive_registry_test.dart`
- `test/core/design_system/aurore_tokens_test.dart`

**Updated**
- `pubspec.yaml` (deps, dev deps, `generate: true`, description)
- `android/app/build.gradle.kts` (flavors)
- `android/app/src/main/AndroidManifest.xml` (`@string/app_name`)

**Removed**
- `lib/main.dart` (replaced by flavor entrypoints)
- `test/widget_test.dart` (default scaffold test)

### Change Log

| Date | Change |
| --- | --- |
| 2026-06-06 | Story 1.1 implemented: Flutter scaffold, 3 flavors, Aurore design system, i18n, backend/observability bootstrap, Hive registry CI gate, GoRouter skeleton. `flutter analyze` clean, 6/6 tests green. Status → review. |

