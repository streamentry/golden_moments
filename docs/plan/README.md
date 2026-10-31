# Plan: the obvious choice for one job, then a category we can measure

Proposal, not status or approval. Restructured 2026-10-31 to reconcile
[category-leader.md](../strategy/category-leader.md) with the earlier version of
this plan. Status lives in [WORKBOARD.md](../../WORKBOARD.md). Appendices:
[verification](verification.md) (facts checked, corrections, could not verify),
[detail](detail.md) (use cases, features, languages),
[competitors](competitors.md), [evidence](evidence.md),
[language markets](language-markets.md). Labels: **proven** (observed or a
primary source), **hypothesis** (plausible, untested), **assumption** (a chosen
number).

**"#1" per storefront** (unchanged from the earlier plan; proposed decisions,
not benchmarks): top 3 in App Store search for the local head terms in 8 of 12
weeks; an average rating of at least 4.5 from at least 50 ratings; at least 8 of
20 pilot households return voluntarily within 7 days; at least 4 of 5 caregivers
describe it correctly after five seconds on the first screenshot, none inferring
treatment; and running costs covered without ads. One addition, with a reason: a
**helpful rate** of at least 70% on at least 50 answers to the website's "Did this
help today?". It is the only caregiver-reported value signal available without
app telemetry.

## 1. The decision

**Own one job: "find something comfortable to enjoy together in the next minute",
for US families caring for someone at home, on whatever is at hand: a phone, a
browser, a TV or paper.** Activity staff in memory care, adult day and library
programs are the second segment, tested in the same pilot.

This follows the earlier plan on scope (one job, made reliable, then
multilingual) and takes five things from category-leader.md: the website as a
free public utility rather than a landing page; problem-specific pages
("keeps asking to go home") over generic tips; value before any sign-up; no
advertising in care workflows; and engagement, not cognition, as the promise. It
rejects, for now, the care platform (accounts, care log, clinician summaries,
subscription, GUIDE pilots): that space already has free nonprofit tools and
Alzheimer's Care Partner, Elevmi's US App Store page returns 404, GUIDE pays nothing
separately for apps, and it would lift four AGENTS.md boundaries at once.

Why this job (scores in [verification](verification.md) §3): NICE NG97 tells
clinicians to offer activities tailored to preferences (**proven**, guideline);
the need recurs daily for years; GM is already the top Apple search result for
"dementia activities" (**proven**, approximate, iTunes Search API); the
competitors in the job are paid (Memory Lane, $69.99/yr), ad-supported or
abandoned; and it fits every current boundary.

**Evidence that would switch the choice to the care platform:** category-leader's
own web test (20–30 caregivers; "What is hardest today?", one answer, a one-tap
log, a printable summary) gets at least 10 to return unprompted within 7 days and
at least 3 to say they or their provider would pay, *and* the activity pilot
misses 8 of 20. Both: a platform must beat free nonprofit tools and the job GM already does.

- **Counterargument:** commercial dementia apps stay small (Memory Lane about 50K
  Play installs; MindMate gone); distribution and caregiver overload may be the
  constraint, whatever the product.
- **Must hold:** families come back without reminders; enough of them search or
  are referred for activities.
- **Cheapest disproof:** the 20-household reuse pilot ([kit](../strategy/reuse-pilot.md)).

## 2. What GM does better than the best alternative

The best alternatives for this job are not apps. They are the **phone's photo
album**, a **printed activity** and a **phone call**. Among apps, Memory Lane
Games is the strongest.

| Versus | GM is better at (status) | GM is worse at |
| --- | --- | --- |
| Photo album | Matching, Look together prompts and captions turn photos into a shared activity with no setup (**hypothesis**) | Zero learning; already on every phone |
| Printed activity | Free, endless, personal photos; the website also prints (**proven** features) | Touchable, no screen, a good gift |
| Memory Lane Games | Free, no subscription (its top complaint), works in a browser and on paper, personal photos (**proven** features) | 1,500+ games, a cited trial, a care-home edition |
| Oya, senior game apps | No ads, no scores or timers, adult look (**proven** features) | 500K+ installs, thousands of ratings |

The category's loudest review complaints are ads, subscriptions, logins, online
dependency, childish content and abandoned apps ([competitors](competitors.md)).
GM answers all of them and says so nowhere prominent. Category quality is low (uMARS 3.35 of 5 across 17 apps).

- **Counterargument:** none of this is a moat. What compounds is ratings, indexed
  pages, organization listings and the helpful-rate record.
- **Must hold:** "less setup than the album" is real for families.
- **Cheapest disproof:** in the pilot, compare against the device photo viewer
  (GM-039). If at least 12 of 20 do not prefer GM, the advantage is not shown.

## 3. The single highest-leverage next action

**Read all five "#1" measures for the first time this week, as one scorecard.**
Rank, ratings and downloads are readable now; the helpful rate needs #104; reuse
and comprehension need people. Today none has a recorded baseline, and only the
homepage appeared in Bing's index.

