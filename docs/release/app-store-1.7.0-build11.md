# 1.7.0 build 11 release record (iOS and Android): prepared, not shipped

**State (2026-11-02):** the tree is prepared; **nothing is built, uploaded or
submitted.** Version 1.6.0 (build 10, 20 languages) was submitted on both stores
on 2026-10-31 and, as far as this repository records, is still awaiting review;
check App Store Connect and Play Console before starting 1.7.0 (App Store
Connect takes one version in review at a time, and the 1.6.0 outcome decides
whether 1.7.0 follows or replaces it).

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

## Not done, and gates

- No build: signing, the App Store Connect API key, the Play upload certificate and
  the review submissions are the maintainer's to approve (see the 1.6.0 record).
- Screenshots were not made per language; new languages use the existing ones.
- No device, VoiceOver or TalkBack run in the new languages, and no 200% text
  check; only the iOS simulator (Persian, Bengali, Hausa, Urdu, Tamil, Telugu,
  Punjabi, Romanian, Amharic, Malayalam, Burmese, Sindhi).
- Native review of every language is open: see
  [native review](../engineering/native-review.md). Review the weakest first
  (Hausa, Amharic, Burmese, Pashto, Sindhi, Somali, Oromo).
- `release_metadata.py --release` has not been run (it requires the release gates).

## Checks to run before building

`dart format`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test`,
the Python tests, `python3 scripts/release_metadata.py --check` and
`python3 scripts/store_locales.py --check`, all from the repository root.
