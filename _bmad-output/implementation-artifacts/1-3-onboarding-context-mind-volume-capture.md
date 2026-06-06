# Story 1.3: Onboarding context & mind-volume capture

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a first-time user,
I want to optionally share my context,
so that the experience feels personalized without being gated.

## Acceptance Criteria

1. **Given** the welcome step is passed **When** I reach the context screens **Then** I can provide **age range**, **family situation**, **current stress level**, and a **mind-volume bucket** (0-10 / 10-20 / 20-50 / 50+) (FR-3).
2. **Given** any context question **When** I choose to skip it **Then** progression to the next step still succeeds — no question is a hard gate (FR-3 assumption, UX-DR7 "Passer").
3. **Given** I select values **When** I leave and return (or the account is later created) **Then** the selected values persist locally and are retrievable (stored as the onboarding draft on the device until Story 1.4 attaches them to the account profile).
4. **Given** the context flow **When** each screen renders **Then** progress dots reflect step position (welcome=1, context=2, mind-volume=3 of 3) and copy is calm, *tutoiement*, localized en+fr (UX-DR13, UX-DR16, NFR-5).
5. **Given** the mind-volume screen **When** I continue or skip **Then** I advance out of onboarding (to the placeholder home until Story 1.4 inserts account creation).

## Tasks / Subtasks

