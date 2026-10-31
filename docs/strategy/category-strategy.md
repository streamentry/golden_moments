# Category strategy: what Golden Moments should own first

Decision record, 2026-10-31. It audits Golden Moments (GM) against
[category-leader.md](category-leader.md) and live competitors, then chooses a
category, a roadmap and the evidence gates that decide what happens next.
Numbers are measured, sourced, or labeled **assumption**. Scores are judgments,
not measurements. Nothing here changes the product boundaries in `AGENTS.md`;
where a recommendation would cross one, it is written as a decision for the
maintainer, not as an approved plan.

## The decision in one paragraph

Own **ready-to-use dementia activities to do together: free, no sign-up, on the
web, on paper and on a phone**, for US family caregivers of someone living at
home, with activity staff (memory care, adult day, libraries) tested as a
second segment. Do not build the "dementia care operating system" that
category-leader.md recommends: it is crowded with free nonprofit tools, needs a
backend, accounts and health-data handling that GM does not have, and assumes a
6–8 person team. The single highest-leverage action now is to **make existing
traffic count**: get the website indexed and measure whether visits turn into
shared activities that caregivers say helped. Until that loop exists, every
other initiative is guesswork.

## 1. Where Golden Moments stands (audit)

| Area | Fact (2026-10-31) | Source |
| --- | --- | --- |
| App | Free, offline, no account, no ads, no in-app purchase. Picture matching (4–12 tiles, pictures visible by default), Look together, up to 24 selected family photos as local copies, 8 bundled packs, iOS reminders, Apple rating prompt, share link | `lib/`, `pubspec.yaml` 1.5.0+9 |
| App languages | Effectively English only: UI strings are hard-coded; the ARB files hold only template strings | `lib/l10n/arb/` |
| App measurement | None in the app by policy. App Store Connect analytics request created 2026-10-30; no daily data yet. The vendor number for Sales reports is not recorded | `scripts/store_downloads.py`, run 2026-10-31 |
| Installs | Owner-reported about 10 a day (unverified). Google Play listing shows **10+ installs** | owner; Play listing |
| Ratings | iOS **0 ratings**; Play 4.7 with a count too small to show | App Store and Play, 2026-10-31 |
| App Store search | **#1 for "dementia activities"**, #2 for "reminiscence dementia"; not in the top 14 for "dementia games" or "alzheimers games" (brain-training apps hold those) | iTunes Search API, 2026-10-31; this approximates, not equals, App Store ranking |
| Play search | #4 for "dementia activities"; not top 10 for "dementia games" (Oya, 500K+ installs, leads) | logged-out Play search |
| Age rating | 16+, unusual for a picture game and likely to deter families | `docs/strategy/us-aso.md` |
| Website | 72 pages: 12 browser games (4 printable), 38 sourced guides, organization page, app page, legal pages. English only. Live since 2026-10-25, deploys on every merge since 2026-10-31 | `site/` |
| Website search | Only the homepage appeared in Bing's index; not in the top 10 for any tested query. Google Search Console and Bing Webmaster Tools are **not verified** | DuckDuckGo/Bing check 2026-10-31; `web-seo.md` |
| Website measurement | GA4 page views only (Google signals and ad personalization off; not on Photo pairs). No activity, print or helpfulness signal before this change | `site/src/components/Analytics.astro` |
| Traffic | Owner reports a lot of ChatGPT referrals (unverified, no numbers recorded) | `web-seo.md` |
| User research | None recorded. The five-caregiver comprehension test and the 12/20-unit usability and reuse studies (GM-039) have not started | `docs/specs/senior-first/validation.md` |
| Outreach | 9 link pitches sent 2026-10-25, no recorded replies | `link-building.md` |

**Repository discrepancies found** (reported, not silently treated as truth):
`release-status.json` still names release 1.4.0+7; the Play metadata says
"Draft for 1.3.0"; the WORKBOARD website table said "no analytics" although
GA4 was approved on 2026-10-25 (corrected in this change).

**What this means.** GM has a product that matches its promise, a store
position on its core query, and a content site, but almost no evidence about
use. The bottleneck is not features. It is that nobody can yet see whether
anyone finds, uses or values it.

## 2. Audit of category-leader.md

### Claims checked against primary sources

