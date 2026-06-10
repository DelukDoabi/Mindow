---
baseline_commit: c441df4b
---

# Story 5.2: Engagement notification types

Status: ready-for-dev

## Story

As a user,
I want kind, relevant notifications,
So that I'm gently re-engaged without pressure.

## Acceptance Criteria

1. **Given** FCM permission is granted (Story 5.1 done) **When** a trigger condition occurs **Then** the user can receive one of four notification types: **Daily Mission**, **Streak**, **Achievement**, and **Mental-load reduced** — each localized to the user's language (FR-14, NFR-5).
2. **And** all notification copy passes the tone-as-gate — no guilt, no urgency, no red alarms (UX-DR16, UX-DR19). Banned: "Tu as raté ta mission", red badge counts, "Dernière chance", overdue framing.
3. **And** tapping a notification deep-links to the relevant screen (Mission → Home, Achievement → Home, Streak → Home, Mental-load → Home). Navigation uses GoRouter.
4. **And** foreground notifications are handled gracefully: a local in-app banner (SnackBar or equivalent) is shown instead of the OS overlay.
5. **And** background / terminated state notifications are handled: the app opens to the correct screen via `getInitialMessage`.
6. **And** the send-notification Edge Function (`supabase/functions/send-notification/index.ts`) accepts a payload specifying `user_id`, `notification_type`, `language`, and optional context data, calls the FCM HTTP v1 API server-side, and returns `200` on success.
7. **And** the Edge Function is protected: it can only be invoked with the Supabase service-role key — never from the client.
8. **And** no notification is sent when permission was not granted (token absent in `user_fcm_tokens`).

## Context & Constraints

- **Story 5.1 is the hard prerequisite**: `firebase_core`, `firebase_messaging`, `FcmClient`, `NotificationRepository`, `NotificationService`, `notification_providers.dart`, and `user_fcm_tokens` are all already in place. Do NOT re-implement or restructure any of those — extend only.
- **Architecture: server-sends, client-receives.** The Flutter client does NOT initiate notifications. The Edge Function (Deno/TypeScript) sends via FCM HTTP v1 API using the Firebase service account. The client only wires `onMessage` / `onBackgroundMessage` / `getInitialMessage` handlers.
- **Edge Function — FCM HTTP v1 API** (not the legacy FCM API): `https://fcm.googleapis.com/v1/projects/{projectId}/messages:send`. Requires a short-lived OAuth 2.0 access token obtained from the Firebase service account JSON (stored as a Supabase secret `FIREBASE_SERVICE_ACCOUNT_JSON`).
- **Four notification types** for MVP:
  - `daily_mission` — "Ta mission du jour t'attend" (FR) / "Your daily mission awaits" (EN)
  - `streak` — "Tu es en feu ! X jours de suite" (FR) / "You're on fire! X days in a row" (EN)
  - `achievement` — "Nouveau badge débloqué 🌱" (FR) / "New badge unlocked 🌱" (EN)
  - `mental_load_reduced` — "Ton sac s'allège — X kg de moins" (FR) / "Your load lightened — X kg less" (EN)
- **Tone guardrails (UX-DR16, UX-DR19) are absolute**. Every string must be reviewed against: no guilt ("tu as raté"), no urgency ("dernière chance"), no negative counter framing. The tone is warm, first-name optional, always leaves the user feeling lighter.
- **No scheduling / cron in this story.** The Edge Function is invoked on-demand (called by other Edge Functions or future cron jobs). Scheduling is a Story 5.x concern. This story only builds the send pipeline.
- **l10n**: notification copy is server-generated (Edge Function uses `language` param). Flutter client does NOT need new ARB keys for the notification body/title — those are rendered by the OS from the FCM payload. However, `notification_payload_type` handling in the client may need a helper constant — keep it in `lib/features/notifications/`.
- **Feature folder stays flat**: `lib/features/notifications/` now has 4 files. If this story adds more than 2 new files, that is fine but do NOT create `data/`, `domain/`, `presentation/` subfolders — still below the threshold.
- **Riverpod**: hand-written `Provider()` only (no `@riverpod` codegen), consistent with `notification_providers.dart` from 5.1.
- **Testing**: Unit test the Edge Function payload builder in isolation. Widget tests for `HomeScreen` must not call real Firebase — use existing `_NoopNotificationService` override pattern.
- **No new Hive typeIds consumed.** Notification delivery is not event-sourced.

## Files Created / Modified in Story 5.1 (Read Before Touching)

