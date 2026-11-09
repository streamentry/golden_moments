# Loop run 2026-11-09 (scheduled pass): negation scan, no code change

Purpose: the same loop prompt as [loop-2026-11-08.md](loop-2026-11-08.md). This is the scheduled pass, following [loop-2026-11-09-claims.md](loop-2026-11-09-claims.md), which named a negation audit across languages as the next idea.

## What was tried

An automated scan of every `site/src/i18n/ui/*.json` file: find strings that mention a disease or treatment word, then check whether each contains an English negation word (not, no, never, nor, cannot, do not, does not).

## Result: the scan does not work

- Of 22 English claim strings with a negation, the scan matched no translation as a claim with its negation.
- It flagged 98 Latin-script languages. Almost all of those flags are false positives: each translation expresses the negation in its own words, so an English-word check cannot see it.

So an automated scan cannot tell whether a translated claim has lost its negation. That check needs either a back-translation into English, reviewed by a native speaker, or a per-language list of negation words. This round did not add either. No code changed.

## What would work

1. Back-translate the claim sentences (About "What we do not claim", FAQ answers that mention diagnosis, treatment or prevention) for every language, then compare each back-translation with the English.
2. Start with the languages shipped to the most people. The app and site languages currently in the index are the first set; the unreviewed machine translations come after.
3. For the claim sentences only, keep the English wording where no reviewer is available, as was done for the Nauruan sentence in [loop-2026-11-09-claims.md](loop-2026-11-09-claims.md).

## Decisions needed

- Whether the back-translation review is worth doing for the unreviewed languages (for example, a native reader or an agreed external service), or whether the English fallback for claim sentences is enough.

## Verification

- This round changed only documentation. No test or build was run for it.
- The scan was run from a Python script in the scratchpad and was not kept.
