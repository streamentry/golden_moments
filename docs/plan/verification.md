# Plan appendix: verification, corrections and scoring

Proposal support, not status. Facts were checked on 2026-10-31 unless dated
otherwise. "Snippet" means seen only in a search excerpt; "approximate" means a
proxy for the real measure. Nothing here is device evidence or approval.

## 1. State of play, corrected

| Item | Earlier statement | Newer evidence (2026-10-31) | Source |
| --- | --- | --- | --- |
| Live iOS version | 1.4.1, 1.5.0+9 candidate | **1.5.0 released 2026-10-30 19:35 UTC**, READY_FOR_SALE | `docs/release/app-store-1.5.0-build9.md`, App Store lookup |
| Play | Not live | A public listing exists: **10+ installs**, 4.7 with a count too small to show, serving 1.4.0; version code 9 committed to production, approval not confirmed | Play listing, logged out; release record |
| Ratings | None shown | iOS 0 | App Store listing |
| App Store search | Unmeasured | **#1 "dementia activities"**, #2 "reminiscence dementia", #4 "alzheimers activities", #17 "dementia games", not in the top 50 for "alzheimers games" | `scripts/store_scorecard.py` (iTunes Search API, top 50; approximates App Store search); `docs/strategy/keyword-research.csv` |
| Play search | Unmeasured | #4 "dementia activities"; not top 10 "dementia games" (Oya, 500K+ installs, leads) | Logged-out Play search |
| Website indexing | Search Console pending | Only the homepage appeared in Bing's index; not top 10 for any tested query; Search Console and Bing Webmaster Tools unverified | DuckDuckGo/Bing results |
| Website measurement | GA4 page views | Unchanged until #104 adds activity events | `site/src/components/Analytics.astro` |
| App analytics | Reports requested 2026-10-30 | The script authenticates; Apple has produced no daily data yet; the Sales report vendor number is not recorded | `scripts/store_downloads.py` run |
| User research | None | None | `docs/specs/senior-first/validation.md` |
| 1.6.0 and 20 languages (2026-11-01) | Not built | Build 10 submitted on both stores 2026-10-31, **awaiting review, not approved**; website deployed in 20 languages, 19 translations noindex; all machine-made and unreviewed | `docs/release/app-store-1.6.0-build10.md` (iOS state read back as Waiting for Review; Play committed to production) |
| Age rating | 16+ | The iTunes Search API reports **17+** (advisory "Unrestricted Web Access"); Apple's age-rating page lists 4+, 9+, 13+, 16+, 18+, and the API may still emit legacy strings. The tier set in App Store Connect was **not read**, so 16+ is unconfirmed | iTunes Search API, 2026-11-01; Apple age-ratings reference |
| Genre | Puzzle | API reports Games; not reconciled | iTunes Search API |
| Ranks 2026-11-01 | Recorded 2026-10-31 | Identical, no new rows in `keyword-research.csv` | `scripts/store_scorecard.py` |

## 2. category-leader.md claims, checked at the primary source

| Claim | Verdict | Correct statement and source |
| --- | --- | --- |
| 7.4M Americans 65+ with Alzheimer's dementia; ~13M unpaid caregivers; $409B | Confirmed | Alzheimer's Association 2026 Facts and Figures. $409B excludes unpaid care (valued at $446B+). [language-markets.md](language-markets.md) still quotes the 2025 edition (7.2M, 11.5M) |
| ~57M worldwide | Caveat | WHO's 2021 estimate, nearly 10M new cases a year (WHO fact sheet, updated 2026-10-26) |
| WHO recommends physical activity, high certainty | Wrong citation | WHO mhGAP 2023 dementia update; cognitive stimulation is conditional, low certainty. The July 2026 WHO guideline covers risk reduction, not people living with dementia |
| NICE NG97 | Confirmed | "Offer a range of activities to promote wellbeing that are tailored to the person's preferences"; do not offer cognitive training to treat mild–moderate Alzheimer's |
| Digital reminiscence, music | Weak | Reminiscence: possible short-term behavior/mood benefit, no effect on cognition (BMC Neurology 26:296, 2026). Music: probably a slight reduction in depression, no effect on agitation or cognition (Cochrane CD003477.pub5, 2025) |
| REACH II, 495 dyads | **Wrong** | 642 caregivers randomized; human-delivered, not an app (Belle et al., Ann Intern Med 2006) |
| CMS GUIDE, 292 participants, partner contracting | Mostly confirmed | 292 on the CMS page (updated 2026-10-27), down from about 390 at launch. **No separate payment for digital tools.** Respite cap shown as $2,500 (web page) and $2,625 (PY2026 fact sheet) |
| FTC Health Breach Notification Rule covers non-HIPAA apps | Confirmed | Final rule April 2024; the FTC withdrew its 2021 policy statement in September 2026 (trade press only) |
| Memory Lane Games, 3,000+ games | Outdated | 1,500+ games; $9.99/mo or $69.99/yr; iOS 4.6 (104 ratings), Play 3.9 (162), 50K+ |
| Elevmi as a leader | Outdated | US App Store page returns 404 |
| Caregiver app use, willingness to pay | Missing | No representative dementia-specific data. AARP/NAC 2025 (all caregivers): 41% track health records with technology. Caregiver Action Network 2026 (272, convenience): 32% say tools should be free, 12% would pay out of pocket |

