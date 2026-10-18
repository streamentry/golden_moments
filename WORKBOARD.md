# Workboard

Updated 2026-10-18 (senior-first R0/R1 continuation). Scope: US English, local-first Golden Moments 1.3.0 candidate.

| Deliverable | Status |
| --- | --- |
| Canonical title/subtitle/keywords and exports | Implemented; metadata CI passed |
| Screenshot storyboard and release/claim checks | Implemented; genuine captures pending |
| Four-tile visible-picture starter | Implemented; focused Flutter tests passed, device review pending |
| Selected family photos and bounded local copies | Implemented; storage/normalization tests passed, native picker and upgrade QA pending |
| Shared viewing and optional prompts | Implemented; caregiver/device review pending |
| Included picture library with no download flow | 121 bundled images; local first-launch/browser and all-pack tests passed |
| Resolved dependency lockfile | Committed by SDK resolver, not hand-edited |
| Analytics deactivation and crash-reporting defaults | Configured; native privacy audit pending |
| Product, architecture, safety and ASO specs | Documented |
| DESIGN.md design system applied app-wide (contrast-safe gold, 16px text floor, calm legacy game) | Implemented; automated contrast/target/text-scale tests; device review pending |
| Senior-first feature plan | Specified in docs/specs/senior-first; not newly implemented or release-approved |
| Senior-first slice 2: family-photo captions/descriptions, favorites and reversible hiding (GM-019, GM-020 partial, GM-018 failure paths) | Implemented; journey tests with real storage pass locally; no device or screen-reader evidence. Per-feature status in `release-status.json` |
| Senior-first slice 1: board first, visible exit, comfort settings on request, safe resume (GM-001/002/003/004/005/012/013/016, gentle matching screen only) | Implemented; strict analysis and the full Flutter suite pass locally and in CI for this branch (counts in the PR description and CI logs, not recorded here); no device, screen-reader or user-comprehension evidence. Per-feature status in `release-status.json` › `senior_first_features` |

PR #44 was independently merged while checks were running. That merge is not release approval. [Validation record](docs/release/validation-2026-10-18.md) distinguishes passed focused tests from remaining strict CI and native checks.

## Next in order

0. Run the device and human scenarios in [docs/release/device-acceptance.md](docs/release/device-acceptance.md) and record evidence per its format.

1. Record full strict CI for the bundled catalog without hiding spelling or coverage failures. The formatter cleanup is retained and the temporary helper is removed.
2. Complete device, offline, failure, rotation and accessibility checks in `docs/release/1.3.0.md`.
3. Test screenshot comprehension with five target caregivers, then capture the actual passing build.
4. Measure US App Store activity/game queries using the worksheet; unknown demand remains unknown.
5. Review privacy, advertising declarations, age rating, language availability and disease positioning before manual submission.

Design follow-ups: set `appStoreUrl` in `lib/shared/utils/share_util.dart` once the App Store listing exists (Apple devices are told to search by name until then). The app is light-only by decision; do not add a dark theme.

## Senior-first specification and next product slice

Read the [specification map](docs/specs/senior-first/README.md), [feature catalog](docs/specs/senior-first/feature-catalog.json), [roadmap](docs/specs/senior-first/roadmap.md), and [comparative validation plan](docs/specs/senior-first/validation.md).

The proposal contains 40 identified capabilities/quality requirements, with baseline state, phase, dependencies and acceptance tests. It is not a directive to build all 40 at once. R0 hardens the existing promise; R1 makes return/personalization easier; R2 validates individual new modes; R3 remains conditional.

Within R0 usability work, the first slice, **board first, visible exit, optional settings** (GM-001/002/005/012/013/016, plus GM-003 preferences), is implemented for the gentle matching screen, and the October 18 R0/R1 continuation (below) extends it to the home screen, Look together and the legacy picture-pack route. Still open: device, screen-reader and human evidence for all of it, and the catalog items listed in that section. Preserve the PR #48 design tokens, contrast fixes and calm legacy UI. Address the timed legacy mismatch/hint and platform-link follow-ups within the same release-hardening phase; do not revive clocks, scores or confetti. Observe independent and shared users before choosing new activities.

Execution status remains here and in release evidence. The feature catalog is a design map, not a parallel claim that requirements have passed. Agent-guidance PR #46 was separate at the baseline read; do not overwrite its work or infer it is merged.

### Senior-first execution tally

