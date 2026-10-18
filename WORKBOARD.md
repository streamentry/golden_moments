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

PR #44 was independently merged while checks were running. That merge is not release approval. [Validation record](docs/release/validation-2026-10-18.md) distinguishes passed focused tests from remaining strict CI and native checks.

## Next in order

1. Record full strict CI for the bundled catalog without hiding spelling or coverage failures. The formatter cleanup is retained and the temporary helper is removed.
2. Complete device, offline, failure, rotation and accessibility checks in `docs/release/1.3.0.md`.
3. Test screenshot comprehension with five target caregivers, then capture the actual passing build.
4. Measure US App Store activity/game queries using the worksheet; unknown demand remains unknown.
5. Review privacy, advertising declarations, age rating, language availability and disease positioning before manual submission.

Design follow-ups: the legacy library game still flips mismatched tiles back after a delay and hides hints after one second (`GameCubit`); move both to the next deliberate tap with tests. Its share link points to Google Play on every platform. Define and verify dark-mode tokens before shipping a dark theme.

## Senior-first specification and next product slice

Read the [specification map](docs/specs/senior-first/README.md), [feature catalog](docs/specs/senior-first/feature-catalog.json), [roadmap](docs/specs/senior-first/roadmap.md), and [comparative validation plan](docs/specs/senior-first/validation.md).

The proposal contains 40 identified capabilities/quality requirements, with baseline state, phase, dependencies and acceptance tests. It is not a directive to build all 40 at once. R0 hardens the existing promise; R1 makes return/personalization easier; R2 validates individual new modes; R3 remains conditional.

Within R0 usability work, the next smallest implementation slice is **board first, visible exit, optional settings** (GM-001/002/005/012/013/016). Preserve the PR #48 design tokens, contrast fixes and calm legacy UI. Address the timed legacy mismatch/hint and platform-link follow-ups within the same release-hardening phase; do not revive clocks, scores or confetti. Observe independent and shared users before choosing new activities.

Execution status remains here and in release evidence. The feature catalog is a design map, not a parallel claim that requirements have passed. Agent-guidance PR #46 was separate at the baseline read; do not overwrite its work or infer it is merged.

## Deferred

Photo-deck exchange, family/iCloud sync, multiple albums, recordings and payments. Optional local reminders also require a separately approved permission/product decision. Documented future acceptance criteria do not authorize implementation. No infrastructure expansion before observed repeat use. No diagnosis, cognitive scoring or treatment functionality.

Stop publication for destructive imports, offline-start failures, unexpected sensitive-data transmission, misleading medical expectations, unresolved content rights, or screenshots of unimplemented behavior. Weak keyword demand is a distribution signal, not a reason to add unrelated diseases.
