# 1.9.0 build 13 release record (iOS and Android): submitted, awaiting review

**State (2026-11-09):** submitted on both stores, not approved. Read both stores back
before saying either is live. Steps are in [publishing-with-api.md](publishing-with-api.md).

## Content

- 100 new drawings in the games and the daily moment (English names for now).
- Reading text has more room between lines.
- The 64 locale release notes use the English text; machine translations stay unreviewed.
- Version bump and notes: PR 181 (`release/1.9.0`).

## iOS

- Version 1.9.0 (build 13), bundle `com.mindfulness.goldenmoments`. Built in a clean
  worktree of `release/1.9.0` with manual signing set only in that worktree (team
  `7MBXZKYSY4`, profile `Golden Moments App Store 2026-10-18`).
- IPA SHA-256 `e3c4084bdd71672fc8db25f65408709c0b141cb329027a1fa8b1f2af37124985`.
  `codesign --verify --deep --strict` passed; Info.plist shows 1.9.0 (13).
- `altool --validate-app` and `--upload-app` reported no errors (delivery
  `2baa0ee4-ae1f-44e2-bbcb-204ca4a59b9a`); build processed `VALID`.
- App Store version `4cdade9a-190c-4c39-94ee-caefba01dc52`, build attached, release
  automatic after approval. What's New set on all 34 localizations; promotional text
  copied from 1.8.0. Review submission `ea738706-0c56-4d05-8e48-688380b2883a`:
  `WAITING_FOR_REVIEW`. 1.8.0 was `READY_FOR_SALE` before this.

## Android

- Version 1.9.0 (version code 13), package `com.mindfulness.golden_moments`.
- AAB SHA-256 `4679ffd817f4bae8f57048306a1e03f0db2ab57fc49f25b5f9d744cb5d5053db`;
  Play reported the same hash. Signer is the registered upload certificate.
- Production track release `1.9.0 (13)`, status `completed`, notes for all 43 listing
  locales; edit `08282774852441529207` committed. Managed publishing is off, so Play
  reviews it automatically.

## Still open

Apple and Google approval; wellbeing and device checks; `medical_claims_review`;
accessibility device review; native review of the translations; the unreviewed
provenance gates for the new drawings (tool terms, AI-image disclosure).