| Claim | Verdict | Correct statement |
| --- | --- | --- |
| 7.4M Americans 65+ with Alzheimer's dementia; ~13M unpaid caregivers; $409B in 2026 costs | Confirmed | Alzheimer's Association 2026 Facts and Figures. $409B excludes unpaid care (valued at $446B+) |
| ~57M people with dementia worldwide | Confirmed with a caveat | It is WHO's **2021** estimate, nearly 10M new cases a year |
| WHO recommends physical activity (high certainty) | Confirmed, wrong citation | WHO mhGAP 2023 dementia update. Cognitive stimulation is conditional, low certainty. The July 2026 WHO guideline covers risk reduction, not people living with dementia |
| NICE NG97 | Confirmed | "Offer a range of activities to promote wellbeing that are tailored to the person's preferences"; do not offer cognitive training to treat mild–moderate Alzheimer's |
| Digital reminiscence and music evidence | Confirmed, weak | Digital reminiscence: possible short-term benefit on behavior/mood symptoms from few small trials; no effect on cognition (BMC Neurology 26:296, 2026). Music: probably a slight reduction in depression, no effect on agitation or cognition, no long-term effect (Cochrane CD003477.pub5, 2025) |
| REACH II: 495 dyads | **Wrong** | 642 caregivers randomized; a human-delivered home and phone program, not an app (Belle et al. 2006) |
| CMS GUIDE: 292 participants; partner contracting allowed | Mostly confirmed | 292 on the CMS page (updated 2026-10-27), down from about 390 at launch. **No separate payment for digital tools**; services are paid as one monthly amount per patient |
| FTC Health Breach Notification Rule covers non-HIPAA apps | Confirmed | Rule finalized April 2024; still in force |
| Memory Lane Games: 3,000+ games, $9.99/mo | Outdated | Listing now says 1,500+ games; $9.99/mo or $69.99/yr; iOS 4.6 (104 ratings) |
| Elevmi as a current leader | Outdated | The US App Store page returns 404 (removed or region-locked) |
| Data on dementia caregivers' app use and willingness to pay | **Missing** | No representative dementia-specific data found. AARP/NAC 2025 (all caregivers): 41% track health records with technology, 19% use electronic task lists. A 2026 Caregiver Action Network convenience survey (272 people): 32% say tools should be free, 12% would pay out of pocket |

### What holds, and what does not fit GM

Holds and is adopted: no brain-training or cognitive claims; value before sign-up;
the caregiver as the person who chooses and sets up; separate, simpler experience
for the person living with dementia; no advertising in care workflows; the
website as a useful public utility rather than a landing page; problem-specific
pages beat generic tips; retention matters more than price; prove organic retention
before paying for users. Its strongest counterargument, that dementia apps stay
small and adoption is the real constraint, is also adopted.

Does not fit and is rejected for now:

- **The care-OS category** (care log, care circle, visit summaries, AI assistant).
  Alzheimer's Care Partner, My ALZ Journey and the free ALZNavigator already
  serve it; Elevmi's apparent withdrawal from the US App Store is a warning
  about its economics. It needs accounts, sync and health-data handling, all
  outside GM's approved boundaries.
- **A 6–8 FTE, 24-month plan with an RCT program.** GM is a small team. Trials
  come after use exists, not before.
- **GUIDE as the first B2B wedge.** GUIDE pays no separate rate for apps, has
  shrunk, and sells through long health-system cycles. It is a later channel for
  a proven product, not a first buyer.
- **≥1M MAU and a multicenter trial as the definition of #1.** No baseline or
  benchmark supports those numbers for GM.

## 3. Category options and the choice

Scored 1–5 by judgment. Score = value × evidence × distribution × defensibility
÷ cost-and-risk.

| Option | Value | Evidence | Distribution | Defensibility | Cost/risk | Score |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| **A. Ready-to-use activity library: web + print + app, for families** | 4 | 4 | 5 | 3 | 2 | **120** |
| B. Same library aimed first at activity staff (memory care, adult day, libraries) | 4 | 3 | 4 | 3 | 2 | 72 |
| C. Family-photo reminiscence app only | 4 | 2 | 2 | 3 | 2 | 24 |
| D. Caregiver care-OS (log, circle, visit summary, AI) | 5 | 3 | 2 | 4 | 5 | 24 |
| E. GUIDE / health-system B2B first | 3 | 2 | 2 | 4 | 5 | 10 |
| F. Brain-training games | 2 | 1 | 3 | 1 | 3 | 2 |

