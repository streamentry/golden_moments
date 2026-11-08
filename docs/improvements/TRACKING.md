# 100 Big Improvements Tracker

Goal: Research sites and evidence related to dementia and Alzheimer's, learn from them, choose the best idea one by one, implement it across the app and web, thoroughly verify, log, commit, and push.

**Progress: 7 / 100 completed**

---

## Completed Improvements

| # | Date | Commit | Topic | Primary Source & Rationale | Scope | Status |
|---|---|---|---|---|---|---|
| 1 | 2026-11-07 | `4bfebad` | Secondary Text Contrast Elevation (G2) | WCAG AAA & Alzheimer's Society contrast guidelines: Darkened walnut from `#5C5346` to `#4F4539` across tokens, raising secondary text contrast to 8.1:1 on surface and 7.1:1 on sunken surfaces. | App & Web Design Tokens | Done |
| 2 | 2026-11-07 | `4bfebad` | Plain Language, First-Screen Localization & Reflow | Alzheimer's Australia Vic (2015) Guidelines: Shortened sentences over 20 words; added translated menu & today's activity across 64 locales; fixed 195 heading hierarchy skips; fixed 320px reflow with large text. | App & Web | Done |
| 3 | 2026-11-07 | `1cfcff8` | Dead-End-Free Activity Completion & Shape Focus | W3C COGA Objective 1 & 4; Smart Interface Design Patterns: Eliminated empty void after completing Sort Together & Word Search with calm `.game__done` restart cards; added shape-conforming `:focus-visible` rings; completed missing UI translation keys. | Web Games (`SortTogether.tsx`, `WordSearch.tsx`, `games.css`, `ui/*.json`) | Done |
| 4 | 2026-11-08 | `50ab0b8` | Touch and Tremor Resilience for Digital Dementia Activities | Musa et al. (2023) Touchscreen Guidelines for Older Adults with Cognitive Impairment & AbilityNet (2025): Added `touch-action: manipulation`, `-webkit-touch-callout: none`, `-webkit-user-drag: none`, `user-select: none`, and tap highlight removal across all interactive boards, cards, and buttons to eliminate 300ms double-tap delay, accidental zoom jumps, and OS contextual menu traps. | Web Games (`games.css`, `components.css`) | Done |
| 5 | 2026-11-08 | `eeb9106` | Dementia-Friendly Print Architecture & Dedicated Handout Action | Alzheimer's Society / Dementia UK Print Guidelines & Alzheimer's Australia Vic (2015): Replaced faint `#999`/`#777` activity sheet borders with high-contrast `#222`/`#333`; upgraded bingo to 16pt large print; added page-break protection (`break-after: avoid`, `break-inside: avoid`); stripped digital promo clutter from printouts; added direct one-tap print button to `/handout/` across all 64 languages. | Web Print & Handout (`components.css`, `games.css`, `HandoutView.astro`) | Done |
| 6 | 2026-11-08 | `d824ed6` | Web High Contrast & Forced-Colors Architecture for Visual & Figure-Ground Decline | Alzheimer's Society & Dementia Visuoperceptual Research: Added `@media (prefers-contrast: more)` reinforced 2-3px borders protecting against figure-ground confusion; added `@media (forced-colors: active)` with `forced-color-adjust: none` on coloring swatches/regions to prevent Windows Contrast Themes from stripping color options into blank dots; mapped game selections to system `Highlight`. | Web UI & Games (`components.css`, `games.css`) | Done |
| 7 | 2026-11-08 | `e753de6` | Dead-End Elimination & Auditory Completion Feedback (Picture Bingo & Coloring) | W3C COGA Objective 7 & Smart Interface Design Patterns: Eliminated caller dead end in `PictureBingo.tsx` when all cards are called by replacing inert button with calm `.game__done` card and primary restart button; added immediate sensory completion feedback (`sounds.done()`) when Picture Bingo finishes and when all regions in `Coloring.tsx` are colored. | Web Games (`PictureBingo.tsx`, `Coloring.tsx`) | Done |

---

## Improvement Pipeline (Target: 100)

| # | Improvement Slot | Status |
|---|---|---|
| 8 | *Next in queue* | Pending |
| 9–100 | Planned one by one | Pending |
