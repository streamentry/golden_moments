# Inspected baseline and integration

Initial review: 2026-10-18 at [commit 2aecea2](https://github.com/streamentry/golden_moments/commit/2aecea2b53e6c3e67a21a4213a5dd2e1753d1334). Final integration: [main commit 1f5ed79](https://github.com/streamentry/golden_moments/commit/1f5ed7997774c8e299b7cafdc8e42402dcdf537a), including PR #48. The catalog's baseline_commit records the initial observation; this document records the subsequent reconciliation.

The repository was read through the GitHub connector. A local Git clone was unavailable because the execution container could not resolve github.com. No native or usability test was performed by writing these specifications.

## Material changes already present

PR #47 includes all eight catalog packs and 121 image assets, along with bundled font/browser-renderer resources. Catalog play no longer depends on runtime image downloads or a download tab. Historical descriptions of downloading this catalog or browser Firebase startup are superseded.

PR #48 landed during this specification work. Its design system, source changes, workflow checks and tests are preserved, not overwritten. [DESIGN](../../../DESIGN.md) now owns the normative tokens and interaction rules: contrast-safe primary gold, bundled Roboto, 16-unit text floor, 48-unit control targets, 56-unit buttons, 64-unit hero/tile targets, and one primary filled action. The legacy stopwatch, move count, confetti and auto-closing invite dialog have already been removed. These are not new unimplemented ideas in this roadmap.

The [release record](../release-status.json) still separates local test evidence from pending native archive, picker, fresh installation, upgrade, accessibility and store gates. This documentation change does not promote that evidence.

## Implementation observations after reconciliation

| Area | Observed baseline | Remaining requirement |
| --- | --- | --- |
| Mobile home | Three prominent activity/setup actions, library entry and guide; updated design tokens | Clear independent/shared use without mandatory setup; easier repeat actions |
| Gentle matching | Four visible tiles by default; 4/6/8/12 choices; optional hidden cards | Controls still precede the board; preferences and session remain widget state rather than durable contracts |
| Exit and replay | Replay and Done for now after the board; normal route back | Reachable exit and confirmation before destructive reset without adding a navigation trap |
| Local pictures | Selected bounded imports and removal controls | Optional descriptions, favorites and migration-safe annotations |
| Shared viewing | Single-picture view and optional prompts | Consistent quiet view, captions, skip/hide and participant choice |
| Included content | All packs included; source asset mapping exists | Rights, permitted redistribution, duplicate clarity and descriptions need an auditable content review |
| Design/accessibility | App-wide tokens, contrast fix, text floor, target/scale tests added by PR #48 | Physical-device assistive-technology review and complete first-viewport usability, not another palette rewrite |
| Legacy matching | Visible stopwatch/score/confetti removed by PR #48 | WORKBOARD records timed mismatch/hint dismissal in GameCubit; make both deliberate-input driven before a no-pressure claim covers every game |
| Platform links | Existing workboard flags Google Play sharing on all platforms | Verify store-specific links; no photo upload or additional sharing service |
| Cross-platform | Mobile photo flow separated from browser catalog | Browser tests cannot establish native picker, Assistive Access or signed-build behavior |
| Acquisition | Canonical US metadata and storyboard exist | Actual App Store query demand and winning screenshot results remain unestablished |

Entry points: [home](../../../lib/features/gentle_activities/presentation/gentle_home_page.dart), [matching](../../../lib/features/gentle_activities/presentation/gentle_game_page.dart), [local-photo contract](../offline-photos.md), [workboard](../../../WORKBOARD.md), and [product contract](../product.md). Relative links resolve current paths; use the pinned commits for historical comparisons.

## R0 integration requirements

GM-006/007 apply the manual-action mismatch/reveal contract to both matching entry points; preserve stable pack IDs and existing tests. GM-032 includes correct platform-specific referral/store links without changing the approved metadata. GM-012/013/015/016 extend and validate the latest design contract rather than weakening its token floors. Do not ship an unverified dark theme; a contrast/accessibility check applies to every shipped theme.

## Terminology in the catalog

- `source_present`: core behavior exists, not proof of every new criterion or publication.
- `partial`: some behavior exists; this specification extends it or verification is missing.
- `proposed`: future behavior, research or quality work not established as complete.
- `deferred`: requires a separate product decision before implementation.

The catalog is not a second release ledger. Execution belongs in WORKBOARD and release evidence. Existing story IDs G1-G3, P1-P3, V1 and L1 remain stable.

## Parallel work

PR #46 (agent/Flutter guidance) was open at inspection. This change does not replace AGENTS.md or depend on unmerged guide paths. Re-read main before implementation. Newer source may supersede observations; reconcile it rather than copying an older tree over concurrent work.
