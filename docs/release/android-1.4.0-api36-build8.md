# Android 1.4.0 API 36 candidate — version code 8

**State (2026-10-21):** Google Play accepted the signed App Bundle in the
production release `1.4.0 (8)` and reports target SDK 36, minimum SDK 24 and
three ABIs. The release is saved for a full rollout but is not submitted yet:
publishing checks still report an incomplete Advertising ID declaration even
though the declaration is saved as No and App content lists it as actioned.
Fresh checks completed with the same issue. A fresh declaration page and an
explicit resave both confirm No; the review-submission button remains disabled.

The Play Console policy page supplied by the maintainer reported an update in
review and the issue “App must target Android 16 (API level 36) or higher.”
Google requires API 36 for app updates submitted from August 31, 2026. The
project now pins both `compileSdkVersion` and `targetSdkVersion` to 36. Android
Gradle Plugin 8.11.1 supports API 36; the documented minimum is 8.9.1.

The app identity is unchanged: `com.mindfulness.golden_moments`. The candidate
uses version name `1.4.0` and version code `8`, supplied to Flutter at build
time so the iOS build number remains independent.

## Build and signing evidence

- Toolchain: Flutter 3.47.7, Dart 3.13.5, JDK 24.0.1, Android SDK/build tools
  36.0.0, Gradle 8.14.3, Android Gradle Plugin 8.11.1, Kotlin plugin 2.2.20.
- Production App Bundle: `output/release/android-1.4.0-api36-build8/app-production-release.aab`
- SHA-256: `01c68adbd0bf1f36db327c0b80d26c6c4f36491cbda8cbe7a867886adb51a4e2`
- The packaged release manifest reports package
  `com.mindfulness.golden_moments`, `versionName="1.4.0"`, `versionCode="8"`,
  `minSdkVersion="24"` and `targetSdkVersion="36"`.
- The Android bundle signature verifies successfully. The AAB signer SHA-256 is
  `B5:3D:D5:57:47:0A:BC:E1:31:6E:53:FD:9F:30:6C:82:72:69:16:0B:F2:37:B4:96:EB:3C:C7:95:D0:40:F7:2F`, matching the replacement upload certificate recorded in the protected Android backup.

## Validation

- `dart format --output=none --set-exit-if-changed lib test` — passed; 127 files
  checked, none changed.
- `flutter analyze --fatal-infos --fatal-warnings --no-pub` — passed with no
  issues.
- `flutter test --coverage --no-pub --no-dds` — 430 tests passed. The default
  test run's local VM-service WebSocket was reset by the execution sandbox, so
  the passing run bypassed Flutter's development-service proxy.
- Python unit tests — 64 passed. `python3 scripts/release_metadata.py --check`
  — valid.
- Android 16 (API 36) Pixel emulator smoke test: the signed version-code 8 APK
  installed; the app launched and rendered the home screen; tapping “Start a
  gentle game” opened the four-tile board. No Android runtime exception appeared
  in the filtered Android runtime logs. Synthetic emulator captures are kept beside the
  AAB as `emulator-home-smoke.png` and `emulator-board-smoke.png`; these are QA
  evidence, not store screenshots.

## Google Play submission gate

The replacement upload-key reset was scheduled for **2026-10-20 13:38 UTC
(20:38 Vietnam time)**. The built-in Browser was used for the upload on October
21. Google Play processed and accepted the bundle signed by the replacement
key without a certificate error. The certificate-copy/download controls did not
yield a usable direct fingerprint readback; acceptance of the signed bundle is
the recorded key-validation evidence.

The outdated Advertising ID answer was corrected from Yes to No. The production
manifest contains no Advertising ID permission, Firebase/advertising SDKs are
removed, and the existing Ads declaration already says No. App content reports
no declarations needing attention and Advertising ID ready to send for review.
Publishing overview still reports the incomplete-declaration issue after fresh
checks and an explicit resave of No. This contradiction must clear before the
release can be submitted; no review submission is claimed.

Managed publishing remains on, so an approved Android update will need a final
publication action. The reviewed US-English release notes are saved. Phone
screenshots are also queued for review; the earlier name and description edits
remain in review.

Play reports two non-blocking warnings: 1,160 previously supported device models
are no longer supported, and delivered APK size increases. The new artifact has
minimum SDK 24 and three ABIs, compared with SDK 23 and four ABIs in 1.2.0.
Estimated delivery is 22.4 MB for a new install and 12.6 MB for an update. These
warnings are recorded, not hidden or marked resolved.

The sanitized receipt is `output/release/store-status-2026-10-21.json`.
Google Play's target API requirement is documented at
[Target API level requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en).

Build the release without `--no-pub`; Flutter must regenerate the production
plugin registry before the Android release task.
