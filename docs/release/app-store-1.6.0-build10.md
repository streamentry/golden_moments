# 1.6.0 build 10 release record (iOS and Android): prepared, not shipped

**State (2026-11-01):** the source and the English and translated store copy
are prepared and checked. **No archive was built, nothing was uploaded and
nothing was submitted.** The iOS archive stopped at code signing, and uploading,
submitting and changing signing each need the maintainer's explicit approval.

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

## What blocked the build

`flutter build ipa --release --build-name=1.6.0 --build-number=10` failed at
code signing on this machine: Xcode reported no account and no provisioning
profile for `com.mindfulness.goldenmoments`. The 1.5.0 record used a temporary
manual signing override that was reverted afterwards. Re-applying it changes
signing, so it needs approval first. The Android bundle needs the upload key
from the backup folder, which also needs approval.

## What the maintainer must decide

1. **Signing.** Approve a temporary signing override for the iOS archive (same
   approach as 1.5.0), or build on a machine that is already signed in.
2. **Upload and submit.** Approve uploading build 10 and submitting version
   1.6.0 with the App Store Connect API, and the matching Android upload.
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
