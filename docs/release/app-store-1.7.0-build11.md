# 1.7.0 build 11 release record (iOS and Android): submitted, awaiting review

**State (2026-11-02):** **submitted on both stores, awaiting review, not
approved.** The maintainer approved the upload and submission in chat the same
day. Version 1.6.0 (build 10) read `READY_FOR_SALE` in App Store Connect before
this submission.

- **iOS:** build 11 (1.7.0) validated with `altool --validate-app` (no errors),
  uploaded with the App Store Connect API (team key `P8ZK4BPD78`), delivery
  `37d9ab13-c285-4350-aef8-1995b8567523`, processed `VALID`, attached to
  version 1.7.0 (id `cf6325f4-483e-4c56-9d17-f6fc4b9ed541`) and submitted
  2026-11-02 14:06 UTC: review submission
  `69e52648-4a9b-452d-a4b7-0e9faf034262`, read back as **Waiting for Review**,
  release type automatic after approval. 34 App Store localizations: the 22 of
  1.6.0 (new "What's New" in each) plus 12 new ones (bn-BD, gu-IN, kn-IN, ml-IN,
  mr-IN, ms, or-IN, pa-IN, ro, ta-IN, te-IN, ur-PK) with description, keywords,
  promotional text, name and subtitle; the English support and marketing links
  were copied. New languages use the English screenshots. Apple's review
  submission call returned HTTP 500 for several minutes and then succeeded.
- **Android:** version code 11 (`1.7.0 (11)`) uploaded with the Play Developer
  API and committed to the production track at full rollout with 43 localized
  listings (English plus 42 locales) and 43 release notes (edit
  `09244861507928311260`). Managed publishing is off, so Play sends it to review
  automatically. The bundle in the Play library has the same SHA-256 as the
  local build.

## Why this release

The app, picture-pack text, photo permission text and store copy now exist in
**50 languages** (51 locales; Chinese counts once): the 20 in 1.6.0 plus 31 more
(Bengali, Urdu, Marathi, Telugu, Swahili, Hausa, Punjabi, Filipino, Tamil,
Persian, Amharic, Javanese, Gujarati, Kannada, Yoruba, Pashto, Malay, Oromo,
Burmese, Malayalam, Sindhi, Odia, Uzbek, Igbo, Sundanese, Zulu, Azerbaijani,
Somali, Assamese, Romanian and Nepali). All are machine translations, unreviewed
by maintainer decision (2026-10-31 and 2026-11-01); the release notes say so.
Nothing in the English app changed except the version and the notes.

## What changed in the tree

- `pubspec.yaml` and `lib/shared/utils/support_info.dart`: 1.7.0+11 (a test keeps
  the two in step).
- English release notes in `metadata/app-store.en-US.json` and
  `metadata/google-play.en-US.json` (identical), exports regenerated;
  `candidate_version` 1.7.0 and the Play release state.
- `metadata/i18n/<language>.json`: the "What's New" notes translated for all 50
  language files, checked by `scripts/store_locales.py`.
- The store listings themselves (name, subtitle, keywords, description) for the 31
  new languages were already written and checked with the languages (PRs #116
  to #122).

## Store locales (what can actually be listed)

`python3 scripts/store_locales.py --list` is the source of truth. Of the 31 new
languages, as the files record them:

- **Both stores:** Bengali, Urdu, Marathi, Telugu, Tamil, Gujarati, Punjabi,
  Kannada, Malayalam, Romanian and Malay.
- **Google Play only:** Persian, Filipino, Swahili, Nepali, Azerbaijani, Amharic,
  Burmese (`my-MM`) and Zulu (`zu`).
- **App Store only:** Odia (`or-IN`).
- **Neither store:** Hausa, Uzbek, Assamese, Pashto, Yoruba, Igbo, Somali, Oromo,
  Javanese, Sundanese and Sindhi. Their listing text is a draft that cannot be
  uploaded; the app itself is still available in them.

The 1.6.0 languages keep the locales listed in the same command.

## Artifacts

- iOS: built with `flutter build ipa --release --build-name=1.7.0
  --build-number=11` and `backups/golden-moments-ios-20261018/ExportOptions.plist`
  with the same temporary signing override as 1.5.0 and 1.6.0 (team
  `7MBXZKYSY4`, manual signing, profile `Golden Moments App Store 2026-10-18`,
  Runner Release only), reverted with git afterwards. `codesign --verify --deep
  --strict` passed; bundle `com.mindfulness.goldenmoments`, 1.7.0 (11), minimum
  iOS 15; all nine plugin frameworks embedded; `CFBundleLocalizations` lists all
  50 language codes plus English. IPA 35,221,011 bytes; SHA-256
  `3f8a476b255b0233c7a6566329b195dd1df58616b12ae4534f5a199fc65edbe7`. Local copy
  `output/release/ipa-1.7.0-11/` (not committed).
- Android: built with the backup wrapper (`flutter build appbundle --release
  --flavor production --build-name=1.7.0 --build-number=11`). Signer SHA-256
  `B5:3D:D5:57:…:D0:40:F7:2F`, the registered upload certificate. AAB
  78,270,956 bytes; SHA-256
  `be3662a90d35e3b55c3b2cdbe26d276d793f6eab6dd24d7b54ab4eeaadda38a0`. Local copy
  `output/release/android-1.7.0-11/` (not committed).
- Checks on the release tree: `flutter analyze --fatal-infos --fatal-warnings`
  clean, `dart format` no changes, `flutter test` all passed, Python tests and
  `store_locales.py` / `release_metadata.py` `--check` passed.

## Still open

- **Approval.** Apple and Google must approve; read the submission state back
  before saying either is live.
- Screenshots were not made per language; new languages use the existing ones.
- No device, VoiceOver or TalkBack run in the new languages, and no 200% text
  check; only the iOS simulator (Persian, Bengali, Hausa, Urdu, Tamil, Telugu,
  Punjabi, Romanian, Amharic, Malayalam, Burmese, Sindhi).
- Native review of every language is open: see
  [native review](../engineering/native-review.md). Review the weakest first
  (Hausa, Amharic, Burmese, Pashto, Sindhi, Somali, Oromo).
- `release_metadata.py --release` was not run (it requires the release gates).
- A launch of the signed iOS build and the Android bundle on a device was not run.

## Checks to run before building

`dart format`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test`,
the Python tests, `python3 scripts/release_metadata.py --check` and
`python3 scripts/store_locales.py --check`, all from the repository root.
