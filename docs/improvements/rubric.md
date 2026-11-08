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

## Score after Round 20 Picture Puzzle hover targeting & guide frame pass (2026-11-08; earlier 9.87, 9.86, 9.79, 9.59)

| # | Dimension | Measured | Score |
| --- | --- | --- | --- |
| 1 | Plain language | app 441 of 441 strings conform after the six fixes; site play copy 0 long sentences; 404 sentence case confirmed | 10.0 |
| 2 | Type and contrast | floor and 200% tests pass 10; body 15.1:1 gives 10; secondary 8.1:1 gives 10; primary 6.33:1 gives 9.0; high contrast mode & forced colors reinforced = 10; breadcrumb active state 15.1:1 bold & border-bottom = 10; site-nav active high contrast borders = 10; skip link non-text contrast 15.1:1 dual ring = 10; puzzle piece completion check forced-color-adjust preserved = 10; text-size switcher active outline = 10; lang-menu active outline = 10; coloring region focus 8px primary & swatch focus ring = 10; word search cell focus 3px & dashed start distinction in forced colors = 10; tile badge framed in forced colors = 10; breathe circle high contrast border = 10; button pill focus conformity & quiet button reinforced borders in forced colors = 10; puzzle guide thumbnail framed in forced colors = 10 | 9.75 |
| 3 | Targets and navigation | site controls 48 px 10; app target tests 10; icon-only actions carry a word = 10; every action pairs icon and label (including ReadAloud) = 10; shape-conforming focus rings on tiles, puzzle pieces, baskets, breadcrumb links, chips, swatches, word search cells and all button pills = 10; touch & tremor resilience = 10; print action button on handout = 10; zero dead-ends in all games with completion cards (including coloring restart action) = 10; uniform layout order across all 12 games = 10; tactile puzzle elevation & swap destination candidate affordance = 10; language-aware 404 error recovery = 10; visuomotor hover region targeting & word search cell hover & puzzle piece hover = 10; instant deterministic ReadAloud button state recovery = 10; vestibular stability in calm breathing under reduced motion = 10; spoken in-activity prompts & automatic speech cancellation on navigation across 7 activities = 10 | 10.0 |
| 4 | Structure and semantics | axe on all 3,921 built pages clean (0 violations); heading skips 0; landmarks fixed; app semantics tests pass | 10.0 |
| 5 | Reflow and large text | site 1,512 of 1,512 runs clean = 10; app 200% tests pass = 10 | 10.0 |
| 6 | Localization completeness | app keys 100%; site ui keys 100% (64 of 64 languages have footer.pictures); games keys 100%; guides 100%; picture names 68.8% (44 of 64) | 9.38 |
| 7 | Product integrity | gentle-mode and claims guard tests all pass; zero failure sounds; all user interactions paired with gentle tap sounds (including picture puzzle replay & sort together restart) | 10.0 |
| 8 | Verification health | Flutter 668 pass; analysis clean; site 686 pass; build 3,921 pages and check-site 0 errors | 10.0 |

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

History (round 20): Picture Puzzle Visuomotor Hover Targeting, Guide High-Contrast Frame & Multisensory Activity Feedback. Added `:hover` border targeting on `.piece`; framed `.puzzle-guide img` reference thumbnail in high-contrast (2px black) and forced-colors (2px CanvasText); eliminated silent taps on restart/play-again in Picture Puzzle and Sort Together; extended spoken in-activity guidance to Picture Puzzle, Sort Together, and Coloring.

History (round 19): Button Pill Focus Conformity, Quiet Action Contrast & Photo Picker High-Contrast Architecture. Added `.btn:focus-visible` with `border-radius: var(--radius-full)` to fix rectangular focus clipping on pill buttons; reinforced `.btn--quiet` under high contrast with 2px borders; preserved `.btn[aria-pressed='true']` in Windows Forced Colors with system `Highlight` outline; reinforced `.photo-pick` with dashed high-contrast borders and shape-conforming focus outlines; added auditory feedback on Photo Pairs restart and replay.

History (round 18): Spoken In-Activity Verbal Assistance Architecture. Added `readAloudText?: string` to `GameFrame.tsx` and speech cancellation on `text` prop change in `ReadAloud.tsx`. Integrated dynamic spoken prompts: Conversation Cards speaks `card.prompt`; Finish the Saying speaks `saying.start` and post-reveal conversation prompt; Picture Bingo speaks called picture name; Find the Same and Shadow Match speak target item names.

History (round 17): Word Search & Paced Breathing Visuomotor Targeting, Focus & Vestibular Stability Architecture. Added hover guidance and 3px focus-visible outline on `.ws__cell`; differentiated `.ws__cell--start` from completed words with dashed borders in forced colors and high contrast; stabilized `.breathe__circle` under `prefers-reduced-motion` to eliminate jarring jumps; framed `.tile__badge` in Windows Contrast Themes; added auditory tap confirmation to Word Search restart and Calm Breathing toggle.

History (round 16): Web Speech API Native Utterance Architecture & Deterministic End State. In `site/src/lib/games/readAloud.ts`, passing plain JS objects to `synth.speak()` caused TypeError in standard browsers requiring `SpeechSynthesisUtterance`. Added native `createUtterance` with fallback, attached deterministic `onend`/`onerror` hooks to restore button state instantly upon speech completion, and added full vitest unit test coverage.