## 3. Category options, scored

Score = value × evidence × distribution × defensibility ÷ cost-and-risk, each 1–5
by judgment. These are not measurements.

| Option | Value | Evidence | Distribution | Defensibility | Cost/risk | Score |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| One job, web + print + app, families first | 4 | 4 | 5 | 3 | 2 | 120 |
| Same job, activity staff first | 4 | 3 | 4 | 3 | 2 | 72 |
| Family-photo reminiscence app only | 4 | 2 | 2 | 3 | 2 | 24 |
| Caregiver platform (category-leader.md) | 5 | 3 | 2 | 4 | 5 | 24 |
| GUIDE / health systems first | 3 | 2 | 2 | 4 | 5 | 10 |
| Brain-training games | 2 | 1 | 3 | 1 | 3 | 2 |

## 4. Competitive snapshot (US, 2026-10-31)

| App | Model | iOS rating (n) | Play rating (n) / installs | Job |
| --- | --- | --- | --- | --- |
| Golden Moments | Free, no ads, no account | none (0) | 4.7 / 10+ | Photo activities |
| Memory Lane Games | 14-day trial, $9.99/mo or $69.99/yr | 4.6 (104) | 3.9 (162) / 50K+ | Reminiscence quiz |
| Oya | Free + in-app purchases | not found | 4.5 (1.47K) / 500K+ | Matching game |
| Memory Bond | $1.49 unlock | none (0) | not checked | Family photo and voice games |
| My ALZ Journey | Free | 4.4 (20) | 4.1 (44) / 10K+ | Post-diagnosis guidance |
| Alzheimer's Care Partner | $9.99/mo or $99.99/yr | 4.75 (32) | 4.0 (18) / 5K+ | Care coordination |
| Constant Therapy | Subscription | 4.5 (4,186) | 4.5 (1.15K) / 100K+ | Speech rehab |
| CogniFit | ~$9.99/mo | 4.46 (1,740) | 4.0 (10.1K) / 1M+ | Brain training |

Substitutes: printed activity books (~$9), Keeping Busy photo matching ($15.99–$28.98),
Relish kits ($449.99 US starter kit). Care-setting vendors (iN2L/LifeLoop,
Rendever, Tovertafel) sell per site for thousands and do not serve families.

Search results for activity queries are dominated by long idea lists, printable
sites, senior-living operators and small blogs; "dementia keeps asking to go home"
is held by niche blogs.

## 5. Claims the plan relies on, checked at the primary source

