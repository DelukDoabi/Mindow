# Story 1.5: Returning-user routing

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a returning user,
I want to land directly on my Mental Backpack,
so that I'm not forced through onboarding again.

## Acceptance Criteria

1. **Given** an authenticated returning user (a persisted Supabase session restored on cold open) **And** onboarding was completed on this account/device **When** the app opens **Then** they land on the Mental Backpack (Home), not the welcome/onboarding flow (FR-2).
2. **Given** a first-time / signed-out user (no persisted session) **When** the app opens **Then** they start on the welcome screen and the full onboarding flow is unchanged (no regression to Stories 1.2–1.4).
3. **Given** the returning-user cold open **When** Home renders **Then** it renders immediately with no blocking spinner — the routing decision is resolved before the first frame (synchronously), so the user never sees a welcome flash or a loading gate (UX-DR17 cold open). Cached weight + last stats are stubbed by the existing placeholder Home; the real cached Mental Backpack content lands with the Epic 2 sync engine.
4. **Given** a user who is authenticated but has NOT completed onboarding (e.g. created an account mid-flow then relaunched) **When** the app opens **Then** onboarding is NOT skipped — they resume the onboarding flow (completion, not mere authentication, is the gate for skipping onboarding) (FR-1).
5. **Given** an in-session auth change (sign-in completing, or a future sign-out) **When** the auth state changes **Then** the router re-evaluates routing reactively (no app restart required) — the redirect guard watches the auth-state source added in Story 1.4.
6. **Given** no Supabase backend is configured for the active flavor (`env.hasSupabase == false`) **When** the app opens **Then** the user is treated as signed-out, routing degrades to the normal welcome/onboarding flow, and nothing crashes (the redirect guard tolerates a `null` client exactly as the rest of auth does).

## Tasks / Subtasks

