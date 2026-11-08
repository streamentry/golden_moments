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
| 4 | Structure and semantics | 15% | mean of: axe violations 0 on the sampled pages (10 or 0); heading order skips 0 on all built pages (10 or 0); landmarks (10 or 0); app semantics tests pass (10 or 0). Axe must cover every built page (3,920) | axe-core 4.14 run; heading scan of `site/dist`; `flutter test` |
| 5 | Reflow and large text | 15% | 10 x share of runs with no sideways scrolling at 320 px in standard and larger text (site); app 200% tests pass (10 or 0); mean of the two | 320 px scan; `flutter test test/ux_detail_test.dart test/l10n` |
| 6 | Localization completeness | 15% | mean of coverage percentages / 10: app keys, site ui keys, site games keys, site guides, site picture names | `scripts/check_arb.py`, `check-translation.mjs`, guide count, picture-name count |
| 7 | Product integrity | 10% | 10 if the gentle-mode rules (no clock, score, streak, forced recall) and claims guards pass their tests; subtract 2 per failing guard | `flutter test` claims and wording tests |
| 8 | Verification health | 10% | mean of: full Flutter suite passes, strict analysis clean, site tests pass, site build and check-site 0 errors (10 or 0 each) | `flutter analyze --fatal-infos --fatal-warnings`; `flutter test`; `vitest run`; `astro build`; `check-site` |

Overall = sum of weight x score.

## Score after Round 9 layout consistency & orientation pass (2026-11-08; earlier 9.87, 9.86, 9.79, 9.59)

| # | Dimension | Measured | Score |
| --- | --- | --- | --- |
| 1 | Plain language | app 441 of 441 strings conform after the six fixes; site play copy 0 long sentences | 10.0 |
| 2 | Type and contrast | floor and 200% tests pass 10; body 15.1:1 gives 10; secondary 8.1:1 gives 10; primary 6.33:1 gives 9.0; high contrast mode & forced colors reinforced = 10; breadcrumb active state 15.1:1 bold = 10 | 9.75 |
| 3 | Targets and navigation | site controls 48 px 10; app target tests 10; icon-only actions carry a word = 10; shape-conforming focus rings on tiles, puzzle pieces, baskets and breadcrumb links = 10; touch & tremor resilience = 10; print action button on handout = 10; zero dead-ends in all games with completion cards = 10; uniform layout order across all 12 games = 10 | 10.0 |
| 4 | Structure and semantics | axe on all 3,921 built pages clean (0 violations); heading skips 0; landmarks fixed; app semantics tests pass | 10.0 |
| 5 | Reflow and large text | site 1,512 of 1,512 runs clean = 10; app 200% tests pass = 10 | 10.0 |
| 6 | Localization completeness | app keys 100%; site ui keys 100% (64 of 64 languages have footer.pictures); games keys 100%; guides 100%; picture names 68.8% (44 of 64) | 9.38 |
| 7 | Product integrity | gentle-mode and claims guard tests all pass | 10.0 |
| 8 | Verification health | Flutter 668 pass; analysis clean; site 675 pass; build 3,921 pages and check-site 0 errors | 10.0 |

Weighted overall: 1.000 + 1.4625 + 1.000 + 1.500 + 1.500 + 1.407 + 1.000 + 1.000 = **9.87**.
Lowest dimension: localization at 9.38 (floor is 7.0). **The bar (above 8.6, none below 7.0) is met.**

## Not verified (not scored, not blockers)

- VoiceOver and TalkBack on hardware; a physical phone at 200% text.
- Native review of any machine-made translation.
- Store review and release approval.
- Brand choices kept by the maintainer: serif headlines and the brand gold (6.33:1 on background, scored in dimension 2).

## Next improvements, by lowest score (for the next loop)

1. Localization (9.38): picture names for the 20 languages left in English (needs a translator; machine output there is unreliable).
2. Type and contrast (9.75): primary gold text at 6.33:1 (brand decision, kept).

