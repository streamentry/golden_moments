# 1.11.0 build 15 release record (iOS and Android): submitted, awaiting review

**State (2026-11-28):** submitted on both stores, not approved. Read both stores
back before saying either is live. Steps are in
[publishing-with-api.md](publishing-with-api.md).

## Content

- Reminders pick from 50 calm lines on the device (`docs/retention/nudges.md`):
  no line returns within 21 days, a skip line at most once a week, slow-down
  and last-note lines. iOS only, opt-in, as before.
- Home shows one of those lines under Today's activity, on every platform.
- New strings in all 116 translated app languages, machine-made and unreviewed.
- Release notes: English in every listing, as in 1.10.0
  (`metadata/app-store.en-US.json`, `metadata/google-play.en-US.json`).

## Checks on the built commit

- Built from `main` at `f9574804`. App code (`lib`, `test`, `ios`, `android`,
  `pubspec.*`) is identical to the #313 merge `42613dd4`; later commits touch
  only the website.
- CI on #313: build, gentle-activities, design-system, release-metadata,
  web-visual, spell-check passed; `app-copy-coverage` failed under the recorded
  maintainer exception (WORKBOARD, 2026-11-28).
- Local, Flutter 3.47.7: `dart format --set-exit-if-changed` clean;
  `flutter analyze --fatal-infos --fatal-warnings` no issues;
  `flutter test -j 1`: 763 passed; Python unit tests 150 OK.
- `release_metadata.py --check` passed; `store_locales.py --check` 115 of 115.

## iOS

- Version 1.11.0 (build 15), bundle `com.mindfulness.goldenmoments`. Built in a
  detached worktree with manual signing set only there (team `7MBXZKYSY4`,
  profile `Golden Moments App Store 2026-10-18`).
- IPA SHA-256 `4825512b73068019a610e8f5c5bebece8b3f26a4a74c1d38fc93f46922eb0569`.
  `codesign --verify --deep --strict` passed; Info.plist shows 1.11.0 (15);
  signed by iPhone Distribution (7MBXZKYSY4).
- `altool --validate-app` and `--upload-app` reported no errors (delivery
  `a10d639b-25b7-45b9-8e71-3f0325418974`); build processed `VALID`,
  `usesNonExemptEncryption` false.
- App Store version `787c053d-1aa6-4277-82d2-47f7ccb90844`, build attached,
  release after approval. What's New set on all 34 localizations; promotional
  text kept exactly as in 1.10.0 (translated in 12 locales, empty in the rest).
  Review submission `95d7edeb-b549-4b51-9723-81a7a4e948ca`: `WAITING_FOR_REVIEW`.
  1.10.0 was `READY_FOR_SALE` before this.

## Android

- Version 1.11.0 (version code 15), package `com.mindfulness.golden_moments`.
- AAB SHA-256 `0d48e99dcf9635becbbaf4919f48d90b4a94db7d8ba301936735483b8993b1ba`;
  Play reported the same hash. Signer is the registered upload certificate
  (`B5:3D:D5:57:…:F7:2F`).
- Production track release `1.11.0 (15)`, status `completed`, notes for all 43
  listing locales; edit `12095852607426174260` committed. Managed publishing is
  off, so Play reviews it automatically. 1.10.0 (14) was `completed` before this.

## Still open

Apple and Google approval. The device checks this record asked for before upload
were not done (no physical device on the build Mac): the reminder on the lock
screen at 100% and 200% text and with VoiceOver, tapping it to open the day's
activity, and the Home line at 200% text in English and Arabic. Also open:
`medical_claims_review`, native review of the translations, and
`release_metadata.py --release` gates.