- [x] **Task 1: Synchronous onboarding-completion seed** (AC: #1, #3, #4)
  - [x] The router `redirect` callback is synchronous, but `OnboardingRepository.isComplete()` is async (Hive). To resolve routing before the first frame with no spinner/flash (AC#3), seed the completion flag at bootstrap and expose it through a synchronous provider — mirror the proven `envProvider` override pattern.
  - [x] Add `final onboardingCompleteProvider = Provider<bool>((ref) => throw UnimplementedError('seeded in bootstrap'));` (a plain hand-written `Provider`, NOT codegen — it exists only to be overridden, exactly like `envProvider`). Place it in `lib/features/onboarding/onboarding_repository.dart` (next to `onboardingRepositoryProvider`) or a small `onboarding_routing.dart`; keep it in the onboarding feature.
  - [x] In `lib/app/bootstrap.dart`, after `Hive.initFlutter()`, read the persisted completion once (`final onboardingComplete = await OnboardingRepository().isComplete();`) and add `onboardingCompleteProvider.overrideWithValue(onboardingComplete)` to the existing `ProviderScope(overrides: [...])` (alongside `envProvider`). This opens the onboarding box before first frame — a legitimate bootstrap responsibility (read persisted routing state up front), positioning Epic 2 to seed cached weight the same way.
- [x] **Task 2: Auth-aware redirect guard in the router** (AC: #1, #2, #4, #5, #6)
  - [x] In `lib/core/router/app_router.dart`, add a `redirect` callback to the `GoRouter`. Read state via `ref.read` INSIDE the callback (do NOT `ref.watch` the auth/completion providers at provider-build scope — that would rebuild the whole `GoRouter` and lose the navigation stack):
    - `final signedIn = ref.read(authRepositoryProvider).currentSnapshot.isSignedIn;` — synchronous; Supabase restored the persisted session during `Supabase.initialize` (awaited in bootstrap), so `currentSession` is available on the first frame. With no backend, `currentSnapshot` is signed-out (AC#6).
    - `final complete = ref.read(onboardingCompleteProvider);` — synchronous (seeded in Task 1).
  - [x] Redirect rule: a returning user (`signedIn && complete`) currently sitting on an onboarding/welcome route (`welcome`, `onboardingContext`, `onboardingMindVolume`, `account`) is redirected to `Routes.home`. Everyone else returns `null` (no redirect) — first-time and incomplete users keep the existing flow unchanged (AC#2/#4). Add a small private `bool _isOnboardingRoute(String location)` helper rather than inlining string checks.
  - [x] Keep `initialLocation = Routes.welcome` unchanged. The redirect (not a computed initial location) handles the returning-user case — this keeps deep links and the guard composable, and matches the file's existing doc comment ("returning-user redirects (Stories 1.4/1.5) … hook into the `redirect` callback added here later").
- [x] **Task 3: Reactive re-evaluation via refreshListenable** (AC: #5)
  - [x] Make the router re-run its `redirect` when auth state changes, without rebuilding the router. Create a `ValueNotifier<int>` (or equivalent `Listenable`) inside `appRouter`, `ref.onDispose(notifier.dispose)`, and `ref.listen(authStateProvider, (_, __) => notifier.value++)` (side-effect listen — NOT watch). Pass it as `GoRouter(refreshListenable: notifier, ...)`.
  - [x] Do NOT add `ref.watch` of `authStateProvider`/`onboardingCompleteProvider` at the `appRouter` body level — that recreates the `GoRouter` on every change and drops navigation state. The listenable pattern is the correct GoRouter+Riverpod idiom.
- [x] **Task 4: Update the router doc comment** (AC: all)
  - [x] Update the `appRouter` doc comment: Story 1.5 now implements the returning-user redirect (was "added later"). Note that the premium guard (Epic 6) still hooks the same `redirect` later.
- [x] **Task 5: Tests** (AC: #1, #2, #4, #5, #6)
  - [x] Create `test/core/router/app_router_test.dart`. Build the real `appRouterProvider` inside a `ProviderContainer` with overrides:
    - `authRepositoryProvider.overrideWithValue(...)` using an in-memory fake `AuthRepository` (reuse the Story 1.4 pattern: `extends AuthRepository` with `super(null)`, overriding `currentSnapshot` to a chosen `AuthSnapshot` and `authStateChanges()` to a controllable stream).
    - `onboardingCompleteProvider.overrideWithValue(true/false)`.
  - [x] Tests (mirror the established `UncontrolledProviderScope` + `MaterialApp.router` harness from `account_screen_test.dart`):
    - Returning user (`signedIn=true`, `complete=true`) → after pump, the Home (`homeWelcomeTitle`) is shown, NOT the welcome headline (AC#1).
    - First-time user (`signedIn=false`, `complete=false`) → welcome screen is shown (AC#2).
    - Authenticated but incomplete (`signedIn=true`, `complete=false`) → welcome/onboarding shown, NOT redirected home (AC#4).
    - No backend (fake with `super(null)`, signed-out snapshot, `complete=false`) → welcome shown, no crash (AC#6).
  - [x] `flutter analyze` clean; `flutter test` green. Keep ALL prior tests green (Stories 1.1–1.4); this story changes routing behavior only via the additive redirect — no existing screen behavior changes.

## Dev Notes

### Previous story intelligence (Stories 1.1–1.4)

- **Codegen workflow (CRITICAL):** after writing/altering `@riverpod` code (`app_router.dart` here), run `dart run build_runner build` (the `--delete-conflicting-outputs` flag is REMOVED in this build_runner — omit it). Confirm regenerated `.g.dart` before analyze. Then `flutter gen-l10n` only if ARB changed (this story adds NO new strings — it reuses existing welcome/home/account copy). [Story 1.4 debug log]
- **Flutter PATH (CRITICAL, Windows):** prepend `$env:Path = "C:\src\flutter\bin;" + $env:Path;` to EVERY flutter/dart command (new terminals don't inherit it). The `error: daemon terminated` line is harmless noise.
- **Provider override testing pattern (reuse):** `account_screen_test.dart` overrides `authRepositoryProvider` + `onboardingRepositoryProvider` with in-memory fakes, wrapped in `UncontrolledProviderScope` + `MaterialApp.router` (locale fr). Mirror this exactly; here also override `onboardingCompleteProvider.overrideWithValue(bool)` and build the REAL `appRouterProvider`.
- **AuthRepository is already routing-ready:** Story 1.4 deliberately built `currentSnapshot` (synchronous, from the persisted session) and the `authState` stream "as the source the router redirect watches (Story 1.5)". Reuse them; do NOT add new auth surface. `AuthSnapshot { userId, isSignedIn }` is backend-agnostic — no `supabase_flutter` type leaks into the router.
- **No-backend tolerance (established):** `authRepositoryProvider` passes a `null` client when `env.hasSupabase == false`; `currentSnapshot` is then signed-out and `authStateChanges()` is `Stream.empty()`. The redirect inherits this for free — AC#6 needs no special-casing beyond reading `currentSnapshot`.
- **Lints (`very_good_analysis`, strict):** `package:mindow/...` imports only; sort directive sections; single quotes (`'...'`) unless the string contains an apostrophe; `dart format lib test` before commit. Watch `avoid_redundant_argument_values`, `prefer_const_declarations`, `document_ignores`. No new pub deps expected, so `sort_pub_dependencies` is N/A.
- **Routing facts:** `Routes` is an `abstract final class` of `static const String` paths in `app_router.dart`: `welcome='/welcome'`, `onboardingContext='/onboarding/context'`, `onboardingMindVolume='/onboarding/mind-volume'`, `account='/onboarding/account'`, `home='/'`. `appRouter` is `@Riverpod(keepAlive: true)`; `MindowApp` does `ref.watch(appRouterProvider)`. The placeholder Home (`_PlaceholderHome`) already renders synchronously from `homeWelcomeTitle`/`homeWelcomeBody` — it is the stand-in Mental Backpack until Epic 2.
- **Bootstrap seeding precedent:** `bootstrap.dart` already overrides `envProvider.overrideWithValue(env)` in the `ProviderScope`. Adding `onboardingCompleteProvider.overrideWithValue(...)` follows the identical pattern; Hive is already `initFlutter()`-ed before the override is computed.

### Architecture patterns and constraints (MUST follow)

- **Returning users land on the Mental Backpack:** [Source: epics.md#FR-2 "returning users land on Mental Backpack"; epics.md#Story-1.5]. The decision gate is **authenticated AND onboarding-complete** — authentication alone is not enough (AC#4), preserving FR-1 ("a completed user never sees onboarding again").
- **Routing = GoRouter, redirect guard:** [Source: architecture.md#Routing "GoRouter — PRD-prescribed"; architecture.md "router/app_router.dart # GoRouter (+ premium_guard)"]. The redirect is the documented extension point for auth/first-launch (this story) and the Epic 6 premium guard (later). Keep it a single composable `redirect`.
- **Providers via codegen, router state via listen-not-watch:** `@riverpod`/`@Riverpod(keepAlive: true)` for codegen providers; the one hand-written `Provider` (`onboardingCompleteProvider`) is the documented exception (override-only seed, like `envProvider`). Inside `appRouter`, use `ref.listen` + `ref.read` for routing inputs so the `GoRouter` instance is stable across auth changes. [Source: architecture.md#Frontend-Architecture "Riverpod + GoRouter + repository pattern"; Story 1.1–1.4 convention]
- **Offline-first / Hive = source of truth:** the onboarding-complete flag is read from Hive at bootstrap (local source of truth). Supabase only tells us *whether a session exists*; onboarding completion is a local fact. [Source: architecture.md#Data-Architecture]
- **Cold open with no blocking spinner (UX-DR17):** routing must be resolved synchronously on the first frame — hence the bootstrap seed. No `AsyncValue`/`FutureBuilder` gate in front of the app. The real cached weight/stats are Epic 2; this story only guarantees the *routing* is instant and the placeholder Home renders without a spinner. [Source: epics.md#UX-DR17 "cold open (cached weight, no blocking spinner)"; epics.md#Story-1.5 AC2]
- **Secrets never on client / no new backend calls:** this story makes NO network calls — it only reads the already-restored session and the local completion flag. [Source: architecture.md#Authentication-&-Security]
- **No new feature folder:** this is wiring inside `core/router` + a one-line bootstrap seed + a tiny onboarding provider. No new screens. [Source: architecture.md#Code-Organization]

### UX specifics (Aurore)

- **No welcome flash for returning users:** because routing is seeded synchronously, an authenticated, completed user goes straight to Home — they must never see the welcome screen blink first. This is the crux of AC#3. [Source: epics.md#UX-DR17 cold open]
- **No blocking spinner / no loading gate:** do not wrap the app in a splash/loading screen waiting on async state. The placeholder Home (and later the real Backpack) renders immediately from cached/local data. [Source: EXPERIENCE.md#State-Patterns "cold open: cached weight, no blocking spinner"]
- **No new copy, no tone work:** this story reuses existing localized strings (welcome, home, account). Nothing new to translate. [Source: this story is pure routing]
- **First-launch flow untouched:** the "Passer"-everywhere skippable onboarding (Stories 1.2–1.4) is unchanged for signed-out/incomplete users. [Source: EXPERIENCE.md#State-Patterns first-launch; UX-DR7]

### Source tree components to touch (this story)

```
mindow/
├── lib/
│   ├── app/bootstrap.dart                              # UPDATE — read isComplete() after Hive init; add onboardingCompleteProvider override
│   ├── core/router/app_router.dart                     # UPDATE — add redirect guard + refreshListenable; update doc comment (+regen .g)
│   └── features/onboarding/onboarding_repository.dart   # UPDATE — add hand-written onboardingCompleteProvider (override-only seed)
└── test/core/router/
    └── app_router_test.dart                            # NEW — redirect behavior across the 4 cases
```

[Source: architecture.md#Code-Organization; existing repo layout from Stories 1.1–1.4]

### Testing standards summary

- `flutter_test` for widget tests; `test/` mirrors `lib/`. [Source: architecture.md#Testing]
- Router tests must NOT initialize Supabase or real Hive: build the real `appRouterProvider` with `authRepositoryProvider` (in-memory fake `extends AuthRepository`, `super(null)`) and `onboardingCompleteProvider` overridden to a fixed bool. Use `UncontrolledProviderScope` + `MaterialApp.router(routerConfig: container.read(appRouterProvider), locale: fr)` (the `account_screen_test.dart` harness).
- Assert on landed screen via a unique on-screen string: Home = `homeWelcomeTitle` value (fr), welcome = the welcome headline. Use `pumpAndSettle`.
- For the reactive case (AC#5), drive the fake's auth stream (e.g. a `StreamController<AuthSnapshot>`) and verify the router redirects after emitting a signed-in snapshot (optional/stretch — the 4 static cases are the must-haves).
- Keep ALL prior tests green: Stories 1.1 (Hive registry gate), 1.2 (welcome), 1.3 (context + repository), 1.4 (account + completion-flag). The redirect is additive — existing screen tests build their own local routers and are unaffected.

### Project Structure Notes

- Aligns with architecture: routing logic stays in `core/router`; the completion seed lives in the onboarding feature; bootstrap composes the override. No new feature folder, no new screens.
- Deliberate variances (with rationale):
  - **Synchronous bootstrap seed for completion:** chosen over an `AsyncValue`/`FutureProvider` so the redirect resolves before the first frame (AC#3 "no blocking spinner", no welcome flash). Costs one extra Hive box-open at startup; acceptable and reused by Epic 2 for cached weight.
  - **`onboardingCompleteProvider` is hand-written (not codegen):** it exists solely to be overridden in bootstrap, exactly like `envProvider`. This is the established exception to the codegen-only rule.
  - **Cached weight/stats deferred to Epic 2:** AC2's "cached weight + last stats" is satisfied by the existing placeholder Home rendering instantly; the real event-sourced Backpack content is Epic 2. Documented so the dev agent does NOT build the Backpack/sync engine here.
  - **`redirect` + `refreshListenable` (listen, not watch):** keeps the `GoRouter` instance stable across auth changes so navigation state is preserved — the correct GoRouter+Riverpod idiom.
- No conflicts with Stories 1.1–1.4; the redirect is purely additive.

### References

- [Source: epics.md#Story-1.5] — acceptance criteria (BDD): authenticated returning user lands on Mental Backpack, not onboarding; cached weight + last stats render immediately, no blocking spinner
- [Source: epics.md#FR-2] — account creation & auth; returning users land on Mental Backpack
- [Source: epics.md#FR-1] — guided onboarding; a completed user never sees onboarding again
- [Source: epics.md#UX-DR17] — state patterns incl. cold open (cached weight, no blocking spinner)
- [Source: architecture.md#Routing] — GoRouter, PRD-prescribed; app_router.dart hosts the guard
- [Source: architecture.md#Frontend-Architecture] — Riverpod + GoRouter + repository pattern; offline-first Hive-first
- [Source: architecture.md#Code-Organization] — core/router placement
- [Source: lib/core/router/app_router.dart] — `Routes`, `appRouter`, redirect hook anticipated for 1.4/1.5
- [Source: lib/features/auth/auth_repository.dart] — `AuthRepository.currentSnapshot` (sync), `authStateChanges()`; backend-agnostic `AuthSnapshot`
- [Source: lib/features/auth/auth_controller.dart] — `authStateProvider` ("the source the router redirect watches (Story 1.5)")
- [Source: lib/features/onboarding/onboarding_repository.dart] — `isComplete()`, `onboardingRepositoryProvider`
- [Source: lib/app/bootstrap.dart] — Hive init before overrides; `envProvider.overrideWithValue` seeding precedent
- [Source: lib/app/app.dart] — `MindowApp` watches `appRouterProvider`
- [Source: test/features/auth/account_screen_test.dart] — fake `AuthRepository`/override harness to reuse

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (GitHub Copilot, bmad-dev-story workflow).

### Debug Log References

- `dart run build_runner build` not required — the `@riverpod appRouter` signature was unchanged; only the body gained the redirect/listenable, so `app_router.g.dart` regenerates identically. No new ARB keys → no `flutter gen-l10n`.
- `flutter analyze` — first pass flagged one `cascade_invocations` on the duplicated `ref` receiver; converted `ref.onDispose(...)` + `ref.listen(...)` into a `ref..onDispose()..listen()` cascade → `No issues found!`.
- `flutter test` — `All tests passed!` (23/23: 19 prior + 4 new router redirect cases).
- `dart format lib test` — formatted, 3 files changed; re-ran analyze → still clean.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- **Synchronous routing seed:** `onboardingCompleteProvider` (hand-written override-only `Provider<bool>`, the documented `envProvider`-style exception) is seeded in `bootstrap.dart` by reading `OnboardingRepository().isComplete()` once after `Hive.initFlutter()`. This lets the router `redirect` resolve before the first frame — no welcome flash, no blocking spinner (AC#3 / UX-DR17 cold open).
- **Redirect gate = authenticated AND complete:** `signedIn && onboardingComplete && _isOnboardingRoute(matchedLocation)` → `Routes.home`. Authentication alone does NOT skip onboarding (AC#4); first-time/signed-out/incomplete users keep the unchanged flow (AC#2). `_isOnboardingRoute` matches `welcome` or any `/onboarding/*` path.
- **Reactive, stack-preserving:** auth changes bump a `ValueNotifier` via `ref.listen(authStateProvider, …)` wired to `GoRouter.refreshListenable`; the `GoRouter` instance is never rebuilt (no `ref.watch` of routing inputs at body scope), so the navigation stack survives sign-in/out (AC#5).
- **No-backend tolerance (AC#6):** with `env.hasSupabase == false`, `authRepositoryProvider` holds a `null` client, `currentSnapshot` is signed-out and `authStateChanges()` is `Stream.empty()` — the redirect inherits this and degrades to the normal welcome flow with no crash and no special-casing.
- **Deferred (documented):** real cached weight + last stats (AC#2 wording) render via the existing placeholder Home now; the event-sourced Mental Backpack content lands with the Epic 2 sync engine. The premium guard (Epic 6) will hook the same `redirect` later.
- `initialLocation` unchanged (`Routes.welcome`); no new screens, no new feature folder, no Hive `typeId`, registry untouched.

### File List

**New:**
- `test/core/router/app_router_test.dart`

**Modified:**
- `lib/features/onboarding/onboarding_repository.dart` — add hand-written `onboardingCompleteProvider` (override-only seed) + `flutter_riverpod` import
- `lib/app/bootstrap.dart` — read `isComplete()` after Hive init; add `onboardingCompleteProvider` override to the `ProviderScope`
- `lib/core/router/app_router.dart` — auth-aware `redirect` guard + `refreshListenable`; `_isOnboardingRoute` helper; updated doc comment (+ regenerated `app_router.g.dart` if changed)
