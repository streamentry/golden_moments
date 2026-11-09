# Loop run 2026-11-09 (heading pass): descriptive headings checked, no code change

Purpose: the same loop prompt as [loop-2026-11-08.md](loop-2026-11-08.md). Earlier passes are in the other `loop-2026-11-09*.md` logs.

## Searched

- **AbilityNet, "Designing for Dementia" (2025):** paraphrased: arrange content under clear headings and sub-headings; the headings should be descriptive and reflect the hierarchy of the content. Source: <https://abilitynet.org.uk/factsheets/designing-dementia> (search snippet).
- **NIA, "Making Your Website Senior Friendly" (health literacy appendix, snippet):** use action verbs in headers. Source: <https://odphp.health.gov/healthliteracyonline/2010/apdx-e.htm>.

## Checked

Counted every h2 and h3 on the 71 English pages of the built site (11,823 pages in total).

- Most headings are specific: "Picture puzzle", "Find the same", "Questions and answers", "Take these games with you".
- Repeated across all pages, and so not descriptive per page: "Play", "Activity ideas", "For caregivers", "About", "Legal", "Language". These are footer and navigation headings, where repetition is expected.
- Generic and repeated on a few pages: "Good to know" (12 pages), "Helpful guides" (12 pages), "Try together" (39 pages), "Ready for a gentle game?" (45 pages).

## Why no change

- The generic labels ("Good to know", "Helpful guides", "Try together") are shared UI strings. Each is translated into 65 languages in `site/src/i18n/ui/*.json`. Changing the English wording alone would leave the other 64 languages describing a different heading, and changing all of them is a translation task that needs reviewers.
- The "action verb" advice from the NIA is about headers in content. Most of the content headings already read as statements or questions, so a rewrite would be a stylistic choice, not a fix for a known barrier.

## Result

No code or copy changed. This pass records that the heading family conforms well enough for a code change to be unjustified, and it names the translation task that would be needed for the generic labels.

## Decisions needed

- Whether the translation task is worth doing: replacing "Good to know" and "Helpful guides" with descriptive headings in all languages.
