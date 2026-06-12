---
baseline_commit: b965d11
---

# Story 9.1: Android release signing & keystore CI integration

Status: review

## Story

As a developer,
I want a production upload keystore wired into CI,
So that every release build is signed with the production key and is uploadable to Google Play.

## Acceptance Criteria

1. **Given** a production upload keystore generated with `keytool -genkey -v -keystore mindow-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mindow`
   **When** the CI pipeline builds the `prodRelease` flavor
   **Then** `android/app/build.gradle.kts` uses a `signingConfigs.release` block that reads `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` from `android/key.properties` (gitignored).

2. **And** `android/key.properties` is populated (in CI) from four GitHub Actions secrets: `UPLOAD_KEYSTORE_B64`, `UPLOAD_KEYSTORE_PASSWORD`, `UPLOAD_KEY_ALIAS`, `UPLOAD_KEY_PASSWORD`.

3. **And** the `buildTypes.release.signingConfig` no longer references `signingConfigs.debug` (the TODO comment is removed).

4. **And** `flutter build appbundle --flavor prod -t lib/main_prod.dart` exits 0 in CI and produces the signed AAB.

5. **And** the debug signing key is NOT used for any production build (falls back to debug only when `key.properties` is absent locally).

## Context & Constraints

- `android/.gitignore` already contains `key.properties` and `**/*.jks` — the keystore file must NEVER be committed.
- `versionCode` uses `flutter.versionCode` which is driven by `--build-number` flag at build time; CI passes `${{ github.run_number }}` as the build number so it auto-increments.
- `targetSdk = flutter.targetSdkVersion` — currently resolved from flutter SDK (≥34 as of Flutter 3.44.1). No manual override needed.
- This story ONLY touches `android/app/build.gradle.kts`. The CI workflow that calls the build is Story 9.3.
- Key generation is a one-time manual step — see Manual Steps section below.

## Implementation Plan

### Changes to `android/app/build.gradle.kts`

1. Add `java.util.Properties` import and load `key.properties` from `rootProject.file("key.properties")`.
2. Add a `signingConfigs.create("release")` block that reads the 4 properties (conditional on file existing).
3. Update `buildTypes.release.signingConfig` to use `signingConfigs.getByName("release")` when the file exists, else fall back to `"debug"` for local developer convenience.
4. Remove the TODO comment.

### Manual Steps (one-time, before Story 9.3)

```powershell
# 1. Generate the keystore (run ONCE locally, store securely)
keytool -genkey -v -keystore mindow-upload-key.jks `
  -keyalg RSA -keysize 2048 -validity 10000 -alias mindow

# 2. Create android/key.properties (gitignored — never commit)
@"
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=mindow
storeFile=../../mindow-upload-key.jks
"@ | Set-Content android/key.properties

# 3. Base64-encode the keystore for the CI secret
[Convert]::ToBase64String([IO.File]::ReadAllBytes("mindow-upload-key.jks")) | clip
# Paste the clipboard value as UPLOAD_KEYSTORE_B64 in GitHub → Settings → Secrets → Actions

# 4. Add the other 3 secrets in GitHub Actions:
#    UPLOAD_KEYSTORE_PASSWORD = <store-password>
#    UPLOAD_KEY_ALIAS         = mindow
#    UPLOAD_KEY_PASSWORD      = <key-password>
```

## Files Modified

| File | Action |
|------|--------|
| `android/app/build.gradle.kts` | Modified — release signing config from key.properties |
