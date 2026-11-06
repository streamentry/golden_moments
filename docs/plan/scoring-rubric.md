# Scoring rubric: how close Golden Moments is to the best choice

Status: self-assessment, 2026-11-06, after PR #145 merged (`0b38405`). Replace these scores with user-test results as they arrive.

"#1 choice" cannot be measured from inside the repo. It depends on real people choosing the app and on store results. So this rubric scores the parts we can check: product, content, language, site and evidence. Each criterion is scored 0 to 10. A score needs evidence in the repo or a stated test. Where the evidence is missing, the score is capped.

## The ten criteria

| # | Criterion | Score now | Evidence | What raises it |
| - | --- | --- | --- | --- |
| 1 | No prevention or treatment claims | 8 | Help and home pages say the app does not diagnose, treat, prevent or measure dementia. Healthy habits says "linked with" and that nothing is proven to prevent dementia. Tests ban claim wording (`habits_page_test`, `arb_files_test`). | A native-speaker review of the health wording in every language. |
| 2 | Gentle, no-pressure play | 8 | No clock, score, streak or countdown in play screens. Tests check forbidden words (`wellbeing_pages_test`, `picture_puzzle_test`). | A device run to confirm nothing reads as pressure. |
| 3 | Accessible for older eyes and hands | 6 | Text floor 16 and 200% text tested. Tap targets 48 and up. High-contrast option in the comfort settings. No device or VoiceOver run. | VoiceOver and TalkBack runs, and a 200% check on a real device. |
| 4 | Content breadth for the shared activity | 5 | Eight picture packs, six starter pictures, the matching game, look-together, word search, puzzle, conversation cards, bingo, coloring, sorting, and the wellbeing features. Competitors claim "thousands" (Memory Lane Games, vendor claim). | More packs, and family-photo features beyond look-together. The photo-frame gap is still open. |
| 5 | Languages in the app | 7 | 64 language codes in the app, with translated text for all. Quality is machine-made and unreviewed. Competitors list 11 to 22 languages, so this is ahead on count. | Native review of each language, starting with the weakest. |
| 6 | The website | 7 | About 3,400 pages built, sitemaps for all 65 languages, 651 site tests, 0 `check-site` errors. Guides: 40 in English, and 13 newer languages still fall back to English. | Translate the 40 guides for the 13 newer languages. |
| 7 | Privacy and trust | 9 | No account, no ads, no analytics in the app, works offline. Store copy says so. Competitor complaints about ads, subscriptions and online dependence do not apply. | Keep it that way; check any new feature against this. |
| 8 | Price and cost | 8 | Free, no subscription, no in-app purchase in the app. | None required; this is a fixed product choice. |
| 9 | Good taste and clear UX | 6 | Design system with tokens, one main action per screen, tests for layout. Judgement of taste has no test. | Usability sessions with caregivers and with adults in their 40s and 50s. |
| 10 | Evidence that it helps people | 2 | No usability study, no install data, no retention data. Category-level studies show low quality across dementia apps, and nothing shows Golden Moments is better. | A small, consented pilot with measured use, as the repo's validation plan describes. |

**Total: 71 of 100** (self-assessed).

## Rules for changing a score

- A score rises only when a test, a file or a measured result shows it. Opinion does not raise a score.
- Criterion 10 cannot go above 5 until there is measured use from real people.
- Criteria 1, 2 and 7 are protected: no change may lower them, and any claim needs the same review as the rest of the copy.
- No score is a claim that the app is the best. This rubric is a way to see the gaps, not a ranking.

## Next steps, in order of value per effort

1. Native review of the new health wording in the languages flagged by the translators (criteria 1 and 5).
2. A device run and a VoiceOver or TalkBack pass on the new screens (criteria 2 and 3).
3. Translate the 40 guides for the 13 newer languages (criterion 6).
4. Usability sessions with caregivers and with 40 to 60 year olds, using the validation protocol in `docs/specs/senior-first/validation.md` (criteria 9 and 10).
5. Decide on the photo-frame gap with the maintainer (criterion 4).
