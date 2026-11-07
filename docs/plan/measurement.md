# Measuring use and return without app analytics

Decided 2026-11-07 by the maintainer: the app stays free of analytics SDKs.
Firebase stays removed (WORKBOARD › Maintainer decisions, 2026-10-18), and
`tests/test_network_boundary.py` keeps it out. Engagement and retention are
read from what Apple and Google already measure for every app, plus consented
pilot diaries ([validation](../specs/senior-first/validation.md)). Nothing in
this guide adds a permission, SDK, network request or App Privacy label change.

This is a plan and a reading guide. None of these figures has been observed yet.

## Where each number comes from

Apple's usage metrics count only devices whose owners agreed to share
diagnostics and usage data with developers, and they are blank below Apple's
privacy thresholds (at least five active devices in the range). At about 15
installs a day, many daily cells will be blank or noisy. Read weeks, not days.

| Metric | Source | Definition and limits |
| --- | --- | --- |
| Installations (first-time) | ASC › Analytics › Acquisition, or `scripts/store_downloads.py` | First-time downloads per day. All users, not opt-in only. A download is not a use. |
| New users | ASC "First-time downloads" | Same as above; Apple has no separate "new user" figure. |
| DAU | ASC › Analytics › Usage › Active Devices, daily; or the "App Sessions" report (unique devices per day) | Devices with at least one session (≥2 seconds) that day. **Opt-in only.** It counts devices, not people: a caregiver's phone used with two relatives is one. |
| WAU / MAU | Active Devices with the date range set to 7 or 30 days | Opt-in only. Do not add up daily figures: a device active on 5 days would count 5 times. |
| DAU/MAU | Average daily Active Devices ÷ 30-day Active Devices, same window | A ratio of two opt-in counts. At this scale treat ±10 points as noise. |
| D1 / D7 / D28 retention | ASC › Analytics › Retention (the dashboard also shows Day 14) | Share of devices that installed on a day **and opened the app** that later opened it on day N. Apple measures D28, not D30; use D28 as the D30 stand-in. Devices that never opened the app are excluded. Opt-in only. |
| Returning users | Active Devices minus that period's first-time downloads (approximate) | Not exact: opt-in and all-user counts mixed. Directional only. |
| Sessions per active user | Sessions ÷ Active Devices, same range | Apple's session = app in the foreground ≥2 seconds. A pause in the app can split one sitting into two. |
| Engaged sessions | Not available | Apple has no engaged-session metric. GA4's "engaged session" exists only on the website. |
| Activities completed per active user | Not available in the app | Requires in-app events, which this decision excludes. Website activity events exist through GA4 (`site/src/lib/track.ts`) for the browser games only. |
| Daily activity completion rate | Not available in the app | Same reason. Use pilot diaries: "Did you use Today's activity? Did you finish it? Did you enjoy it?" |
| By country | ASC › any metric › filter or "View by: Territory" | Small territories fall under the privacy threshold. |
| By app version | ASC › Usage › "View by: App Version", or the App Sessions report's version column | Lets you compare before and after a release such as the one with Today's activity. |
| Crash-free sessions (guardrail) | ASC › Analytics › Crashes, and Xcode Organizer | Opt-in only. |
| Deletions (guardrail) | "App Store Installation and Deletion" report | Opt-in only. |
| Google Play equivalents | Play Console › Statistics (installed audience, DAU/MAU) and › User acquisition › Retained installers | Play counts are not opt-in, so they are not comparable with Apple's. Keep the two stores separate. |

## How to look (founder steps)

1. App Store Connect → Apps → Golden Moments → **Analytics**.
2. **Overview**: set the range to the last 30 days. Read First-Time Downloads,
   Sessions, Active Devices and Crashes.
3. **Metrics** → choose *Active Devices* → set the interval to *Daily* (DAU),
   then *Weekly* (WAU), then the 30-day range total (MAU). Use *View by → Territory*
   or *App Version* to split.
4. **Retention**: open the Retention tab and read Day 1, Day 7 and Day 28 for each
   weekly install cohort. Note the cohort size; ignore cohorts under about 20.
5. Downloads by day from the terminal (no app change):

   ```bash
   ASC_KEY_ID=... ASC_ISSUER=... python3 scripts/store_downloads.py --days 28
   ```

   The same ongoing report request (2026-10-30) also produces the "App Sessions"
   and "App Store Installation and Deletion" reports. A reader for those is a
   follow-up; until then use the web console.

## Baseline and the first experiment

- **Baseline window:** four full weeks on the current store build (1.8.0)
  before the build with Today's activity reaches users. Record weekly: first-time
  downloads, weekly Active Devices, sessions per active device, and D1/D7/D28
  for each weekly cohort, with cohort sizes.
- **Change:** the Today's activity card on Home (`lib/features/todays_activity/`).
- **Primary metric:** D7 retention. **Secondary:** D1, D28, daily Active Devices,
  sessions per active device. **Guardrails:** crash rate, deletions, reminder
  complaints or turn-offs reported in support mail, review text, and any
  accessibility regression. A longer session is not a goal; short, pleasant
  sessions are fine for this audience.
- **Reading it:** compare four weeks after release with the baseline, by app
  version. At about 100 installs a week and an opt-in share that is unknown, a
  D7 cohort may hold a few dozen devices. A change of a few points is within
  noise. Report the direction with the cohort sizes; do not claim significance.
  Seasonality (holidays) and store-ranking changes confound a before/after read.

## Reversibility

The card is behind a compile-time switch. Build without it:

```bash
flutter build ipa --dart-define=GM_TODAYS_ACTIVITY=false
```

It stores only a day key and the other activity's id when someone chooses
"Something else" (`todays_activity.day`, `todays_activity.id` in shared
preferences). Removing the card leaves those two keys unused and harmless.

## If in-app analytics is ever reconsidered

It would need a new maintainer decision recorded in WORKBOARD, a caregiver
consent screen with collection off by default, updates to `/app-privacy/`
(which today says the app has no analytics), the App Privacy label
("Product Interaction" and "Device ID" linked or not), the privacy manifest,
`tests/test_network_boundary.py`, and a fresh App Review. Event parameters
would be limited to activity id, completion status, duration bucket and app
version. No names, photos, notes, diagnoses or anything inferred about health.
Advertising SDKs would need a separate decision and ATT review.
