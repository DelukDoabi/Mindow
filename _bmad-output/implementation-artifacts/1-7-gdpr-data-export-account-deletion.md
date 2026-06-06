# Story 1.7: GDPR data export & account deletion

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want to export my data and delete my account,
so that I keep control of my personal information.

## Acceptance Criteria

1. **Given** Settings **When** I request an export **Then** the client invokes the `account-export` Edge Function and I get clear, calm feedback that my export is being prepared (NFR-10). The function is scaffolded to return my Preoccupations and derived data; the full data cascade completes when those tables land (Epic 2 sync engine).
2. **Given** Settings **When** I request account deletion **Then** I must confirm an explicit, clearly-worded destructive dialog before anything happens (no accidental deletion).
3. **Given** I confirm deletion **When** the action runs **Then** the client invokes the `account-delete` Edge Function (which is scaffolded to erase all Preoccupations and derived data via cascade), I am signed out, and I land back on the welcome screen.
4. **Given** no backend is configured for the active flavor (`SupabaseClient` is null) **When** I trigger export or delete **Then** the app degrades gracefully (no crash) and shows the calm error message — actions throw only when invoked, never on screen build (mirrors the Story 1.4 auth-unavailable pattern).
5. **Given** a Settings entry point **When** I am on the Home placeholder **Then** I can reach Settings (a top-right settings affordance), and from Settings I can reach both GDPR actions; copy is calm *tutoiement*, localized en+fr, using the Aurore design system.
6. **Given** the named Edge Functions are a GDPR contract (NFR-10) **When** this story ships **Then** `supabase/functions/account-export/` and `supabase/functions/account-delete/` exist as deployable scaffolds that authenticate the caller and define the export/erase contract; deployment + the full Preoccupations/derived-data cascade are completed alongside the Epic 2 data model. [Epic 1 = GDPR groundwork, epics.md]

## Tasks / Subtasks