All 40 catalog IDs have an entry in `release-status.json` › `senior_first_features` (enforced by `tests/test_senior_status.py`). Current tally (PRs #61-#66 merged to main on 2026-10-19): 4 deferred, 13 implemented unverified, 6 not started, 17 partial. Nothing is `verified`: no native device, VoiceOver/TalkBack, upgrade, traffic-capture or human-pilot evidence exists, and every release gate in that file is still pending. R2 items wait on pilot evidence; R3 items are deferred and not authorized.

## Maintainer decisions (2026-10-18)

Recorded at the maintainer's instruction; each is scoped and reversible.

- **Coverage gate loosened.** `min_coverage` is 62 in `.github/workflows/main.yaml` (template default 100, which this codebase could never meet; first set to 45, then ratcheted after the dead downloader was removed and 64.93% was measured). It is a floor just under the measured level, to be raised as coverage grows and never lowered silently.
- **Spell-check scope.** The legacy translated store descriptions in `docs/store-description/` are excluded because an English dictionary cannot check them (and their non-English medical claims are not reused); about 28 genuine technical words were added to the dictionary.
- **Legacy downloader removed** (35 unreachable files and seven unused packages). Stored files from older installs are not touched. Native iOS/Android builds still need to confirm the plugin removal.
- **Firebase removed.** The maintainer first kept Firebase for possible engagement measurement, then decided to remove it. `firebase_core`, `firebase_analytics` and `firebase_crashlytics`, the Android Google-services plugin and `google-services.json`, iOS `GoogleService-Info.plist` and its Xcode references, and the collection flags are gone; `tests/test_network_boundary.py` keeps them gone. Engagement is measured by consented diaries and interviews per `docs/specs/senior-first/validation.md`. On 2026-10-18 the iOS lock files were regenerated on a Mac (no pods besides Flutter; both `Package.resolved` files removed, Firebase was the only remote Swift package) and an unsigned release build was inspected: no Firebase or Google measurement code is linked (details in `docs/release/network-privacy-audit.md`; the lock files are now guard-tested). A signed archive, the merged Android manifest and an app-level privacy manifest decision remain open.
- **PR #54 merged** at the maintainer's instruction after its own checks passed.
- **Support contact:** the Help page shows, as copyable text (never opened by the app), the `support_url` and `terms_url` from the store metadata, the mobile-app privacy policy (`/app-privacy/` on the same site) and the support address the maintainer publishes (`apple@locuno.com`). Open findings for the maintainer: (1) the metadata `privacy_policy_url` points at the general website notice (`/privacy/`), not the app policy; (2) the site's privacy-choices page says to choose "Remove" while the app says "Remove this copy"; (3) the iOS share link stays unset because the published App Store listing is named "Memento Maze" and I cannot confirm it is this app and bundle.
- **Not decided by the assistant:** the image rights review needs the maintainer or a qualified reviewer; nothing was marked reviewed.

## Deferred

Photo-deck exchange, family/iCloud sync, multiple albums, recordings and payments. Optional local reminders also require a separately approved permission/product decision. Documented future acceptance criteria do not authorize implementation. No infrastructure expansion before observed repeat use. No diagnosis, cognitive scoring or treatment functionality.

Stop publication for destructive imports, offline-start failures, unexpected sensitive-data transmission, misleading medical expectations, unresolved content rights, or screenshots of unimplemented behavior. Weak keyword demand is a distribution signal, not a reason to add unrelated diseases.

## October 18 senior-first R0/R1 continuation

Pinned Flutter 3.47.7 / Dart 3.13.5 installed locally; Xcode 27.1 with the iOS 26.5 simulator available; **no physical device and no Android SDK** (installing the Android SDK needs its license accepted by the maintainer). Work split into reviewable PRs, each with an independent review where it touched data or accessibility; the maintainer approved merging them in order on 2026-10-19, and each was merged only after its branch was updated with main and all seven CI checks passed on that exact commit. Nothing is device-verified.

| PR | Scope (feature IDs) | Evidence |
| --- | --- | --- |
| #61 | Test reliability: preference leakage between files under `very_good --optimization`, condition waits in the photo journey | Journey flake reproduced in CI on #63 and under local load |
| #62 | Look together complete (GM-008, GM-002), one Start in the first view at large text (GM-001), rotation (GM-016), backup note on delete (GM-027) | 209+ tests; iOS simulator walkthrough of home, Look together, hide, game |
| #63 | iOS lock files regenerated after the Firebase removal (GM-028) | Unsigned release build: no Firebase/measurement code, identity unchanged; guard covers lock files |
| #64 | Legacy picture-pack route: quiet default, Reduce Motion, tile semantics, fixed exit, reflow (GM-002/003/012-016) | 228 tests; web release build passes all browser smoke checks |
| #65 | Favorites and Not for me for included packs, Suggested packs, empty-topic explanation (GM-020/024/026) | 270 tests; 11 browser smoke checks incl. hide, reload, show again |
| #66 | Photo storage hardening: staged writes, no link following, no loss on stat errors, adoption, upgrade fixtures (GM-018/027/030) | 244 tests; two data-loss reviews, final verdict approve |

Simulator journeys on the integrated build (iOS 26.5, iPhone 17 Pro Max, debug, fresh install): launch → one-tap start → choose a tile → Done for now → reopen → Carry on restored the board; Your family photos → system picker (no permission prompt) → three photos copied as metadata-free 1024-pixel PNGs → caption and favorite saved → Look together showed the caption on request → game used the photos without cropping → Remove copy deleted one copy and its details only. Two defects found this way were fixed in #62 (clamped helper text, a destructive button labelled 'Continue'). Simulator runs are not device, VoiceOver or user evidence.

Findings for the maintainer, not decided here:
- **Sound default:** installs that never touched the library sound switches now start quiet (stored choices are kept). Mention in release notes.
- **App-level privacy manifest:** the iOS build carries plugin manifests but no app `PrivacyInfo.xcprivacy`; decide against Apple's current rules before submission.
- **Corrupt photo manifest:** it surfaces an error and is never overwritten, but there is no in-app recovery flow yet; a "keep what can be verified" recovery is a product decision.
- **Content:** the *Classic Cars* pack cover shows a lightbulb; include it in the GM-025 rights and clarity review.

Next executable actions, in order: run `docs/release/device-acceptance.md` on a physical iPhone and iPad (VoiceOver walkthrough of start/play/stop/import/remove, rotation, Reduce Motion, airplane-mode fresh install, upgrade from the App Store build); install the Android SDK only with the maintainer's license acceptance and repeat; then the five-caregiver comprehension test and genuine screenshots (GM-033). R2 stays at the unshipped GM-009 prototype until the pilot (GM-039) chooses; R3 stays deferred.

## October 18 store publication continuation

Pulled latest main `de84c46`. Corrected ASO offline copy for all eight bundled packs, added a Google Play US-English draft and export validation, and aligned website/help/privacy/terms URLs with the [GitHub Pages website](https://streamentry.github.io/golden-moments-web/). The selected name remains `Dementia Games: Golden Moments` and subtitle `Alzheimer's Photo Activities`.

Strict analysis and all 109 Flutter tests passed on the latest native source; metadata/Python checks pass. Google Play confirms replacement-key activation on October 20, 2026 at 13:38 UTC (20:38 Vietnam time); uploads are blocked until then. The latest runtime source archived successfully. Removed the unused Flutter launch-image placeholders and aligned the launch background with DESIGN.md; the final signed archive and IPA export passed, with the placeholder warning resolved. The prior 2aecea2 IPA is not the current candidate. Remaining native/device/privacy/caregiver/screenshot gates are not marked passed by these checks. Store changes must remain drafts until those gaps and matching screenshots are resolved.

Release evidence for this continuation: all 109 Flutter tests and strict analysis passed; 25 Python tests and both metadata export checks passed. Hosted web visual, design, gentle-activity and metadata checks passed. The unchanged full-coverage gate reports 36.83% against 100%; the English spelling job still flags translated/historical store text. Those failures remain visible. Website PR #3 deployed commit `48ded15ae94080d13c93b797a8c71f2f8fb85f09`; home, help, terms and privacy all returned HTTP 200 with expected updated content.

App Store Connect version 1.3.0 was created and US-English name/subtitle plus description, notes, keywords, support and marketing URLs were saved. The browser session disconnected before privacy-link and Play listing edits were completed. Binary upload has not occurred; use of an existing API credential from a different app's protected backup requires explicit approval. Public review submission remains pending the native/privacy/screenshot gates above.

## Legal and app-review disclosure work

The website privacy/terms/deletion/safety documentation is prepared in `streamentry/golden-moments-web` PR #2, awaiting CI and qualified legal/privacy review before publication. This app PR adds a privacy, terms, safety and support entry accessible from the home guide and legacy settings with an offline-readable summary. **Do not mark legally cleared or App Review-ready.** Public paths are contingent on website PR deployment. Check final iOS/Android SDK manifests, traffic, permissions, Apple privacy nutrition labels, public support mailbox and required DPO details, existing medical claims, and actual device link behavior. The website publishes under a GitHub Pages project prefix. Apple Standard EULA remains the default, not an unreviewed custom EULA.

## iOS review candidate 1.3.0 build 6 (2026-10-19)

Prepared from `c3fcd03` plus the annotation-save busy-state regression fix. The
actual candidate passes 189 Flutter tests, strict analysis and 56 Python tests.
The signed Firebase-free IPA validates with Apple and processes as VALID.
Separate native iPhone/iPad iOS 18.5 sessions imported the two synthetic demo
photos through the real picker and exercised matching, viewing, comfort controls
and the included library. Twelve genuine store screenshots, originals, generation
prompts and hashes are committed under `assets/screenshots/en-US/`; all twelve
Apple asset deliveries completed and checksums/order were read back.

The owner requested review submission and US-English fallback; 17 obsolete draft
localizations were removed after a protected backup. The published1.0 translations
were retained. Public release is MANUAL. Review submission does not certify the
pending physical-device, upgrade, accessibility, caregiver, legal or inherited
asset-rights gates. The release validator remains fail-closed. See
[build 6 evidence](docs/release/app-store-1.3.0-build 6.md) for exact limits and store state.

Apple readback confirmed build 6 **WAITING_FOR_REVIEW** at 2026-10-18T17:44:55Z;
public release remains MANUAL. This is submitted, not approved or published.
