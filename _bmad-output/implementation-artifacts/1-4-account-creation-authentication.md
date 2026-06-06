# Story 1.4: Account creation & authentication

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a new user,
I want to create an account via Apple, Google, or Email,
so that my data is saved and synced.

## Acceptance Criteria

1. **Given** the account screen (the terminal onboarding step, reached after the mind-volume question) **When** I choose any of the three providers (Apple, Google, Email) **Then** an account is created and I am authenticated via Supabase Auth (FR-2).
2. **Given** any provider button **When** I tap it and the flow is in progress **Then** the button shows a non-blocking loading state and a failed/cancelled attempt surfaces a calm, localized error (no guilt/urgency) without leaving the screen broken — I can retry.
3. **Given** I have completed the onboarding questions (draft answers from Story 1.3) **When** my account is successfully created **Then** the onboarding state is marked complete locally so a completed user never sees onboarding again on that account (FR-1), and the captured draft answers remain retrievable as the basis of the profile (attached to the account in this story locally; full server profile sync lands with the Epic 2 sync engine).
4. **Given** an authenticated session **When** the app is relaunched **Then** the persisted Supabase session is restored (no re-login) — the foundation Story 1.5 uses to route returning users straight to the Mental Backpack.
5. **Given** the account screen **When** it renders **Then** it uses the Aurore design system (AuroreCanvas, glass/pill buttons, ink/ink-muted text), copy is calm *tutoiement* localized en+fr, and a "Passer" secondary action remains available (UX-DR7) routing to the placeholder home (account creation stays optional per the skippable-onboarding rule).
6. **Given** no Supabase backend is configured for the current flavor (`env.hasSupabase == false`, e.g. UI-only scaffold builds) **When** the account screen loads **Then** it still renders and does not crash; auth calls degrade gracefully (surfaced as the same calm error path), keeping the scaffold bootable.

## Tasks / Subtasks