- [x] **Task 1: GDPR repository wiring** (AC: #1, #3, #4)
  - [x] Add `exportData()` and `deleteAccount()` to `lib/features/auth/auth_repository.dart` (it is the single Supabase boundary and already holds the nullable `SupabaseClient` + `signOut`). `exportData()` → `_requireClient().functions.invoke('account-export')` (returns `Future<void>`; the Edge Function handles delivery). `deleteAccount()` → `_requireClient().functions.invoke('account-delete')` then `await signOut()`. Both throw `AuthUnavailableException` when the client is null (via `_requireClient()`), never on construction/build.
  - [x] Do NOT leak any `supabase_flutter` type across the boundary (keep the abstraction; methods return `Future<void>`).
- [x] **Task 2: Settings screen** (AC: #1, #2, #3, #5)
  - [x] Create `lib/features/settings/settings_screen.dart` (`ConsumerStatefulWidget` — needs busy/error local state like the account screen). `AuroreCanvas` → SafeArea → Padding(`AuroreSpacing.xl`) → Column: a back affordance / title (`settingsTitle`), a "Privacy & data" section with two actions: `settingsExportData` (calm FilledButton/ListTile → `_runExport`) and `settingsDeleteAccount` (danger-styled action → confirmation dialog → `_runDelete`). Show a `CircularProgressIndicator` while busy and a calm inline error (`settingsActionError`) on failure.
  - [x] `_runDelete` shows an `AlertDialog` (`settingsDeleteConfirmTitle`/`settingsDeleteConfirmBody`, cancel + confirm). On confirm: `await ref.read(authRepositoryProvider).deleteAccount();` then `if (context.mounted) context.go(Routes.welcome);`. Guard async-gap `BuildContext` with `context.mounted`.
  - [x] `_runExport`: `await ref.read(authRepositoryProvider).exportData();` then show a calm success `SnackBar`/inline confirmation (`settingsExportRequested`). On error set the error flag.
  - [x] No literals; reuse Aurore tokens. Delete action uses `AuroreColors.danger` for affordance, not alarm.
- [x] **Task 3: Routing + Home entry point** (AC: #5)
  - [x] In `lib/core/router/app_router.dart`: add `Routes.settings = '/settings'` + its `GoRoute` (`SettingsScreen`). Settings is a top-level route (NOT under `/onboarding`), so the Story 1.5 returning-user redirect does NOT pull a signed-in user away from it.
  - [x] Add a top-right settings `IconButton` (`Icons.settings_outlined`, ink-muted) to `_PlaceholderHome` (wrap the centered content so the icon sits in the top-right via `SafeArea` + `Stack`/`Align`) → `context.go(Routes.settings)`.
- [x] **Task 4: Edge Function scaffolds (GDPR contract groundwork)** (AC: #6)
  - [x] Create `supabase/functions/account-export/index.ts` — Deno/TS: verify the caller JWT (auth-scoped client from the `Authorization` header), return `{ user, preoccupations: [], derived: {} }` JSON with a documented `// Epic 2:` extension point where Preoccupations + derived data are gathered once those tables exist. CORS-safe (handle `OPTIONS`).
  - [x] Create `supabase/functions/account-delete/index.ts` — Deno/TS: verify the caller JWT, then use a service-role client to `auth.admin.deleteUser(userId)` (FK `ON DELETE CASCADE` erases Preoccupations + derived data once the Epic 2 schema lands). Return `204`. CORS-safe.
  - [x] Add `supabase/functions/_shared/cors.ts` with shared CORS headers. NOTE in the story: Supabase project config + deployment are deferred (no project linked yet); these are deployable source scaffolds, not analyzed by `flutter analyze` (non-Dart).
- [x] **Task 5: Localization (en + fr)** (AC: #1, #2, #3, #5)
  - [x] Add to `assets/l10n/app_en.arb` (with `@description`) + `app_fr.arb` (fr = tone source, no `@description`): `settingsTitle`, `settingsPrivacySection`, `settingsExportData`, `settingsExportRequested`, `settingsDeleteAccount`, `settingsDeleteConfirmTitle`, `settingsDeleteConfirmBody`, `settingsDeleteConfirmCta`, `settingsCancel`, `settingsActionError`. Calm tutoiement, no guilt/urgency; the delete copy is clear about permanence without being alarmist.
  - [x] Run `flutter gen-l10n`.
- [x] **Task 6: Tests** (AC: #1, #2, #3, #4, #5)
  - [x] Create `test/features/settings/settings_screen_test.dart` — override `authRepositoryProvider` with a `_FakeAuthRepository extends AuthRepository` (super(null); records `exportCalls`/`deleteCalls`/`signedOut`; optional `shouldThrow`). Local GoRouter with `/settings`, `/welcome` (stub `Text('welcome')`). Assert: renders title + export + delete actions; tapping export calls `exportData` once and shows the success copy; tapping delete shows the confirm dialog, cancelling does NOT call `deleteAccount`, confirming calls `deleteAccount` once and lands on `welcome`; when `shouldThrow`, the calm error copy shows and no navigation occurs.
  - [x] `flutter analyze` clean; `flutter test` green; keep ALL prior tests green (Stories 1.1–1.6, 28 tests). No existing screen behavior changes except the new Home settings icon (no test asserts the home placeholder has no buttons).

## Dev Notes

### Previous story intelligence (Stories 1.1–1.6)

- **Auth boundary pattern (reuse):** `AuthRepository` is the single Supabase boundary, holds a nullable `SupabaseClient`, and uses `_requireClient()` to throw `AuthUnavailableException` only when an action is invoked (never on build). Add `exportData`/`deleteAccount` here. `signOut()` already exists — `deleteAccount` reuses it. [lib/features/auth/auth_repository.dart]
- **No-backend graceful degradation:** `authRepositoryProvider` passes `null` when `!env.hasSupabase`; reads degrade to signed-out, actions throw on invoke. The Settings screen must build fine with a null client and only surface the calm error when the user taps an action. [Stories 1.1, 1.4]
- **Screen-level testing (reuse):** raw Supabase-calling methods are NOT unit-tested (mocking `SupabaseClient` is heavy and no prior story does it). Test at the screen level with a `_FakeAuthRepository extends AuthRepository` (super(null)) overriding the methods — exactly like `test/features/auth/account_screen_test.dart`. [Story 1.4]
- **Async-gap BuildContext:** guard `context.go`/dialog after `await` with `if (context.mounted)` (`use_build_context_synchronously`). [Story 1.6]
- **Codegen workflow:** no new `@freezed`; `auth_repository.dart` already has `@Riverpod(keepAlive: true) authRepository` — its signature is unchanged (only new methods on the class), so **build_runner is not required** (regenerates identically). New ARB keys → `flutter gen-l10n` only. The `--delete-conflicting-outputs` flag is REMOVED — omit it.
- **Flutter PATH (CRITICAL, Windows):** prepend `$env:Path = "C:\src\flutter\bin;" + $env:Path;` to EVERY flutter/dart command. `error: daemon terminated` is harmless noise.
- **Lints (`very_good_analysis`, strict):** `package:mindow/...` imports only; sort directive sections; single quotes unless the string contains an apostrophe (use double quotes then — `avoid_escaping_inner_quotes` bit Story 1.6); `dart format lib test` before commit; watch `cascade_invocations` on repeated receivers, `avoid_redundant_argument_values`, `prefer_const_declarations`. `analysis_options.yaml` only analyzes Dart — the `supabase/functions/*.ts` scaffolds are ignored.
- **Routing facts:** `Routes` is an `abstract final class` of `static const String` in `app_router.dart`: `welcome='/welcome'`, `onboardingContext`, `onboardingMindVolume`, `onboardingConsent`, `account='/onboarding/account'`, `home='/'`. The Story 1.5 redirect `_isOnboardingRoute` matches `welcome` OR any `/onboarding/*` — so `/settings` (top-level) is NOT redirected for a signed-in user. `appRouter` is `@Riverpod(keepAlive: true)`. `_PlaceholderHome` is a private `StatelessWidget` in `app_router.dart` rendering `homeWelcomeTitle`/`homeWelcomeBody` centered — add the settings icon here.
- **Commit hygiene (CRITICAL):** multi-line `git commit -m` with parentheses/apostrophes hangs PowerShell's PSReadLine. Write the message to a temp file and `git commit -F .git/COMMIT_MSG_x.txt`, then `git push`, then delete the temp file. [Story 1.6 incident]

### Architecture patterns and constraints (MUST follow)

- **GDPR export + delete via Edge Functions (cascade):** "GDPR export + delete via Edge Functions (cascade erase of Preoccupations + derived data)." The client invokes the named functions; the server does the cascade. [Source: architecture.md#Authentication-&-Security; architecture.md#API-&-Communication-Patterns]
- **Named Edge Functions are part of the contract:** `account-export` and `account-delete` appear in the Edge Functions list and the source tree (`supabase/functions/account-export/`, `account-delete/`). Scaffold them now as deployable groundwork. [Source: epics.md (Edge Functions list); architecture.md#Source-tree]
- **Epic 1 = GDPR groundwork:** "Establishes the technical foundation and GDPR …"; "plus GDPR consent/export/delete groundwork." So the full cascade over Preoccupations/derived tables completes with the Epic 2 data model + sync engine; this story lays the client wiring + function scaffolds. [Source: epics.md#Epic-1]
- **AI/secret key safety (N/A here but adjacent):** the service-role key used by `account-delete` lives only in the Edge Function env, never on the client (OWASP secret management). The client never holds admin credentials — it only invokes the function with the user's JWT. [Source: architecture.md#Authentication-&-Security]
- **Auth = Supabase (Apple/Google/Email), RLS by user_id:** deletion goes through `auth.admin.deleteUser`; `ON DELETE CASCADE` FKs (added with the Epic 2 schema) erase the user's rows. [Source: architecture.md#Authentication-&-Security]
- **Offline-first / single boundary:** screens depend on `AuthRepository`, never on `supabase_flutter`. [Source: architecture.md#Frontend-Architecture; Stories 1.1/1.4]
- **i18n from launch; Aurore design system is the single source of truth:** every label en+fr (fr = tone source); AuroreCanvas + tokens, no literals, no third-party UI kit. [Source: epics.md#NFR-5; DESIGN.md]

### UX specifics (Aurore)

- **Settings reachable from Home header:** "Settings | Home header | Account, notifications, privacy/export, partner link" — privacy/export lives in Settings. For the Epic 1 placeholder Home, a top-right settings icon is enough; the full settings IA arrives with later epics. [Source: EXPERIENCE.md#Screen-inventory]
- **Destructive action = explicit confirmation, calm not alarmist:** deletion must be confirmed via a clear dialog; copy states permanence plainly without guilt or scare tactics. Use `AuroreColors.danger` as a restrained signal. [Source: EXPERIENCE.md#Voice-and-Tone "Gentleness is a hard gate"; DESIGN.md danger token]
- **Calm feedback for export:** a reassuring "your export is being prepared" message; no spinner-of-doom, no legalese. [Source: EXPERIENCE.md#Voice-and-Tone]
- **No new backend/home build:** Settings routes back to welcome after deletion; the real settings surface and data delivery are later. [Source: epics.md#Epic-2+]

### Source tree components to touch (this story)

```
mindow/
├── assets/l10n/app_en.arb                              # UPDATE — settings* keys (+ @descriptions)
├── assets/l10n/app_fr.arb                              # UPDATE — settings keys (fr tone source)
├── lib/
│   ├── core/router/app_router.dart                     # UPDATE — Routes.settings + GoRoute + Home settings icon
│   └── features/
│       ├── auth/auth_repository.dart                   # UPDATE — exportData()/deleteAccount()
│       └── settings/
│           └── settings_screen.dart                    # NEW — GDPR export + delete UI
├── supabase/functions/
│   ├── _shared/cors.ts                                 # NEW — shared CORS headers
│   ├── account-export/index.ts                         # NEW — JWT-verified export contract scaffold
│   └── account-delete/index.ts                         # NEW — JWT-verified cascade-delete scaffold
└── test/features/settings/
    └── settings_screen_test.dart                       # NEW — export/delete/confirm/error/no-backend
```

[Source: architecture.md#Source-tree; existing repo layout from Stories 1.1–1.6]

### Testing standards summary

- `flutter_test`; `test/` mirrors `lib/`. Override `authRepositoryProvider` with an in-memory fake (super(null)); wrap in `UncontrolledProviderScope` + `MaterialApp.router` (locale fr). [Stories 1.4/1.6]
- Confirmation dialog: pump, tap delete, `pumpAndSettle`, assert dialog text; tap cancel → assert no `deleteAccount`; re-open, tap confirm → assert `deleteAccount` called once + lands on `welcome`.
- Keep ALL prior tests green (28 across Stories 1.1–1.6). The Edge Function `.ts` scaffolds are not exercised by `flutter test`.

### Project Structure Notes

- New flat `features/settings/` folder (single screen — stays flat per the >~5-files rule). GDPR repository methods live on the existing `AuthRepository` (single Supabase boundary; `deleteAccount` reuses `signOut`).
- Deliberate variances (with rationale):
  - **Edge Functions scaffolded, not deployed:** no Supabase project is linked and the Preoccupations/derived-data schema lands in Epic 2, so the functions authenticate + define the contract now and complete their data cascade with the Epic 2 data model. AC#1/#3 reference what the functions "are scaffolded to" do.
  - **Export returns `Future<void>` (no file/share UI):** delivery is an Edge Function concern; the client gives calm feedback. Surfacing/downloading the payload is refined later.
  - **Raw Supabase-calling methods not unit-tested:** consistent with all prior auth methods; tested at the screen level via a fake repository.
- No conflicts with Stories 1.1–1.6; the only existing-screen change is the new Home settings icon, and `/settings` is outside the Story 1.5 onboarding redirect.

### References

- [Source: epics.md#Story-1.7] — AC (BDD): `account-export` returns Preoccupations + derived data; `account-delete` cascade-erases and signs out
- [Source: epics.md#NFR-10] — GDPR data rights: export + full account deletion ship in MVP
- [Source: epics.md (Edge Functions list)] — `account-export`, `account-delete` named functions
- [Source: epics.md#Epic-1] — Epic 1 establishes GDPR export/delete groundwork
- [Source: architecture.md#Authentication-&-Security] — GDPR export/delete via Edge Functions (cascade); service-role key server-only; `auth.admin.deleteUser`
- [Source: architecture.md#API-&-Communication-Patterns] — Edge Functions for account export/delete
- [Source: architecture.md#Source-tree] — `supabase/functions/account-export/`, `account-delete/`
- [Source: EXPERIENCE.md#Screen-inventory, #Voice-and-Tone] — Settings holds privacy/export; gentle, non-alarmist destructive UX
- [Source: DESIGN.md] — Aurore tokens incl. `danger`
- [Source: lib/features/auth/auth_repository.dart] — single boundary, nullable client, `_requireClient()`, `signOut()` to extend
- [Source: lib/core/router/app_router.dart] — `Routes`, `appRouter`, `_PlaceholderHome`, Story 1.5 redirect scope
- [Source: test/features/auth/account_screen_test.dart] — `_FakeAuthRepository`/override harness to mirror

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (GitHub Copilot)

### Debug Log References

- `flutter gen-l10n` — regenerated `AppLocalizations` for the 10 new `settings*` keys (en + fr). No errors.
- `dart format lib test` — 49 files, 0 changed (code already formatted).
- `flutter analyze` — `No issues found!` (ran in 54.1s).
- `flutter test` — `All tests passed!` 33/33 (28 prior + 5 new settings screen tests).
- build_runner NOT run: `authRepositoryProvider` signature is unchanged (only new methods on the class body), so generated output is identical.

### Completion Notes List

- All 6 ACs implemented. GDPR export + account deletion wired client-side through the single `AuthRepository` Supabase boundary (`exportData()` / `deleteAccount()`), with the existing `_requireClient()` graceful-degradation pattern (actions throw `AuthUnavailableException` only on invoke when no backend is configured, never on build).
- New `SettingsScreen` (Aurore design system, calm tutoiement copy en+fr): export action with reassuring feedback, delete action gated behind an explicit non-alarmist confirmation dialog; on confirmed delete the user is signed out and routed back to `/welcome`. Reached via a top-right settings icon on the Home placeholder; `/settings` is a top-level route outside the Story 1.5 onboarding redirect.
- Three deployable Edge Function scaffolds created (`account-export`, `account-delete`, shared `_shared/cors.ts`): JWT-verified, CORS-safe, defining the GDPR contract.
- **Deferrals (by design, all noted in ACs / Project Structure Notes):**
  - Edge Functions are scaffolded source, NOT deployed — no Supabase project is linked yet; deployment + the full Preoccupations/derived-data cascade complete with the Epic 2 data model + sync engine.
  - `exportData()` returns `Future<void>` — no file/share/download UI; delivery is an Edge Function concern, the client only gives calm feedback.
  - Raw Supabase-calling methods are not unit-tested (consistent with all prior auth methods); covered at the screen level via `_FakeAuthRepository extends AuthRepository`.
- This is the final Epic 1 story — Epic 1 (technical foundation + GDPR groundwork: consent, export, delete) is complete.

### File List

- `lib/features/auth/auth_repository.dart` (MODIFIED) — added `exportData()` + `deleteAccount()`
- `lib/features/settings/settings_screen.dart` (NEW) — GDPR export + delete UI
- `lib/core/router/app_router.dart` (MODIFIED) — `Routes.settings` + `GoRoute` + Home settings icon
- `supabase/functions/_shared/cors.ts` (NEW) — shared CORS headers
- `supabase/functions/account-export/index.ts` (NEW) — JWT-verified export contract scaffold
- `supabase/functions/account-delete/index.ts` (NEW) — JWT-verified cascade-delete scaffold
- `assets/l10n/app_en.arb` (MODIFIED) — `settings*` keys (+ `@description`)
- `assets/l10n/app_fr.arb` (MODIFIED) — `settings*` keys (fr tone source)
- `test/features/settings/settings_screen_test.dart` (NEW) — 5 screen tests
