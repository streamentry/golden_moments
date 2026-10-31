# 1.5.0 build 9 release record (iOS and Android)

**State (2026-10-31):**

- **iOS:** build 9 uploaded with the App Store Connect API (team key
  `P8ZK4BPD78`, at the maintainer's direction), processed `VALID`, attached to
  version 1.5.0 and submitted on 2026-10-30 14:29 UTC: review submission
  `6ac69151-97e3-42d6-80e6-79dd2825cc54`, read back as **Waiting for Review**,
  release type automatic after approval.
- **Android:** version code 9 uploaded with the Play Developer API and committed
  to the production track as `1.5.0 (9)`, full rollout, en-US release notes.
  Managed publishing is off: Play Console showed pre-review checks running,
  after which the change goes to review and publishes on approval.

**Update (2026-10-31):** Apple approved 1.5.0 and released it automatically.
App Store Connect reads `READY_FOR_SALE`, and the public US lookup shows
version 1.5.0 released 2026-10-30 19:35 UTC (0 ratings at that time). Google
Play still served 1.4.0 publicly; the Android release was not yet confirmed as
approved.

## Why this release

Growth pass from PR #95: Apple's rating prompt at a voluntary pause and a Rate
link on Help (GM-034), opt-in iOS reminders (GM-038), the App Store link in
iPhone shares, and new keywords and promotional text. The live 1.4.1 listing
showed no ratings and an age rating of 16+ on 2026-10-30.

## Source and checks

Built from main `7f54bd5` (merge of PR #95). PR #95 CI: build, design-system,
gentle-activities, release-metadata, web-visual and semantic PR passed;
spell-check failed on words inherited from the 1.4.1 record and is fixed in
PR #96 (Markdown only, no effect on the binary).

- Flutter 3.47.7; Xcode 27.1; minimum iOS 15. `flutter analyze --fatal-infos
  --fatal-warnings`: no issues on the release tree. PR head: 450 Flutter tests,
  64 Python tests, metadata check, DESIGN.md lint 0/0.
- The temporary signing override from the 1.4.1 record (team `7MBXZKYSY4`,
  manual signing, profile `Golden Moments App Store 2026-10-18`, Runner Release
  only) was applied for `flutter build ipa` and reverted afterwards.

## Artifact

- `codesign --verify --deep --strict`: passed; TeamIdentifier `7MBXZKYSY4`.
  Bundle `com.mindfulness.goldenmoments`, 1.5.0 (9).
- Embedded frameworks: App, Flutter, audioplayers_darwin, image_picker_ios,
  integration_test, objective_c, share_plus, shared_preferences_foundation,
  url_launcher_ios. The Dart snapshot contains the `golden_moments/native`
  channel.
- IPA 33,330,453 bytes; SHA-256
  `d47c2e69df8a2c92dd99b4c4f23e1746ec6ebd3be9b9abf3f1991c74d8f6ad5c`.
  Local copy: `output/release/ipa-1.5.0-9/` (not committed).
- `altool --validate-app`: no errors. Upload delivery
  `4b34d226-8a59-457a-80f5-eab09df91a5c`.
- Not run: a launch of the signed build on a device.

## Android artifact

- Built with the backup wrapper (`flutter build appbundle --release --flavor
  production --build-name=1.5.0 --build-number=9`) and the replacement upload
  key from `backups/golden-moments-android-20261018/`.
- Signer SHA-256 `B5:3D:D5:57:…:D0:40:F7:2F`, the registered upload
  certificate. AAB 70,704,538 bytes; SHA-256
  `5e12f8a4051c6c4ac77d4d3c84e91fa88f3d82d1ac40b62cc960a357dbb2b233`, the same
  value Play reported for version code 9. Local copy
  `output/release/android-1.5.0-9/` (not committed).
- Reminders are hidden on Android; Rate opens the Play listing. Not run: an
  emulator or device smoke test of this bundle.
- The Play service account `play-store-upload@…` was given Golden Moments
  permissions in Play Console on 2026-10-30, matching its access to the
  account's other apps.

## Store metadata to save with 1.5.0

From `metadata/en-US/`: release notes, keywords
(`memory,seniors,elderly,…,nostalgia`, 99 bytes) and promotional text.
Saved through the API and read back. Description, screenshots, URLs and
review notes carried over from 1.4.1.

Age rating: Apple required the new "social media" answer before submission;
it was set to No (no in-app social features). At the maintainer's choice the
advertising and unrestricted-web-access answers stay Yes, so the rating stays
16+ (shown by the API as `SEVENTEEN_PLUS`).

## Remaining release evidence

Simulator only: the rating sheet on Home after a finished game and the
notification question after "Turn on reminder" (`docs/release/evidence/1.5.0/`).
Pending: a physical-device run including a reminder firing, VoiceOver on the
reminder page, an Android build, and the evidence still open since 1.4.0.