| Claim | Verdict | What the source says |
| --- | --- | --- |
| The US App Store indexes es-MX, vi, ko, zh-Hans, zh-Hant, fr, pt-BR, ar and ru | **Partly** | Apple's [App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations) lists exactly these as *additional supported languages* for the USA and says nothing about search. Indexing is vendor-reported ([AppTweak](https://www.apptweak.com/aso-blog/how-to-benefit-from-cross-localization-on-the-app-store), updated 2025-11-21): observed behavior that can change |
| en-GB is an indexed extra language in 172 of 175 storefronts | **Partly** | English (U.K.) appears in 172 of 175 storefronts on Apple's table: the default language in 135, additional in 37. "Indexed" is again vendor-reported. [detail](detail.md) A4 and [language markets](language-markets.md) should read "present in 172" |
| FDA General Wellness, final January 2026 | Confirmed; nuance | "Document issued on January 6, 2026" ([PDF](https://www.fda.gov/media/90652/download)). Mental-acuity claims must not reference any disease; disease-linked wellness claims are limited to conditions where lifestyle is well accepted to matter (heart disease, high blood pressure, type 2 diabetes). **Alzheimer's appears nowhere**, so no dementia-linked wellness claim is covered. A product claiming to "improve memory" is given as not low risk |
| 17 dementia apps, uMARS 3.35 of 5 | Confirmed | Chen, Lee and Ma, JMIR Form Res 8:e51076 (2024): 3.35 (SD 0.56); engagement 3.04 and information 3.14 lowest, functionality 3.76 highest |
| Bilingual people with dementia revert to their first language | **Weak, mixed** | A 2016 systematic review of 9 studies (International Journal of Language & Communication Disorders 51(2), doi:10.1111/1460-6984.12190): better performance in the *dominant* language, and possibly equal decline in both; a 2017 review of 15 studies calls the picture "complex and, at times, inconclusive". Widely reported by clinicians, not established. GM-041 rests on a hypothesis |
| Google Play requires a "not a medical device" sentence | Mostly confirmed | Play Console Help, [Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511): health apps that are not medical devices must state they are "not a medical device and does not diagnose, treat, cure, or prevent any medical condition" and remind users to consult a professional. Read through a summarizing tool; check the live wording before use. [competitors](competitors.md) cites an older policy URL |
| Apple 1.4.1 | Confirmed | Medical apps that could give inaccurate data or be used to diagnose or treat get closer review; a recreational app with no medical claims is outside it ([guidelines](https://developer.apple.com/app-store/review/guidelines/), page truncated near the end but both sections read) |
| Apple 5.1.1(ix) | Confirmed; relevance open | Highly regulated fields (healthcare among them) must be submitted by the legal entity providing the service, not an individual. Whether a recreational app counts is a maintainer and counsel question |
| FTC v. Lumosity | Confirmed, date unread | $2 million redress, $50 million judgment suspended; the FTC alleged implied protection against decline, MCI and dementia ([press release](https://www.ftc.gov/news-events/news/press-releases/2016/01/lumosity-pay-2-million-settle-ftc-deceptive-advertising-charges-its-brain-training-program)). The page text gave no date; "January 2016" rests on the URL |
| MHRA labeling | Partly | Intended purpose follows labeling, instructions and promotional material ([MHRA](https://www.gov.uk/government/publications/crafting-an-intended-purpose-in-the-context-of-software-as-a-medical-device-samd/crafting-an-intended-purpose-in-the-context-of-software-as-a-medical-device-samd)). That store descriptions count, and that disclaimers do not cure claims elsewhere, was seen only in search snippets |

## 6. Could not verify

- First-time downloads per day (Apple data not yet produced; vendor number unknown); the owner's "about 10 a day".
- The owner's report of substantial ChatGPT referrals (no numbers recorded).
- Google rankings (only Bing-based results could be read).
- Exact App Store ranks (the iTunes Search API only approximates them).
- Play rating count for Golden Moments; Elevmi's status (404 could be region-locking).
- B2B vendor prices (quotes only); GrandPad current pricing.
- The FTC's September 2026 withdrawal of its health-app policy statement (trade press only).
- Representative data on dementia caregivers' app use or willingness to pay.
- Any Apple statement that additional languages are indexed for search on any storefront.
- An FDA example of a dementia or Alzheimer's claim under general wellness (there is none).
- A study showing a first-language, as opposed to dominant-language, advantage in bilingual dementia.
- The age tier and genre actually set in App Store Connect (the API says 17+ and Games; docs say 16+ and Puzzle), and whether "Unrestricted Web Access" is what drives the mapping.
- Whether Apple or Google has approved 1.6.0 (submitted, not read back as approved).
- Whether translated store listings or website pages are of acceptable quality (no native review yet).
- Whether 1.6.0's languages change downloads by territory (no post-release data; Apple's reports lag).
- The MHRA statement that app store descriptions count as promotional material (snippet only).