- [x] **Task 1: Onboarding answers model** (AC: #1, #3)
  - [x] Create `lib/features/onboarding/onboarding_answers.dart` — a `freezed` + `json_serializable` model `OnboardingAnswers` with nullable fields `ageRange`, `familySituation`, `stressLevel`, `mindVolumeBucket`.
  - [x] Define enums in the same file: `AgeRange` (under25, from25to34, from35to44, from45to54, over55), `FamilySituation` (single, couple, withChildren, singleParent), `StressLevel` (low, moderate, high, veryHigh), `MindVolumeBucket` (upTo10, from10to20, from20to50, over50).
  - [x] Run `dart run build_runner build --delete-conflicting-outputs`; confirm `.freezed.dart` + `.g.dart` generated.
- [x] **Task 2: Local persistence repository** (AC: #3)
  - [x] Create `lib/features/onboarding/onboarding_repository.dart` — `OnboardingRepository` that lazily opens a plain Hive box (`'onboarding'`, **no TypeAdapter/typeId** — stores the `toJson` map only) and exposes `Future<OnboardingAnswers> load()` and `Future<void> save(OnboardingAnswers)`.
  - [x] Add `@Riverpod(keepAlive: true) OnboardingRepository onboardingRepository(Ref ref)` provider.
- [x] **Task 3: Draft controller** (AC: #1, #2, #3)
  - [x] Create `lib/features/onboarding/onboarding_controller.dart` — `@riverpod class OnboardingDraft extends _$OnboardingDraft`. `build()` returns `const OnboardingAnswers()` and best-effort hydrates from the repository. Setter methods (`setAgeRange`, `setFamilySituation`, `setStressLevel`, `setMindVolumeBucket`) update state and persist via the repository (fire-and-forget `unawaited`).
- [x] **Task 4: Reusable Aurore choice chip** (AC: #1, #4)
  - [x] Create `lib/core/design_system/widgets/aurore_choice_chip.dart` — a selectable pill chip (`AuroreRadii.md`) using Aurore tokens: selected = accent-tinted glass, unselected = plain glass; `ink`/`inkMuted` text. Takes `label`, `selected`, `onTap`.
- [x] **Task 5: Context screen** (AC: #1, #2, #4)
  - [x] Create `lib/features/onboarding/onboarding_context_screen.dart` (`ConsumerWidget`). `AuroreCanvas` → SafeArea → top-right "Passer" link → title + three labeled chip groups (age range, family situation, stress level) bound to the draft controller → `ProgressDots(count: 3, activeIndex: 1)` → primary "Continuer" CTA.
  - [x] "Passer" and "Continuer" both navigate to `Routes.onboardingMindVolume`.
- [x] **Task 6: Mind-volume screen** (AC: #1, #2, #4, #5)
  - [x] Create `lib/features/onboarding/onboarding_mind_volume_screen.dart` (`ConsumerWidget`). `AuroreCanvas` → "Passer" link → question copy → 4 bucket chips bound to the draft → `ProgressDots(count: 3, activeIndex: 2)` → "Continuer" CTA.
  - [x] "Passer" and "Continuer" both navigate to `Routes.home` (account creation is Story 1.4).
- [x] **Task 7: Routing** (AC: #1, #5)
  - [x] Add `Routes.onboardingContext = '/onboarding/context'` and `Routes.onboardingMindVolume = '/onboarding/mind-volume'`; add their `GoRoute`s.
  - [x] Update `WelcomeScreen`: primary "Commencer" → `Routes.onboardingContext`; "Passer" → `Routes.home` (skips all of onboarding).
- [x] **Task 8: Localization (en + fr)** (AC: #1, #4)
  - [x] Add keys to `assets/l10n/app_en.arb` + `app_fr.arb`: screen titles/subtitles, the four group labels, every option label (age/family/stress/bucket), and `onboardingContinue`. Reuse the existing `onboardingSkip`. French = tone source of truth.
  - [x] Run `flutter gen-l10n`.
- [x] **Task 9: Tests** (AC: #1, #2, #3)
  - [x] `test/features/onboarding/onboarding_repository_test.dart` — init Hive in a temp dir, `save` answers, `load` returns the same values (round-trip incl. enums); empty box loads `const OnboardingAnswers()`.
  - [x] `test/features/onboarding/onboarding_context_screen_test.dart` — pump in `ProviderScope`+`MaterialApp` (fr): title + "Passer" present, tapping an age chip marks it selected in the draft, "Continuer" present.
  - [x] `flutter analyze` clean; `flutter test` green.

## Dev Notes

### Previous story intelligence (Stories 1.1–1.2)

- **Hive is initialized in `bootstrap.dart`** via `Hive.initFlutter()` before the widget tree — the box can be opened at runtime. [lib/app/bootstrap.dart]
- **No TypeAdapter codegen available:** `hive_generator` was removed in Story 1.1 (analyzer conflict with riverpod_generator). Store onboarding answers as a primitive `Map` (`toJson`) in a plain `Hive.openBox('onboarding')` — do NOT add a Hive `typeId` or touch `hive_registry.dart` (keep the CI gate test untouched). The maintained `hive_ce_generator` fork is reserved for Epic 2's typed event boxes.
- **Reusable widgets exist:** `AuroreCanvas` (gradient background) and `ProgressDots` (count/activeIndex) in `lib/core/design_system/widgets/`. Reuse them — the context flow is steps 2 and 3 of the 3-dot sequence started by the welcome screen.
- **l10n pattern:** ARB in `assets/l10n/`, generated to `lib/core/l10n/`, then `flutter gen-l10n`. Do NOT re-add `synthetic-package` to `l10n.yaml`. `onboardingSkip` ("Passer") already exists — reuse it.
- **Lints (`very_good_analysis`):** `package:` imports only; sort directives; `dart format lib test` before commit. Watch `avoid_redundant_argument_values` and `prefer_single_quotes` (both bit Story 1.2). Use `'...'` single quotes except when the string contains an apostrophe.
- **Codegen models are fixed:** `freezed` for the data model, `riverpod_generator` (`@riverpod`) for providers/controller. `build.yaml` sets `field_rename: snake` for json_serializable — enum/field JSON keys come out snake-cased automatically.
- **Testing google_fonts:** building screens under `MaterialApp` in widget tests is fine (the 1.2 welcome test does it). Only the deterministic-token tests avoid theme construction.

### Architecture patterns and constraints (MUST follow)

- **Feature stays FLAT:** keep `lib/features/onboarding/` flat for this story (model, repository, controller, two screens + the existing welcome = ~6 files). It crosses the ~5-file guideline only slightly; defer the `{data,domain,presentation}/` split to a later story to avoid churning Story 1.2's file/imports. [Source: architecture.md#Folder-Granularity-Rule]
- **Providers via codegen only:** `@riverpod` / `@Riverpod(keepAlive: true)`. No hand-rolled `Provider`/`StateProvider`/`ChangeNotifier`. [Source: architecture.md#Dart/Flutter naming]
- **DB↔Dart casing only in data layer:** the model's `fromJson`/`toJson` is the single serialization boundary; screens never touch JSON. [Source: architecture.md#Naming-Patterns]
- **NOT an event:** onboarding answers are profile preferences, not domain events — they are NOT modeled as `DomainEvent`s and do NOT go through the sync outbox. They persist as a local draft now and become part of the account profile in Story 1.4. [Source: epics.md#FR-3; architecture.md#Events]
- **No backend in this story:** there is no authenticated user yet (account creation is Story 1.4). Persist locally only; do not call Supabase. [Source: epics.md#Story-1.4 sequence]
- **Design system is the single source of truth:** colors/spacing/radii/type from `core/design_system`; chips use `AuroreRadii.md` (20px) per DESIGN.md. No literals. [Source: DESIGN.md; epics.md#UX-DR1]
- **i18n from launch:** every label localized en+fr; fr is the tone source of truth (no guilt/urgency, tutoiement). [Source: epics.md#NFR-5, #UX-DR16]

### UX specifics (Aurore)

- **Canvas:** `AuroreCanvas` dawn gradient (reused). [Source: DESIGN.md]
- **Chips:** soft pills, `rounded/md` (20px); selected = accent-tinted glass, unselected = plain glass; non-shouting. [Source: DESIGN.md#Radii, #Glass]
- **Secondary action "Passer":** text-only `ink-muted` link, top-right, always present on each question screen (UX-DR7). [Source: DESIGN.md; epics.md#UX-DR7]
- **Progress dots:** 3-dot sequence; context = index 1, mind-volume = index 2 (welcome was index 0). [Source: epics.md#UX-DR13]
- **Buckets copy:** mind-volume question presents 0-10 / 10-20 / 20-50 / 50+ as the four options. [Source: prd.md#FR-3; epics.md#Story-1.3]
- **Tone:** calm, encouraging, skippable; "any question is optional" framing — never a gate. [Source: epics.md#UX-DR16, #UX-DR17]

### Source tree components to touch (this story)

```
mindow/
├── assets/l10n/app_en.arb                              # UPDATE — context/mind-volume keys
├── assets/l10n/app_fr.arb                              # UPDATE — context/mind-volume keys (fr tone)
├── lib/
│   ├── core/design_system/widgets/
│   │   └── aurore_choice_chip.dart                     # NEW — selectable pill chip
│   ├── core/router/app_router.dart                     # UPDATE — 2 onboarding routes
│   └── features/onboarding/
│       ├── welcome_screen.dart                         # UPDATE — Commencer → context
│       ├── onboarding_answers.dart                     # NEW — freezed model + enums (+gen)
│       ├── onboarding_repository.dart                  # NEW — Hive-backed persistence
│       ├── onboarding_controller.dart                  # NEW — @riverpod draft notifier (+gen)
│       ├── onboarding_context_screen.dart              # NEW — age/family/stress
│       └── onboarding_mind_volume_screen.dart          # NEW — mind-volume bucket
└── test/features/onboarding/
    ├── onboarding_repository_test.dart                 # NEW — persistence round-trip
    └── onboarding_context_screen_test.dart             # NEW — widget test
```

[Source: architecture.md#Complete-Project-Directory-Structure]

### Testing standards summary

- `flutter_test` for widget tests; `test/` mirrors `lib/`. [Source: architecture.md#Structure-Patterns]
- Hive in unit tests: `Hive.init(Directory.systemTemp.createTempSync(...).path)` in `setUp`, `tearDown` closes/deletes; do NOT use `initFlutter` (needs path_provider). Open the same `'onboarding'` box the repository uses.
- Keep the Story 1.1 Hive registry gate and Story 1.2 welcome tests green — this story adds no Hive typeId and only changes welcome's navigation target.

### Project Structure Notes

- Aligns with architecture: feature code under `features/onboarding/` (flat), shared chip under `core/design_system/widgets/`.
- Deliberate variances: onboarding kept FLAT despite crossing ~5 files (defer split); answers persisted as a local draft (no profile/account yet — Story 1.4 attaches them).
- No conflicts with Stories 1.1/1.2.

### References

- [Source: epics.md#Story-1.3] — acceptance criteria (BDD)
- [Source: epics.md#FR-3] — onboarding context capture (fields + skippable + stored on profile)
- [Source: epics.md#UX-DR7] — secondary "Passer" action
- [Source: epics.md#UX-DR13] — progress dots
- [Source: epics.md#UX-DR16/UX-DR17] — tone-as-gate, skippable framing
- [Source: epics.md#NFR-5] — localization
- [Source: prd.md#FR-3] — screens 2 (age/family/stress) & 3 (mind-volume buckets 0-10/10-20/20-50/50+)
- [Source: architecture.md#Project-Structure, #Naming-Patterns, #Events] — layout, codegen, casing boundary, events vs preferences
- [Source: DESIGN.md] — Aurore chips, radii, glass, secondary action

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (GitHub Copilot)

### Debug Log References

- `dart run build_runner build` — wrote 11 outputs (freezed + riverpod_generator + json_serializable). Generated: `onboarding_answers.freezed.dart`, `onboarding_answers.g.dart`, `onboarding_repository.g.dart`, `onboarding_controller.g.dart`.
- `flutter gen-l10n` — regenerated `AppLocalizations` with the new onboarding keys.
- `flutter analyze` — No issues found!
- `flutter test` — 15/15 passed (tokens, hive registry gate, onboarding context widget, welcome widget).
- `dart format lib test` — applied.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- All 9 tasks implemented per spec. Onboarding feature kept FLAT as planned (~6 source files), split deferred to a later story.
- Answers persist as a local Hive draft (plain box `'onboarding'`, `toJson` map, no typeId) — Hive registry CI gate untouched. Story 1.4 will attach the draft to the account profile.
- `OnboardingAnswers` is a `freezed` model; enums serialize snake-cased via `build.yaml` `field_rename: snake`. Serialization confined to the data layer (repository), screens never touch JSON.
- Providers/controller via `@riverpod` codegen only; no hand-rolled providers.
- Repository unit test inits Hive in a temp dir (not `initFlutter`); context-screen widget test overrides `onboardingRepositoryProvider` with an in-memory fake to avoid Hive.
- No Supabase/backend calls — no authenticated user yet (Story 1.4).

### File List

**New:**
- `lib/features/onboarding/onboarding_answers.dart` (+ generated `.freezed.dart`, `.g.dart`)
- `lib/features/onboarding/onboarding_repository.dart` (+ generated `.g.dart`)
- `lib/features/onboarding/onboarding_controller.dart` (+ generated `.g.dart`)
- `lib/features/onboarding/onboarding_context_screen.dart`
- `lib/features/onboarding/onboarding_mind_volume_screen.dart`
- `lib/core/design_system/widgets/aurore_choice_chip.dart`
- `test/features/onboarding/onboarding_repository_test.dart`
- `test/features/onboarding/onboarding_context_screen_test.dart`

**Modified:**
- `lib/features/onboarding/welcome_screen.dart` — Commencer → context, Passer → home
- `lib/core/router/app_router.dart` — onboardingContext + onboardingMindVolume routes
- `assets/l10n/app_en.arb`, `assets/l10n/app_fr.arb` — onboarding context/mind-volume keys
