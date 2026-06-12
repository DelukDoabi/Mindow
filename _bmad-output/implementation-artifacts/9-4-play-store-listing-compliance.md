---
baseline_commit: b965d11
---

# Story 9.4: Play Store listing, content rating & compliance

Status: ready-for-dev

## Story

As a product owner,
I want the Mindow app listing on Google Play to be complete, accurate, and compliant,
So that the app passes the pre-launch review and is approved for public distribution.

## Acceptance Criteria

1. **Given** the Mindow app is created in Google Play Console under `com.mindow.mindow`
   **When** the store listing is filled in
   **Then** the title (≤30 chars), short description (≤80 chars), and full description (≤4000 chars) are localized in **French** and **English**, with no prohibited terms.

2. **And** at least 2 phone screenshots (1080×1920 or 16:9) + 1 feature graphic (1024×500) are uploaded; screenshots show real in-app screens.

3. **And** a hosted privacy policy URL is set (covers AI processing disclosure + GDPR rights).

4. **And** content rating questionnaire is completed; app is rated appropriate for the intended audience.

5. **And** the data safety form is filled: Preoccupation content (sent to AI), FCM token, and account data declared with correct handling/sharing disclosures.

6. **And** `targetSdk` in `build.gradle.kts` meets Google Play minimum (≥API 34).

7. **And** app category is set to "Santé et remise en forme" or "Productivité".

## Context & Constraints

- **Package name**: `com.mindow.mindow` (already declared in `android/app/build.gradle.kts`).
- **`targetSdk`**: currently `flutter.targetSdkVersion` resolved from Flutter 3.44.1 SDK → API 35. No manual change needed; verify via `flutter doctor`.
- **Privacy policy**: Must be a publicly accessible URL. Covers: user account data, preoccupation text sent to Gemini AI (third-party processor), FCM token for notifications, GDPR export/delete rights (Story 1-7).
- **Data safety**: Google requires explicit declaration of all data collected. Be conservative — when in doubt, declare the data type.
- **Screenshots**: Should show the core value prop (backpack + kg, mission card, garden). Use a French-language device for the primary locale screenshots.

## Manual Checklist

### Step 1: Create the app in Play Console

- [ ] Google Play Console → All apps → Create app
- [ ] App name: `Mindow` (you can set the store listing name differently)
- [ ] Default language: French (France)
- [ ] App type: App
- [ ] Free or paid: Free
- [ ] Agree to Play Console Developer Program Policies

### Step 2: Store listing — French (main)

- [ ] **App name** (≤30 chars): `Mindow — Charge mentale`
- [ ] **Short description** (≤80 chars): `Décharge tes préoccupations. Mindow les pèse et t'aide à alléger ton esprit.`
- [ ] **Full description** (≤4000 chars): craft a full description emphasizing:
  - Capture en moins de 3 secondes
  - L'IA pèse chaque préoccupation en kg
  - Mission du jour = une action à la fois
  - Jardin mental + progression douce
  - Offline-first, sans jugement
- [ ] Upload screenshots (see Step 5)
- [ ] Upload feature graphic (1024×500 px)

### Step 3: Store listing — English (translation)

- [ ] Add English (United States) translation
- [ ] **App name**: `Mindow — Mental Load`
- [ ] **Short description**: `Dump your worries. Mindow weighs them and helps lighten your mind.`
- [ ] **Full description**: equivalent English version

### Step 4: Privacy policy

- [ ] Draft a privacy policy document covering:
  - Data collected: account email, preoccupation text, FCM token
  - Third-party AI processing (Gemini) — data sent to Google AI
  - GDPR rights: export (Settings → Export) + deletion (Settings → Delete account)
  - Data retention and deletion timelines
- [ ] Host it at a public URL (GitHub Pages, Notion public page, or simple static site)
- [ ] Enter the URL in Play Console → App content → Privacy policy

### Step 5: Screenshots

- [ ] Take screenshots on a real Android device (or emulator, portrait 1080×1920 or 2400×1080 landscape)
- [ ] Required screens (minimum 2, recommended 5–8):
  - [ ] Home screen (backpack + kg total)
  - [ ] Mission card (daily mission)
  - [ ] Mental Garden
  - [ ] Capture flow (input field)
  - [ ] Onboarding welcome screen
- [ ] Feature graphic (1024×500 px): Mindow logo on the dawn-gradient canvas

### Step 6: Content rating

- [ ] Play Console → App content → Ratings
- [ ] Complete the IARC questionnaire:
  - Category: Lifestyle / Health
  - No violence, no sexual content, no gambling
  - Contains user-generated content (preoccupations) → declare it
- [ ] Target audience: Adults (18+) or General (depends on questionnaire answers)

### Step 7: Data safety form

- [ ] Play Console → App content → Data safety
- [ ] Declare the following data types:
  | Data type | Collected | Shared | Purpose | Required? |
  |-----------|-----------|--------|---------|-----------|
  | Email address | Yes | No | Account | Yes |
  | User IDs | Yes | No | Sync | Yes |
  | App activity (preoccupations) | Yes | Yes (AI processor) | App functionality | Yes |
  | Device or other IDs (FCM token) | Yes | No | Push notifications | Yes |
- [ ] Mark "Data is encrypted in transit"
- [ ] Mark "Users can request data deletion" (Settings → Delete account)

### Step 8: App category

- [ ] Play Console → Store settings → App category: **Health & Fitness** (Santé et remise en forme)

### Step 9: Final compliance check

- [ ] No medical claims in the description ("Mindow is not a medical device")
- [ ] No financial claims
- [ ] Crisis gate verified (Story 2.3) — app routes to support resources for self-harm content
- [ ] `targetSdk` ≥ 34 verified in `build.gradle.kts`

## Files Created / Modified

> This story has no code changes. All steps are manual Play Console operations.
> Exception: if privacy policy requires a dedicated screen in-app (beyond the Settings link to the URL), that would be a separate story.
