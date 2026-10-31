# Plan: the obvious choice for one job, then a category we can measure

Proposal, not status or approval. Reconciles
[category-leader.md](../strategy/category-leader.md) with the earlier plan;
updated 2026-11-01. Status lives in [WORKBOARD.md](../../WORKBOARD.md). Appendices:
[verification](verification.md) (facts checked, corrections, could not verify),
[detail](detail.md) (use cases, features, languages),
[competitors](competitors.md), [evidence](evidence.md),
[language markets](language-markets.md). Labels: **proven** (observed or a
primary source), **hypothesis** (plausible, untested), **assumption** (a chosen
number).

**State, 2026-11-01.** iOS 1.5.0 is live (released 2026-10-30, 0 ratings). 1.6.0
(build 10, 20 languages) was submitted on both stores on 2026-10-31 and is
awaiting review; nothing in it is approved yet. The website is live in 20
languages, with the 19 translations kept out of search and sitemaps until native
review. All translations are machine-made and unreviewed, by maintainer decision.
First-time downloads were 7 on 2026-10-29 and 8 on 2026-10-30 (Apple's data starts
2026-10-29). There is no retention, reuse or comprehension data.

**"#1" per storefront** (proposed decisions, not benchmarks): top 3 in App Store
search for the local head terms in 8 of 12 weeks; an average rating of at least
4.5 from at least 50 ratings; at least 8 of 20 pilot households return
voluntarily within 7 days; at least 4 of 5 caregivers describe it correctly after
five seconds on the first screenshot, none inferring treatment; and running costs
covered without ads. One addition, with a reason: a **helpful rate** of at least
70% on at least 50 answers to the website's "Did this help today?". It is the only
caregiver-reported value signal available without app telemetry.

## 1. The decision

**Own one job: "find something comfortable to enjoy together in the next minute",
for US families caring for someone at home, on whatever is at hand: a phone, a
browser, a TV or paper.** Activity staff in memory care, adult day and library
programs are the second segment, tested in the same pilot.

This follows the earlier plan on scope (one job, made reliable) and takes five
things from category-leader.md: the website as a free public utility rather than a
landing page; problem-specific pages ("keeps asking to go home") over generic
tips; value before any sign-up; no advertising in care workflows; and engagement,
not cognition, as the promise. It rejects, for now, the care platform (accounts,
care log, clinician summaries, subscription, GUIDE pilots): free nonprofit tools
and Alzheimer's Care Partner already hold that space, Elevmi's US App Store page
returns 404, GUIDE pays nothing separately for apps, and it would lift four
AGENTS.md boundaries at once.

Why this job (scores in [verification](verification.md) §3): NICE NG97 tells
clinicians to offer activities tailored to preferences (**proven**, guideline);
the need recurs daily for years; GM is the top Apple search result for "dementia
activities" (**proven**, approximate); competitors in the job are paid,
ad-supported or abandoned; and it fits every current boundary.

**Languages are now a running test, not a plan.** The maintainer shipped 19
machine translations before the measurements this plan wanted first. Treat that
as a bet with a cheap read (section 4, day 30), not as proof: translation is
spent, so what remains is native review, per-language screenshots and listing
tuning. The risk is quality in a regulated, emotional subject; the mitigation is
review in the order of [native review](../engineering/native-review.md).

**Evidence that would switch the choice to the care platform:** category-leader's
own web test (20–30 caregivers; "What is hardest today?", one answer, a one-tap
log, a printable summary) gets at least 10 to return unprompted within 7 days and
at least 3 to say they or their provider would pay, *and* the activity pilot
misses 8 of 20. Both: a platform must beat free nonprofit tools and the job GM
already does.

- **Counterargument:** commercial dementia apps stay small (Memory Lane about 50K
  Play installs; MindMate gone); distribution and caregiver overload may be the
  constraint, whatever the product. Rank #1 for the head term yields about 8
  first-time downloads a day, which suggests store search for these terms is
  small (**hypothesis**).
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
| Memory Lane Games | Free, no subscription (its top complaint), works in a browser and on paper, personal photos, now 20 languages (**proven** features) | 1,500+ games, a cited trial, a care-home edition |

The category's loudest complaints are ads, subscriptions, logins, online
dependency, childish content and abandoned apps ([competitors](competitors.md));
GM answers all of them and says so nowhere prominent. Quality is low (uMARS 3.35
of 5 across 17 apps).

- **Counterargument:** none of this is a moat. What compounds is ratings, indexed
  pages, organization listings and the helpful-rate record.
- **Must hold:** "less setup than the album" is real for families.
- **Cheapest disproof:** in the pilot, compare against the device photo viewer
  (GM-039). If at least 12 of 20 do not prefer GM, the advantage is not shown.

