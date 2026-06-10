---
baseline_commit: 07ceac0391ac38e03717525a98142880c5694dd2
implementation_commit: 5d92db56ec87f86690e04e0e8ed278e961047c6d
---

# Story 5.1: Notification permission & FCM setup

Status: review

## Story

As a user,
I want to grant notification permission,
So that I can receive gentle reminders.

## Acceptance Criteria

1. **Given** the app is fully loaded and the user is authenticated, **When** the notification permission prompt is triggered, **Then** the OS system permission dialog is shown (iOS / Android 13+) — no blocking modal, no guilt copy.
2. **And** declining permission leaves **all core flows fully usable** — Brain Dump, Daily Mission, Gamification; no error banners, no reduced functionality messaging (UX-DR17, UX-DR19).
3. **And** when permission is granted, an FCM token is obtained and stored in the `user_fcm_tokens` Supabase table, scoped to the current user and platform (FR-14).
4. **And** if the FCM token rotates (e.g., app reinstall), the stored token is refreshed automatically via the `onTokenRefresh` stream without user action.
5. **And** the entire setup flow (permission request + token storage) is fire-and-forget — any failure is silently swallowed and core flows are unaffected.
6. **And** the permission prompt is shown at most once per app lifecycle (not on every Home mount).

## Context & Constraints

- **Firebase is NEW to the project**: `firebase_core` and `firebase_messaging` are NOT yet in `pubspec.yaml`. This story adds them for the first time. Firebase requires platform-specific setup files that the FlutterFire CLI generates (but see FCM gotchas below re: corporate network).
- **Architecture**: FCM token storage is infrastructure (not a domain event). No new `DomainEvent` subclass is introduced. No `OutboxRecord` Hive typeId consumed.
- **Single Supabase boundary pattern**: `NotificationRepository` follows the same pattern as other repositories — holds a `nullable SupabaseClient?`; `_requireClient()` throws on unauthenticated invoke.
- **Feature folder**: starts FLAT at `lib/features/notifications/` (< 5 files, does not touch the sync engine). Do NOT add `{data,domain,presentation}/` subfolders unless the story scope expands.
- **Riverpod**: providers via codegen (`@riverpod`). No manual `Provider()` construction.
- **Seam for testability**: Firebase `FirebaseMessaging` must be abstracted behind an `FcmClient` interface so tests can use a fake without real Firebase platform init.
- **Timing of the permission ask**: show on first authenticated Home Screen arrival, AFTER onboarding is complete. NOT as a blocking modal over the capture input. NOT on every app open.
- **Permission is non-blocking**: the prompt fires as a unawaited microtask from the Home screen — it must never block the main UI thread or prevent navigation.
- **No custom pre-permission rationale dialog** in v1 — OS system prompt is sufficient for MVP. If added later, use `notificationPermission*` l10n keys.
- **No l10n additions** in this story — all copy is OS-native (system permission dialog). No FR/EN ARB keys required.
- **Tone compliance (UX-DR16, UX-DR19)**: Do not show "X notifications blocked" or any negative framing if permission is denied. The feature simply stays inactive.
- **MVP global toggle**: notification opt-out granularity = global toggle for MVP (architecture.md deferred decision). Story 5.3 implements the Settings toggle. This story just stores the token; it does not implement a toggle UI.
- **Platform notes**:
  - **iOS**: permission dialog is always explicit; APNs key must be uploaded to Firebase Console for production push delivery (simulator works without APNs for token registration).
  - **Android ≥ 13 (API 33)**: `POST_NOTIFICATIONS` permission required in `AndroidManifest.xml` and must be requested at runtime.
  - **Android < 13**: push permission granted implicitly; no dialog shown.
  - **Web**: requires a VAPID key from Firebase Console for `getToken(vapidKey: ...)`. For MVP the web token is optional; a null token is safe (graceful skip).

## Resolved Decisions

