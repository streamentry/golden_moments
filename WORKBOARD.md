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

## Website: dementiaactivities.games (2026-10-25)

Astro + React + TanStack Store site in `site/`, built as static files for Cloudflare Workers Static Assets. Read [site/README.md](site/README.md) and [site/CONTENT_GUIDE.md](site/CONTENT_GUIDE.md).

| Deliverable | Status |
| --- | --- |
| 11 browser games at launch; 12 on 2026-10-31 with shadow match (picture pairs, find the same, sort together, picture puzzle, finish the saying, word search, coloring, conversation cards, photo pairs, picture bingo, calm breathing) | Implemented; logic unit tests pass; every game exercised in the built-in browser under the Workers runtime at 375px and desktop; no device, screen-reader or caregiver testing |
| 35 sourced guides at launch (16 activities, 7 caregiving, 10 brain health incl. prevention and fasting); 38 on 2026-10-31 (21 activities, 7 caregiving, 10 brain health) | Written with cited, opened sources; brain-health pages carry a health notice; not reviewed by a clinician (the editorial policy says so) |
| SEO/GEO: titles, descriptions, canonicals, JSON-LD, sitemap, robots, `llms.txt`, `llms-full.txt`, share images | Implemented; `scripts/check-site.mjs` passes with 0 errors |
| Privacy: no ads or accounts; Google Analytics 4 since 2026-10-25 (signals and ad personalization off), not loaded on photo pairs, which is local only | Implemented; photo pairs made no network requests after photos were chosen, and the `_headers` CSP (`connect-src 'self'`) blocked a test request to another site |
| Accessibility | axe-core (WCAG 2.2 AA + best practice): no violations on the 11 pages scanned. Independent code review fixes applied (picker focus ring, focus after answers, one completion live region, word-search arrow keys and 48px cells, 48px footer links). No assistive-technology user testing |
| Exceptions recorded | Calm breathing is the one paced activity (stops on a tap or after six breaths), recorded in `DESIGN.md` |
| App legal pages (moved from `streamentry/golden-moments-web`, 2026-10-25) | `/app-privacy/`, `/privacy-choices/`, `/safety/`, `/support/`, `/help/` and `/legal/` added; app license merged into `/terms/`; copy updated for iOS 1.4.0 (family photos live, Firebase removed, Cloudflare hosting, current button labels). `check-site.mjs` guards each page; `pnpm check:live` checks them after deploy. Not deployed yet, not legally reviewed. The old site's demo, home and activities pages were dropped: the games and guides here replace them. Checklist moved to `docs/legal/app-review-gates.md` |
| Deployment | Live at <https://dementiaactivities.games> (RunLumi account, 2026-10-25); www 301-redirects to the apex; no external requests or CSP violations on the live home and picture-pairs pages. `web@dementiaactivities.games` forwards through Cloudflare Email Routing (test delivered). Dashboard items left: Always Use HTTPS, turn off Web Analytics auto-setup, Search Console and Bing |

Open items for the maintainer: legal review of the website privacy notice and terms; the Play listing link points at the existing package while 1.4.0 awaits review. The app (`lib/shared/utils/support_info.dart`, `lib/features/legal/`), `metadata/*.json` and both store consoles still link to `streamentry.github.io/golden-moments-web/`: after deploying the moved pages, switch them to `dementiaactivities.games` in the next app release, then retire or redirect the old site. The app shows `apple@locuno.com` while the site pages use `web@dementiaactivities.games`.

## Golden Hour design pass and website auto-deploy (2026-10-30)

