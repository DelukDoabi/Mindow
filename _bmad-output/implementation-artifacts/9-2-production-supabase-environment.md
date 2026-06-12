---
baseline_commit: b965d11
---

# Story 9.2: Backend production readiness

Status: ready-for-dev

## Story

As a developer,
I want the existing Supabase project verified and fully configured for production traffic,
So that real users are served by a fully operational backend from day one.

## Context & Constraints

- **Supabase free tier = 1 project.** The existing project (`knnnhrynruyyjofoxvet`) is both
  dev and production. There is no separate prod project.
- **Data isolation** is guaranteed exclusively by Row Level Security (`user_id`). This is
  the accepted MVP tradeoff.
- **No migration needed**: all migrations have already been applied to this project during
  development. Step 4 below is a sanity-check only.
- **Corporate network blocker** (see repo notes): the Supabase CLI cannot authenticate on
  the Volvo corporate network. All CLI operations must go through GitHub Actions CI or the
  Supabase Dashboard web UI.
- **Edge Functions deploy workflow**: `.github/workflows/deploy-edge-functions.yml`.
  The `environment: Mindow` GitHub environment holds `SUPABASE_ACCESS_TOKEN` +
  `SUPABASE_PROJECT_ID` as environment-level secrets.

## Acceptance Criteria

1. **Given** the existing Supabase project (`knnnhrynruyyjofoxvet`)
   **When** all Edge Functions are deployed via the CI workflow
   **Then** every function (`account-export`, `account-delete`, `send-notification`,
   `ai-analyze`, `mission-generate`) is present and reachable on the project.

2. **And** `FIREBASE_SERVICE_ACCOUNT_JSON` is set as a secret in the Supabase Dashboard
   (Edge Functions → Secrets), enabling `send-notification` to authenticate to FCM.

3. **And** `GEMINI_API_KEY` is set as a secret in the Supabase Dashboard
   (Edge Functions → Secrets), enabling `ai-analyze` to call Gemini.

4. **And** RLS policies are verified: a test user's rows in `mental_items` are not
   accessible by another user's JWT.

5. **And** all migration files in `supabase/migrations/` are confirmed applied
   (no pending migration; visible in Supabase Dashboard → Database → Migrations).

## Manual Checklist

### Step 1: Deploy all Edge Functions

- [ ] Trigger the `deploy-edge-functions.yml` workflow manually in GitHub Actions (or push a commit)
- [ ] In Supabase Dashboard → Edge Functions, confirm all functions are listed with a recent deploy timestamp:
  - `account-export`
  - `account-delete`
  - `send-notification`
  - `ai-analyze`
  - `mission-generate`

### Step 2: Configure Edge Function secrets

In the Supabase Dashboard → Edge Functions → Secrets:

- [ ] **`FIREBASE_SERVICE_ACCOUNT_JSON`**
  - Firebase Console → Project Settings → Service Accounts → Generate new private key
  - Copy the downloaded JSON content and paste it as the secret value

- [ ] **`GEMINI_API_KEY`**
  - https://aistudio.google.com/app/apikey → Create API key (free tier)
  - Paste the key as the secret value

### Step 3: Verify RLS

- [ ] In Supabase Dashboard → Authentication, create two test users (A and B) via "Add user"
- [ ] Insert a dummy row in `mental_items` for user A (via SQL Editor with service role)
- [ ] Run the following in SQL Editor to confirm user B cannot see user A's data:
  ```sql
  SET LOCAL request.jwt.claims = '{"sub": "<user-B-uuid>"}';
  SELECT * FROM mental_items;
  -- Must return 0 rows
  ```
- [ ] Delete both test users after verification (Authentication → Users → Delete)

### Step 4: Verify migrations

- [ ] Supabase Dashboard → Database → Migrations
- [ ] Confirm every timestamp from `supabase/migrations/` is listed as applied
- [ ] If any are missing, apply via SQL Editor (paste the migration file content)

### Step 5: Smoke-test an Edge Function

- [ ] Supabase Dashboard → Edge Functions → `send-notification` → Test
- [ ] Send a test payload `{"user_id": "test", "notification_type": "daily_mission", "language": "fr"}`
- [ ] Verify the function returns 200 with `{"sent": false, "reason": "no_token"}` — this is correct and expected (no FCM token registered for the fake user)