| # | Question | Decision |
|---|----------|----------|
| 1 | What triggers the permission prompt? | First authenticated Home arrival (unawaited, fire-and-forget from `HomeScreen.initState` equivalent). |
| 2 | One-time vs. every-open? | Guarded by `NotificationService._setupDone` flag (in-memory per session). Once per app lifecycle; storage (SharedPreferences or HiveBox) for cross-launch guard is deferred — the OS itself suppresses duplicate system dialogs. |
| 3 | Where is the FCM token stored? | `user_fcm_tokens` Supabase table. Upsert keyed on `(user_id, platform)` — one row per user per platform. |
| 4 | What RLS policy? | SELECT / INSERT / UPDATE restricted to `auth.uid() = user_id`. No admin policy needed in MVP. |
| 5 | What happens if token save fails? | Exception is caught and swallowed. Core flows unaffected. Dev: log to Sentry in production via `Sentry.captureException`. |
| 6 | Platform string values? | `'ios'`, `'android'`, `'web'` (lowercase, matches `defaultTargetPlatform` mapping). |
| 7 | FlutterFire CLI blocked on corporate net? | Use Firebase Console web UI + manual `firebase_options.dart` creation (see Gotchas). |
| 8 | Should we handle foreground notification display? | Out of scope for 5.1. Story 5.2 adds notification types and payload handling. `FirebaseMessaging.onMessage` and `onBackgroundMessage` wiring belongs there. |

## Technical Notes For Dev

### New packages to add to pubspec.yaml

```yaml
dependencies:
  firebase_core: ^3.13.0
  firebase_messaging: ^15.2.0
```

After `flutter pub add firebase_core firebase_messaging`, run `flutter pub get`.

> ⚠️ **Exact versions**: check [pub.dev](https://pub.dev) for the latest stable on the day you implement — the versions above are targets as of 2026-06.

### Firebase platform setup (do this BEFORE writing any Dart code)

**Option A — FlutterFire CLI (preferred, requires personal/home network):**
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id>
```
This generates `lib/firebase_options.dart` and places `google-services.json` / `GoogleService-Info.plist` automatically.

**Option B — Manual (corporate network fallback):**
1. Go to [Firebase Console](https://console.firebase.google.com), create a project.
2. Add iOS app (bundle ID: `com.mindow`), download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`.
3. Add Android app (package: `com.mindow`), download `google-services.json` → place at `android/app/google-services.json`.
4. Manually create `lib/firebase_options.dart` (copy the template from [FlutterFire docs](https://firebase.flutter.dev/docs/overview)) — fill in values from Firebase Console → Project settings → Your apps.
5. Add Web app, get the `firebaseConfig` JS snippet for use in `web/index.html`.

### Android build files changes

`android/app/build.gradle.kts` — add plugin:
```kotlin
plugins {
    // existing plugins...
    id("com.google.gms.google-services")
}
```

`android/build.gradle.kts` — add to `plugins` block (using the BOM):
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

`android/app/src/main/AndroidManifest.xml` — add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS changes

`ios/Runner/AppDelegate.swift` — add Firebase import and configure call:
```swift
import UIKit
import Flutter
import FirebaseCore   // ADD

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()  // ADD — before GeneratedPluginRegistrant
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

> ℹ️ If using Swift Package Manager / Firebase Swift SDK: no AppDelegate change needed (firebase_messaging handles this automatically via method swizzling on recent plugin versions). Check the plugin README.

### bootstrap.dart changes

Firebase must be initialized **before** Supabase. Modify `lib/app/bootstrap.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:mindow/firebase_options.dart';

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ... existing Supabase / Hive init below
}
```

### FcmClient abstraction (testability seam)

Create `lib/features/notifications/fcm_client.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FcmClient {
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  });
  Future<String?> getToken({String? vapidKey});
  Stream<String> get onTokenRefresh;
}

class RealFcmClient implements FcmClient {
  const RealFcmClient();

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) =>
      FirebaseMessaging.instance.requestPermission(
        alert: alert,
        badge: badge,
        sound: sound,
      );

  @override
  Future<String?> getToken({String? vapidKey}) =>
      FirebaseMessaging.instance.getToken(vapidKey: vapidKey);

  @override
  Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;
}
```

### NotificationRepository sketch

```dart
// lib/features/notifications/notification_repository.dart

class NotificationRepository {
  NotificationRepository(this._supabaseClient, this._fcmClient);

  final SupabaseClient? _supabaseClient;
  final FcmClient _fcmClient;

  SupabaseClient _requireClient() {
    final client = _supabaseClient;
    if (client == null) throw StateError('Supabase client not available');
    return client;
  }

  Future<NotificationSettings> requestPermission() =>
      _fcmClient.requestPermission();

  Future<String?> getFcmToken() => _fcmClient.getToken();