Why A wins:

1. **Guidelines support the job, not a product claim.** NICE tells clinicians
   to offer activities tailored to the person's preferences; WHO recommends
   physical activity and conditionally supports cognitive stimulation; neither
   supports cognitive training. There is no evidence that GM itself helps, and
   digital reminiscence evidence is weak, so GM promises an enjoyable shared
   activity and measures whether families find it helpful, nothing more.
2. **The need recurs daily.** "What can we do together right now?" comes back
   every day for years (people 65+ live four to eight years on average after
   diagnosis). Care-planning tasks come back monthly.
3. **Distribution is already partly won.** GM is the top Apple result for its
   core query, and the web results for activity queries are long idea lists,
   printables and small blogs, which a focused site can beat. ChatGPT already
   sends visits.
4. **It fits the constraints.** Static site, offline app, no accounts, no
   backend, no health data. Running costs are near zero.
5. **Competitors leave a gap.** Memory Lane Games, the best activity app, is
   $69.99/yr and quiz-based. Oya leads Play with a plain matching game. Memory
   Bond has the family-photo idea but no traction. The caregiver apps do
   coordination, not activities. B2B engagement vendors (iN2L/LifeLoop,
   Rendever, Tovertafel) cost thousands per site and do not serve families.

B is kept as a test, not discarded: activity staff run activities every day,
recommend tools to families, and are already addressed by `/for-organizations/`.
If they show more repeat use than families (gate G4), they become the wedge.

**Category statement.** Golden Moments is the free place families go when they
need something good to do with someone living with dementia, and it works in
ten seconds on whatever is at hand: a browser, a TV, a printer or a phone.

## 4. Competitive advantage, honestly

Meaningfully better than the alternatives today:

| Versus | GM is better at | GM is worse at |
| --- | --- | --- |
| Memory Lane Games | Free, no subscription surprise (its top complaint), works in a browser and on paper, personal photos | Content volume (1,500+ games), awards, a cited trial, a care-home Pro app |
| Oya and senior game apps | No scores, timers or ads; designed for shared use and dignity | Install base (500K+), ratings counts in the thousands |
| Alzheimer's Association, Alzheimer's Society | Something to *do* immediately, not reading | Authority, trust, search dominance, local services |
| Printed books, Keeping Busy, Relish ($9–$450) | Free, endless, personal photos | Touchable, good as gifts, no screen |
| Care-coordination apps | Simpler, no setup | Not a coordination tool (by choice) |

None of these is a moat on its own. The moat GM can build is **compounding**:
search authority across hundreds of activity and problem pages, a growing ratings
lead on its core store query, links and referrals from organizations that list
it, and a consented signal of which activities actually helped (section 8). A
large competitor can copy a feature; it cannot quickly copy two years of earned
trust and that feedback record.

