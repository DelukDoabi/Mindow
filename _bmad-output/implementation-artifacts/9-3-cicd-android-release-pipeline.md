---
baseline_commit: b965d11
---

# Story 9.3: CI/CD Android release pipeline (tag-triggered)

Status: review

## Story

As a developer,
I want a GitHub Actions workflow that automatically builds and uploads a signed AAB to
Google Play on every version tag,
So that releasing a new version is a single `git tag v1.0.0 && git push --tags` command.

## Acceptance Criteria

1. **Given** a Git tag matching `v*.*.*` is pushed to `main`
   **When** the `deploy-android.yml` workflow triggers
   **Then** it checks out the code, sets up Java 17 + Flutter 3.44.1, injects `FIREBASE_OPTIONS_B64`, and reconstructs `android/key.properties` from CI secrets.

2. **And** it runs `flutter build appbundle --flavor prod -t lib/main_prod.dart --release --build-number ${{ github.run_number }}` and exits 0.

3. **And** it uploads the resulting AAB (`build/app/outputs/bundle/prodRelease/app-prod-release.aab`) to the Google Play **internal** track using `r0adkll/upload-google-play@v1` with a service account JSON secret `PLAY_SERVICE_ACCOUNT_JSON`.

4. **And** the workflow fails fast (non-zero exit) if any required secret is missing or if the build fails.

5. **And** `versionCode` is `${{ github.run_number }}` (auto-incrementing, never collides with previous Play Store uploads) — passed via `--build-number`.

6. **And** the existing `ci.yml` (analyze + test) remains unchanged and still runs on every push/PR.

## Context & Constraints

- **Story 9.1 prerequisite**: `build.gradle.kts` must have the `signingConfigs.release` block in place before this workflow runs.
- **Story 9.2 prerequisite**: `FIREBASE_SERVICE_ACCOUNT_JSON` and `GEMINI_API_KEY` must be
  set as Supabase Edge Function secrets before the first tag-triggered deploy can serve real
  users end-to-end. The CI workflow itself does not depend on these secrets directly.
- **`r0adkll/upload-google-play@v1`** requires:
  - A Google Play service account with the "Release manager" role on the app
  - The service account JSON exported and stored as `PLAY_SERVICE_ACCOUNT_JSON` GitHub Actions secret
  - The app must already exist in Play Console (package name `com.mindow.mindow`, created before first upload)
  - Guide: https://github.com/r0adkll/upload-google-play#service-account-setup
- **Java 17** is required by AGP 9.0.1 + Kotlin 2.3.20.
- **`FIREBASE_OPTIONS_B64`** already exists as a GitHub Actions secret (used in `ci.yml`).
- **Keystore reconstruction**: the keystore file is base64-encoded as `UPLOAD_KEYSTORE_B64` and must be decoded to a file that `key.properties` points to.
- **`android/key.properties` path convention**: `storeFile` in `key.properties` must be a path that `build.gradle.kts` can resolve from the `android/app/` directory. Use an absolute path reconstructed in CI (e.g. `${{ github.workspace }}/mindow-upload-key.jks`).
- `flutter gen-l10n` and `dart run build_runner build` must run before the AAB build (same as in CI).
- No code obfuscation / minification in v1 (can be added later). No `proguard-rules.pro` changes needed.

## Implementation: `.github/workflows/deploy-android.yml`

See the created file. Key decisions:
- `workflow_dispatch` is also included so the release can be triggered manually if needed.
- `versionName` = the tag name (e.g. `1.0.0`), passed via `--build-name`.
- The keystore is written to `$RUNNER_TEMP/mindow-upload-key.jks` (cleaned up automatically after job).
- `key.properties` is written to `android/key.properties` pointing to the temp keystore.

## Manual Prerequisites (before first deploy)

### Create a Google Play service account

1. Go to Google Play Console → Setup → API access
2. Link to a Google Cloud project (create one if needed)
3. In Google Cloud Console → IAM & Admin → Service Accounts → Create service account
4. Grant it the "Release manager" role in Play Console → Users & permissions
5. Create a JSON key → download → paste content as `PLAY_SERVICE_ACCOUNT_JSON` in GitHub Actions secrets

### Create the app in Play Console

- Package name: `com.mindow.mindow`
- The app must be manually created (Google requires at least one manual upload for new apps)
- Upload an initial AAB manually to unlock the API for subsequent uploads

## Files Created / Modified

| File | Action |
|------|--------|
| `.github/workflows/deploy-android.yml` | Created — tag-triggered Android release CI/CD |