  Future<void> saveFcmToken(String token, String platform) async {
    await _requireClient().from('user_fcm_tokens').upsert(
      {
        'fcm_token': token,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,platform',
    );
  }

  Stream<String> get onTokenRefresh => _fcmClient.onTokenRefresh;
}
```

> `user_id` is NOT passed explicitly — it is injected server-side by Supabase RLS via `auth.uid()`. The `upsert` does not include `user_id` in the payload because the INSERT trigger / default sets it from JWT.
> 
> **Actually**: Supabase PostgREST does NOT auto-inject `user_id` on INSERT. You must set a `DEFAULT auth.uid()` in the table DDL **or** pass `user_id` explicitly from the client. Use a column default: `user_id uuid NOT NULL DEFAULT auth.uid()` in the migration (see Task 3). This way the client never sends `user_id` and cannot forge it.

### NotificationService sketch

```dart
// lib/features/notifications/notification_service.dart

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class NotificationService {
  NotificationService(this._repository);

  final NotificationRepository _repository;
  bool _setupDone = false;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> setupNotifications() async {
    if (_setupDone) return;
    _setupDone = true;

    try {
      final settings = await _repository.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        return; // declined — stop here, core flows continue unaffected
      }

      final token = await _repository.getFcmToken();
      if (token == null) return; // no token (e.g., web without VAPID key) — safe skip

      await _repository.saveFcmToken(token, _platformString());
      _listenTokenRefresh();
    } catch (e, st) {
      // Silently swallow — notification setup is non-critical
      await Sentry.captureException(e, stackTrace: st);
    }
  }

  void _listenTokenRefresh() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _repository.onTokenRefresh.listen(
      (newToken) async {
        try {
          await _repository.saveFcmToken(newToken, _platformString());
        } catch (e, st) {
          await Sentry.captureException(e, stackTrace: st);
        }
      },
    );
  }

  String _platformString() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  void dispose() => _tokenRefreshSub?.cancel();
}
```

### Notification providers sketch

```dart
// lib/features/notifications/notification_providers.dart

@riverpod
FcmClient fcmClient(Ref ref) => const RealFcmClient();

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final fcm = ref.watch(fcmClientProvider);
  return NotificationRepository(supabase, fcm);
}

@riverpod
NotificationService notificationService(Ref ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final service = NotificationService(repo);
  ref.onDispose(service.dispose);
  return service;
}
```

> `supabaseClientProvider` already exists in the repo (provides `SupabaseClient?`). Import from `lib/core/data/supabase_client.dart` or its provider file.

### Home screen trigger

In `lib/features/brain_dump/presentation/home_screen.dart`, inside the ConsumerStatefulWidget `initState` (or equivalent):

```dart
@override
void initState() {
  super.initState();
  // Fire-and-forget: notification setup is non-critical
  Future.microtask(() {
    if (mounted) {
      ref.read(notificationServiceProvider).setupNotifications();
    }
  });
}
```

> Do NOT `await` this. Do NOT show any UI error if it fails.

### Supabase DB migration (Task 3)

Create `supabase/migrations/20260610120000_create_user_fcm_tokens.sql`:

```sql
-- user_fcm_tokens: stores per-user per-platform FCM registration tokens
-- One row per (user_id, platform). Upsert on conflict updates the token.
CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid        NOT NULL DEFAULT auth.uid()
                          REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token   text        NOT NULL,
  platform    text        NOT NULL
                          CHECK (platform IN ('ios', 'android', 'web', 'other')),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_fcm_tokens_user_platform_unique UNIQUE (user_id, platform)
);