| Alternative | Why not first |
| --- | --- |
| Translate (es, vi) | Multiplies a loop nobody has measured; the earlier plan says the same |
| Device acceptance | Required before more releases, but it decides quality, not direction; it runs in parallel on hardware |
| New modes or a care log | No evidence about which problem limits use |
| More content | Pages that are not indexed earn nothing |
| Paid search | No approved budget; retention unknown |

**Ships in 7 days:** Search Console and Bing verified, sitemap submitted; #104
merged and `answer` registered in GA4; `scripts/store_downloads.py` reading
first-time downloads and deletions per day; App Store and Play positions and
rating counts recorded in `keyword-research.csv`; a scorecard table in WORKBOARD;
pilot and five-second-test recruitment started.

**Success:** by day 14, every measure has a dated value or a stated reason it has
none.

- **Counterargument:** measuring changes nothing by itself.
- **Must hold:** enough traffic exists to read (more than about 30 activity starts
  a week, **assumption**).
- **Invalidates it:** if pages are already indexed and starts stay under that
  after 14 days, demand reaching GM is the constraint; switch to direct
  distribution (pilot, associations, roundups).

## 4. Roadmap and gates

| By | Do | Continue if (**assumptions**) | Otherwise |
| --- | --- | --- | --- |
| Day 7 | Scorecard (section 3); age questionnaire re-answered truthfully; device acceptance on one iPhone started | Every measure has a baseline | Fix the missing source first |
| Day 30 | Pilot run (12 families, 8 staff); five-second test; two problem pages live; strings moved to ARB (no-regret for any language); "No ads. No subscription. No account. Works offline." in the second screenshot and Play short description; Play 1.5.0 confirmed live | Pilot ≥8/20 return, ≥12/20 prefer GM; helpful ≥70% (n≥50); ≥50% of sitemap URLs indexed | Reuse fails: diagnose setup and activity fit, add nothing. Helpful 50–69%: fix the activities with most "Not really" first. Below 50%: stop growth work |
| Day 90 | Segment decision (staff if ≥2× families' return or print rate, or ≥5 organizations adopt); en-GB and es-MX listings; GM-041 participant-language test with 3 Vietnamese- and 3 Spanish-speaking families | US top 3 for 2 of 3 head terms; ≥20 ratings averaging ≥4.5; GM-041 families ask for it unprompted | Hold languages; deepen US distribution |
| Day 365 | Languages per [detail](detail.md) A4, each held unless it reaches top 3 within six months; a paid path only if a gate below passes | US meets all five "#1" measures | If reuse and helpful both stay below gate for two quarters, stop new features and keep GM as a maintained free resource |

- **Counterargument:** gates slow a small team.
- **Must hold:** gates are read on schedule.
- **Cheapest disproof:** if a gate is skipped twice, replace the plan with the
  day-7 scorecard alone.

## 5. Growth

Founder-led and cheap first; no paid spend without an approved budget.

1. **Search:** problem-to-activity pages (asking to go home, repeated questions,
   visiting day, late afternoon, a rainy day), each with what to say, red flags,
   two activities and a printable. A few excellent pages a month, human-written
   and sourced; no mass production.
2. **App discovery:** ratings through the existing prompt only; the review-gap
   message in screenshots; en-GB and es-MX listings as US and UK reach moves.
3. **Associations and care settings:** memory cafés, Area Agencies on Aging,
   libraries, adult day programs and support groups via `/for-organizations/`
   and `/handout/`; follow up the nine October pitches; get listed in "best
   dementia apps" roundups.
4. **Referral loop:** "Share with family" in the app and the handout carry the
   site; App Store campaign tokens (`ct=web`) make web-to-install visible.
5. **Retention:** the optional reminder the caregiver sets, personal photos and
   new local packs; never streaks or nudges.

- **Counterargument:** AI answers may satisfy searches without a visit.
- **Must hold:** organizations list free tools for families.
- **Cheapest disproof:** 20 organization asks; fewer than 3 listings after 30 days
  means outreach is the wrong channel.

## 6. Business model and unit economics

- **Uses:** the person living with dementia, with a family helper or staff.
- **Pays:** nobody today. Candidates: families (one-time unlock), organizations
  (group use), grants.
- **Recommends:** associations, memory cafés, activity directors, social workers,
  roundup sites, search and AI answers.
- **Can block:** store review (claims), the 16+ age rating, care-setting
  procurement, family distrust of ads or subscriptions, stigma of "dementia" in a
  name, and the person living with dementia.

| Option | Verdict |
| --- | --- |
| Free core, no ads | Keep; required for trust and reach |
| One-time unlock for extra packs (about $6.99, **assumption**) | Test after day 90 if reuse passes; needs the payments boundary lifted |
| Organization tier (group mode, weekly printable plan) | Test only if staff win the segment decision |
| Subscription | No: only 12% of caregivers in a 2026 convenience survey would pay out of pocket, and surprise subscriptions are the category's top complaint |
| B2B health systems, GUIDE | Later; no app payment exists in GUIDE |
| Ads | No |

**Economics today:** fixed costs are small (Apple $99 a year, a domain,
Cloudflare static hosting); no acquisition spend. The constraint is founder time,
so prefer work that compounds (indexed pages, ratings, listings). No revenue scenario is given: it would be invented.

- **Counterargument:** free forever may not fund the work.
- **Must hold:** a small share of returning families or organizations will pay
  once.
- **Cheapest disproof:** after day 90, ask 10 organizations and 20 returning
  families what they would pay, before building payment.

## 7. Product and technical

**One system.** The website is the front door: it answers the search, starts an
activity in seconds with no sign-up, prints, and points to the app only for what
the web cannot do (personal photos offline, a home-screen habit, a reminder). The
app is the habit at home. Both share DESIGN.md.

- **Accessibility:** DESIGN.md gates stay mandatory; device, VoiceOver and TalkBack
  checks are open and block the next release.
- **Localization:** move strings to ARB first; then en-GB, es-MX (supported on
  the US storefront; vendors, not Apple, report it is indexed), vi through GM-041
  participant language as a US move (first-language reversion is weak, mixed
  evidence, so GM-041 is a hypothesis); other languages per
  [detail](detail.md) A4. Mainland China excluded (ICP filing). 치매, 老年痴呆
  and *démence* are naming problems for native reviewers, not translations.
- **Privacy:** no backend, no accounts; the website sends only the event names in
  #104 and a fixed Yes/Not really answer; app retention comes from store reports.
- **Claims:** enjoyment, conversation and mood in the moment only. Nothing about
  cognition, memory, agitation, sundowning, caregiver burden or disease course
  (FDA general wellness 2026 never names Alzheimer's, so even "mental acuity"
  is unsafe beside a dementia audience; FTC Lumosity 2016; Apple 1.4.1 and 5.1.1(ix), the
  Google Play "not a medical device" sentence, MHRA labeling).
- **AI where it clearly helps:** translation drafts with native review, image alt
  text and source checks in production. **Where it would not:** a chat companion,
  generated activities, scoring, or anything that sends family photos off the
  device. No AI in the app.

- **Counterargument:** without accounts, families cannot share packs.
- **Must hold:** one device per household is enough for the job.
- **Cheapest disproof:** count pilot households that ask to share photos across
  devices; above 5 of 20 reopens GM-022 file packs (no backend).

## 8. Measurement

| Measure | Source | Baseline (2026-10-31) |
| --- | --- | --- |
| First-time downloads, deletions, sessions per storefront | App Store Connect reports (`scripts/store_downloads.py`); Play Console | Not produced yet; owner reports about 10 a day |
| Search rank on head terms | `keyword-research.csv` (iTunes Search API, Play search) | #1 "dementia activities", not top 14 "dementia games" or "alzheimers games" |
| Ratings | Store listings | iOS 0; Play count too small to show |
| Indexed pages, non-brand impressions | Search Console, Bing | Not verified; Bing showed only the homepage |
| Website activation, meaningful use | GA4 `activity_start`, `activity_restart`, `activity_print` | Starts with #104 |
| Caregiver-reported value | GA4 `activity_feedback` helpful rate, with n | Starts with #104 |
| Voluntary reuse, preference | Pilot record sheet (off GitHub) | Not run |
| Comprehension | Five-second test | Not run |
| Trust | Complaints, medical-claim or privacy incidents (target 0), review themes | 0 recorded |
| Economics | Costs, revenue | Near-zero cost, no revenue |

- **Counterargument:** small numbers get read as proof.
- **Must hold:** every figure carries its count and date.
- **Cheapest disproof:** review the first scorecard for any number without n.

## 9. Maintainer decisions

The three that matter most:

1. **Merge #104 (website activity events).** Recommend yes: it is the only
   caregiver-reported value signal without app telemetry.
2. **Verify Search Console and Bing, and register `answer` in GA4.** Recommend
   this week.
3. **Send the pilot messages** ([kit](../strategy/reuse-pilot.md)). Recommend
   this week; it is the test that can disprove the plan.

Then:

4. Re-answer the App Store age questionnaire truthfully; recommend now.
5. Create the App Store campaign provider token; recommend now.
6. Approve the review-gap message in the second screenshot and Play short
   description, through the canonical metadata and claims check; recommend yes.
7. Promote GM-036 (string extraction) to R1; recommend yes, no-regret.
8. Approve GM-041 participant language as a catalog entry; recommend yes after
   the six-family test.
9. Confirm Play publication and device acceptance gate any new language;
   recommend yes.
10. Approve GM-042 helper settings without a password; recommend a usability
    check first.
11. Approve a translation review budget per language; recommend deciding at day 90.
12. Keep the payments, accounts, backend and AI boundaries; recommend no change
    before the day-90 gates.
