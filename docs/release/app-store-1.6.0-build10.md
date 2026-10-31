# 1.6.0 build 10 release record (iOS and Android): prepared, not shipped

**State (2026-11-01):** the source and the English and translated store copy
are prepared and checked, and the **iOS archive is built and verified locally**.
**Nothing was uploaded or submitted.** The maintainer approved the temporary
signing override on 2026-11-01; uploading, submitting and the Android build
still need their own approval. The web version of this release (website in 20
languages, PR #103) was deployed on 2026-11-01 at the maintainer's request.

## Why this release

The app, picture-pack text, photo permission text and store copy now exist in
20 languages (English plus 19 machine translations), by maintainer decision
(2026-10-31, GM-036). All 19 translations are unreviewed; the English release
notes say so. Nothing in the English app changed except the version.

## What changed in the tree

- `pubspec.yaml` and `lib/shared/utils/support_info.dart`: 1.6.0+10 (a test
  keeps the two in step).
- English release notes in `metadata/app-store.en-US.json` and
  `metadata/google-play.en-US.json` (identical), exports regenerated.
- `candidate_version` 1.6.0 and the Play release state.
- `metadata/i18n/<language>.json`: store listings and "What's New" notes for all
  19 languages, checked by `scripts/store_locales.py`.

## Checks run on this tree

- `dart format`: no changes. `flutter analyze --fatal-infos --fatal-warnings`:
  no issues. `flutter test`: 528 tests passed.
- Python: 94 tests passed, including the store listing and review status tests.
- `python3 scripts/release_metadata.py --check` and
  `python3 scripts/store_locales.py --check`: passed (19 of 19 languages).
- Not run: `release_metadata.py --release` (it requires the release gates),
  a launch of any build on a device, screen reader or large text checks in the
  translated languages, and Arabic right-to-left checks on a device.

## iOS artifact

- `flutter build ipa --release --build-name=1.6.0 --build-number=10` first failed
  at code signing (no account or profile in Xcode). With the maintainer's
  approval it was rebuilt with the same temporary override as 1.5.0: Runner
  Release only, manual signing, team `7MBXZKYSY4`, distribution identity and
  profile `Golden Moments App Store 2026-10-18` (valid to 2027-09-08). The
  override was applied to `ios/Runner.xcodeproj/project.pbxproj` and reverted
  with git afterwards; the committed project is unchanged.
- `codesign --verify --deep --strict`: passed; TeamIdentifier `7MBXZKYSY4`.
  Bundle `com.mindfulness.goldenmoments`, 1.6.0 (10), minimum iOS 15.
  `CFBundleLocalizations` lists all 20 languages, and each has its `.lproj`
  folder with `InfoPlist.strings`.
- IPA 33,936,577 bytes; SHA-256
  `8069b645eaa232aef5f48182c4eac21430b4e21b9b41d103284671789d8c742c`. Local copy
  `output/release/ipa-1.6.0-10/` (not committed).
- Not run: `altool --validate-app` (it sends the binary to Apple), a launch of
  the signed build on a device, and the Android bundle (needs the upload key
  from the backup folder).

## What the maintainer must decide

1. **Upload and submit.** Approve uploading build 10 and submitting version
   1.6.0 with the App Store Connect API (team key `P8ZK4BPD78`, as for 1.5.0),
   and the matching Android build and upload.
2. **Android.** Approve using the upload key from the backup folder to build
   the bundle.
3. **Localized listings.** Approve creating the 19 App Store localizations and
   Google Play listings from `metadata/i18n`. App Store Connect needs "What's
   New" text for every added language (prepared) and decisions about screenshots
   for each language (the screenshots are still English).
4. **The unreviewed caveat.** The translations ship unreviewed. Native review
   follows [native review](../engineering/native-review.md); until a language is
   reviewed its website pages stay out of search.

## After release

Re-run `scripts/store_downloads.py` for several days and compare with the first
reading of 7 downloads on 2026-10-29 and 8 on 2026-10-30. Keep this record up to
date with the real upload and submission details if the release goes ahead.
