# Story 1.6: AI processing consent & privacy notice

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want clear consent and a privacy notice for AI processing,
so that I knowingly agree before my worries are sent to the AI.

## Acceptance Criteria

1. **Given** the onboarding flow **When** I reach the consent step (after the mind-volume question, before account creation) **Then** a clear, calm privacy notice is shown explaining that what I write is sent to a third-party AI provider as-is to be analyzed, and nothing is shared elsewhere (NFR-9 Standard posture).
2. **Given** the consent step **When** I tap the explicit affirmative action ("J'accepte") **Then** consent to AI processing is recorded as granted (`true`) and persisted locally, and I advance to account creation (Story 1.4 screen).
3. **Given** the consent step **When** I do NOT explicitly accept (I use the always-available "Passer") **Then** consent is NOT recorded as granted (it stays not-granted) and onboarding remains skippable — I leave to the home placeholder (UX-DR7 / skippable-onboarding rule). Consent is captured ONLY on an explicit affirmative action (NFR-9 "explicit consent").
4. **Given** consent has been recorded **When** the value is read back **Then** the granted/not-granted state is retrievable from local persistence (the basis the Epic 2 AI-Analysis gate will check before sending any Preoccupation to the AI). Full server-profile sync of the consent flag is deferred to the Epic 2 sync engine; this story persists it locally (mirrors the Story 1.3/1.4 draft + completion-flag pattern).
5. **Given** the consent screen **When** it renders **Then** it uses the Aurore design system (AuroreCanvas, glass/pill buttons, ink/ink-muted text), copy is calm *tutoiement* localized en+fr (no guilt/urgency/legalese dump), and a "Passer" secondary action remains available.
6. **Given** the consent flag is required before AI runs (AC enforcement point) **When** an AI Analysis is later attempted (Epic 2) **Then** it must check this persisted consent first — documented here as the contract; the actual gate lands with the Epic 2 Brain-Dump/AI feature. This story does NOT build AI Analysis; it only captures, persists, and exposes the consent + shows the notice.

## Tasks / Subtasks

