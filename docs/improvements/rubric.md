# Scoring rubric for improvement loops

Used by [AGENTS.md](../../AGENTS.md). **Done = overall above 8.6 and no dimension below 7.0.**
Every score comes from automated evidence only. Anything that needs a person or a
physical device is listed under "Not verified" and is not scored, not a blocker.

## Dimensions, weights and formulas

| # | Dimension | Weight | Score formula (0 to 10) | Evidence commands |
| --- | --- | --- | --- | --- |
| 1 | Plain language | 10% | 10 x share of participant-facing strings whose sentences are all 20 words or fewer (app `app_en.arb`; site `play/en.json`) | the sentence-length script in the log (round 2) |
| 2 | Type and contrast | 15% | mean of: text floor and 200% text tests pass (10 or 0); body text contrast 7:1 or more (10 or 0); secondary text 7:1 or more (10 or 0); primary text on background, 10 x min(1, ratio / 7) | `flutter test test/design_system_test.dart`; contrast script on `DESIGN.md` tokens |
| 3 | Targets and navigation | 10% | mean of: site controls 48 px high (10 or 0); app target tests pass (10 or 0); share of icon-only actions that now carry a word, x 10 | touch-target scan; `grep IconButton lib` |
| 4 | Structure and semantics | 15% | mean of: axe violations 0 on the sampled pages (10 or 0); heading order skips 0 on all built pages (10 or 0); landmarks (10 or 0); app semantics tests pass (10 or 0). Minus 0.5 because axe covers a sample, not every page | axe-core 4.14 run; heading scan of `site/dist`; `flutter test` |
| 5 | Reflow and large text | 15% | 10 x share of runs with no sideways scrolling at 320 px in standard and larger text (site); app 200% tests pass (10 or 0); mean of the two | 320 px scan; `flutter test test/ux_detail_test.dart test/l10n` |
| 6 | Localization completeness | 15% | mean of coverage percentages / 10: app keys, site ui keys, site games keys, site guides, site picture names | `scripts/check_arb.py`, `check-translation.mjs`, guide count, picture-name count |
| 7 | Product integrity | 10% | 10 if the gentle-mode rules (no clock, score, streak, forced recall) and claims guards pass their tests; subtract 2 per failing guard | `flutter test` claims and wording tests |
| 8 | Verification health | 10% | mean of: full Flutter suite passes, strict analysis clean, site tests pass, site build and check-site 0 errors (10 or 0 each) | `flutter analyze --fatal-infos --fatal-warnings`; `flutter test`; `vitest run`; `astro build`; `check-site` |

Overall = sum of weight x score.

## Score after the labelled-actions pass (2026-11-07; earlier 9.59 at `89b2280`)

| # | Dimension | Measured | Score |
| --- | --- | --- | --- |
| 1 | Plain language | app 441 of 441 strings conform after the six fixes; site play copy 0 long sentences | 10.0 |
| 2 | Type and contrast | floor and 200% tests pass 10; body 15.1:1 gives 10; secondary 8.1:1 gives 10; primary 6.33:1 gives 9.0 | 9.75 |
| 3 | Targets and navigation | site controls 48 px 10; app target tests 10; icon-only actions 8 of 8 now carry a word (gentle board help and comfort; library Settings; game Hint and Options; download Pause, Try again and Cancel) = 10 | 10.0 |
| 4 | Structure and semantics | axe 0 violations (118 runs); heading skips 0 of 3,921; landmarks fixed; app semantics tests pass; minus 0.5 for sampling | 9.5 |
| 5 | Reflow and large text | site 1,512 of 1,512 runs clean = 10; app 200% tests pass = 10 | 10.0 |
| 6 | Localization completeness | app keys 100%; site ui keys 98.4% (footer link missing in 20 of 64); games keys 100%; guides 100%; picture names 68.8% (44 of 64) | 9.34 |
| 7 | Product integrity | gentle-mode and claims guard tests all pass | 10.0 |
| 8 | Verification health | Flutter 668 pass; analysis clean; site 675 pass; build and check-site 0 errors | 10.0 |

Weighted overall: 1.000 + 1.4625 + 1.000 + 1.425 + 1.500 + 1.401 + 1.000 + 1.000 = **9.79**.
Lowest dimension: localization at 9.34 (floor is 7.0). **The bar (above 8.6, none below 7.0) is met.**

## Not verified (not scored, not blockers)

- VoiceOver and TalkBack on hardware; a physical phone at 200% text.
- Native review of any machine-made translation.
- Store review and release approval.
- Brand choices kept by the maintainer: serif headlines and the brand gold (6.33:1 on background, scored in dimension 2).

## Next improvements, by lowest score (for the next loop)

1. Localization (9.34): picture names and the footer link for the 20 languages left in English (needs a translator; machine output there is unreliable).
2. Structure and semantics (9.5): run axe on every built page, not a sample (removes the 0.5 sampling deduction).
3. Type and contrast (9.75): primary gold text at 6.33:1 (brand decision, kept).

History: the library Settings action first failed three 200% tests when put in the app bar; it passes as a body-level button at the end of the page. Hint and Options now sit under the board and scroll with it; the download controls moved into their own wrapping row. The new `commonPause` word is machine-translated in 64 languages (unreviewed). Loading and error states of the library home no longer show Settings.