| Deliverable | Status |
| --- | --- |
| `DESIGN.md` rewritten: Atmosphere and Signature details, a gold ramp (`primary-deep`, `accent-pale`, `accent-deep`), `surface-raised`, `secondary-container`/`-outline`, `on-ink*`, `shadow-ink`, Fraunces display typography, `rounded.sm`, `spacing.mat`, mirrored component list for the website | Lint 0 errors / 0 warnings; every color token has a Dart constant and the drift test checks both directions |
| Fraunces Bold (OFL) bundled for headlines in the app (`assets/fonts/Fraunces-Bold.ttf`, 36 KB) and the website (`fraunces-latin-700-normal.woff2`, 18 KB): one static instance of the variable font, recorded in `asset-provenance.json` | `gmBuildTheme` display/headline/title-lg roles use it; strict analysis and the full suite pass locally; seen on the iPhone simulator (home, picture packs). No real-device or 200% device evidence yet |
| Mounted print in the app (`GmMountedPicture`): print-white mat with a hairline, corners 16 → 8 → 4 | Tests updated; seen on the simulator pack cards |
| Website: tokens, Fraunces headings, sunrise rule on the header, Honey rule on the footer, umber shadows, tokenized notices, game badges and the breathing circle | `pnpm verify` passes (20 tests, 72 pages, 0 check errors); home and a guide inspected at desktop and 375px, no overflow |
| Fix: `_revealFinish` threw on a heading taller than the viewport (large text in a short window) | Fixed in `gentle_game_page.dart`; covered by the existing ux_detail tests, which now load both shipped fonts |
| Website deploys itself: `site.yaml` `deploy` job on pushes to `main` publishes the checked build with `wrangler deploy`, then runs IndexNow | Needs `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` repository secrets before the first merge; until they exist the job fails and `pnpm run deploy` by hand still works |

Next: add the two secrets, merge, watch the first deploy; re-check the app at 200% text on iPhone SE and iPad with the serif headlines; refresh the OG images (`scripts/og-games.mjs`) and store screenshots so they carry the new headline type.

## Category strategy and activity measurement (2026-10-31)

[Category strategy](docs/strategy/category-strategy.md) audits Golden Moments against `category-leader.md` and live competitors and chooses the first category: **ready-to-use dementia activities to do together, free, on the web, on paper and on a phone**, for US family caregivers, with activity staff tested as a second segment. It rejects the care-platform category for now, corrects five claims in the research document and sets gates G1–G6.

| Deliverable | Status |
| --- | --- |
| Strategy, audit, roadmap, measurement and decision gates | Written; claims checked against primary sources and live store listings on 2026-10-31 |
| Website activity events through the existing GA4 tag (`site/src/lib/track.ts`, `GameFrame`): `activity_start`, `activity_restart`, `activity_done`, `activity_print`, and an optional "Did this help today?" (`activity_feedback`, answer `yes` or `not_really`) | Implemented; unit tests, build and site checks pass; the start-once and print-only-on-printable-sheets rules have unit tests; the rest (start on a click only, the question appearing after the first click, focus moving to the reply, 56px buttons, nothing loaded or sent on Photo pairs) was checked by hand in the built-in browser under the Workers runtime with a stubbed tag, and has no automated component test. Privacy notice updated. **New website telemetry: merging is the maintainer's decision** |
| Baseline | First-time downloads unmeasured (App Store Connect data not yet produced; Sales vendor number not recorded); iOS 0 ratings; top Apple search result for "dementia activities"; Bing showed only the homepage indexed |

Next, in order: verify Google Search Console and Bing Webmaster Tools and submit the sitemap (maintainer, DNS on Cloudflare); register `answer` as an event-scoped custom dimension in GA4; re-answer the App Store age questionnaire truthfully (not just to lower the rating); create the App Store campaign provider token for `ct=web`; record the first week of events, downloads and indexed pages as the baseline; start recruiting the 20-unit reuse pilot.

## Growth pass: ratings, reminders and ASO (2026-10-30, 1.5.0+9 candidate)

Owner goal: from about 10 to 100 installs a day, with high retention. Maintainer decisions on 2026-10-30: add Apple's rating prompt plus a Help link (reverses the 2026-10-18 "no rating request" choice; GM-034) and build opt-in reminders (GM-038, R3, now approved). Both use a small iOS channel in `AppDelegate.swift` with no new package; Android hides reminders and gets only the Rate link to Play. iPhone shares now carry the App Store link. Keywords, promotional text and the Play short description were rewritten (see `docs/strategy/us-aso.md` › October 30, including console actions such as the 16+ age rating).