History (round 15): Accessible Coloring Visuomotor Guidance, Region Targeting & Focus Architecture. In `games.css`, added `:hover` targeting on `.color-page [data-region]` (`stroke: var(--gm-primary); stroke-width: 6;`) for pre-tap confirmation; upgraded keyboard `:focus-visible` stroke to 8px high-contrast primary (10px in high contrast mode; system `Highlight` in forced-colors mode); added missing `:focus-visible` ring on `.swatch:focus-visible` (3px primary outline with 3px offset); dynamically surfaced primary restart button upon picture completion eliminating dead ends in `Coloring.tsx`.

History (round 14): Error Recovery, Orientation Preservation & High-Contrast Navigation Architecture. In `404.astro`, corrected Title Case violation to "Play a game"; added language-aware error recovery via `detectPathLocale` and `readCookie`, routing caregiver recovery links directly to their preferred language routes (`/${lang}/...`); added high-contrast and forced-colors active outlines for text size buttons, breadcrumbs active state (`border-bottom: 2px solid Highlight / #000`), and language menu active item (`outline: 2px solid Highlight`).

History (round 13): Multisensory Selection Affordance, Tactile Elevation & Forced-Colors Check Architecture. Added tactile visual elevation (`transform: scale(1.04); box-shadow: 0 4px 12px rgba(60, 44, 10, 0.25);`) to picked up puzzle pieces in `PicturePuzzle.tsx`, with motion-reduction safety; added swap destination candidate affordance (`data-has-selected="true"`) to unselected puzzle pieces; eliminated silent taps across activities (deselection in `PicturePuzzle` and `WordSearch`, invalid word attempt in `WordSearch`, next/prev in `ConversationCards`, color swatch tap in `Coloring`, clear in `PhotoPairs`); preserved completion checkmarks in Windows Contrast Themes with `forced-color-adjust: none` and system `Highlight` borders.

History (round 12): Auditory Overload Prevention, Skip Link Contrast & High-Contrast Focus Architecture. Suppressed runaway audio by cancelling speech synthesis on game restart and exit in `GameFrame.tsx`; upgraded skip link focus ring to 15.1:1 dual ring (`outline: 3px solid var(--gm-background); box-shadow: 0 0 0 5px var(--gm-on-surface);`); added high-contrast and forced-colors focus outlines for ChoiceChips and active ReadAloud buttons.

History (round 5): Dementia-Friendly Print Architecture & Dedicated Handout Action. Print activities (word search, coloring, picture bingo, conversation cards) and caregiver guides are frequently printed onto paper by family members, memory care coordinators, and support groups. Upgraded print sheets with high-contrast `#000`/`#222`/`#333` borders replacing faint `#999`/`#777` borders that wash out for older adults with cataract/contrast loss; upgraded bingo text to 16pt large print. Added print-break protection (`break-after: avoid` on headings, `break-inside: avoid` on cards/answers/tables, `orphans: 3`, `widows: 3`). Stripped digital clutter and app promotion banners (`.cta-band`, `.article-aside`, `.app-cta`, `.play-cta`, `.toc`) from printed output and expanded articles to full paper width. Added a dedicated `.no-print` print action button to `/handout/` across all 64 languages so caregivers can print with one tap without digging through browser menus.

History (round 4): Touch and Tremor Resilience for Digital Dementia Activities. Older adults with dementia and tremors often struggle on touchscreens due to resting-hand contact, accidental drags, unintentional text selection, or trembling double-taps. Added `touch-action: manipulation` across interactive game elements (`.btn`, `.chip`, `.board`, `.tile`, `.basket`, `.puzzle`, `.piece`, `.ws`, `.ws__cell`, `.swatch`, `.color-page`) to eliminate double-tap delay (300ms) and disorienting viewport zoom jumps while preserving smooth single-finger scrolling. Added `-webkit-touch-callout: none`, `-webkit-user-drag: none`, and `pointer-events: none` on inner images to prevent accidental iOS/Android context menus ("Save Image") or ghost drag outlines. Added `user-select: none`, `-webkit-user-select: none`, and `-webkit-tap-highlight-color: transparent` to eliminate distracting blue selection boxes and grey tap flashes.

History (round 3): Sort Together and Word Search completed flows improved. In Sort Together, when all items are sorted into baskets, a calm completion card (.game__done) now appears with the reassuring message `ui.sortTogether.sorted` and a primary button `ui.sortTogether.restart` ("New pictures") so users and caregivers never face an empty void or dead end (W3C COGA Obj 1 & 4, Smart Interface Design Patterns). In Word Search, when all words are found, the footer offers a primary "New puzzle" button alongside "Print this puzzle". Also, shape-conforming `:focus-visible` outlines were added to `.tile`, `.piece` and `.basket` in `games.css`. The missing `footer.pictures` key was added to the 20 remaining language dictionaries in `site/src/i18n/ui/`, bringing UI dictionary completeness to 100% (64 of 64).

History: the library Settings action first failed three 200% tests when put in the app bar; it passes as a body-level button at the end of the page. Hint and Options now sit under the board and scroll with it; the download controls moved into their own wrapping row. The new `commonPause` word is machine-translated in 64 languages (unreviewed). Loading and error states of the library home no longer show Settings.

History (full axe pass): axe-core 4.14 over all 3,920 built pages at 375 px found one rule failing, `scrollable-region-focusable`, on 402 pages: wide markdown tables scroll sideways but could not take keyboard focus. Fix: `FocusableTables.astro` (a bundled script that sets `tabindex="0"` on every `.prose table`) and a `:focus-visible` outline. An `@astrojs/markdown-remark` rehype plugin was not used because Astro 7's default markdown processor does not run it without a new dependency. The table is announced as a table with no extra name.