## 3. The single highest-leverage next action

**Run the reuse pilot: send the pilot messages this week.** The first scorecard
now exists; it shows GM is already first for its head term yet gets about 8
first-time downloads a day. So the open question is not rank but whether anyone
returns and whether enough people arrive, and only people can answer that.
Everything else (reviews, more pages, more languages) multiplies a loop nobody has
shown to work.

Not first: native review multiplies reach, not return; device acceptance is
overdue (1.5.0 and 1.6.0 shipped without it) but runs in parallel and gates the
next release; new modes, more content or paid search have no evidence behind them.

**Ships in 7 days:** pilot messages sent to 12 families and 8 staff, and the
five-second test started; 1.6.0 approval read back on both stores; downloads read
by territory (the script needs a by-territory option); Search Console and Bing
verified and the sitemap submitted; positions and rating counts recorded in
`keyword-research.csv`.

**Success:** by day 14, at least 20 pilot participants recruited and every measure
has a dated value or a stated reason it has none.

- **Counterargument:** a pilot of 20 is small and recruiting may bias it toward
  friendly families.
- **Must hold:** the households have the job (someone living with dementia at
  home) and are not people we already know.
- **Invalidates it:** fewer than 8 of 20 return in 7 days. Then diagnose setup and
  activity fit before any further release.

## 4. Roadmap and gates

