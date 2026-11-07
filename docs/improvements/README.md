# Improvements log: dementia and Alzheimer's sources

Goal (2026-11-07): search the dementia and Alzheimer's sites, learn from them, and improve the app and the website one item at a time until nothing else is worth changing. This log records what was learned, what was checked, what changed, and what needs a maintainer decision.

- [sources.md](sources.md): what was read, what was only seen in search results, and what could not be reached.
- [audit-2026-11-07.md](audit-2026-11-07.md): the app and website measured against those sources, with file references.

## Status

| Item | Status |
| --- | --- |
| Research: guidance, interface design and competitor apps | Done for the sources that could be opened; Alzheimer's Society spreadsheet and Dementia UK not reached |
| Audit of app and web | Done by reading code, tokens and copy; no device or assistive-technology run |
| Code change 1: secondary text contrast (G2) | Done: walnut `#5C5346` to `#4F4539` in `DESIGN.md`, `lib/design_system.dart` and `site/src/styles/tokens.css`. Secondary text is now 8.1:1 on surface, 7.1:1 on surface-sunken, 9.4:1 on print white. Full Flutter suite passes (665 tests); strict analysis clean |
| Attempt: labelled help and comfort actions (G1) | Prototyped and reverted. A labelled row under the board, and then in the bottom bar, broke the 200% small-phone layout (a 168 px overflow in the bottom bar) and pushed the board or the comfort button off screen with eight tiles. The tested layout needs a redesign, not a row |
| Attempt 2 of option A (labelled row in the app bar's bottom slot, height scaled with text) | Reverted. At 200% text on a 320x568 phone the row takes about 240 px, and the existing large-text guarantees fail (4 gentle-board tests, 8 failures across the gentle suites). Option A needs either a scrolling row or relaxed large-text guarantees, which is a product decision |
| Code change 2: "Continue" to a verb and object (G5, app) | Done for the daily moment step: new key `dailyMomentShowNextStep` = "Show the next step" (English; other languages fall back to English until translated). Shared `commonContinue` left as is for dialogs. Wellbeing tests updated and passing |
| Code change 3: on-page text-size control (G4, site) | Done: "Standard text" / "Larger text" buttons in the header; choice kept in this browser (guarded storage); root font 125% when on. English strings only; other 65 languages show English until translated. Verified in the built site at 375 px: 16 px to 20 px, state kept on reload, no horizontal overflow |
| Code change 4: visible Home link (G6, site) | Done: "Home" is the first nav item, in addition to the logo. Verified in the built page |
| Translations (this round) | Added to every locale, machine-made and unreviewed as the existing policy allows: site `common.textSize` in 64 languages (the Home nav item reuses the existing `common.home`); app `dailyMomentShowNextStep` in all 67 ARB files. Site `check-translation` reports no new problems (the `footer.pictures` gap in other languages was already there) |
| Verification | Full Flutter suite 665 passing on the final run (one earlier run failed `family_album_test` once; it passes alone and on the rerun, so it looks flaky, not caused by these changes); strict analysis clean. Site: vitest 675 passing; `astro build` 3,921 pages; `check-site` 0 errors (614 title-length warnings, pre-existing in translated titles). DESIGN.md lint not run (npx blocked) |
| Code change 5: labelled help and comfort row (G1, Option A, your choice) | Done: the icon-only app-bar actions on the gentle board are gone; "How this works" and "Comfort settings" are outlined buttons with words, under the board. Tooltips kept. Short screens and large text switch to the scrolling layout, so the row may need a scroll at 200%. Two tests were updated to bring the row into view before tapping or checking the bottom line. New regression test `gentle_tool_labels_test.dart`. Not device-checked |
| Verification (round 5) | Full Flutter suite 668 passing; strict analysis clean |
| Simulator evidence (iPhone 17 Pro simulator, iOS 26.5, debug build) | Default text: home, then the gentle board with four-pair grid, "There is no time limit.", "How this works" and "Comfort settings" under the status line, then "Done for now" and "Start again". Accessibility extra-large text: home wraps without clipping; the board starts above the fold; the labelled row wraps to two-line buttons and is reached by scrolling. Not run: VoiceOver, a physical device, the other 200% phone sizes. Screenshots were taken with the simulator tool; not saved to the repo |
| Round 2: sentence length (Alzheimer's Australia Vic 2015) | Six app strings over 20 words shortened in `app_en.arb` (same meaning; other languages unchanged); one claims-guard test updated for the new sentence casing. Participant-facing website copy already conformed. Detail in the audit's "Round 2" section |
| Commits and PRs | None. Changes are uncommitted on `improve/dementia-research-2026-11-07` |

Not run: `npx @google/design.md lint DESIGN.md` (blocked in this environment). The site checks ran with a symlinked `site/node_modules` from the main checkout.

## Backlog, in the order I would take them

1. **G1, visible words beside icon-only app-bar actions** (attempted; reverted, see status) (`gentle_game_page.dart`, `game_page.dart`, `home_page.dart`). `DESIGN.md` says every icon has a word, and these five icon-only actions do not have one. Two options:
   - A. Put a labelled row (help, comfort settings) under the title on the gentle game page, wrapping at large text. Keep the existing tooltips so `find.byTooltip` tests still work.
   - B. Keep one labelled action in the app bar ("Comfort settings") and move "How this works" into that sheet.
   Option A is closer to the rule; option B is smaller. Either needs a 200% text check on iPhone SE and a device or simulator run. **Decision needed: A or B.**
2. **G5, verb-plus-object button labels.** Copy-only: `commonContinue` and the games' "Next". **Decision needed: approve the new wording, then this is a small PR.**
3. **G4, a text-size control on the website.** Browser zoom already works; an on-page control would need new strings in every site language, which are machine-made and unreviewed. **Decision needed: build it, or rely on browser zoom and say so on the site.**
4. **G2, muted text contrast.** Done (see status). Secondary text is now 8.1:1 on surface and 7.1:1 on sunken surfaces. The 7:1 target is practice from a search result, not a standard.
5. **G3, serif headlines.** One blog says sans-serif is recommended; the Society's own page could not be confirmed. **Next step: open the Society's spreadsheet from a browser before deciding.**
6. **G6, home control.** Trace the app's back path on a device.
7. **G7, memory-test framing.** Product position, not a code change.

## Decisions still open

- G1: done as Option A (see status). It needs a device check at 200% text and VoiceOver. The "board first at large text" rule is kept; the row scrolls below the board at large text.
- G3: the Alzheimer's Society checklist asks for sans-serif type; Fraunces headlines are a brand decision. Kept.
- Colour: several brand colours sit under the checklist's 7:1 minimum (primary 6.3:1 on background). Kept; a brand change.
- The site and app strings are machine-made and unreviewed. A native speaker should check them (the translation policy in `site/src/i18n/TRANSLATING.md`).
- G2 was changed by my call; reverse it in one commit if you prefer the old walnut.

## Why the rest is not done

The sources mostly confirm what the app and site already do. The layout gap (G1) cannot be closed by adding a row without redesigning the large-text layout, which the existing tests protect. The copy gap (G5) needs approval of wording. Each is recorded with its options above.

## How to verify this log

- Every factual claim about code cites a file and line in this branch at `2bdb35d`.
- Contrast ratios were computed with the WCAG relative-luminance formula from the hex values in `DESIGN.md`.
- Sources marked "search snippet only" are not used to justify a change.
