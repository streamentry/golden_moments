# 1.10.0 build 14 release record (iOS and Android): submitted, awaiting review

**State (2026-11-12):** submitted on both stores, not approved. Read both stores back
before saying either is live. Steps are in [publishing-with-api.md](publishing-with-api.md).

## Content

- Built from `main` at `a53c390b` (version bump in `e8aa6b80`).
- Mobile visual audit: clearer screens for playing together, the first picture game
  spreads each pair apart, Look together no longer counts the pictures.
- Text follows the phone's size from 100% to 200%; Plan my day, Daily moment and other
  pages fit better with large text.
- Today help numbers are labelled for the U.S., with a note to use a local number elsewhere.
- Locale release notes use the English text until translated, as in 1.9.0.

## Checks on the built commit

- `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos --fatal-warnings`:
  clean. `flutter test -j 1`: 698 passed. Python unit tests: OK.
- `release_metadata.py --check` and `store_locales.py --check` (64 of 64): passed.
- CI on `a53c390b`: build and spell-check passed; `web-visual` (browser catalog
  screenshots) failed on a timeout, which does not cover the mobile app.

## iOS

- Version 1.10.0 (build 14), bundle `com.mindfulness.goldenmoments`. Built in a detached
  worktree with manual signing set only there (team `7MBXZKYSY4`, profile
  `Golden Moments App Store 2026-10-18`).
- IPA SHA-256 `c3c53029ac469532683997f922c2bb42154a30f797de529b782490c533a2e73c`.
  `codesign --verify --deep --strict` passed; Info.plist shows 1.10.0 (14).
- `altool --validate-app` and `--upload-app` reported no errors (delivery
  `9a932ece-1992-4430-84a9-d80eea1e6524`); build processed `VALID`.
- App Store version `9dcc8b86-fbfe-4160-98b5-0efdb60a09b9`, build attached, release
  after approval. What's New set on all 34 localizations; promotional text copied from
  1.9.0. Review submission `950f4b4f-c16b-4d78-865f-7ecbd10ec122`: `WAITING_FOR_REVIEW`.
  1.9.0 was `READY_FOR_SALE` before this.

## Android

- Version 1.10.0 (version code 14), package `com.mindfulness.golden_moments`.
- AAB SHA-256 `75f7edf7c681a6e602c27d5d08ae56ed84bbf83ba052112e03e355441f7acd0e`;
  Play reported the same hash. Signer is the registered upload certificate.
- Production track release `1.10.0 (14)`, status `completed`, notes for all 43 listing
  locales; edit `13303867267223980714` committed. Managed publishing is off, so Play
  reviews it automatically.

## Still open

Apple and Google approval; wellbeing and device checks; `medical_claims_review`;
accessibility device review at 200% text on real devices; native review of the
translations; `release_metadata.py --release` gates.
