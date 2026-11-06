# 1.8.0 build 12 release record (iOS and Android): submitted, awaiting review

**State (2026-11-06):** submitted on both stores, not approved. The maintainer
chose to publish and change the category now, overriding the hold in
[wellbeing spec](../specs/wellbeing.md) (decision of 2026-11-06). Nothing here is
approved, device-verified or released until each store says so.

## Content

- Daily moment, Plan my day, My progress and Healthy habits (see
  [wellbeing spec](../specs/wellbeing.md)). New screens are English-only until
  translated; the 64 locale release notes say so.
- Store category: **Health & Fitness** primary, **Lifestyle** secondary (App Store),
  and **Health & Fitness** with type **App** (Google Play).
- The Healthy habits sentence was removed from the release notes in every language.
  App Review notes describe the routine and state that the app does not claim to
  prevent dementia.

## iOS

- Version 1.8.0 (build 12), bundle `com.mindfulness.goldenmoments`, minimum iOS 15.
- Built from a clean worktree at commit `f2afcaf` (`/Volumes/SANDISK-Data/gm-build-180`),
  not from the main checkout. Temporary App Store signing was applied only in that
  worktree (team `7MBXZKYSY4`, manual, profile `Golden Moments App Store 2026-10-18`,
  Runner Release).
- IPA SHA-256 `1b5a6925511df5352003a2a58b2e61b2954de3e7fa9e815ccf9bcd9561539ce5`.
  Local copy `output/release/ipa-1.8.0-12/golden_moments.ipa` (not committed).
- `codesign --verify --deep --strict` passed. `xcrun altool --validate-app` and
  `--upload-app` both reported no errors (delivery `cdc2a138-f156-47a2-b04e-4cf336dacda6`).
  Build processed `VALID`.
- App Store version `986788ba-5881-45c3-8ad0-f1160ef6750d` attached to build 12.
  34 localizations; What's New set in each (English and the 33 translations). Screenshots
  copied from 1.7.0 by App Store Connect.
- Category set on the editable app info (`ae867253-e983-4e2a-91a9-6b78fb84586e`):
  primary Health & Fitness, secondary Lifestyle. Both game subcategories cleared
  (they belonged to Games).
- Review submission `efaff72d-38ee-4bf8-8842-0045660d3e3d`: `WAITING_FOR_REVIEW`,
  submitted 2026-11-06 16:15 UTC, release type automatic after approval.
- 1.7.0 (build 11) was `READY_FOR_SALE` on iOS before this submission.

## Android

- Version 1.8.0 (version code 12), package `com.mindfulness.golden_moments`, production
  track, status `completed`.
- Built with `backups/golden-moments-android-20261018/build-android.sh` against the same
  clean worktree. AAB SHA-256 `70d952b95441e916510aaa3adf6a7aef7950797aa124d2824a035eb70ce84113`
  (matches the uploaded bundle). Signer SHA-256
  `B5:3D:D5:57:47:0A:BC:E1:31:6E:53:FD:9F:30:6C:82:72:69:16:0B:F2:37:B4:96:EB:3C:C7:95:D0:40:F7:2F`,
  the registered upload certificate. Local copy `output/release/android-1.8.0-12/`.
- Release notes set for all 43 Play listing locales, from the same 64-file metadata
  (per-locale notes; en-US for any locale without one).
- Play edit committed `17809034096417019210`. Managed publishing is off, so Play sends it
  for review automatically.
- Category: Play Console Store settings now shows **App**, **Health & Fitness**
  (saved from the console). Play Console reports **1 change** in Publishing overview,
  "Submit 1 change for review", with checks running at the time of the record. Confirm
  it is sent before saying it is in review.
- Play warns that choosing **App** removes the game from Google Play Games on PC.

## Checks on the release tree (commit `f2afcaf` plus this doc)

- `dart format` (no changes), `flutter analyze --fatal-infos --fatal-warnings` (no issues),
  `flutter test --no-pub` (all 639 passed).
- `scripts/release_metadata.py --check` and `scripts/store_locales.py --check` (64 of 64,
  0 problems). `python3 -m unittest discover -s tests` has one local-only failure,
  `test_asset_provenance`, from files on this machine that are not in git (`.DS_Store`,
  `assets/icons/app_icon_bk.png`, the `LaunchImage` assets). CI's clean checkout does not
  have them. Not verified on CI.
- `scripts/release_metadata.py --release` was **not** run. It requires device-verified
  features and evidenced gates, and both are open (see below).

## Still open

- **Approval.** Apple and Google must approve. Read both stores back before saying
  either is live.
- **Gates not evidenced:** wellbeing screens not device-verified; `medical_claims_review`
  pending (Health & Fitness plus the Healthy habits page raises review risk); fresh-install
  and upgrade checks; accessibility device review; privacy and SDK audit.
- **Translations:** all new notes and the 1.8.0 strings are machine-made and unreviewed.
- **Icon and launch screen.** The commits `9250a2f` (new app icon across app, web,
  site and stores) and `00f64fe` (new logo on iOS launch screen and site share images)
  are on this branch and ship in 1.8.0. They were committed by another session on this
  checkout during the run; confirm they are intended.
- **Other local changes:** `assets/icons/app_icon_bk.png` is untracked and not part of the
  release.