- [x] **Task 1: Auth repository abstraction** (AC: #1, #2, #4, #6)
  - [x] Create `lib/features/auth/auth_repository.dart` — an `AuthRepository` class wrapping the Supabase Auth surface needed for this story. Methods: `Future<void> signInWithApple()`, `Future<void> signInWithGoogle()`, `Future<void> signInWithEmail({required String email, required String password})` (sign-up-or-sign-in via OTP/magic-link or password — pick the simplest supabase_flutter path and document it), `Future<void> signOut()`, plus `Stream<AuthChange> authStateChanges()` and a `Session? get currentSession`.
  - [x] Keep it the **single boundary** to `supabase_flutter` Auth. No screen or controller imports `supabase_flutter` directly. This is what makes auth testable (the screen test overrides the repository — Supabase is never initialized in tests).
  - [x] Tolerate the no-backend case: if `Supabase.instance` is not initialized (scaffold flavor), repository construction/use must not throw at import/build time; surface failures only when a provider button is actually tapped.
  - [x] Add `@Riverpod(keepAlive: true) AuthRepository authRepository(Ref ref)` provider. Reuse `supabaseClientProvider` where a client is needed.
- [x] **Task 2: Auth state provider** (AC: #1, #4)
  - [x] Create `lib/features/auth/auth_controller.dart` — an `@riverpod` provider exposing the current auth state derived from `AuthRepository.authStateChanges()` (e.g. a `Stream`/`AsyncValue` of the session, or a small `AuthState` value). This is the source Story 1.5's router `redirect` will watch.
  - [x] No hand-rolled `Provider`/`ChangeNotifier`; codegen only.
- [x] **Task 3: Onboarding completion flag** (AC: #3)
  - [x] Extend the onboarding persistence so "onboarding complete" is recorded locally and survives relaunch. Prefer adding `Future<void> markComplete()` + `Future<bool> isComplete()` to the existing `OnboardingRepository` (same plain `'onboarding'` Hive box, a primitive `bool` under a new key — **no typeId**, do not touch `hive_registry.dart`).
  - [x] On successful auth in the account screen, call `markComplete()` so returning users skip onboarding (the actual redirect is Story 1.5; this story only persists the flag and the draft).
- [x] **Task 4: Account screen** (AC: #1, #2, #5, #6)
  - [x] Create `lib/features/auth/account_screen.dart` (`ConsumerWidget`/`ConsumerStatefulWidget` if local loading state is needed). `AuroreCanvas` → SafeArea → top-right "Passer" link (→ `Routes.home`) → headline + supporting copy → three provider buttons (Apple, Google, Email) → on success: `markComplete()` then navigate to `Routes.home`.
  - [x] Email path: simplest acceptable UX — either an inline email+password form or a dedicated small screen/section. Keep it minimal; the goal is a working third provider, not a full email UX.
  - [x] Loading + error states are calm and localized (AC#2). Reuse Aurore tokens and the existing `FilledButton` pill theme; provider buttons may be glass/secondary styled per DESIGN.md. No new color/spacing literals.
- [x] **Task 5: Routing** (AC: #1, #5)
  - [x] Add `Routes.account = '/onboarding/account'` and its `GoRoute` (`AccountScreen`).
  - [x] Update `OnboardingMindVolumeScreen`: "Continuer" → `Routes.account` (was `Routes.home`); "Passer" stays/also goes to `Routes.home`.
  - [x] Do NOT add the auth `redirect` guard here — that is Story 1.5. Keep `initialLocation = Routes.welcome` unchanged for this story.
- [x] **Task 6: Localization (en + fr)** (AC: #1, #2, #5)
  - [x] Add keys to `assets/l10n/app_en.arb` + `app_fr.arb`: account screen title + subtitle, the three provider button labels (`accountContinueWithApple`/`Google`/`Email`), email field labels/hints if used, and a calm generic auth-error string (`accountAuthError`). Reuse existing `onboardingSkip`. French = tone source of truth (no guilt/urgency, tutoiement).
  - [x] Run `flutter gen-l10n`.
- [x] **Task 7: Tests** (AC: #1, #2, #3, #6)
  - [x] `test/features/auth/account_screen_test.dart` — pump in `ProviderScope`+`MaterialApp` (fr) with a `_FakeAuthRepository` overriding `authRepositoryProvider` (in-memory, no Supabase). Assert: title + three provider buttons + "Passer" render; tapping a provider button calls the fake's sign-in and then `OnboardingRepository.markComplete()` is invoked (override `onboardingRepositoryProvider` with an in-memory fake as in Story 1.3); a fake that throws surfaces the localized error and stays on the screen (AC#2/#6).
  - [x] Extend `test/features/onboarding/onboarding_repository_test.dart` (or add a focused test) — `markComplete()` then `isComplete()` returns `true`; default `isComplete()` is `false` on a fresh box.
  - [x] `flutter analyze` clean; `flutter test` green (keep Stories 1.1–1.3 tests green — this story only changes the mind-volume "Continuer" target and adds the account route).

## Dev Notes

### Previous story intelligence (Stories 1.1–1.3)

- **Codegen workflow (CRITICAL):** after writing `@freezed`/`@riverpod` code, run `dart run build_runner build` (the `--delete-conflicting-outputs` flag is REMOVED in this build_runner — it is ignored/warns; just omit it). Confirm `.g.dart` files appear before analyze. Then `flutter gen-l10n` for new ARB keys. [Story 1.3 debug log]
- **Flutter PATH (CRITICAL, Windows):** prepend `$env:Path = "C:\src\flutter\bin;" + $env:Path;` to EVERY flutter/dart command (new terminals don't inherit it). The `error: daemon terminated` line in output is harmless noise.
- **Provider override testing pattern (reuse):** Story 1.3's `onboarding_context_screen_test.dart` overrides `onboardingRepositoryProvider` with an in-memory `_FakeOnboardingRepository extends OnboardingRepository`, wrapped in `UncontrolledProviderScope` + `MaterialApp.router` (locale fr). Mirror this exactly for `authRepositoryProvider` → `_FakeAuthRepository`. This avoids initializing Supabase/Hive in widget tests.
- **Hive in unit tests:** `Hive.init(Directory.systemTemp.createTempSync(...).path)` in `setUp`, `Hive.deleteFromDisk()` + tempdir delete in `tearDown` (see `onboarding_repository_test.dart`). The completion-flag test extends this same harness.
- **No typeId / registry untouched:** the onboarding box stays a plain `Hive.openBox<dynamic>('onboarding')` storing primitives/maps. The `markComplete()` flag is a plain `bool` under a new key — do NOT add a Hive `typeId`, do NOT touch `lib/core/sync/hive_registry.dart` or its CI-gate test.
- **Lints (`very_good_analysis`, strict):** `package:mindow/...` imports only; sort directive sections; `dart format lib test` before commit. Watch `avoid_redundant_argument_values`, `prefer_single_quotes` (use `'...'` unless the string contains an apostrophe), `prefer_const_declarations`, `document_ignores` (any `// ignore:` needs an explanatory comment above it — see how `bootstrap.dart` documents the `anonKey` ignore), and `sort_pub_dependencies` (keep `pubspec.yaml` deps alphabetical if you add any).
- **Reusable widgets exist:** `AuroreCanvas` (gradient bg), `ProgressDots(count, activeIndex)`, `AuroreChoiceChip`. The account screen is the terminal step AFTER the 3-dot sequence (welcome=0, context=1, mind-volume=2) — do NOT add a 4th dot; either omit `ProgressDots` on the account screen or treat it as a distinct "create account" moment. [Story 1.3]
- **l10n pattern:** ARB in `assets/l10n/`, generated to `lib/core/l10n/`, then `flutter gen-l10n`. Do NOT re-add `synthetic-package` to `l10n.yaml`. `AppLocalizations.of(context)` returns non-null. Reuse `onboardingSkip` ("Passer").
- **Routing pattern:** `Routes` is an `abstract final class` of `static const String` path constants in `lib/core/router/app_router.dart`; `appRouter` is `@Riverpod(keepAlive: true)`. The file's doc comment already anticipates: *"Auth and first-launch vs returning-user redirects (Stories 1.4/1.5) … hook into the `redirect` callback added here later."* This story adds the `account` route + screen; the `redirect` guard itself is Story 1.5.

### Architecture patterns and constraints (MUST follow)

- **Auth = Supabase Auth (Apple/Google/Email):** [Source: architecture.md#Authentication-&-Security "Auth: Supabase Auth — Apple, Google, Email (FR-2)"; epics.md#FR-2]. Use the already-installed `supabase_flutter` (^2.14.1) — no new auth packages unless strictly required (e.g. native Google/Apple id-token sign-in). If a native helper is needed (`sign_in_with_apple`, `google_sign_in`), add it to `pubspec.yaml` deps in alphabetical order and prefer Supabase's `signInWithIdToken`; otherwise use Supabase OAuth (`signInWithOAuth`) with deep-link redirect. Document the chosen path in Completion Notes.
- **Secrets never on client:** only the public Supabase URL + anon key ship (via `--dart-define`, surfaced by `Env`). The OpenAI key and any service secrets live ONLY in Edge Functions. [Source: architecture.md#AI-key-safety; lib/app/env.dart]
- **Single serialization/back-end boundary:** the `AuthRepository` is the only file touching `supabase_flutter` Auth. Screens/controllers depend on the repository abstraction (mirrors the offline-first repository pattern). [Source: architecture.md#Frontend-Architecture "repository pattern over an abstract SyncQueue"]
- **Providers via codegen only:** `@riverpod` / `@Riverpod(keepAlive: true)`; no hand-rolled `Provider`/`StateProvider`/`ChangeNotifier`. [Source: architecture.md#State; Story 1.1–1.3 convention]
- **Offline-first / Hive = source of truth:** the onboarding-complete flag + draft answers persist locally first. Supabase is the replica. Full server profile upsert and cross-device restore depend on the Epic 2 event-sourced sync engine, which does not exist yet — so this story's AC#3 "attached to the account" is satisfied LOCALLY (flag + draft retained), with server profile sync explicitly deferred to Epic 2. Do NOT build the events/sync infra here. [Source: architecture.md#Data-Architecture; epics.md#Epic-2]
- **Feature folder granularity:** create a NEW flat feature folder `lib/features/auth/` (repository, controller, account screen ≈ 3 files). Stay flat; defer the `{data,domain,presentation}/` split (matches the onboarding decision). [Source: architecture.md#Code-Organization "feature-first (auth, brain_dump, …)"; Folder-Granularity-Rule]
- **i18n from launch:** every label localized en+fr; fr is the tone source of truth. [Source: epics.md#NFR-5; EXPERIENCE.md#Voice-and-Tone]
- **Design system is the single source of truth:** AuroreCanvas + tokens; no literals. Provider buttons follow DESIGN.md glass/pill conventions. [Source: DESIGN.md; epics.md#UX-DR1]

### UX specifics (Aurore)

- **Tone gate (hard):** every string must leave the user feeling lighter — no guilt, urgency, or failure language. The auth-error copy must be reassuring ("Petit souci de connexion. On réessaie ?"), never alarmist. [Source: EXPERIENCE.md#Voice-and-Tone, "Gentleness is a hard gate"]
- **"Passer" secondary action:** text-only `ink-muted` link, top-right, always present (account creation stays skippable — onboarding is never a hard gate). [Source: EXPERIENCE.md#State-Patterns "First launch … 'Passer' always available"; UX-DR7]
- **Canvas + components:** `AuroreCanvas` dawn gradient; pill primary `FilledButton` (already themed), glass secondary buttons for providers. [Source: DESIGN.md; lib/core/design_system/aurore_theme.dart]
- **No backpack/home build here:** the account screen routes to the existing `_PlaceholderHome` on success/skip. The real Mental Backpack home is Epic 2. [Source: epics.md#Story-1.5, #Epic-2]
- **Loading/error are non-blocking and calm:** a provider tap shows in-button progress; failure returns to a usable screen with a gentle retry — never a blocking modal over the flow. [Source: EXPERIENCE.md#Interaction-Primitives "Banned: blocking modals"]

### Source tree components to touch (this story)

```
mindow/
├── assets/l10n/app_en.arb                              # UPDATE — account screen + provider + error keys
├── assets/l10n/app_fr.arb                              # UPDATE — account keys (fr tone source of truth)
├── lib/
│   ├── core/router/app_router.dart                     # UPDATE — add Routes.account + GoRoute
│   ├── features/auth/                                  # NEW feature folder (flat)
│   │   ├── auth_repository.dart                        # NEW — Supabase Auth boundary (+ @riverpod provider) (+gen)
│   │   ├── auth_controller.dart                        # NEW — @riverpod auth-state provider (+gen)
│   │   └── account_screen.dart                         # NEW — Apple/Google/Email + Passer
│   └── features/onboarding/
│       ├── onboarding_repository.dart                  # UPDATE — markComplete()/isComplete() (+regen .g)
│       └── onboarding_mind_volume_screen.dart          # UPDATE — Continuer → Routes.account
└── test/features/
    ├── auth/account_screen_test.dart                   # NEW — fake auth repo widget test
    └── onboarding/onboarding_repository_test.dart      # UPDATE — completion-flag round-trip
```

[Source: architecture.md#Code-Organization; existing repo layout from Stories 1.1–1.3]

### Testing standards summary

- `flutter_test` for widget tests; `test/` mirrors `lib/`. [Source: architecture.md#Testing]
- Widget tests must NOT initialize Supabase or real Hive — override `authRepositoryProvider` and `onboardingRepositoryProvider` with in-memory fakes (Story 1.3 pattern). Building screens under `MaterialApp`/`MaterialApp.router` is fine despite `google_fonts` (the 1.2/1.3 screen tests do it); only deterministic-token tests avoid theme construction.
- Unit-test the completion flag with the temp-dir Hive harness already in `onboarding_repository_test.dart`.
- Keep ALL prior tests green: Story 1.1 Hive registry gate, 1.2 welcome, 1.3 context + repository. The only behavioral change to existing screens is the mind-volume "Continuer" navigation target.

### Project Structure Notes

- Aligns with architecture: new `features/auth/` (flat) per the feature-first organization that explicitly lists `auth`. Shared canvas/buttons stay in `core/design_system`.
- Deliberate variances (with rationale):
  - **Server profile sync deferred:** AC#3's "synced/attached to account" is realized LOCALLY (onboarding-complete flag + retained draft) because the event-sourced sync engine is Epic 2. Cross-device restore and the `profiles` upsert land then. Documented so the dev agent does NOT prematurely build sync/Edge infra.
  - **Auth `redirect` guard deferred to Story 1.5:** this story adds the account route/screen and persists auth + completion; the first-launch-vs-returning routing logic is Story 1.5.
  - **`auth` folder kept FLAT** (~3 files) — matches the onboarding decision; split deferred.
- No conflicts with Stories 1.1–1.3 beyond the intended mind-volume navigation update.

### References

- [Source: epics.md#Story-1.4] — acceptance criteria (BDD): three providers via Supabase Auth, onboarding-complete persistence, sign-out/in restores data
- [Source: epics.md#FR-2] — account creation & auth (Apple/Google/Email); returning users land on Mental Backpack
- [Source: epics.md#FR-1] — guided onboarding ends at account creation
- [Source: epics.md#Epic-1] — "create an account via Apple, Google, or Email — landing on their Mental Backpack"
- [Source: architecture.md#Authentication-&-Security] — Supabase Auth providers, RLS per user_id, AI-key safety
- [Source: architecture.md#Frontend-Architecture] — Riverpod + GoRouter + repository pattern; offline-first Hive-first
- [Source: architecture.md#Code-Organization] — feature-first folders incl. `auth`
- [Source: EXPERIENCE.md#Voice-and-Tone, #State-Patterns, #Interaction-Primitives] — tone gate, "Passer" always available, no blocking modals
- [Source: DESIGN.md] — Aurore tokens, glass/pill buttons
- [Source: lib/app/env.dart] — `env.hasSupabase`, public-keys-only config
- [Source: lib/app/bootstrap.dart] — Supabase initialized only when configured; `// ignore: deprecated_member_use` documentation pattern
- [Source: lib/core/data/supabase_client.dart] — `supabaseClientProvider`
- [Source: lib/core/router/app_router.dart] — `Routes`, `appRouter`, redirect hook anticipated for 1.4/1.5

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (GitHub Copilot, bmad-dev-story workflow).

### Debug Log References

- `dart run build_runner build` — wrote 10 outputs (incl. `auth_repository.g.dart`, `auth_controller.g.dart`); `--delete-conflicting-outputs` omitted (removed in this build_runner).
- `flutter gen-l10n` — regenerated `AppLocalizations` with 9 new `account*` keys.
- `flutter analyze` — `No issues found!` (clean).
- `flutter test` — `All tests passed!` (19/19: 15 prior + 3 account screen + 1 onboarding completion-flag).
- `dart format lib test` — formatted, 1 file changed.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- **Auth path chosen:** OAuth (`signInWithOAuth(OAuthProvider.apple/google)`) for the social providers and `signInWithPassword`→fallback-`signUp` for email. OAuth opens the browser flow and the authenticated session arrives later via deep link, so the screen calls `markComplete()` + navigates home on the *call* returning — a local-scope simplification adequate for the scaffold; full session-gated routing is Story 1.5.
- **No-backend tolerance (AC#6):** `AuthRepository` holds a nullable `SupabaseClient?`; when `env.hasSupabase == false` the provider passes `null`, `authStateChanges()` returns `Stream.empty()`, and any auth action throws `AuthUnavailableException` surfaced through the same calm localized error path. The screen renders and never crashes.
- **Backend-agnostic boundary:** repository exposes only `AuthSnapshot {userId, isSignedIn}` and `AuthUnavailableException` — no `supabase_flutter` type leaks to controller/screen, keeping widget tests Supabase-free via `authRepositoryProvider` override.
- **Deferred (documented):** server profile upsert / cross-device restore → Epic 2 sync engine; auth `redirect` guard + returning-user routing → Story 1.5; `auth` feature folder kept FLAT (3 source files); `initialLocation` unchanged (`Routes.welcome`).
- No Hive `typeId` added; `hive_registry.dart` and its CI-gate test untouched. Onboarding-complete flag is a plain `bool` under a new key in the existing `'onboarding'` box.

### File List

**New:**
- `lib/features/auth/auth_repository.dart` (+ `auth_repository.g.dart`)
- `lib/features/auth/auth_controller.dart` (+ `auth_controller.g.dart`)
- `lib/features/auth/account_screen.dart`
- `test/features/auth/account_screen_test.dart`

**Modified:**
- `lib/features/onboarding/onboarding_repository.dart` — `markComplete()` / `isComplete()`
- `lib/features/onboarding/onboarding_mind_volume_screen.dart` — "Continuer" → `Routes.account`, "Passer" → `Routes.home`
- `lib/core/router/app_router.dart` — `Routes.account` + `GoRoute`
- `assets/l10n/app_en.arb` / `assets/l10n/app_fr.arb` — 9 new `account*` keys
- `test/features/onboarding/onboarding_repository_test.dart` — completion-flag round-trip test
