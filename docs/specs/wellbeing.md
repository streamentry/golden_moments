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

## Healthy habits (for adults looking after their health)

A page, **Healthy habits** on Home, for any adult who wants to look after their health as they age, not only for older people or caregivers. It lists six habits taken from the changeable risk factors in the 2024 Lancet Commission report (hearing and vision, blood pressure and cholesterol, physical activity, social contact, smoking and alcohol, head injury). Source facts are the ones in the website guides `brain-health/can-dementia-be-prevented` and `brain-health/risk-factors`.

Rules specific to this page:

- Every habit line says "linked with". Nothing says a habit prevents, protects against, or lowers anyone's risk. The page states that these are not a promise for any one person and that no habit, game or diet has been proven to prevent dementia. A test checks both, and bans claim, brain, score, streak and timer wording (`test/features/habits/habits_page_test.dart`).
- The app is not presented as a way to prevent dementia. Daily moment and the matching game stay recreational, as before; nothing here says they train or protect anything.
- No age is asked and no one is addressed by age. There is nothing to tick off, count, score or track, and no data is stored.
- The source is named as selectable text, with the site name `dementiaactivities.games` and a note that the guide is in English. The app does not open it, which keeps the app's rule that nothing leaves the device from here. The full guide path is not shown because it contains the word "brain", which the localization test keeps out of all app text.
- The page ends with a doctor note and a button to **Plan my day**, which now includes a "call or message someone" suggestion for oneself in the afternoon.

Not done, on purpose: the store listing and metadata are unchanged. Describing the app to people who want to prevent dementia would invite exactly the claim the product must not make, so any change to store copy needs the same no-claims review as all copy, and a maintainer decision.

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
- Entry points: the Home menu (`home_menu_page.dart`), in the "Each day" section, with
  the caregiver's "What is hardest today?" page.

## Tests

- `test/features/wellbeing/moment_history_test.dart`: keys, dedupe, sort, clear, every
  unreadable shape left untouched, clear of an unreadable record.
- `test/features/wellbeing/wellbeing_pages_test.dart`: the three steps and save, Back,
  the unreadable case, planner choices and navigation, progress list order, confirmed
  clear, and a check that no visible text contains clock, score, streak or countdown
  wording.

## Maintainer decisions still open

1. **Decision (2026-11-06): hold the category change until version 1.8.0 is approved.** The primary category stays as it is in App Store Connect for 1.7.0. The change to Health & Fitness (primary) with Lifestyle (secondary) is made with the 1.8.0 listing, after the wellbeing screens are checked on a device and Apple's review of the health-related category is checked. Until then, the recommendation in the metadata is the only record.
   **Primary category detail.** `metadata/app-store.en-US.json` now recommends Health & Fitness
   as primary and Lifestyle as secondary. This is a recommendation only. The category
   in App Store Connect has not been changed, and Apple's review of a health-related
   category has not been checked. Changing it needs that check and an explicit decision.
2. **Store description.** The English store description has not been rewritten to
   describe these features. Doing so needs the same no-claims review as any copy.
3. **Translations and native review.** The new strings are machine-made and
   unreviewed, like the rest of the app text.
