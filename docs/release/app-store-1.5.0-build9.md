# iOS 1.5.0 build 9 release record

**State (2026-10-30):** a signed App Store IPA is built and verified locally. It
is **not uploaded**. The maintainer chose to upload it with Transporter; after
that, version 1.5.0 is created in App Store Connect with the canonical metadata
and submitted for review. This is not Apple approval or storefront availability.

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
- Not run: `altool --validate-app` (no issuer ID available on this Mac;
  Transporter validates on delivery) and a launch of the signed build.

## Store metadata to save with 1.5.0

From `metadata/en-US/`: release notes, keywords
(`memory,seniors,elderly,…,nostalgia`, 99 bytes) and promotional text.
Description, screenshots, URLs and review notes carry over from 1.4.1. The
maintainer re-answers the age-rating questionnaire (currently 16+).

## Remaining release evidence

Simulator only: the rating sheet on Home after a finished game and the
notification question after "Turn on reminder" (`docs/release/evidence/1.5.0/`).
Pending: a physical-device run including a reminder firing, VoiceOver on the
reminder page, an Android build, and the evidence still open since 1.4.0.
