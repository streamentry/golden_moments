# 1.6.0 build 10 release record (iOS and Android): prepared, not shipped

**State (2026-11-01):** **submitted on both stores, awaiting review.** Build 10
was uploaded and version 1.6.0 submitted at the maintainer's direction; the web
version (website in 20 languages, PR #103) was deployed the same day.

- **iOS:** build 10 uploaded with the App Store Connect API (team key
  `P8ZK4BPD78`), delivery `1d6d4352-0786-4db6-8e80-72b2c948a9ec`, processed
  `VALID`, attached to version 1.6.0 and submitted 2026-10-31 22:42 UTC: review
  submission `ccbc8382-ced0-4c47-ad38-79ce2875d1b5`, read back as **Waiting for
  Review**, release type automatic after approval. 21 App Store localizations
  (name, subtitle, description, keywords, promotional text, "What's New",
  support, marketing and privacy links). App Store Connect first refused the
  submission because the new localizations lacked a support link; the English
  links were copied across. Screenshots were not added for the new languages;
  they use the app's existing screenshots.
- **Android:** version code 10 (`1.6.0 (10)`) committed to the production track at
  full rollout with 23 localized listings and release notes. The bundle in the
  Play library has the same SHA-256 as the local build and was signed with the
  registered upload certificate. Play sends it to review automatically
  (managed publishing is off).

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

## Still open

1. **Approval.** Apple and Google must approve; read the submission state back
   before saying either is live.
2. **Unreviewed translations.** All 19 languages ship unreviewed. Native review
   follows [native review](../engineering/native-review.md); until a language is
   reviewed its website pages stay out of search.
3. **Screenshots per language** and **device checks** (large text, screen reader,
   Arabic right to left) were not done.
4. **After release**, re-run `scripts/store_downloads.py` for several days and
   compare with the first reading of 7 downloads on 2026-10-29 and 8 on
   2026-10-30.