| File | What 5.1 did |
|------|-------------|
| `lib/features/notifications/fcm_client.dart` | `FcmClient` interface + `RealFcmClient` — do NOT change |
| `lib/features/notifications/notification_repository.dart` | token save/refresh — do NOT change |
| `lib/features/notifications/notification_service.dart` | `setupNotifications()` idempotent — do NOT change |
| `lib/features/notifications/notification_providers.dart` | 3 hand-written Providers — extend if needed |
| `supabase/migrations/20260610120000_create_user_fcm_tokens.sql` | `user_fcm_tokens` table — deployed, do NOT re-run |
| `lib/firebase_options.dart` | gitignored, real values in place locally — do NOT commit |
| `android/app/google-services.json` | platform config in place |
| `ios/Runner/GoogleService-Info.plist` | platform config in place |

## Files to Create (New)

| File | Purpose |
|------|---------|
| `supabase/functions/send-notification/index.ts` | Deno Edge Function — accepts `{user_id, notification_type, language, context}`, fetches FCM token from `user_fcm_tokens`, obtains OAuth token, calls FCM HTTP v1 API |
| `lib/features/notifications/notification_handler.dart` | Flutter: wires `FirebaseMessaging.onMessage`, `onBackgroundMessage`, `getInitialMessage` → GoRouter navigation |

## Files to Modify (Existing)

| File | Change |
|------|--------|
| `lib/app/app.dart` or bootstrap / `HomeScreen` | Register `NotificationHandler.init(router)` after Firebase init |
| `test/features/notifications/notification_handler_test.dart` | Unit tests for payload routing |

## Technical Implementation Guide

### Part A — Edge Function `send-notification`

**Location:** `supabase/functions/send-notification/index.ts`

**Pattern:** Follow exactly the same structure as `supabase/functions/mission-generate/index.ts` — same imports, same `corsHeaders`, same error-response shape.

**Required Supabase secret** (add via Dashboard → Edge Functions → Secrets, or `supabase secrets set` from CI):
```
FIREBASE_SERVICE_ACCOUNT_JSON=<full JSON content of Firebase service account key>
```
Get the service account key from: Firebase Console → Project Settings → Service Accounts → Generate new private key.

**FCM HTTP v1 flow:**

```typescript
// 1. Parse service account JSON from env
const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON')!);

// 2. Get short-lived OAuth 2.0 access token
//    Use the googleapis JWT flow (no external lib needed in Deno):
//    - Create a JWT signed with RS256 using serviceAccount.private_key
//    - POST to https://oauth2.googleapis.com/token
//    - Scope: https://www.googleapis.com/auth/firebase.messaging

// 3. Fetch FCM token for user from user_fcm_tokens
const { data } = await supabase
  .from('user_fcm_tokens')
  .select('fcm_token, platform')
  .eq('user_id', userId)
  .single();

// 4. Build FCM message (title + body from notification_type + language)
// 5. POST to FCM HTTP v1
//    https://fcm.googleapis.com/v1/projects/{projectId}/messages:send
```

**Notification payloads by type:**

```typescript
const MESSAGES: Record<string, Record<string, { title: string; body: string }>> = {
  daily_mission: {
    fr: { title: 'Ta mission du jour', body: 'Une petite victoire t'attend aujourd'hui.' },
    en: { title: 'Your daily mission', body: 'A small win is waiting for you today.' },
  },
  streak: {
    fr: { title: 'Continue comme ça !', body: '{days} jours de suite — tu avances.' },
    en: { title: 'Keep it up!', body: '{days} days in a row — you're moving forward.' },
  },
  achievement: {
    fr: { title: 'Nouveau badge 🌱', body: 'Tu as débloqué : {name}' },
    en: { title: 'New badge 🌱', body: 'You unlocked: {name}' },
  },
  mental_load_reduced: {
    fr: { title: 'Ton sac s'allège', body: '{kg} kg de préoccupations en moins cette semaine.' },
    en: { title: 'Your load lightened', body: '{kg} kg fewer worries this week.' },
  },
};
```

**Tone check:** Every string above must pass: no "tu as raté", no "dernière chance", no red urgency. The strings above are the canonical ones — do NOT change tone for any reason.

**Authorization:** The function must validate the `Authorization` header carries the Supabase service-role JWT. Reject with `403` otherwise. Use the same pattern as other Edge Functions.

**Response shape:**
```json
{ "sent": true, "platform": "ios" }
// or on missing token:
{ "sent": false, "reason": "no_token" }
```

### Part B — Flutter `NotificationHandler`

**Location:** `lib/features/notifications/notification_handler.dart`