-- Row Level Security
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can only read their own tokens
CREATE POLICY "user_fcm_tokens_select_own"
  ON public.user_fcm_tokens
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own token (user_id defaults to auth.uid())
CREATE POLICY "user_fcm_tokens_insert_own"
  ON public.user_fcm_tokens
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own token
CREATE POLICY "user_fcm_tokens_update_own"
  ON public.user_fcm_tokens
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index for efficient lookup by user
CREATE INDEX idx_user_fcm_tokens_user_id ON public.user_fcm_tokens (user_id);
```

Deploy via Supabase Dashboard SQL editor (corporate net workaround, like previous migrations) or via GitHub Actions if the deploy-edge-functions workflow can be extended to also run `supabase db push`.

## Tasks / Subtasks

- [ ] **Task 1 — Firebase project setup & platform config (prerequisite — do first)**
  - [ ] Create Firebase project via [Firebase Console](https://console.firebase.google.com)
  - [ ] Add iOS app (bundle ID: `com.mindow`), download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`
  - [ ] Add Android app (package: `com.mindow`), download `google-services.json` → place at `android/app/google-services.json`
  - [ ] Add Web app, copy `firebaseConfig` snippet for web/index.html
  - [ ] Generate `lib/firebase_options.dart` — via FlutterFire CLI on personal network OR manually fill values from Firebase Console
  - [ ] Update `android/app/build.gradle.kts`: add `id("com.google.gms.google-services")` to plugins block
  - [ ] Update `android/build.gradle.kts`: add `id("com.google.gms.google-services") version "4.4.2" apply false` to plugins block
  - [ ] Update `android/app/src/main/AndroidManifest.xml`: add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` (required for Android 13+)
  - [ ] Update `ios/Runner/AppDelegate.swift`: add `import FirebaseCore` + `FirebaseApp.configure()` call (if not using method swizzling)
  - [ ] Update `web/index.html`: add Firebase SDK script tags and `firebaseApp` init in the `<head>` or before Flutter bootstrap (refer to FlutterFire web setup docs)

- [ ] **Task 2 — Add packages & bootstrap Firebase (AC: all)**
  - [ ] Add `firebase_core: ^3.13.0` and `firebase_messaging: ^15.2.0` to `pubspec.yaml` dependencies
  - [ ] Run `flutter pub get`
  - [ ] In `lib/app/bootstrap.dart`, add `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` call BEFORE Supabase init
  - [ ] Verify `flutter analyze` is clean after changes

- [ ] **Task 3 — Supabase DB migration (AC: #3)**
  - [ ] Create `supabase/migrations/20260610120000_create_user_fcm_tokens.sql` with the DDL from the Technical Notes above
  - [ ] Deploy via Supabase Dashboard SQL editor (paste and run the migration SQL)
  - [ ] Verify table appears in Supabase Dashboard → Table Editor with RLS enabled

- [ ] **Task 4 — FcmClient abstraction (testability seam)**
  - [ ] Create `lib/features/notifications/fcm_client.dart` with `abstract class FcmClient` + `RealFcmClient implements FcmClient`
  - [ ] Verify `flutter analyze` is clean

- [ ] **Task 5 — NotificationRepository (AC: #3, #4, #5)**
  - [ ] Create `lib/features/notifications/notification_repository.dart` with `requestPermission`, `getFcmToken`, `saveFcmToken`, `onTokenRefresh` as described in Technical Notes
  - [ ] Single Supabase boundary pattern: `_requireClient()` throws on unauthenticated invoke (matches all other repos)
  - [ ] Verify `flutter analyze` is clean

- [ ] **Task 6 — NotificationService (AC: #1, #2, #4, #5, #6)**
  - [ ] Create `lib/features/notifications/notification_service.dart` with `setupNotifications()` and `_listenTokenRefresh()` as described
  - [ ] `_setupDone` flag prevents re-entry within a single session (AC: #6)
  - [ ] All exceptions are caught, Sentry-logged, and swallowed (AC: #5)
  - [ ] Declined permission returns early without any side effect (AC: #2)
  - [ ] Verify `flutter analyze` is clean

- [ ] **Task 7 — Notification providers (AC: all)**
  - [ ] Create `lib/features/notifications/notification_providers.dart` with `fcmClientProvider`, `notificationRepositoryProvider`, `notificationServiceProvider` using `@riverpod` codegen
  - [ ] Run `dart run build_runner build` (needed for the new `@riverpod` annotations)
  - [ ] Verify generated `.g.dart` file appears and `flutter analyze` is clean

- [ ] **Task 8 — Home screen trigger (AC: #1, #2, #6)**
  - [ ] In `lib/features/brain_dump/presentation/home_screen.dart`, add `Future.microtask` call to `setupNotifications()` in `initState`
  - [ ] Ensure it is unawaited and guarded by `mounted` check
  - [ ] Verify the Home screen still loads and functions correctly when `setupNotifications` is not called (provider overridden in tests)
  - [ ] Verify `flutter analyze` is clean

- [ ] **Task 9 — Tests (AC: #1, #2, #5, #6)**
  - [ ] Create `test/features/notifications/notification_repository_test.dart`:
    - Create a `FakeFcmClient` (implements `FcmClient`) with configurable `requestPermission` response (authorized / denied) and stub token
    - `saveFcmToken` calls Supabase upsert with correct payload (mock SupabaseClient)
    - `getFcmToken` returns null when `FakeFcmClient.getToken` returns null — no crash
    - `onTokenRefresh` stream emits new token and triggers `saveFcmToken`
  - [ ] Create `test/features/notifications/notification_service_test.dart`:
    - `setupNotifications` with denied permission: `saveFcmToken` is never called
    - `setupNotifications` with authorized permission + valid token: `saveFcmToken` is called once
    - `setupNotifications` with authorized permission + null token (web): `saveFcmToken` never called
    - `setupNotifications` when `saveFcmToken` throws: exception is swallowed, no rethrow
    - `setupNotifications` called twice: only one `requestPermission` call (idempotent via `_setupDone` flag)
    - Token refresh: when `onTokenRefresh` emits, `saveFcmToken` is called with the new token
  - [ ] Update `test/features/brain_dump/presentation/home_screen_test.dart`:
    - Override `notificationServiceProvider` with a no-op stub (avoids real Firebase init)
    - Verify existing home screen assertions still pass (non-regression)

## Suggested File Targets

- `lib/firebase_options.dart` (CREATE — generated or manual)
- `lib/app/bootstrap.dart` (UPDATE — add Firebase.initializeApp)
- `lib/features/notifications/fcm_client.dart` (CREATE)
- `lib/features/notifications/notification_repository.dart` (CREATE)
- `lib/features/notifications/notification_service.dart` (CREATE)
- `lib/features/notifications/notification_providers.dart` (CREATE)
- `lib/features/notifications/notification_providers.g.dart` (GENERATED — build_runner)
- `lib/features/brain_dump/presentation/home_screen.dart` (UPDATE — add microtask trigger)
- `supabase/migrations/20260610120000_create_user_fcm_tokens.sql` (CREATE)
- `android/app/google-services.json` (CREATE — from Firebase Console)
- `android/app/build.gradle.kts` (UPDATE — add google-services plugin)
- `android/build.gradle.kts` (UPDATE — add google-services classpath)
- `android/app/src/main/AndroidManifest.xml` (UPDATE — POST_NOTIFICATIONS permission)
- `ios/Runner/GoogleService-Info.plist` (CREATE — from Firebase Console)
- `ios/Runner/AppDelegate.swift` (UPDATE — Firebase configure)
- `web/index.html` (UPDATE — Firebase SDK scripts)
- `pubspec.yaml` (UPDATE — add firebase_core + firebase_messaging)
- `test/features/notifications/notification_repository_test.dart` (CREATE)
- `test/features/notifications/notification_service_test.dart` (CREATE)
- `test/features/brain_dump/presentation/home_screen_test.dart` (UPDATE — override notificationServiceProvider)

## Definition of Done Checklist

- [ ] Firebase platform files in place for iOS, Android, and Web (3 config files + `firebase_options.dart`)
- [ ] `Firebase.initializeApp` runs before Supabase in `bootstrap.dart`
- [ ] `user_fcm_tokens` table exists in Supabase with RLS enabled and correct policies
- [ ] Declining permission leaves all core flows fully usable — no error, no reduced UX
- [ ] Granted permission → FCM token stored in Supabase (verified in Dashboard)
- [ ] Token refresh listener is active and re-saves on rotation
- [ ] `setupNotifications` called at most once per session (idempotent via `_setupDone`)
- [ ] All exceptions in notification flow are caught and swallowed (Sentry-logged)
- [ ] `FcmClient` abstraction in place — no direct `FirebaseMessaging.instance` calls outside `RealFcmClient`
- [ ] `notificationServiceProvider` overrideable in tests (verified in home_screen_test)
- [ ] All new unit tests pass
- [ ] No regressions in Home screen tests
- [ ] `flutter analyze` clean

## Testing Standards Summary

- **Unit tests** (`flutter_test`) — pure Dart, no Firebase platform setup required:
  - `FakeFcmClient` (implements `FcmClient`) provides all Firebase seam
  - `FakeSupabaseClient` (or mock) provides the Supabase upsert seam
  - Test the service-level orchestration: permission denied → no token call, exception → swallowed
  - Test the repository-level token handling: null token, valid token, refresh stream
- **Widget test update** (home_screen_test):
  - Override `notificationServiceProvider` with a `_NoopNotificationService` (never calls Firebase)
  - Run existing assertions — non-regression, no new assertions needed for this story
- **No integration tests for this story** — push delivery is not verifiable in CI
- **Targeted run before handoff:**
  ```
  flutter test test/features/notifications/
  flutter test test/features/brain_dump/presentation/home_screen_test.dart
  ```

## Dev Agent Gotchas

### Firebase setup blockers
- **FlutterFire CLI may be blocked on corporate network** (same issue as Supabase CLI — Go-based binary, SSL inspection). **Workaround**: run `flutterfire configure` from a personal network, OR manually copy values from Firebase Console to `firebase_options.dart`. See Option B in Technical Notes.
- **`firebase_options.dart` must exist before `Firebase.initializeApp` is called** — if the file is missing, the app will crash at boot. Create a placeholder with stub values to keep the project compilable while setting up Firebase, then replace with real values.
- **iOS simulator**: FCM tokens can be obtained on simulators but APNs delivery doesn't work. For verifying token registration, use a physical device OR check the Supabase Dashboard for the inserted token row.
- **Android google-services plugin version**: the version in `build.gradle.kts` must match or be compatible with the `firebase_messaging` SDK version. If you see a version conflict, check [Firebase Android BoM compatibility](https://firebase.google.com/docs/android/setup).

### Build runner
- **`build_runner` IS needed** for the new `@riverpod` providers in `notification_providers.dart`. Run: `dart run build_runner build --delete-conflicting-outputs` — actually the `--delete-conflicting-outputs` flag warns are now harmless since Flutter 3.44, but omit it as per repo convention; just `dart run build_runner build`.
- The generated `.g.dart` file must be committed.

### Sentry import
- `notification_service.dart` imports `sentry_flutter` (already in `pubspec.yaml`). No new dependency needed for Sentry.

### `mounted` guard after async gaps
- The `initState` microtask checks `mounted` before calling `ref.read(...)`. Failing to check `mounted` causes "looking up a deactivated widget's ancestor" errors in tests (widget unmounted before microtask resolves).

### `use_build_context_synchronously`
- No `BuildContext` is used in the notification service — no async context guard needed here. But keep it in mind for any future notification dialog additions.

### `onTokenRefresh` subscription cancellation
- The `_tokenRefreshSub` must be cancelled in `NotificationService.dispose()`, which is called via `ref.onDispose` in the provider. Failing to cancel causes a stream leak in tests.

### `upsert` vs `insert` in PostgREST
- Supabase upsert requires `onConflict: 'user_id,platform'` to specify the unique constraint columns. Without this, upsert falls back to default PK conflict which won't help for the (user_id, platform) scenario.

### Existing lint patterns
- `avoid_escaping_inner_quotes`: use double-quoted string literals in Dart for strings with apostrophes (French copy if added later).
- `cascade_invocations`: chain method calls on the same object with `..`.
- Run `dart format lib test` before committing.

### Corporate network during development
- Same Firebase CLI limitations as Supabase CLI. Browser-based Firebase Console always works. Token storage verification: check Supabase Dashboard → Table Editor → `user_fcm_tokens`.

## References

- `_bmad-output/planning-artifacts/epics.md` — Story 5.1 / FR-14 / UX-DR17 / UX-DR19
- `_bmad-output/planning-artifacts/architecture.md` — FCM (p. notifications), feature-first folder rule, single Supabase boundary pattern
- `lib/app/bootstrap.dart` — existing init sequence to extend
- `lib/core/data/supabase_client.dart` (or `supabase_providers.dart`) — `supabaseClientProvider` reference
- `lib/features/missions/missions_repository.dart` — single Supabase boundary pattern example
- `lib/features/brain_dump/presentation/home_screen.dart` — file to extend with notification trigger
- `test/features/brain_dump/presentation/home_screen_test.dart` — file to update with notificationServiceProvider override
- [firebase_messaging pub.dev](https://pub.dev/packages/firebase_messaging)
- [FlutterFire setup guide](https://firebase.flutter.dev/docs/overview)
- [Supabase PostgREST upsert docs](https://supabase.com/docs/reference/dart/upsert)