- [x] **Task 1: Persist the AI-consent flag** (AC: #2, #3, #4)
  - [x] Extend `lib/features/onboarding/onboarding_repository.dart` (same plain `'onboarding'` Hive box, a primitive `bool` under a NEW key `'ai_consent'` — **no typeId**, do not touch `hive_registry.dart`). Add `static const String _aiConsentKey = 'ai_consent';`, `Future<void> setAiConsent({required bool granted})` (puts the bool), and `Future<bool> isAiConsentGranted()` (returns `box.get(_aiConsentKey) == true`, default `false`).
  - [x] Keep consent SEPARATE from `OnboardingAnswers` (the context draft). Consent is a distinct privacy/legal flag, not a context answer — store it as its own key like the completion flag, NOT inside the draft model.
- [x] **Task 2: Consent screen** (AC: #1, #2, #3, #5)
  - [x] Create `lib/features/onboarding/onboarding_consent_screen.dart` (`ConsumerWidget` — no local async state needed beyond a button tap; follow the mind-volume screen structure). `AuroreCanvas` → SafeArea → Padding(`AuroreSpacing.xl`) → Column(crossAxis start): top-right "Passer" `TextButton` (ink-muted → `Routes.home`) → Spacer → title (`headlineMedium`) → privacy-notice body (`bodyLarge`/`bodyMedium`, ink-muted, comfortable `height`) → Spacer → primary `FilledButton` "J'accepte" that records consent then advances to `Routes.account`.
  - [x] On accept: `await ref.read(onboardingRepositoryProvider).setAiConsent(granted: true);` then `if (context.mounted) context.go(Routes.account);`. Guard the async-gap `BuildContext` use with `context.mounted` (very_good_analysis `use_build_context_synchronously`).
  - [x] No new color/spacing literals; reuse Aurore tokens and the themed pill `FilledButton`. No progress dots (consent is a distinct privacy moment, like the account screen — do NOT add a 4th dot to the 3-dot welcome/context/mind-volume sequence).
- [x] **Task 3: Routing** (AC: #1, #2)
  - [x] In `lib/core/router/app_router.dart`: add `Routes.onboardingConsent = '/onboarding/consent'` and its `GoRoute` (`OnboardingConsentScreen`), placed between the mind-volume and account routes. The Story 1.5 redirect guard already covers it (`_isOnboardingRoute` matches any `/onboarding/*` path) — no guard change needed.
  - [x] Update `OnboardingMindVolumeScreen`: "Continuer" → `Routes.onboardingConsent` (was `Routes.account`); "Passer" stays → `Routes.home`. Update the screen's doc comment accordingly.
- [x] **Task 4: Localization (en + fr)** (AC: #1, #2, #5)
  - [x] Add keys to `assets/l10n/app_en.arb` (with `@description`) + `app_fr.arb` (fr = tone source of truth, no `@description` in the fr file — match the existing convention): `consentTitle`, `consentBody` (the privacy notice text), `consentAccept` (explicit affirmative button label). Reuse existing `onboardingSkip` ("Passer"). Calm tutoiement, no legalese dump, no guilt/urgency.
  - [x] Run `flutter gen-l10n`.
- [x] **Task 5: Tests** (AC: #2, #3, #4)
  - [x] Extend `test/features/onboarding/onboarding_repository_test.dart` (temp-dir Hive harness already there) — `isAiConsentGranted()` is `false` on a fresh box; after `setAiConsent(granted: true)` it returns `true`; after `setAiConsent(granted: false)` it returns `false`.
  - [x] Create `test/features/onboarding/onboarding_consent_screen_test.dart` — pump in `UncontrolledProviderScope` + `MaterialApp.router` (locale fr), overriding `onboardingRepositoryProvider` with an in-memory `_FakeOnboardingRepository` (mirror `account_screen_test.dart` / `onboarding_context_screen_test.dart`). Local GoRouter with `/onboarding/consent`, `/onboarding/account` (stub `Text('account')`), and `/` (stub `Text('home')`). Assert: title + notice body + "J'accepte" + "Passer" render; tapping "J'accepte" records consent (fake's flag true) and lands on `account`; tapping "Passer" leaves consent not-granted and lands on `home`.
  - [x] `flutter analyze` clean; `flutter test` green. Keep ALL prior tests green (Stories 1.1–1.5) — the only behavioral change to an existing screen is the mind-volume "Continuer" target (mind-volume has no test asserting its navigation target, so no existing test breaks).

## Dev Notes

### Previous story intelligence (Stories 1.1–1.5)

- **Codegen workflow (CRITICAL):** the consent screen is a plain `ConsumerWidget` and the repository change is hand-written — only run `dart run build_runner build` if you add a new `@riverpod`/`@freezed` (not expected here). The new route is a `static const String` (no codegen). New ARB keys require `flutter gen-l10n`. The `--delete-conflicting-outputs` flag is REMOVED in this build_runner — omit it. [Stories 1.4/1.5 debug logs]
- **Flutter PATH (CRITICAL, Windows):** prepend `$env:Path = "C:\src\flutter\bin;" + $env:Path;` to EVERY flutter/dart command (new terminals don't inherit it). The `error: daemon terminated` line is harmless noise.
- **Provider override testing pattern (reuse):** `account_screen_test.dart` and `onboarding_context_screen_test.dart` override `onboardingRepositoryProvider` with an in-memory `_FakeOnboardingRepository extends OnboardingRepository`, wrapped in `UncontrolledProviderScope` + `MaterialApp.router` (locale fr). Mirror this exactly. The consent fake overrides `setAiConsent`/`isAiConsentGranted` in-memory.
- **Hive in unit tests:** `Hive.init(Directory.systemTemp.createTempSync(...).path)` in `setUp`, `Hive.deleteFromDisk()` + tempdir delete in `tearDown` (see `onboarding_repository_test.dart`). The consent-flag test extends this same harness alongside the existing `markComplete()`/`isComplete()` test.
- **No typeId / registry untouched:** the onboarding box stays a plain `Hive.openBox<dynamic>('onboarding')` storing primitives/maps. The `ai_consent` flag is a plain `bool` under a new key — do NOT add a Hive `typeId`, do NOT touch `lib/core/sync/hive_registry.dart` or its CI-gate test. [Stories 1.1, 1.3, 1.4]
- **Lints (`very_good_analysis`, strict):** `package:mindow/...` imports only; sort directive sections; single quotes (`'...'`) unless the string contains an apostrophe; `dart format lib test` before commit. Watch `use_build_context_synchronously` (guard `context.go` after `await` with `if (context.mounted)`), `avoid_redundant_argument_values`, `prefer_const_declarations`, `cascade_invocations` (bit Story 1.5 — prefer `obj..a()..b()` over repeating the receiver). No new pub deps expected.
- **Routing facts:** `Routes` is an `abstract final class` of `static const String` paths in `app_router.dart`: `welcome`, `onboardingContext='/onboarding/context'`, `onboardingMindVolume='/onboarding/mind-volume'`, `account='/onboarding/account'`, `home='/'`. The Story 1.5 redirect `_isOnboardingRoute` matches `welcome` OR any `/onboarding/*` — so `/onboarding/consent` is automatically guarded for returning users with no change. `appRouter` is `@Riverpod(keepAlive: true)`.
- **Onboarding flow today (after Story 1.4/1.5):** welcome (dot 0) → context (dot 1) → mind-volume (dot 2) → **[consent — NEW]** → account → home. mind-volume "Continuer" currently goes to `Routes.account`; this story inserts consent between them. The account screen is a "distinct moment" without progress dots (Story 1.4 decision) — apply the same to consent.
- **Repository persistence precedent:** `OnboardingRepository` already has `save(answers)`, `load()`, `markComplete()`, `isComplete()` over the same box via a cached `_openBox()`. Add `setAiConsent`/`isAiConsentGranted` in the same style. `onboardingRepositoryProvider` is `@Riverpod(keepAlive: true)`.

### Architecture patterns and constraints (MUST follow)

- **Privacy posture = Standard (NFR-9):** Preoccupations are sent to the AI provider as-is; the user gives explicit consent to AI processing at onboarding and a clear privacy notice is shown; GDPR baseline. The notice copy must state plainly that what the user writes goes to a third-party AI to be analyzed. [Source: epics.md#NFR-9; epics.md#Story-1.6]
- **Consent is the gate for AI Analysis:** consent state is stored and "required before any AI Analysis runs". The enforcement gate lives where AI Analysis is invoked — that feature is Epic 2 (Brain Dump & Mental Backpack). This story captures + persists + exposes the consent and shows the notice; it does NOT build the AI pipeline or its gate. Document the contract so Epic 2 wires it. [Source: epics.md#Story-1.6 AC2; epics.md#Epic-2]
- **Secrets never on client / AI key safety:** no AI calls happen in this story; when they do (Epic 2) they run server-side via Edge Functions only. Nothing here touches the OpenAI key. [Source: architecture.md#Authentication-&-Security; lib/app/bootstrap.dart]
- **Offline-first / Hive = source of truth:** the consent flag persists locally first (the device is the source of truth). Server-profile upsert of consent rides the Epic 2 event-sourced sync engine, which does not exist yet — so AC#4's "stored on the profile" is satisfied LOCALLY now, with server sync deferred (same deliberate variance as the Story 1.4 onboarding-complete flag and draft). Do NOT build sync/Edge infra here. [Source: architecture.md#Data-Architecture; epics.md#Epic-2]
- **Providers via codegen only (where providers are added):** `@riverpod`/`@Riverpod(keepAlive: true)`. This story adds NO new provider (it reuses `onboardingRepositoryProvider`); if you choose to add a consent provider, use codegen — but YAGNI: the Epic 2 gate can read the repository directly, so prefer not adding one now. [Source: architecture.md#State; Story 1.1–1.5 convention]
- **Feature folder granularity:** the consent screen lives in the EXISTING flat `lib/features/onboarding/` folder (privacy consent is part of onboarding). No new feature folder; stay flat. [Source: architecture.md#Code-Organization]
- **i18n from launch:** every label localized en+fr; fr is the tone source of truth. [Source: epics.md#NFR-5; EXPERIENCE.md#Voice-and-Tone]
- **Design system is the single source of truth:** AuroreCanvas + tokens; no literals. [Source: DESIGN.md; epics.md#UX-DR1]

### UX specifics (Aurore)

- **Tone gate (hard):** the privacy notice must be clear but calm — a short, human explanation, NOT a legalese wall. No guilt, urgency, or alarm. Reassure that the user stays in control (can export/delete anytime — true per Story 1.7/NFR-10). [Source: EXPERIENCE.md#Voice-and-Tone "Gentleness is a hard gate"]
- **Explicit affirmative consent:** consent is recorded ONLY when the user taps the clear primary "J'accepte" button — never implied by merely viewing or skipping. This satisfies NFR-9 "explicit consent". [Source: epics.md#NFR-9]
- **"Passer" secondary action:** text-only ink-muted link, top-right, always present (onboarding is never a hard gate). Skipping consent leaves it not-granted and routes to home. [Source: EXPERIENCE.md#State-Patterns; UX-DR7]
- **No new backend/home build:** the consent screen routes onward to the existing account screen (accept) or the `_PlaceholderHome` (skip). The real Mental Backpack is Epic 2. [Source: epics.md#Epic-2]
- **No progress dots on consent:** consent is a distinct privacy moment (like account), outside the 3-dot welcome/context/mind-volume sequence. [Source: Story 1.4 decision]

### Source tree components to touch (this story)

```
mindow/
├── assets/l10n/app_en.arb                              # UPDATE — consentTitle/consentBody/consentAccept (+ @descriptions)
├── assets/l10n/app_fr.arb                              # UPDATE — consent keys (fr tone source of truth)
├── lib/
│   ├── core/router/app_router.dart                     # UPDATE — add Routes.onboardingConsent + GoRoute
│   └── features/onboarding/
│       ├── onboarding_repository.dart                  # UPDATE — setAiConsent()/isAiConsentGranted()
│       ├── onboarding_mind_volume_screen.dart          # UPDATE — Continuer → Routes.onboardingConsent
│       └── onboarding_consent_screen.dart              # NEW — privacy notice + explicit consent
└── test/features/onboarding/
    ├── onboarding_repository_test.dart                 # UPDATE — consent-flag round-trip
    └── onboarding_consent_screen_test.dart             # NEW — accept records + routes; skip leaves not-granted
```

[Source: architecture.md#Code-Organization; existing repo layout from Stories 1.1–1.5]

### Testing standards summary

- `flutter_test` for widget tests; `test/` mirrors `lib/`. [Source: architecture.md#Testing]
- Widget tests must NOT initialize real Hive — override `onboardingRepositoryProvider` with an in-memory fake (Story 1.3/1.4 pattern). Building screens under `MaterialApp.router` is fine despite `google_fonts`.
- Unit-test the consent flag with the temp-dir Hive harness already in `onboarding_repository_test.dart` (extend, don't replace).
- Keep ALL prior tests green: Story 1.1 Hive registry gate, 1.2 welcome, 1.3 context + repository, 1.4 account + completion-flag, 1.5 router redirect. The only behavioral change to an existing screen is the mind-volume "Continuer" target (no existing test asserts it).

### Project Structure Notes

- Aligns with architecture: consent screen + persistence stay in the existing flat `features/onboarding/`; routing in `core/router`.
- Deliberate variances (with rationale):
  - **Consent stored LOCALLY, server-profile sync deferred to Epic 2:** AC#4's "stored on the profile" is realized locally (Hive flag) because the event-sourced sync engine is Epic 2 — identical to the Story 1.4 onboarding-complete flag decision.
  - **AI-Analysis gate deferred to Epic 2:** AC#6's "required before any AI Analysis runs" is a documented contract; the enforcement point is the Epic 2 Brain-Dump/AI feature. This story makes the consent retrievable; it does NOT build AI Analysis.
  - **Consent kept OUT of `OnboardingAnswers`:** it is a privacy/legal flag, not a context answer — stored as its own Hive key like the completion flag.
  - **No new provider:** reuse `onboardingRepositoryProvider`; the Epic 2 gate reads the repository directly (YAGNI on a dedicated consent provider).
- No conflicts with Stories 1.1–1.5 beyond the intended mind-volume navigation update; the Story 1.5 redirect already covers the new `/onboarding/consent` path.

### References

- [Source: epics.md#Story-1.6] — acceptance criteria (BDD): explicit consent captured + clear privacy notice; consent stored on profile and required before AI Analysis
- [Source: epics.md#NFR-9] — Privacy (Standard posture): Preoccupations sent to AI as-is; explicit consent at onboarding; clear privacy notice; GDPR baseline
- [Source: epics.md#NFR-10] — GDPR data rights (export + deletion) — basis for the "you can export/delete anytime" reassurance in the notice (shipped in Story 1.7)
- [Source: epics.md#Epic-1] — "consent to AI processing … landing on their Mental Backpack"
- [Source: epics.md#Epic-2] — Brain Dump & Mental Backpack: where AI Analysis (and its consent gate) lands
- [Source: architecture.md#Authentication-&-Security] — AI-key safety; Edge-only AI calls
- [Source: architecture.md#Data-Architecture] — offline-first Hive-first; server profile via Epic 2 sync
- [Source: architecture.md#Code-Organization] — feature-first folders incl. `onboarding`
- [Source: EXPERIENCE.md#Voice-and-Tone, #State-Patterns] — tone gate, "Passer" always available
- [Source: DESIGN.md] — Aurore tokens, glass/pill buttons
- [Source: lib/features/onboarding/onboarding_repository.dart] — `markComplete()`/`isComplete()` precedent; `onboardingRepositoryProvider`
- [Source: lib/features/onboarding/onboarding_mind_volume_screen.dart] — current "Continuer" → `Routes.account` to re-point at consent
- [Source: lib/core/router/app_router.dart] — `Routes`, `appRouter`, Story 1.5 `_isOnboardingRoute` redirect already covering `/onboarding/*`
- [Source: test/features/onboarding/onboarding_repository_test.dart] — temp-dir Hive harness to extend
- [Source: test/features/auth/account_screen_test.dart] — `_FakeOnboardingRepository`/override harness to mirror

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8

### Debug Log References

- `flutter gen-l10n` — regenerated `AppLocalizations` for the new `consentTitle`/`consentBody`/`consentAccept` keys (no build_runner needed; no new `@riverpod`/`@freezed`).
- `flutter analyze` — first pass flagged `avoid_escaping_inner_quotes` (3 issues) in the consent screen test where strings contained apostrophes (`J'accepte`, `d'IA`); switched those to double-quoted strings. Re-run: `No issues found!`.
- `flutter test` — 28/28 green (23 prior + repository consent round-trip/revoke + 3 consent-screen widget tests).

### Completion Notes List

- AI-processing consent is captured ONLY on the explicit "J'accepte" affirmative action (NFR-9 "explicit consent"); viewing or skipping never grants it. Persisted locally as a plain `bool` under the `ai_consent` key in the existing `onboarding` Hive box (no typeId; Hive registry untouched).
- Consent kept OUT of `OnboardingAnswers` — it is a privacy/legal flag, not a context answer; stored alongside the completion flag.
- Inserted a dedicated consent step in the flow: welcome → context → mind-volume → **consent** → account → home. mind-volume "Continuer" now targets `Routes.onboardingConsent`. The consent screen has no progress dots (distinct privacy moment, like the account screen).
- The Story 1.5 returning-user redirect already guards `/onboarding/consent` (its `_isOnboardingRoute` matches any `/onboarding/*`) — no guard change needed.
- Privacy notice copy is calm tutoiement (en + fr), states plainly that what the user writes is sent to a third-party AI partner to be analyzed, nothing shared elsewhere, and the user can export/delete anytime — no legalese dump, no guilt/urgency.
- **Deferred (deliberate variance):** AC#4 "stored on the profile" is realized LOCALLY now (Hive flag); server-profile sync of consent rides the Epic 2 event-sourced sync engine. AC#6 "required before any AI Analysis runs" is a documented contract — the enforcement gate lands with the Epic 2 Brain-Dump/AI feature, which reads `isAiConsentGranted()`. No AI pipeline or new provider was added (YAGNI; the Epic 2 gate reads the repository directly).

### File List

- `lib/features/onboarding/onboarding_repository.dart` (MODIFIED) — `_aiConsentKey`, `setAiConsent`, `isAiConsentGranted`
- `lib/features/onboarding/onboarding_consent_screen.dart` (NEW) — privacy notice + explicit consent screen
- `lib/features/onboarding/onboarding_mind_volume_screen.dart` (MODIFIED) — "Continuer" → `Routes.onboardingConsent`
- `lib/core/router/app_router.dart` (MODIFIED) — `Routes.onboardingConsent` + `GoRoute`
- `assets/l10n/app_en.arb` (MODIFIED) — `consentTitle`/`consentBody`/`consentAccept` (+ `@descriptions`)
- `assets/l10n/app_fr.arb` (MODIFIED) — fr consent keys
- `lib/core/l10n/app_localizations*.dart` (REGENERATED via `flutter gen-l10n`)
- `test/features/onboarding/onboarding_repository_test.dart` (MODIFIED) — consent round-trip + revoke
- `test/features/onboarding/onboarding_consent_screen_test.dart` (NEW) — render + accept-records-and-routes + skip-leaves-not-granted
