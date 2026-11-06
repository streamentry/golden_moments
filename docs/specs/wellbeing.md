# Daily wellbeing: Daily moment, Activity planner, My progress

Status: implemented on the branch for this change, with widget and unit tests. Not
device-verified, not approved for release, and not approved as the primary App Store
category. The category is a maintainer decision (see below).

## Why

Golden already offers gentle picture matching, family-photo activities and the
caregiver's "What is hardest today?" page. The goal was a small, daily, unhurried
routine that could sit under a Health & Fitness recommendation, with Lifestyle kept as
the secondary category because the family-photo, reminiscence and shared-activity
features fit it best.

## What it is

- **Daily moment.** Three steps, one picture and one open question at a time, about 5
  to 10 minutes if the person wants that long. It uses the six bundled starter pictures
  and the existing "look together" questions. Done for now records today's date on
  this phone. The person can go back a step or leave at any time.
- **Activity planner ("Plan my day").** Suggested steps for a time of day (morning,
  afternoon, evening) and for whom (oneself, or someone one cares for). A step either
  opens an existing page (Daily moment, matching game, look together) or is a plain
  suggestion with no action. Nothing is saved.
- **My progress.** The dates on which a Daily moment was finished, newest first. Dates
  only. There is no count, score, streak, average or list of missed days. Clearing it
  asks first and leaves pictures and other activities alone.

## Boundaries (all apply)

- No clock, timer, countdown, step count, move count, score, points, streak or
  praise. The "5 to 10 minutes" is a sentence, not a timer.
- No health, fitness, sleep, diet or cognitive claim anywhere in the copy. "Step outside,
  if you can" is a suggestion, not a benefit. Store copy must not change this.
- Local only. No account, network request, telemetry or analytics. The only stored
  value is the list of days (below), on this phone.
- An unreadable saved record is shown as unreadable and is never overwritten by a new
  save. The person can clear it on purpose.
- Every new string has a translator description; other languages fall back to English
  until translated.

## Storage

Key `wellbeing.momentDays.v1` in shared preferences. JSON:
`{"v":1,"days":["2026-11-02","2026-11-06"]}`. Each day is a local calendar day
(yyyy-MM-dd), at most once. Any other shape is unreadable. Code:
`lib/features/wellbeing/data/moment_history.dart`.

## Where it lives

- `lib/features/wellbeing/data/moment_history.dart`: the day store.
- `lib/features/wellbeing/data/routines.dart`: the routine table.
- `lib/features/wellbeing/presentation/`: the three pages.
- Entry points: three text buttons on the Home screen, under "Look together" and above
  the caregiver's "Today" button (`gentle_home_page.dart`).

## Tests

- `test/features/wellbeing/moment_history_test.dart`: keys, dedupe, sort, clear, every
  unreadable shape left untouched, clear of an unreadable record.
- `test/features/wellbeing/wellbeing_pages_test.dart`: the three steps and save, Back,
  the unreadable case, planner choices and navigation, progress list order, confirmed
  clear, and a check that no visible text contains clock, score, streak or countdown
  wording.

## Maintainer decisions still open

1. **Primary category.** `metadata/app-store.en-US.json` now recommends Health & Fitness
   as primary and Lifestyle as secondary. This is a recommendation only. The category
   in App Store Connect has not been changed, and Apple's review of a health-related
   category has not been checked. Changing it needs that check and an explicit decision.
2. **Store description.** The English store description has not been rewritten to
   describe these features. Doing so needs the same no-claims review as any copy.
3. **Translations and native review.** The new strings are machine-made and
   unreviewed, like the rest of the app text.
