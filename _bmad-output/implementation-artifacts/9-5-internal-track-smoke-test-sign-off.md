---
baseline_commit: b965d11
---

# Story 9.5: Internal track smoke test & production readiness sign-off

Status: ready-for-dev

## Story

As a developer,
I want to validate the complete user journey on a real Android device installed from the
Play Store internal track,
So that I'm confident the production build works end-to-end before promoting to public.

## Acceptance Criteria

1. The signed prod AAB (deployed via Story 9.3 pipeline) installs correctly on a physical Android device from the Play Store internal track.

2. The **full core journey** completes without crash:
   - Cold launch → onboarding → account creation (Supabase prod auth)
   - Capture a Preoccupation → AI Analysis returns a weight (Edge Function reachable on prod)
   - Daily Mission generated → act on it → validate → weight-release animation plays
   - At least one notification received on the device within 2 minutes of the trigger

3. **GDPR** (Story 1-7) verified on prod: requesting account deletion from Settings triggers the `account-delete` Edge Function and erases the test user's data from the prod database.

4. **Crisis gate** verified on prod: a preoccupation with explicit self-harm language routes to the support resource screen and does NOT generate a Mission.

5. **Sentry** captures at least one test event (manual `Sentry.captureMessage` call during QA).

6. **PostHog** receives `onboarding_complete` and `first_preoccupation_captured` events on the prod instance.

7. When all ACs above pass, the story is marked `done` and the internal track build is **promoted to the production track** in Google Play Console.

## Context & Constraints

- **Prerequisites**: Stories 9.1, 9.2, 9.3, 9.4 must all be complete before this story.
- **Internal track access**: add test Google accounts (tester Gmail addresses) in Play Console → Internal testing → Testers. The tester must join the test program via the opt-in link.
- **Sentry test call**: add `Sentry.captureMessage('QA smoke test — Story 9.5');` temporarily (revert before public launch tag).
- **PostHog events**: verify in PostHog dashboard → Live events, filter by `distinct_id` of the test account.
- **Crisis gate QA**: use a clearly fictional/test phrase referencing self-harm to trigger the gate. Verify no Mission is created and the crisis_resources.dart screen appears.
- **Promotion**: Play Console → Internal testing → Releases → promote the build to the Production track. This makes it publicly available. Confirm the team is ready before promoting.

## Manual Checklist

### Step 1: Trigger the release build

- [ ] Tag the commit: `git tag v1.0.0 && git push --tags`
- [ ] Verify `deploy-android.yml` workflow runs and succeeds in GitHub Actions
- [ ] Confirm the AAB appears in Play Console → Internal testing → Releases

### Step 2: Set up internal testers

- [ ] Play Console → Internal testing → Testers → Manage testers
- [ ] Add tester Gmail addresses
- [ ] Copy the internal test opt-in link
- [ ] Accept opt-in on the test device

### Step 3: Install from Play Store internal track

- [ ] On the test Android device, open the opt-in link → Join the program
- [ ] Install Mindow from the Play Store (internal track badge visible)
- [ ] Verify package name: `com.mindow.mindow` (not `.dev` or `.staging`)

### Step 4: Smoke test the core journey

- [ ] **Cold launch**: app opens, shows onboarding
- [ ] **Account creation**: create a test account via Email (Supabase prod)
- [ ] **Capture**: submit a preoccupation → appears immediately in pending state
- [ ] **AI Analysis**: wait for the AI to return a weight (kg appears, not "pending")
- [ ] **Daily Mission**: confirm the mission card appears on Home
- [ ] **Validate mission**: tap "C'est fait ✓" → weight-release animation plays → kg decreases
- [ ] **Notification**: manually call the `send-notification` Edge Function with the test user's FCM token (via Supabase Dashboard → Edge Functions → Invoke) → notification appears within 2 min

### Step 5: GDPR verification

- [ ] Go to Settings → Account → Delete account
- [ ] Confirm deletion dialog
- [ ] Verify: app logs out and returns to onboarding
- [ ] In Supabase prod Dashboard → Table Editor → `mental_items`: verify 0 rows for the deleted user

### Step 6: Crisis gate verification

- [ ] Create a new test account
- [ ] Capture a preoccupation using a clear self-harm test phrase (e.g. "je veux me faire du mal")
- [ ] Verify: crisis_resources.dart screen appears instead of a Mission
- [ ] Verify: no `daily_mission` is generated for that preoccupation
- [ ] Delete the test account after verification

### Step 7: Observability verification

- [ ] **Sentry**: open Sentry dashboard → Issues → verify test capture appears
- [ ] **PostHog**: open PostHog dashboard → Live events → filter by test user → verify:
  - `onboarding_complete` event present
  - `first_preoccupation_captured` event present

### Step 8: Remove QA artifacts & promote

- [ ] Revert temporary `Sentry.captureMessage` call (if added)
- [ ] Tag the clean build: `git tag v1.0.1 && git push --tags` (or use the already-passing v1.0.0 if no revert needed)
- [ ] Play Console → Internal testing → Releases → select the passing build → Promote to Production
- [ ] Monitor Play Console for review status (new apps typically take 1–3 days for the first review)

## Files Created / Modified

> This story has no code changes. All steps are manual QA and Play Console operations.
