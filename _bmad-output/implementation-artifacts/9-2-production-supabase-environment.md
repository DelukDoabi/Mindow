---
baseline_commit: b965d11
---

# Story 9.2: Production Supabase environment provisioning

Status: ready-for-dev

## Story

As a developer,
I want a dedicated production Supabase project isolated from dev data,
So that real user data never co-mingles with development data and all migrations are
verified on prod before launch.

## Acceptance Criteria

1. **Given** a new Supabase project created for production
   **When** all existing migrations under `supabase/migrations/` are applied
   **Then** every migration applies cleanly with no errors.

2. **And** all Edge Functions deploy successfully to the prod project, enabling the full AI and notification pipeline.

3. **And** `FIREBASE_SERVICE_ACCOUNT_JSON` is set as a secret in the prod Supabase Dashboard (Edge Functions → Secrets), enabling `send-notification` to authenticate to FCM.

4. **And** `GEMINI_API_KEY` is set as a secret in the prod Supabase Dashboard (Edge Functions → Secrets), enabling `ai-analyze` to call Gemini.

5. **And** CI secrets are updated for the production deploy context (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_PROJECT_ID`).

6. **And** RLS is verified: a test user's Preoccupations are not accessible by another user's JWT on the prod instance.

7. **And** the dev Supabase project is retained as-is for development; the two environments share no data.

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
