# Scoring rubric: repository scoring, no human check

Status: version 2, 2026-11-06. Replaces the earlier self-assessment (71 of 100). Scored by `scripts/score_rubric.py`, which reads only files in the repository. No person, device, store or user data is used. Run it with `python3 scripts/score_rubric.py`.

## What this rubric measures, and what it does not

It measures what the repository shows about each criterion. It does not measure whether the app is the best, whether people choose it, or whether it helps anyone. Two criteria have a ceiling because the repository cannot show their quality (translation quality, and visual taste). Criterion 10 is capped at 0 until a measured study exists in the repository. A high score here is not a claim of being "#1".

Scores are 0 to 10 per criterion, weights equal, total out of 100.

## The ten criteria and their formulas

1. **No prevention or treatment claims.** Scans the app's own UI copy (all ARB files) and the site UI dictionaries for a claim pattern ("prevents/cures/reverses/slows/lowers your risk ... dementia"). A match counts only if it asserts something: questions, sentences with a negation ("no game has been proven to..."), and text introduced by "claims that" are skipped. Score = 10 minus 2 per remaining match. Guide articles are not scored: they quote research, which a pattern cannot tell from a claim.
2. **Gentle play.** English UI copy must not contain a score, streak, countdown, timer, points, a move counter, seconds, "hurry", "timed" or "faster" (negated sentences are skipped). Score = 10 minus 1 per match. The verb "move" is not a move counter and is not counted.
3. **Accessibility (presence of checks).** Six checks, equal weight: a 200%-text test, a tap-target minimum, a semantics-label test, the high-contrast setting, its contrast test, and a hidden-tile test. This checks that the tests exist, not that they pass. Score = 10 times the share present.
4. **Content breadth.** Picture packs in `assets/data/packs_index.json`. Score = min(10, 10 times packs / 12). Currently 8 packs, so 6.7.
5. **Languages (ceiling 8).** Share of app languages whose ARB file has every English key, times 8. The ceiling is because translation quality is not measured.
6. **Website guides.** Share of all site languages that have all 40 English guides, English counting as one. Languages without a guide folder count as zero, so the denominator is all 65 site languages. Currently 51 of 65, so 7.8.
7. **Privacy.** 10 if no analytics, advertising, crash or cloud SDK appears in `pubspec.yaml`, otherwise 0.
8. **Price.** 10 if no in-app purchase or subscription SDK appears in `pubspec.yaml`, otherwise 0.
9. **Design consistency (ceiling 7).** Share of `DESIGN.md` color tokens that have a matching Dart constant, times 7. This checks consistency, not taste: taste has no repository measure.
10. **Evidence of effect (capped at 0 until a result file exists).** 0 if no usability or pilot results file exists under `docs/`, 5 if one exists. The 5 is the ceiling until measured use from real people is recorded, and a result file must still be reviewed by a person before the score is trusted.

## Current score

**79.5 of 100** on 2026-11-06. Criteria 1, 2, 3, 7 and 8 are at 10. Criterion 4 is 6.7 (8 packs). Criterion 5 is 8 (ceiling). Criterion 6 is 7.8 (guides for 13 newer languages and Mongolian are missing). Criterion 9 is 7 (ceiling). Criterion 10 is 0 (no measured study).

## Corrections made while building the scorer

- The first claim scan counted FAQ questions and a list of prohibited claims as assertions. Both are now skipped, and the claim scope excludes guide articles.
- The first pressure scan counted the verb "move". It now counts only move-counter wording.
- The first guide-coverage denominator left out languages with no guide folder. It now uses all 65 site languages.

These are scorer corrections, made because the first version measured the wrong thing. They were not made to raise the total.

## Reaching 90

The total would reach 90 only if criteria 4, 6, 9 and 10 rose substantially. Criterion 10 requires a measured study, criterion 9 needs a visual or usability check that the repository cannot do, and criterion 4 needs new content with clear picture rights. None of these is a code change, so a 90 from this scorer would need that work first.
