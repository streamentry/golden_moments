# Loop run 2026-11-09 (second pass): translated claims, and check-site fixed

Purpose: the same loop prompt as [loop-2026-11-08.md](loop-2026-11-08.md). The earlier 2026-11-09 round is in [loop-2026-11-09.md](loop-2026-11-09.md). This pass also fixed the blocking check-site failures on PR #174.

## Searched

1. **FTC v. Lumos Labs (Lumosity), 2016 settlement.** The settlement bars claims that a product "delays or protects against age-related decline in memory or other cognitive function, including ... dementia, or Alzheimer's disease" unless the claim is backed by competent and reliable scientific evidence. Sources: [a 2016 news report, which quotes the settlement text](https://arstechnica.com/tech-policy/2016/01/lumosity-pays-2-million-to-ftc-to-settle-bogus-brain-training-claims/) and [Reuters, which quotes the FTC statement](https://www.reuters.com/article/legal/lumosity-to-refund-2-mln-apps-brain-training-efficacy-is-unproven-ftc-idUSL1N14P1B1/). Read as search snippets, not full pages.
2. **Link wording (WCAG 2.4.4).** Searched the English UI strings and content for "click here", "read more", "learn more" and bare "here" links. None found, so nothing to change in that family.

Earlier rounds covered contrast, touch, focus, audio, print, navigation and typography (see [TRACKING.md](TRACKING.md)).

## Chosen idea: a translated claim must not say the opposite

A Nauruan (`na`) paragraph under "What we do not claim" on the About page read, in English: "Ete diagnose, test, measure, treat, slow me prevent dementia me Alzheimer's disease". The English is "They do not diagnose, test, measure, treat, slow or prevent dementia or Alzheimer's disease". The translation dropped the negation, so it asserted that the games do diagnose and treat dementia. That is the kind of claim the FTC settlement prohibits, and the repo's own rules forbid it ([AGENTS.md](../../AGENTS.md): no diagnosis, no clinical claims, no claimed treatment or prevention benefits).

Fix: the flagged sentence in `src/i18n/ui/na.json` (`pages.about.bodyHtml`) now uses the English sentence, which states the negation. The rest of that Nauruan page is unchanged. The Nauruan translation is unreviewed machine text, so the rest of it should not be trusted for claims until it is reviewed.

Why this is the best idea of the options checked: it is a user-visible claim error with a legal basis, the check that caught it already exists (`scripts/check-site.mjs`, claims wording), and the fix is one sentence.

## Also fixed on this branch: check-site (blocking PR #174)

- **Meta descriptions.** 1,068 descriptions in translated pages were wider than the 170 limit (up to 355). `BaseLayout.astro` now fits each one to the limit: whole sentences when they fit, otherwise a word-boundary cut with an ellipsis. The width rule matches `check-site.mjs` and is covered by `src/lib/meta-description.test.ts` (7 tests).
- **Two short descriptions.** The Sichuan Yi (`ii`) picture-puzzle description (52 wide) and handout description (58 wide) were under the 70 minimum. Both now use the English text, which is a valid length. This is a mixed-language page until the Yi translations are reviewed.

## Result

- `check-site`: 0 errors, 464 warnings (title lengths; not blocking). Before this change: 1,071 errors.
- Site unit tests: 1,786 of 1,786 pass.
- `tsc --noEmit` passes. `astro build` builds 11,825 pages.

## Not verified

- A native reader of Nauruan, Sichuan Yi or the other unreviewed translations.
- Whether the fitted descriptions read well: a cut at a word boundary can end mid-thought when no sentence fits.
- Whether any other translation drops a negation in a claim sentence. A check looks for claim words, not for lost negations.

## Next idea (for a later round)

A negation audit of every claim sentence across all languages. Check that each sentence containing a disease or treatment word, in each language, keeps a negation whenever the English has one. Start with the "What we do not claim" and FAQ answers on the About, Help and brain-health pages. This needs a native or back-translation review, so it is not started here.