Evidence: strict analysis clean, 450+ Flutter tests pass with 79.8% line coverage, 64 Python tests and metadata checks pass, DESIGN.md lint 0/0. iOS 26.5 simulator, debug build: Apple's rating sheet appeared on Home after a finished game with seeded counters, never on the finish message (`docs/release/evidence/1.5.0/`); the notification question appeared only after "Turn on reminder", and scheduling succeeded. Not device-verified, no VoiceOver run, Android not built.

## Growth and localization plan (2026-10-31, proposal)

`docs/plan/README.md` proposes how the app could become the first choice for one job in ten languages, with research appendices on [language markets](docs/plan/language-markets.md), [competitors and review gaps](docs/plan/competitors.md) and [design evidence](docs/plan/evidence.md). It reframes "cover all use cases" as "handle every moment of one job", sequences device acceptance and the Play release before a third language, and proposes two catalog entries (GM-041 participant language, GM-042 helper settings without a password). It records how it differs from `docs/strategy/category-leader.md` (a platform bet that the current boundaries exclude) and proposes running that document's cheapest web test before any platform scope decision. Nothing in it is approved, scheduled or implemented; the decisions it asks for are listed in its section 9. Documentation only: Python guidance and metadata checks run; no Flutter or device run was performed for it.

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

End-to-end and UX pass (stacked on #67): an `integration_test/` suite drives the real app through seven journeys (first game, stop and resume, comfort settings, Look together, an installed family collection without the picker, the picture-pack library, and 200% text). All 8 tests pass on the iPhone 17 Pro Max and iPad Pro 13-inch simulators (iOS 26.5); run with `flutter test integration_test -d <simulator>` (see `integration_test/README.md`; it clears app data). A screen-by-screen review at phone, 200% text and iPad sizes led to: a picture of the activity on Home, a calm 'All pairs together.' finish, unclamped app-bar titles, measured button pairs, a clearer library ('Picture packs', tile counts instead of difficulty words, one column on phones, 1px Driftwood card borders), honest card backs for hidden tiles, and Look together keeping the picture in sight. Running the suite at 200% text on the iPhone found three real defects, all fixed with regression tests. Simulators are not physical devices or screen-reader runs.

Detail pass (after #70): a review of 24 screen states at phone, 200% text and iPad sizes, including family-photo grids, photo options, dialogs, the picture puzzle and the pack page. It led to:
- Confirmations that make the safe choice the filled primary, with full-width stacked actions when labels do not fit.
- Play again as the primary action on the pack-game finish.
- A 1px line above fixed bottom bars only while content continues beneath them, and a linen app bar when content scrolls under it.
- At 200% text, a finished board scrolls its closing words into view (a jump with Reduce Motion).
- Equal-width comfort chips in full rows.
- Picture-puzzle exit labels that no longer break mid-phrase, and a puzzle board that grows on iPad.
- Full-width sheet actions.
- A Classic Cars cover and captions that show and name the pack's own cars.

New journeys J8 (help and privacy offline, a note sent nowhere) and J9a/J9b (confirmations at 100% and 200%) bring the suite to 11 tests, all passing on the iPhone 17 Pro Max and iPad Pro 13-inch simulators (iOS 26.5). The family-photos journey also caught Home throwing a negative-height layout error under a keyboard, now fixed with a regression test. Widget tests: 377 pass, also in one isolate in random order, with 78.7% line coverage. The browser smoke passes 11 of 11. Simulators are not physical devices or screen-reader runs.

Maintainer decisions, made on 2026-10-19 at the owner's request ("make the right decision"):
- **Sound default:** keep library music and sounds off for installs that never chose; stored choices are kept. The release notes now say so.
- **App-level privacy manifest:** added `ios/Runner/PrivacyInfo.xcprivacy`. It declares no tracking, no collected data, and the app's own reasons for file timestamps in its container (C617.1) and its preferences (CA92.1), and it is built into the app. Flutter.framework and the plugin bundles keep their own manifests. The signed-archive privacy report remains a release gate.
- **Corrupt photo list:** a "keep what can be verified" recovery, only on request. The damaged list is set aside, never deleted, and the copies whose content matches their names come back with their details. A list from a newer app version is never moved.
- **Car pack content:** named for what it shows, as *Cars and Trucks* under the *Cars* topic. Its cover, preview and topic icon are the pack's own photos. Genuinely vintage car photos would be new content for the GM-025 rights review. The 12 store screenshots were then recaptured from main at `fce00d7` and placed in the approved frames (GM-033); see `assets/screenshots/en-US/README.md`.


Picture-pack library as an album (after #76): with the owner's approval, the 8 covers and 5 topic pictures were fetched again from their recorded Unsplash sources at 1200x675 and 480x480 (about 1.2 MB more in the app). Pack and topic cards now mount the picture like a print (inset, rounded, decoded at the size shown), lead with a larger title, and keep favorite and "Not for me" in a footer under a hairline. The 121-asset mapping is unchanged.

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
localizations were removed after a protected backup. The published 1.0 translations
were retained. Version 1.3.0 was manually released and is now READY_FOR_SALE. Its
review history and the pending physical-device, accessibility, caregiver, legal and
inherited asset-rights gates are recorded in [build 6 evidence](docs/release/app-store-1.3.0-build6.md).


## iOS 1.4.0 build 7 submission (2026-10-19)

PR #86 merged commit `7738d7f8b4407297086a30ec13f75acace976ddf` to sync iOS
plugin pods and the Xcode embed phase. Pinned Flutter analysis, all 430 Flutter
tests, 63 Python checks and metadata validation pass. The signed 1.4.0 build 7
IPA validates and processes as **VALID**. All 12 en-US screenshots are complete
and match their committed file checksums. App Store Connect reports
**WAITING_FOR_REVIEW** with automatic release selected after approval. The
release is submitted, not approved or publicly available. Physical-device,
screen-reader, caregiver, runtime privacy/legal and inherited asset-rights gates
remain pending. Full record: `docs/release/app-store-1.4.0-build7.md`.

## Android 1.4.0 API 36 resubmission (2026-10-20)

The Play Console policy page supplied by the maintainer showed an update in review with an API 36 target requirement. The production manifest now targets API 36. Version code 8 is built and signed with the replacement upload key; 430 Flutter tests, 64 Python tests, strict analysis, metadata validation, and a Pixel emulator smoke test on Android 16 passed. The AAB and checksums are in `output/release/android-1.4.0-api36-build8/`; detailed evidence is in [the Android release record](docs/release/android-1.4.0-api36-build8.md). Google Play upload and review submission remain pending: verify the replacement certificate in Play Console after its stated activation time, then upload and submit the candidate.

## iOS 1.4.0 publication confirmed (2026-10-21)

Live App Store Connect readback confirms version 1.4.0 is `READY_FOR_SALE` /
`READY_FOR_DISTRIBUTION` and downloadable. Build 7 is valid, review is complete,
and the approved automatic release has completed. The [release record](docs/release/app-store-1.4.0-build7.md)
links the current receipt to the earlier submission evidence. Android version
code 8 remains prepared locally; Play Console authentication and upload-key
certificate readback are still required before its upload and submission.

## Android 1.4.0 bundle accepted by Google Play (2026-10-21)

Using the built-in Browser, uploaded the signed version-code 8 AAB to a
production release named `1.4.0 (8)`. Play accepted its signing key and reports
target SDK 36. Corrected the outdated Advertising ID declaration to No; the Ads
declaration already says No. The release and phone screenshots are saved for
review, but submission is still blocked by a publishing check that calls the
saved declaration incomplete. Fresh checks completed with the same issue, and
a fresh page and explicit resave confirm No. Managed publishing is on.
The [Android release record](docs/release/android-1.4.0-api36-build8.md)
records the validation contradiction, delivery size and device-support warnings;
neither upload acceptance nor a saved rollout is a review submission or release.