History (round 9): Layout Consistency, Audio Setting Feedback & Breadcrumb Orientation. Normalized GameFrame layout order across all activities by moving action buttons in `FinishTheSaying.tsx` and completion cards in `PicturePuzzle.tsx` to `footer`, ensuring polite live status announcements always precede actions; added immediate auditory confirmation chime on sound enable; elevated breadcrumb active page contrast (`color: var(--gm-on-surface); font-weight: 700;`) and `:focus-visible` ring to prevent navigational disorientation.

History (round 5): Dementia-Friendly Print Architecture & Dedicated Handout Action. Print activities (word search, coloring, picture bingo, conversation cards) and caregiver guides are frequently printed onto paper by family members, memory care coordinators, and support groups. Upgraded print sheets with high-contrast `#000`/`#222`/`#333` borders replacing faint `#999`/`#777` borders that wash out for older adults with cataract/contrast loss; upgraded bingo text to 16pt large print. Added print-break protection (`break-after: avoid` on headings, `break-inside: avoid` on cards/answers/tables, `orphans: 3`, `widows: 3`). Stripped digital clutter and app promotion banners (`.cta-band`, `.article-aside`, `.app-cta`, `.play-cta`, `.toc`) from printed output and expanded articles to full paper width. Added a dedicated `.no-print` print action button to `/handout/` across all 64 languages so caregivers can print with one tap without digging through browser menus.

History (round 4): Touch and Tremor Resilience for Digital Dementia Activities. Older adults with dementia and tremors often struggle on touchscreens due to resting-hand contact, accidental drags, unintentional text selection, or trembling double-taps. Added `touch-action: manipulation` across interactive game elements (`.btn`, `.chip`, `.board`, `.tile`, `.basket`, `.puzzle`, `.piece`, `.ws`, `.ws__cell`, `.swatch`, `.color-page`) to eliminate double-tap delay (300ms) and disorienting viewport zoom jumps while preserving smooth single-finger scrolling. Added `-webkit-touch-callout: none`, `-webkit-user-drag: none`, and `pointer-events: none` on inner images to prevent accidental iOS/Android context menus ("Save Image") or ghost drag outlines. Added `user-select: none`, `-webkit-user-select: none`, and `-webkit-tap-highlight-color: transparent` to eliminate distracting blue selection boxes and grey tap flashes.

History (round 3): Sort Together and Word Search completed flows improved. In Sort Together, when all items are sorted into baskets, a calm completion card (.game__done) now appears with the reassuring message `ui.sortTogether.sorted` and a primary button `ui.sortTogether.restart` ("New pictures") so users and caregivers never face an empty void or dead end (W3C COGA Obj 1 & 4, Smart Interface Design Patterns). In Word Search, when all words are found, the footer offers a primary "New puzzle" button alongside "Print this puzzle". Also, shape-conforming `:focus-visible` outlines were added to `.tile`, `.piece` and `.basket` in `games.css`. The missing `footer.pictures` key was added to the 20 remaining language dictionaries in `site/src/i18n/ui/`, bringing UI dictionary completeness to 100% (64 of 64).

History: the library Settings action first failed three 200% tests when put in the app bar; it passes as a body-level button at the end of the page. Hint and Options now sit under the board and scroll with it; the download controls moved into their own wrapping row. The new `commonPause` word is machine-translated in 64 languages (unreviewed). Loading and error states of the library home no longer show Settings.

History (full axe pass): axe-core 4.14 over all 3,920 built pages at 375 px found one rule failing, `scrollable-region-focusable`, on 402 pages: wide markdown tables scroll sideways but could not take keyboard focus. Fix: `FocusableTables.astro` (a bundled script that sets `tabindex="0"` on every `.prose table`) and a `:focus-visible` outline. An `@astrojs/markdown-remark` rehype plugin was not used because Astro 7's default markdown processor does not run it without a new dependency. The table is announced as a table with no extra name.