| By | Do | Continue if (**assumptions**) | Otherwise |
| --- | --- | --- | --- |
| Day 7 | Pilot messages and five-second test started; approvals read back; scorecard repeated; age questionnaire re-answered truthfully; device acceptance started on one iPhone | Every measure has a baseline | Fix the missing source first |
| Day 30 | Pilot run (12 families, 8 staff); two problem pages live; native review under way for Spanish and Vietnamese; "No ads. No subscription. No account. Works offline." in the second screenshot and Play short description | Pilot ≥8/20 return, ≥12/20 prefer GM; helpful ≥70% (n≥50); ≥50% of sitemap URLs indexed. **Languages:** 30 days after 1.6.0 is live, at least 20% of first-time downloads come from outside the US or from Spanish or Vietnamese in the US | Reuse fails: diagnose, add nothing. Helpful 50–69%: fix the activities with most "Not really". Below 50%: stop growth work. Languages below 10%: stop review spending after Spanish and Vietnamese |
| Day 90 | Segment decision (staff if ≥2× families' return or print rate, or ≥5 organizations adopt); en-GB listing; GM-041 participant-language test with 3 Vietnamese- and 3 Spanish-speaking families | US top 3 for 2 of 3 head terms; ≥20 ratings averaging ≥4.5; GM-041 families ask for it unprompted | Hold languages; deepen US distribution |
| Day 365 | Reviewed languages only reach search; a paid path only if a gate below passes | US meets all five "#1" measures | If reuse and helpful both stay below gate for two quarters, stop new features and keep GM as a maintained free resource |

- **Counterargument:** gates slow a small team. **Must hold:** they are read on
  schedule. **Disproof:** a gate skipped twice means the plan shrinks to the
  day-7 scorecard.

## 5. Growth

Founder-led and cheap first; no paid spend without an approved budget.

1. **Search:** problem-to-activity pages (asking to go home, visiting day, a rainy
   day), each with what to say, two activities and a printable; a few
   human-written, sourced pages a month.
2. **App discovery:** ratings through the existing prompt only; the review-gap
   message in screenshots; the localized listings as US and international reach.
3. **Associations and care settings:** memory cafés, Area Agencies on Aging,
   libraries and adult day programs via `/for-organizations/` and `/handout/`;
   follow up the nine October pitches.
4. **Referral loop:** "Share with family" in the app and the handout carry the
   site; App Store campaign tokens (`ct=web`) make web-to-install visible.
5. **Retention:** the optional reminder the caregiver sets, personal photos and
   new local packs; never streaks or nudges.

- **Counterargument:** AI answers may satisfy searches without a visit.
  **Must hold:** organizations list free tools. **Disproof:** fewer than 3
  listings from 20 asks in 30 days.

## 6. Business model and unit economics

- **Uses:** the person living with dementia, with a family helper or staff.
- **Pays:** nobody today. Candidates: families (one-time unlock), organizations
  (group use), grants.
- **Recommends:** associations, memory cafés, activity directors, social workers,
  roundup sites, search and AI answers.
- **Can block:** store review (claims), the 16+ age rating, care-setting
  procurement, family distrust of ads or subscriptions, stigma of "dementia" in a
  name, and the person living with dementia.

Verdicts: free core without ads, keep (trust and reach). One-time unlock for
extra packs (about $6.99, **assumption**), test after day 90 if reuse passes;
needs the payments boundary lifted. Organization tier, only if staff win the
segment decision. Subscription, no: 12% of caregivers in a 2026 convenience
survey would pay out of pocket, and surprise subscriptions are the category's top
complaint. Health systems and GUIDE, later (no app payment exists). Ads, no.

**Economics today:** fixed costs are small (Apple $99 a year, a domain,
Cloudflare static hosting); no acquisition spend. The constraint is founder time,
so prefer work that compounds (indexed pages, ratings, listings). No revenue
scenario is given: it would be invented.

- **Counterargument:** free forever may not fund the work. **Must hold:** a
  small share will pay once. **Disproof:** after day 90, ask 10 organizations and
  20 returning families what they would pay, before building payment.

## 7. Product and technical

**One system.** The website is the front door: it answers the search, starts an
activity in seconds with no sign-up, prints, and points to the app only for what
the web cannot do (personal photos offline, a home-screen habit, a reminder). The
app is the habit at home. Both share DESIGN.md.

- **Accessibility:** DESIGN.md gates stay mandatory; device, VoiceOver, TalkBack,
  200% text and Arabic right-to-left checks are open and block the next release.
- **Localization:** app, listings, website, games and 40 guides exist in 19
  languages, machine-made and unreviewed. Review order and sign-off steps are in
  [native review](../engineering/native-review.md): Spanish and Vietnamese first,
  because the US store lists both as additional languages (indexing is
  vendor-reported). Mainland China is excluded (ICP filing). Naming of dementia in
  Korean, Chinese and French is a native-reviewer decision, not a translation.
  GM-041 participant language stays a hypothesis (first-language reversion is weak,
  mixed evidence).
- **Privacy:** no backend, no accounts; the website sends only the event names in
  #104 and a fixed Yes/Not really answer; app retention comes from store reports.
- **Claims:** enjoyment, conversation and mood in the moment only. Nothing about
  cognition, memory, agitation, sundowning, caregiver burden or disease course
  (FDA general wellness 2026 never names Alzheimer's; FTC Lumosity 2016; Apple
  1.4.1; the Play "not a medical device" sentence; see [verification](verification.md) §5).
- **AI:** translation drafts with native review and source checks in
  production; none in the app, and never anything that sends photos off device.

- **Counterargument:** without accounts, families cannot share packs.
- **Must hold:** one device per household is enough for the job.
- **Cheapest disproof:** count pilot households that ask to share photos across
  devices; above 5 of 20 reopens GM-022 file packs (no backend).

## 8. Measurement

| Measure | Source | Baseline (2026-11-01) |
| --- | --- | --- |
| First-time downloads, deletions, sessions per storefront | App Store Connect reports (`scripts/store_downloads.py`); Play Console | 7 (10-29), 8 (10-30); by territory, deletions and sessions not read yet |
| Search rank on head terms | `scripts/store_scorecard.py`, Play search | #1 "dementia activities", #2 "reminiscence dementia", #4 "alzheimers activities", #17 "dementia games" (same on 10-31) |
| Ratings | Store listings | iOS 0; Play count too small to show |
| Indexed pages, non-brand impressions | Search Console, Bing | Not verified; 19 languages now noindex by design |
| Website use and helpful rate (with n) | GA4 `activity_*` events | Live; not read yet |
| Voluntary reuse, preference | Pilot record sheet (off GitHub) | Not run |
| Comprehension | Five-second test | Not run |
| Trust, economics | Incidents (target 0), review themes; costs, revenue | 0 incidents; near-zero cost, no revenue |

- **Counterargument:** small numbers get read as proof. **Must hold:** every
  figure carries its count and date. **Disproof:** any number without n.

## 9. Maintainer decisions

The three that matter most:

1. **Send the pilot messages** ([kit](../strategy/reuse-pilot.md)). Recommend this
   week; it is the test that can disprove the plan.
2. **Name native reviewers, Spanish and Vietnamese first.** Recommend now: the
   translated site stays out of search until a language is reviewed, and the
   subject is regulated and emotional.
3. **Verify Search Console and Bing, and register `answer` in GA4.** Recommend
   this week (not confirmed done).

Then: re-answer the App Store age questionnaire truthfully and reconcile
the 17+ the API reports with the 16+ in our docs; create the campaign provider
token; approve the review-gap screenshot and Play short description through the
canonical metadata; run device acceptance before the next release (overdue);
per-language screenshots after review; GM-041 and GM-042 only after their tests;
a review budget beyond two languages at the day-30 gate; keep the payments,
accounts, backend and AI boundaries until the day-90 gates. All recommended,
none approved.
