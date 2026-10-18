# Workboard

Updated 2026-10-18. Scope: US English, local-first Golden Moments 1.3.0 candidate.

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
| Senior-first slice 1: board first, visible exit, comfort settings on request (GM-001/002/003/005/012/013/016, gentle matching screen only) | Implemented; strict analysis and 109 Flutter tests pass locally; no device, screen-reader or user-comprehension evidence. Per-feature status in `release-status.json` › `senior_first_features` |

PR #44 was independently merged while checks were running. That merge is not release approval. [Validation record](docs/release/validation-2026-10-18.md) distinguishes passed focused tests from remaining strict CI and native checks.

## Next in order

1. Record full strict CI for the bundled catalog without hiding spelling or coverage failures. The formatter cleanup is retained and the temporary helper is removed.
2. Complete device, offline, failure, rotation and accessibility checks in `docs/release/1.3.0.md`.
3. Test screenshot comprehension with five target caregivers, then capture the actual passing build.
4. Measure US App Store activity/game queries using the worksheet; unknown demand remains unknown.
5. Review privacy, advertising declarations, age rating, language availability and disease positioning before manual submission.

Design follow-ups: set `appStoreUrl` in `lib/shared/utils/share_util.dart` once the App Store listing exists (Apple devices are told to search by name until then). The app is light-only by decision; do not add a dark theme.

## Senior-first specification and next product slice

Read the [specification map](docs/specs/senior-first/README.md), [feature catalog](docs/specs/senior-first/feature-catalog.json), [roadmap](docs/specs/senior-first/roadmap.md), and [comparative validation plan](docs/specs/senior-first/validation.md).

The proposal contains 40 identified capabilities/quality requirements, with baseline state, phase, dependencies and acceptance tests. It is not a directive to build all 40 at once. R0 hardens the existing promise; R1 makes return/personalization easier; R2 validates individual new modes; R3 remains conditional.

Within R0 usability work, the first slice, **board first, visible exit, optional settings** (GM-001/002/005/012/013/016, plus GM-003 preferences), is implemented for the gentle matching screen only. Still open: home-screen simplification, the photo/together/legacy screens, GM-004 safe resume and everything else in the catalog. Preserve the PR #48 design tokens, contrast fixes and calm legacy UI. Address the timed legacy mismatch/hint and platform-link follow-ups within the same release-hardening phase; do not revive clocks, scores or confetti. Observe independent and shared users before choosing new activities.

Execution status remains here and in release evidence. The feature catalog is a design map, not a parallel claim that requirements have passed. Agent-guidance PR #46 was separate at the baseline read; do not overwrite its work or infer it is merged.

## Deferred

Photo-deck exchange, family/iCloud sync, multiple albums, recordings and payments. Optional local reminders also require a separately approved permission/product decision. Documented future acceptance criteria do not authorize implementation. No infrastructure expansion before observed repeat use. No diagnosis, cognitive scoring or treatment functionality.

Stop publication for destructive imports, offline-start failures, unexpected sensitive-data transmission, misleading medical expectations, unresolved content rights, or screenshots of unimplemented behavior. Weak keyword demand is a distribution signal, not a reason to add unrelated diseases.

## Legal and app-review disclosure work

The website privacy/terms/deletion/safety documentation is prepared in `streamentry/golden-moments-web` PR #2, awaiting CI and qualified legal/privacy review before publication. This app PR adds a privacy, terms, safety and support entry accessible from the home guide and legacy settings with an offline-readable summary. **Do not mark legally cleared or App Review-ready.** Public paths are contingent on website PR deployment. Check final iOS/Android SDK manifests, traffic, permissions, Apple privacy nutrition labels, public support mailbox and required DPO details, existing medical claims, and actual device link behavior. The website publishes under a GitHub Pages project prefix. Apple Standard EULA remains the default, not an unreviewed custom EULA.