**Responsibilities:**
1. `FirebaseMessaging.onMessage.listen(...)` — foreground: show a SnackBar with the notification title/body. Use `ScaffoldMessenger` via a global `scaffoldMessengerKey` (inject via `MaterialApp`).
2. `FirebaseMessaging.onMessageOpenedApp.listen(...)` — app in background, user taps notification: navigate via `router.go('/') ` (all four types route to Home for MVP).
3. `FirebaseMessaging.instance.getInitialMessage()` — app was terminated, notification opened app: same Home routing.
4. `FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler)` — top-level function (must be annotated `@pragma('vm:entry-point')`), just logs/acknowledges, no UI.

**Background handler** must be a top-level function (Flutter/Firebase constraint):
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI work here — background isolate. Just log.
}
```

**Registration:** Call `NotificationHandler.init(router)` once after Firebase and GoRouter are initialized — in `lib/app/app.dart` or bootstrap. It must be called after `WidgetsFlutterBinding.ensureInitialized()` and `Firebase.initializeApp()`.

**Notification data payload** (sent by Edge Function alongside the `notification` object):
```json
{ "type": "daily_mission" }
```
The handler reads `message.data['type']` for routing. For MVP all types → `/`.

### Part C — Supabase Secret Setup

The Edge Function needs `FIREBASE_SERVICE_ACCOUNT_JSON`. Since Supabase CLI is blocked on the corporate network, add the secret via the **Supabase Dashboard**:

1. Dashboard → **Edge Functions** → **Secrets** (or Project Settings → Edge Functions)
2. Add secret: `FIREBASE_SERVICE_ACCOUNT_JSON` = paste the full JSON from Firebase Console → Project Settings → Service Accounts → Generate new private key

### Part D — Testing

**Edge Function tests** — TypeScript unit tests are out of scope for MVP (no Deno test runner in CI yet). Manual testing via `curl` against the deployed function with the service-role key is sufficient.

**Flutter unit tests** — `test/features/notifications/notification_handler_test.dart`:
- Test that `message.data['type'] == 'daily_mission'` routes to `'/'`
- Test foreground message triggers SnackBar (mock `ScaffoldMessenger`)
- Mock `FirebaseMessaging` instance — use the `FcmClient` fake pattern from 5.1 tests

**Widget tests** — existing `home_screen_test.dart` already overrides `notificationServiceProvider`. `NotificationHandler.init()` is called outside `ProviderScope` — no additional widget test changes needed.

## Dev Notes from Story 5.1

- `NotificationService` is **not** injected into the handler — the handler is a static utility, not a provider.
- `FcmClient` interface exists for test isolation — the handler uses `FirebaseMessaging.instance` directly (it is for incoming messages, not for token management).
- The `_NoopNotificationService` in `home_screen_test.dart` already implements `NotificationService` — no changes needed there.
- The `test/features/notifications/` folder already exists with 12 passing tests.
- `supabase/config.toml` may need a `[functions.send-notification]` entry — check if other functions have entries there.

## Resolved Decisions for this Story

| # | Question | Decision |
|---|----------|----------|
| 1 | Scheduling / cron? | Out of scope — Edge Function is invoked on-demand only. |
| 2 | One Edge Function or per-type? | One `send-notification` function, `notification_type` param routes copy. |
| 3 | Deep-link routing granularity? | All 4 types → Home (`/`) for MVP. Story 5.3 can refine. |
| 4 | Foreground notification UI? | SnackBar via `scaffoldMessengerKey`. No custom modal. |
| 5 | FCM Legacy vs HTTP v1 API? | HTTP v1 (current standard). Legacy API deprecated May 2024. |
| 6 | Service account storage? | Supabase secret `FIREBASE_SERVICE_ACCOUNT_JSON` — never in repo. |
| 7 | Per-type l10n in ARB files? | No — copy is server-generated in Edge Function. No new ARB keys. |
| 8 | `onBackgroundMessage` handler location? | Top-level function in `notification_handler.dart`, `@pragma('vm:entry-point')`. |

## Gotchas

- **FCM HTTP v1 requires a JWT, not the server key.** The legacy `Authorization: key=SERVER_KEY` does NOT work for HTTP v1. You need to exchange a service account JSON for a short-lived OAuth token.
- **`onBackgroundMessage` must be a top-level function** — not a class method, not a closure. If you put it inside a class the app will crash silently on background messages.
- **`getInitialMessage()` returns null if the app was opened normally** — always null-check.
- **Supabase RLS on `user_fcm_tokens`**: the Edge Function uses the service-role client (`SUPABASE_SERVICE_ROLE_KEY` auto-injected by the runtime) which bypasses RLS. The SELECT to fetch `fcm_token` will work even though RLS restricts clients to their own row.
- **`supabase/config.toml`**: check if it needs a `[functions.send-notification]` stanza. Other functions (e.g. `mission-generate`) may not have one — follow the same pattern.