**Reasons GM may never lead:** the Alzheimer's Association and senior-living
publishers own the head terms; Oya owns "dementia games" on Play; AI answers may
satisfy queries without a visit; families may not adopt any app (the research
doc's own counterargument); physical products win as gifts; and a small team
with no revenue can stall. The gates below are designed to find these out
early and cheaply.

## 5. Product strategy: one system

**Website = the front door.** It answers the search, lets someone start an
activity in seconds with no sign-up, offers a printable, and points to the app
only where the app does something the web cannot (personal photos offline, a
home-screen habit, a reminder).

**App = the habit at home.** Personal photos, offline, large targets, no
pressure, a gentle reminder the caregiver chooses.

**Shared promise.** Visible-picture play, no clock or score, an easy way to stop,
plain adult language, no medical claims (DESIGN.md, AGENTS.md).

### Roadmap, each item tied to an observed or researched problem

| When | Item | Problem it solves | Evidence status |
| --- | --- | --- | --- |
| Now | Activity measurement on the website (this change) | Nobody can see whether visits become helpful activities | Necessary for every gate |
| Now | Search Console, Bing, sitemap submission (maintainer) | 72 pages, almost none indexed | Bing showed only the homepage |
| Now | App Store age-rating questionnaire re-answered truthfully, not just to lower the rating (maintainer) | 16+ deters families | Listing shows 16+ |
| 30 days | Problem-to-activity pages: "keeps asking to go home", late-afternoon restlessness, visiting day, repeated questions, a rainy day at home. Each: what to say first, red flags, two activities to start now, a printable | Caregivers search problems, not "activities"; small blogs win these results | Search results checked 2026-10-31 |
| 30 days | Print family-photo matching cards from Photo pairs (local only, never uploaded). **Maintainer decision required** (photo boundary); update the Photo pairs copy and specs first | Families pay $16–$29 for photo-matching sets | Keeping Busy pricing |
| 30 days | Interest-based activity picker on the web ("What do they enjoy?"). Storing answers in the browser contradicts the current privacy notice, so either keep it per visit or get a **maintainer decision** and update the notice first | One next action, not a library | Research doc principle; NICE "tailored to preferences" |
| 90 days | Decide the wedge (G4). If staff: large-screen group mode and a weekly printable plan. If families: more interest packs in the app | Depends on G4 | To be measured |
| 90 days | App strings moved into ARB files | Prerequisite for any translation | Code audit |
| 6–12 months | Spanish site and app, if gates pass | Largest US non-English caregiver group | To be measured from Search Console and store data |
| Deferred | Care log, care circle, accounts, sync, payments, AI in the app | Not yet observed as GM users' problem | Needs G6 and maintainer approval |

## 6. Growth strategy

Ordered by leverage for a small team:

1. **Get indexed and measured** (week 1). Verify Google Search Console and Bing
   Webmaster Tools, submit `sitemap.xml`, request indexing for the top 20 pages.
   ChatGPT search draws on Bing's index, so Bing verification also serves AI
   referrals.
2. **Ratings on the core store query.** The rating prompt shipped in 1.5.0.
   Watch iOS ratings weekly; the first 20–50 decide conversion more than
   keyword changes do. Never incentivize or pre-screen ratings.
3. **Problem-to-activity content**, a few excellent pages a month, each with
   sources and a printable, written and reviewed by a person. No mass-produced
   pages.
4. **Organizations as distribution.** Memory cafés, Area Agencies on Aging,
   libraries, adult day programs and support groups list free resources and
   hand out printables. Use `/for-organizations/` and `/handout/`. Follow up on
   the 9 sent pitches after 2026-11-08 (`link-building.md`). Get listed in
   "best dementia apps" roundups (A Place for Mom, Relish, Graying with Grace,
   NeuroLaunch).
5. **Referral loop inside the product.** "Share with family" in the app and the
   printable handout carry the site address; App Store campaign tokens (`ct=web`)
   make web-to-install visible once the maintainer provides the provider token.
6. **Paid acquisition:** not before organic cohorts show return use (research
   doc's own rule) and not without a separately approved budget.

## 7. Business model

Keep the core free permanently. The evidence is against a consumer subscription
as the first model: only 12% of surveyed caregivers would pay out of pocket
(CAN 2026, convenience sample) and Memory Lane's most damaging complaints are
about discovering its subscription.

| Option | Fit | Next test |
| --- | --- | --- |
| Free core, no ads | Required for trust and reach | Already true |
| Organization tier (group mode, weekly printable plan, branded handouts, priority support) | Best fit if staff validate (G4); vendors charge thousands per site, so a low annual fee is plausible | Ask 10 organizations what they would pay, after G4 |
| One-time app unlock for extra packs (about $6.99, **assumption**) | Fits "no subscription without recurring value" (`us-aso.md`) | Only after G5; needs payment approval |
| Grants and nonprofit sponsorship | Fits the mission; slow | Identify two aging-services grant programs at 90 days |
| Advertising | Rejected | — |

**Unit economics today.** Costs are close to fixed and small: Apple developer
membership $99/yr, a domain, Cloudflare static hosting. There is no paid
acquisition cost. The binding constraint is founder time, so the plan favors
work that compounds (indexed pages, ratings, organization links) over work that
must be repeated (ads, cold outreach without a listing to show).

## 8. Technical strategy

- **Architecture:** keep the static Astro site on Cloudflare (global, near-free
  at any traffic level) and the offline, account-free app. Add no backend until a
  gate requires it.
- **Measurement without sending game content or anything about the person:**
  GA4 still sets its cookies and browser identifier as the privacy notice says;
  the new website events are limited
  to activity start, restart, print, "Done for now" and a fixed Yes / Not really
  answer, sent through the existing GA4 tag, never on Photo pairs, never with
  game content. App retention comes from App Store Connect's aggregate reports
  (sessions, installs and deletions) and Play Console statistics, not from code
  in the app.
- **Accessibility:** DESIGN.md gates stay mandatory. Device, VoiceOver and
  TalkBack checks remain open and are the next release gate, not optional polish.
- **Localization:** move app strings into ARB files first; use Search Console
  country and language data plus store data to choose the second language. Adapt
  activities culturally, not just the strings.
- **AI:** use it in production (drafting, alt text, translation drafts, source
  checks) with a person reviewing every published sentence. No AI in the shipped
  app, per AGENTS.md. Revisit only if an observed user problem needs it, it can
  run without uploading family photos, and the maintainer records a privacy
  decision.

## 9. Measurement

| Layer | Metric | Source | Baseline |
| --- | --- | --- | --- |
| Organic acquisition | Non-brand impressions and clicks for activity and problem queries; indexed pages | Search Console, Bing | Unknown until verified |
| Organic acquisition | First-time downloads per day, by source | App Store Connect, Play Console | Owner-reported ~10/day |
| Activation (web) | Share of game page views with `activity_start` | GA4 | Starts with this change |
| Meaningful use (web) | Sessions with `activity_restart` or `activity_print`; 7-day returning users | GA4 | Starts with this change |
| Meaningful use (app) | Sessions per active device, active days, deletions within 7 days | App Store Connect reports | Data expected within days |
| Caregiver-reported value | Helpful rate = Yes ÷ (Yes + Not really), always with the count | GA4 `activity_feedback` | Starts with this change |
| Trust | Store rating and count; review themes; complaints; medical-claim or privacy incidents (target 0) | Stores, support inbox | iOS 0 ratings |
| Distribution | Referring organizations and resource-list links | Bing, Search Console links, outreach log | 0 confirmed |
| Economics | Monthly cost; revenue once any exists | Accounts | Near-zero cost, no revenue |

**North-star (web):** weekly *good moments* = sessions where an activity was
started and then repeated, printed, or answered Yes. It rewards help, not time
spent. Report it with the helpful rate and its count so a small sample is never
mistaken for proof.

## 10. Decision gates

Thresholds are chosen decisions (**assumptions**), not industry benchmarks.

| Gate | When | Continue if | Otherwise |
| --- | --- | --- | --- |
| G1 Indexed | Day 28 after verification | ≥50% of sitemap URLs indexed in Google; Bing shows more than the homepage | Fix technical or quality causes before writing new pages |
| G2 Activation and value | Day 30 | ≥40% of game page views start an activity, and helpful rate ≥70% with ≥50 answers | 50–69% helpful: keep growth work small and fix the activities with the most Not really answers first. Below 50%: fix the activities before any growth work |
| G3 Voluntary reuse (GM-039) | After a 7-day, 20-unit pilot | ≥8 of 20 return on another day without reminders; ≥12 prefer GM next time | Diagnose setup and activity fit; add no infrastructure |
| G4 Segment | Day 90 | Choose staff as the wedge if they show ≥2× the repeat or print rate of families, or ≥5 organizations adopt it | Stay with families |
| G5 Monetization test | Day 90+ | ≥1,000 weekly activity starts and helpful rate ≥70% | No pricing work yet |
| G6 Expand scope (care log, circle, sync, AI) | 6–12 months | ≥30% of interviewed returning caregivers name coordination as their top unmet need, a partner will pay, and the maintainer approves the privacy decision | Stay in the activity category |

Stop conditions (from `AGENTS.md` and `validation.md`) override every gate:
medical misunderstanding, unexpected data transmission, destructive imports,
misleading screenshots, or pressure-based mechanics.

## 11. Execution roadmap

**7 days**

1. Merge the activity measurement (this PR) — that merge is the maintainer's
   documented decision on the new website events.
2. Maintainer: verify Search Console and Bing (DNS on Cloudflare), submit the
   sitemap, request indexing for the 20 most important pages.
3. Maintainer: re-answer the App Store age questionnaire truthfully (do not
   change answers only to lower the rating); create the App Store campaign
   provider token for `ct=web` links; register `answer` as an event-scoped
   custom dimension in GA4, or the Yes / Not really split cannot be reported.
4. Record a baseline: Apple search positions found today into
   `keyword-research.csv`; first App Store Connect daily data; first week of GA4
   events.
5. Start recruiting the 20-unit reuse pilot through organizations already
   contacted (owner sends; drafts can be prepared).
6. Fix the repository discrepancies listed in section 1.

**30 days:** five problem-to-activity pages; printable family-photo cards;
G1 and G2 read; pilot run and G3 read; first organization listings.

**90 days:** G4 segment decision and its follow-up feature; app strings in ARB;
second outreach cycle; grant shortlist; G5 read.

**12 months:** leadership scorecard below reviewed quarterly; Spanish only if
search and store data justify it.

## 12. What "#1" means here

GM leads the category of **free shared dementia activities in the US** when an
outsider can verify all of these:

- the top App Store result for "dementia activities", with more ratings than any
  direct activity competitor (Memory Lane Games has 104 on iOS today);
- top-3 Google positions for the main activity queries and a majority of the
  problem-to-activity queries it targets;
- more organization resource lists and handouts linking to it than any
  comparable free activity resource;
- a helpful rate of at least 70% on a meaningful count of answers, and a store
  rating of at least 4.6;
- running costs covered by an organization tier, grants or a one-time unlock,
  without ads.

Global leadership is a later claim, made country by country with the same
indicators.

## 13. Immediate priority

**Action:** make existing traffic count: get the 72 pages indexed and measure
whether visits become shared activities that the caregiver says helped.

**Why it beats the alternatives:**

| Alternative | Why not first |
| --- | --- |
| New app features | No evidence yet about which problem limits use; features would be guesses |
| Caregiver reuse pilot | Essential, but recruiting takes weeks; it starts in parallel this week |
| More content | Pages that are not indexed earn nothing; indexation comes first |
| Paid ads or Apple Search Ads | Unknown retention makes any acquisition cost impossible to judge |
| Spanish | No data yet on demand by language |
| GUIDE / health systems | No payment for apps and long sales cycles |

**What would invalidate it:** if, 14 days after verification, Search Console
already shows the pages indexed and GA4 records fewer than about 30 activity
starts a week, then demand reaching GM is the constraint, not visibility or
measurement, and the priority becomes direct distribution (the pilot,
organization listings, roundups). If more than half of answers are Not really,
activity fit is the constraint and comes before growth.

**Done within 7 days:** this PR merged; Search Console and Bing verified with the
sitemap submitted; events visible in GA4 with `answer` registered as a custom
dimension; a baseline table in WORKBOARD.

**How success is measured:** by day 14, a first reading of indexed pages,
activation rate, helpful rate with its count, and first-time downloads per day,
written down as the baseline every later gate compares against.

## Sources

- Alzheimer's Association, 2026 Alzheimer's Disease Facts and Figures, <https://www.alz.org/alzheimers-dementia/facts-figures>
- WHO dementia fact sheet (updated 2026-10-26), <https://www.who.int/news-room/fact-sheets/detail/dementia>; WHO mhGAP 2023 dementia evidence
- NICE NG97, <https://www.nice.org.uk/guidance/ng97>
- Tran et al., digital reminiscence review, BMC Neurology 26:296 (2026), doi:10.1186/s12883-026-04759-y
- Cochrane music-based interventions for dementia, CD003477.pub5 (2025)
- Belle et al., REACH II, Annals of Internal Medicine 145:727 (2006)
- CMS GUIDE Model, <https://www.cms.gov/priorities/innovation/innovation-models/guide> (updated 2026-10-27)
- FTC Health Breach Notification Rule final rule (April 2024)
- AARP/NAC Caregiving in the US 2025; Caregiver Action Network caregiver survey 2026
- App Store and Google Play listings and iTunes Search API results checked 2026-10-31 (Memory Lane Games, Oya, Memory Bond, My ALZ Journey, Alzheimer's Care Partner, Constant Therapy, CogniFit, Elevmi)
- Keeping Busy, Relish, Rendever and Tovertafel public pricing pages, checked 2026-10-31
