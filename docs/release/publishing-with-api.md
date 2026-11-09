# Publishing to the App Store and Google Play with keys and APIs

How 1.5.0 to 1.9.0 were built, uploaded and submitted. Do this only when the
maintainer asks for a release: a request to edit code does not authorize
uploading, submitting or changing store settings. Record each release in
`docs/release/app-store-<version>-build<N>.md` and read both stores back before
saying anything is live.

## Credentials (never commit, print or paste them)

| What | Where |
| --- | --- |
| App Store Connect API key (team key, App Manager) | `~/.appstoreconnect/private_keys/AuthKey_2HR347AH8Q.p8` |
| Its issuer ID | in the key backup notes `lumi-keys-backups/README.md` (next to the keys); not a secret on its own, but keep it out of commits |
| iOS distribution cert and profile | Cloudjet distribution key in the login keychain; profile `Golden Moments App Store 2026-10-18` in `backups/golden-moments-ios-20261018/` (install by copying to `~/Library/MobileDevice/Provisioning Profiles/<UUID>.mobileprovision`) |
| Android upload keystore | `backups/golden-moments-android-20261018/` (alias `golden-moments-upload`; `build-android.sh` reads the password) |
| Google Play API service account | `play-store-upload@…iam.gserviceaccount.com`, JSON in `lumi-keys-backups/` (has Golden Moments permission since 2026-10-30) |

If a path above has moved, search the key backup folders before asking.

## 1. Prepare

1. Version bump in `pubspec.yaml` and `lib/shared/utils/support_info.dart`
   (`appVersion`); new `release_notes` in `metadata/app-store.en-US.json` and
   `metadata/google-play.en-US.json`; copy to `metadata/i18n/*.json`;
   run `python3 scripts/release_metadata.py --write` then `--check` and
   `python3 scripts/store_locales.py --check`. Merge through a PR.
2. Build from a clean `git worktree` of the release branch, never the main
   checkout (other sessions commit there).

## 2. Build

- **Android:** `sh backups/golden-moments-android-20261018/build-android.sh <worktree>`.
  Check the signer with `keytool -printcert -jarfile <aab>`; it must be the
  registered upload certificate (SHA-256 `B5:3D:D5:57:…:F7:2F`).
- **iOS:** `flutter build ios --release --no-codesign --config-only`, then set
  the Runner **Release** configuration in the worktree only to manual signing
  (team `7MBXZKYSY4`, `iPhone Distribution`, the profile name above) and run
  `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -archivePath build/Runner.xcarchive archive`
  then `xcodebuild -exportArchive` with `backups/golden-moments-ios-20261018/ExportOptions.plist`.
  Do not pass signing overrides on the command line: the Pods targets reject
  provisioning profiles. Do not commit the signing edit.
- Verify: `codesign --verify --deep --strict` on the unzipped app, version and
  build in `Info.plist`, SHA-256 of both artifacts.

## 3. App Store Connect (API)

1. `xcrun altool --validate-app` then `--upload-app -f <ipa> -t ios --apiKey <KEY_ID> --apiIssuer <ISSUER>`.
2. Wait until the build is `VALID` (`GET /v1/builds?filter[app]=<appId>&filter[version]=<build>`).
   The app id is in `scripts/store_downloads.py` notes and the earlier release records.
3. `POST /v1/appStoreVersions` (versionString, platform IOS, `releaseType` AUTOMATIC),
   attach the build (`PATCH .../relationships/build`).
4. Set `whatsNew` (and `promotionalText`) on **every** `appStoreVersionLocalizations`
   entry: a new version copies description and keywords but not these.
5. Submit: create a `reviewSubmissions` for the app, add the version as a
   `reviewSubmissionItems`, then PATCH `submitted: true`. Only one version may
   be in review at a time. Read the state back.
6. JWT: ES256, header `kid`, claims `iss`, `iat`, `exp` (max 20 minutes),
   `aud: appstoreconnect-v1`. `scripts/store_downloads.py` shows the signing code.

## 4. Google Play (API)

Use the Android Publisher API (`androidpublisher` v3) with the service account:
create an edit, upload the AAB (`edits.bundles.upload`), assign it to the
`production` track with release notes for every listing locale (per-locale
notes from `metadata/i18n`, en-US otherwise), then `edits.commit`. Managed
publishing is off, so Play sends the change for review. Read the track back.
Store settings such as the category are not in the API; use the console.

## 5. Record

Add `docs/release/app-store-<version>-build<N>.md` (commit, hashes, delivery and
submission ids, notes, what is still open). Approval, device checks and
`release_metadata.py --release` gates stay open until evidenced.
