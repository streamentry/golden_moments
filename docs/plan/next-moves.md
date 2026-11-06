# Next moves toward the top of the category

Status: proposal and ranking, dated 2026-11-06. This is a plan, not status and not
a store claim. It builds on [competitors](competitors.md), researched 2026-10-30
and 31. Recheck live listings before quoting any of them.

## What "number 1" can and cannot mean here

- No file in this repository can show a global rank. Rank depends on downloads,
  ratings and search, and none of these are visible from here.
- The scoring rubric ([scoring-rubric.md](scoring-rubric.md)) measures repository
  evidence only. It scored 79.5 of 100 on 2026-11-06. It is not a rank.
- So this plan aims at the gaps that buyers describe in reviews, and at gaps we
  can close and check. Nothing here says the app is the best.

## What buyers say is missing, and what we already have

| Gap buyers describe | Our position | Status |
| --- | --- | --- |
| Ads, scam purchases, subscriptions ($50 a week, $7.99 a month) | No ads, no purchases, no subscription | True in the app. Stated in store promotional text and the site |
| "Toddler-like", too childish | Adult picture tiles and plain text | True; needs a design check on a device |
| Settings and login too hard for the person | No account, no login | True |
| Online dependency that breaks on weak Wi-Fi | Starter play offline; picture packs ship with the app | True; imported originals from iCloud may need internet |
| Text and contrast too small | Large tiles, high-contrast option | True for the comfort setting; no color-vision option yet |
| Too few games or photos, repetition | 8 packs, family-photo collections | Gap. Packs need licensed images |
| Only in English or a few languages | 64 app languages; 51 of 65 site languages with guides | Gap in guides; translation quality not measured |

## Ranked moves

Order is by value to a real caregiver divided by cost and blocker. Costs are
judgment, not measured.

1. **Finish the 14 missing guide languages** (Catalan, Czech, Danish, Greek,
   Finnish, Hebrew, Croatian, Hungarian, Norwegian Bokmål, Portugal Portuguese,
   Slovak, Slovenian, Swedish, Mongolian). Value: raises the guide share in the
   rubric from 7.8 to 10. Cost: tokens and checks. Blocker: none for drafts. Each
   guide is machine translated and must be labeled that way until a native
   reviewer checks it. Status: in progress on the working branch.
2. **Native review of the new guides and strings.** Value: the only way to make
   the translations trustworthy. Cost: reviewers, paid or volunteer. Blocker:
   people. Without this, do not describe the new languages as reviewed.
3. **A color-vision option in the comfort settings.** Forget-Me-Not offers
   color-vision modes. Value: a real accessibility gap. Cost: small. Needs new
   tokens in `DESIGN.md` and `lib/design_system.dart` together, contrast tests,
   and string translations. Blocker: none. Candidate for the next tick.
4. **A helper mode with no password.** Recollect and Forget-Me-Not use a PIN to
   keep the person out of settings. The requirements study cited in the
   competitor log warns against passwords for this group. Value: fewer accidental
   changes to photos and settings. Cost: a specification and a decision first.
   Blocker: maintainer decision on what it protects and how it is exited. Write a
   spec before code. Status (2026-11-06): proposal written in
   [helper-mode](helper-mode.md), recommending a press-and-hold gesture, not a PIN.
   Not built.
5. **Licensed picture packs (4 more, to reach 12).** Value: the largest content
   gap; rubric criterion 4 would go from 6.7 to 10. Cost: money or commissioned
   work, with model releases for any people shown. Blocker: image source and
   rights. Nothing in this repository can supply clear rights. Do not add
   placeholder packs to raise the score.
6. **A measured usability study** with 5 to 10 caregiver and participant pairs,
   consent, and a results file that a person reviews. Value: the only route to
   rubric criterion 10. Cost: time and recruitment. Blocker: people, an ethics
   and consent plan, and a maintainer decision. A results file must be real.
7. **Check that the "not a medical device" sentence is everywhere it belongs.**
   The store description says the app does not diagnose, treat, prevent or
   measure dementia. The app's own strings do not repeat it. Google Play requires
   a similar statement for health apps. Value: consistency if the category
   changes with 1.8.0. Cost: copy changes in all ARB files and the site. Blocker:
   a copy review under the rules in `AGENTS.md`.

## What this plan does not do

- It does not claim a rank, and no store copy changes.
- It does not change the primary category. The change to Health & Fitness stays
  held for 1.8.0 by maintainer decision (see [wellbeing](../specs/wellbeing.md)).
- It adds no analytics to the app. The site's Google Analytics was approved by
  the maintainer on 2026-10-25. The app has none.

## Checks for the next review

- Guide translations: `python3 site/scripts/check-guide-translation.py <code>`
  for each new language, then `pnpm verify` in `site/`.
- Rubric: `python3 scripts/score_rubric.py`. Expect the total to move only with
  guides, content or evidence.
- Competitor table: reopen each App Store page before quoting ratings, prices or
  dates. Several dates in the table omit the year.

## Confidence

Medium on the order of moves 1 to 3. High that no repository change can settle
rank, and that moves 5 and 6 need people and money outside this repo.
