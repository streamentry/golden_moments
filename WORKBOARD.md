# Workboard

Updated 2026-10-18. Scope: US English, local-first Golden Moments 1.3.0 candidate.

| Deliverable | Status |
| --- | --- |
| Canonical title/subtitle/keywords and generated exports | Implemented; metadata tests supplied |
| Screenshot storyboard and release/claim checks | Implemented; genuine captures pending |
| Four-tile visible-picture starter | Implemented; Flutter/device verification pending |
| Selected family-photo import and bounded local copies | Implemented; native picker/storage/upgrade QA pending |
| Shared viewing and optional prompts | Implemented; caregiver review pending |
| Explicit legacy library instead of launch downloads | Implemented; regression checks pending |
| Analytics deactivation and crash-reporting defaults | Configured; native privacy audit pending |
| Product, architecture, safety and ASO specs | Documented |
| DESIGN.md design system applied app-wide (contrast-safe gold, 16px text floor, calm legacy game) | Implemented; automated contrast/target/text-scale tests; device review pending |

## Next in order

1. Resolve dependencies/lockfiles; run focused and full Flutter tests without hiding baseline failures.
2. Complete device, offline, failure, rotation and accessibility checks in `docs/release/1.3.0.md`.
3. Test screenshot comprehension with five target caregivers, then capture the real passing build.
4. Measure US App Store activity/game queries using the keyword worksheet; unknown demand remains unknown.
5. Review privacy, advertising declarations, age rating, language availability and disease positioning before manual submission.

Design follow-ups: the legacy library game still flips mismatched tiles back after a delay and hides hints after one second (`GameCubit`); move both to the next deliberate tap with tests. Its share link points to Google Play on every platform. Define and verify dark-mode tokens before shipping a dark theme.

## Deferred

Photo-deck exchange, family/iCloud sync, multiple albums, recordings and payments. No infrastructure expansion before observed repeat use. No diagnosis, cognitive scoring or treatment functionality.

Stop publication for destructive imports, offline-start failures, unexpected sensitive-data transmission, misleading medical expectations, or screenshots of unimplemented behavior. Weak keyword demand is a distribution signal, not a reason to add unrelated diseases.