## Files Created / Modified

> This story has no code changes. All steps are manual Dashboard / CI operations.

## Context & Constraints

- **Corporate network blocker** (see repo notes): `supabase` CLI cannot authenticate via browser on Volvo corporate network. Use GitHub Actions CI for all CLI operations, or use the Supabase Dashboard web UI.
- **Supabase project ref (dev)** = `knnnhrynruyyjofoxvet` (dev only — do NOT use for prod).
- Edge Functions deploy workflow = `.github/workflows/deploy-edge-functions.yml`. The `environment: Mindow` GitHub environment holds `SUPABASE_ACCESS_TOKEN` + `SUPABASE_PROJECT_ID` as environment-level secrets.
- For prod, either: (a) create a second GitHub environment (e.g. `Mindow-prod`) with prod project secrets, or (b) update the existing environment secrets after verifying dev is stable.
- `FIREBASE_SERVICE_ACCOUNT_JSON` = Firebase Console → Project Settings → Service Accounts → Generate new private key → paste the JSON content as a Supabase secret.
- `GEMINI_API_KEY` = https://aistudio.google.com/app/apikey (free tier sufficient for MVP).

## Manual Checklist

### Step 1: Create the Supabase production project

- [ ] Go to https://supabase.com/dashboard → New project
- [ ] Name: `mindow-prod` (or similar), region: close to your main user base (e.g. `eu-west-2` for FR users)
- [ ] Note the project ref (`prod-ref`), URL, anon key, and service role key
- [ ] Store them securely (password manager)

### Step 2: Apply migrations to prod

**Option A — via Supabase Dashboard SQL Editor:**
- [ ] Open prod project → SQL Editor
- [ ] Run each migration file from `supabase/migrations/` in chronological order (filename prefix = timestamp)

**Option B — via GitHub Actions (preferred if not on corporate network):**
- [ ] Add a CI job or update `deploy-edge-functions.yml` to also run `supabase db push` with the prod project ref
- [ ] Ensure `SUPABASE_ACCESS_TOKEN` is available in the CI environment

### Step 3: Deploy Edge Functions to prod

- [ ] Update `.github/workflows/deploy-edge-functions.yml` to target the prod project ref
  OR create a dedicated `deploy-prod.yml` workflow
- [ ] Verify all functions appear in the prod project's Edge Functions dashboard:
  - `account-export`
  - `account-delete`
  - `send-notification`
  - `ai-analyze`
  - `mission-generate`
  - `reconcile` (if implemented)

### Step 4: Configure Edge Function secrets on prod

In the prod Supabase Dashboard → Edge Functions → Secrets:
- [ ] `FIREBASE_SERVICE_ACCOUNT_JSON` — Firebase Console → Project Settings → Service Accounts → Generate new private key
- [ ] `GEMINI_API_KEY` — from https://aistudio.google.com/app/apikey
- [ ] Any other secrets used by Edge Functions (check each function's `Deno.env.get(...)` calls)

### Step 5: Update GitHub Actions secrets for prod

In GitHub → Settings → Environments → `Mindow` (or create `Mindow-prod`):
- [ ] `SUPABASE_URL` → prod project URL (e.g. `https://{prod-ref}.supabase.co`)
- [ ] `SUPABASE_ANON_KEY` → prod anon key
- [ ] `SUPABASE_SERVICE_ROLE_KEY` → prod service role key
- [ ] `SUPABASE_PROJECT_ID` → prod project ref

### Step 6: Verify RLS on prod

- [ ] Create two test accounts on prod
- [ ] Capture a Preoccupation with account A
- [ ] Verify account B's JWT cannot query account A's `mental_items` row (403/0 rows via SQL Editor)
- [ ] Delete both test accounts after verification

### Step 7: Firebase prod configuration (optional — if using prod Firebase project)

- [ ] Ensure `android/app/google-services.json` contains the prod Firebase project credentials
- [ ] If using a separate prod Firebase project, update `lib/firebase_options.dart` accordingly
  (this file is gitignored and injected via `FIREBASE_OPTIONS_B64` CI secret)

## Files Modified

> This story has no code changes. All steps are manual provisioning operations.
