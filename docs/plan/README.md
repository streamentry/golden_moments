# Plan: the first choice for one job, in ten languages

Status: proposal written 2026-10-31 against `main` at `bb0d037`. It is a
plan, not a status record or an approval. Execution status stays in
[WORKBOARD.md](../../WORKBOARD.md) and [release-status.json](../specs/release-status.json);
feature membership stays in the [senior-first catalog](../specs/senior-first/feature-catalog.json).
Nothing here authorizes spending, new permissions, a backend, payments or a
store submission. Every item below enters the catalog with its own ID and
acceptance tests only when the maintainer approves it.

Companion research (sources, numbers, what could not be verified):
[language markets](language-markets.md), [competitors and review gaps](competitors.md),
[evidence for activity design](evidence.md).

## 1. The ask, and the strongest objection to it

The ask: *cover all use cases and features, and become the number-one choice
in the top ten languages.*

The objection, which this plan accepts: **feature coverage is how products in
this category lose.** The one competitor with a holistic feature set
(MindMate: games, exercise, nutrition, reminders, life story) returned 404 on
both stores on 2026-10-31, and its last reviews were about crashes, logins and
a setup a person with dementia "could never navigate"
([competitors](competitors.md)). Our only demonstrated hypothesis is *less
setup*: open, choose a manageable activity, enjoy it together. Every added
screen taxes that. "All use cases" also includes jobs we have ruled out
on purpose: diagnosis, cognitive scoring, treatment, cloud sync, AI.

So the plan reframes the goal: **be the obvious first answer to one job, in
each language, for both the family at home and the person who helps them.**
The job is "find something comfortable to enjoy together in the next minute."
Coverage means every *moment* in which that job appears is handled well, not
every feature a competitor lists.

Number one is defined so it can be measured and can fail. Per storefront:

| Measure | Threshold (proposed decision, not a benchmark) |
| --- | --- |
| Organic rank for the three local head terms (the local equivalents of *dementia activities*, *dementia games*, *Alzheimer's activities*) | Top 3 in App Store search for 8 of 12 weeks |
| Rating | At least 4.5 average from at least 50 ratings |
| Voluntary reuse in that language's pilot | At least 8 of 20 use units return on another day within 7 days (the existing GM-039 threshold) |
| Comprehension | 4 of 5 local caregivers describe it as shared photo activities after five seconds on the first screenshot; none infer treatment |

A language that cannot meet the first two within six months of launch is held
(strings maintained, no further content), not abandoned.

## 2. Where we actually stand

Facts from the repository and store readback on 2026-10-30; nothing here is a forecast.

- **Traction:** about 10 installs a day (owner report), no ratings shown on the live
  US listing, age rating 16+, Puzzle category, iOS 1.4.1 live, 1.5.0+9 is the candidate.
  Android 1.4.0 is uploaded but blocked by a Play declaration check; nothing is
  published on Play yet.
- **Verification:** 0 of 40 senior-first items are *verified*. No physical-device,
  VoiceOver/TalkBack, upgrade, traffic-capture or human-pilot evidence exists.
  Every release gate except Flutter tests, iOS archive and real screenshots is pending.
- **Localization:** the app is English-only. `lib/l10n/arb/app_en.arb` holds one
  template placeholder string; roughly 300 to 400 user-facing literals (about 2,400
  words) are hardcoded in `lib/features`, `lib/shared` and `lib/app`. Pack names and captions live in
  `assets/data`. The 17 files in `docs/store-description/` are legacy translations
  of an older product with brain-training wording and must not be submitted.
  The website is `lang="en-US"` only.
- **Fonts (checked with fontTools on the bundled files):** Roboto covers Latin,
  Vietnamese and Cyrillic (896 glyphs); the Fraunces Bold headline subset covers
  Western Latin only (224 glyphs, no Vietnamese diacritics). Neither covers
  Japanese, Chinese, Korean or Arabic.
- **Activities in the app:** gentle matching (visible or hidden), Look together with
  prompts, the unshipped tap-to-place puzzle prototype, the legacy pack game.
  The website already has 11 browser games under the same design contract.
- **Platform gaps that localization inherits:** reminders are iOS-only; Android is
  unbuilt for 1.5.0; the Play listing is not live. Most non-US markets below are
  Android-majority.

Implication: a localized listing in front of an unverified, iOS-only app
multiplies an unproven loop by ten. The sequence in section 7 therefore puts
verification and Android ahead of language three.

## 3. Who we serve: the use-case map

Each row is a person and a moment. "Handled" means the job can be done from
the home screen without instruction; it does not mean verified.

| Person | Moment / job | Today | Plan |
| --- | --- | --- | --- |
| Family member at home (primary buyer) | Fill 10-20 minutes together calmly | Handled: matching, Look together | Keep as the first screen; add two more gentle modes (section 4) |
| Same | Use our own photos without a server | Handled: bounded local copies | Captions and read-aloud in the participant's language |
| Same | Set it up once, hand the device over | Partial (GM-037) | Participant-language and comfort settings prepared by the helper |
| Adult using it independently (mild impairment) | Start alone, stop without judgment | Handled | Keep; never add streaks or nudges |
| Bilingual family: helper speaks English, parent's first language is Spanish, Vietnamese, Chinese, Tagalog... | Play in the parent's language while the helper reads English | Not handled | **Participant language separate from device language** (GM-041 proposal) |
| Paid carer or visiting grandchild who does not know the person's history | Know what to talk about | Partial (captions, prompts) | Local "about these pictures" notes written by the family (GM-019 extension); no diagnosis fields |
| Remote relative | Send photos for the activity | Deferred (sync) | No backend: a file-based pack sent by AirDrop or messaging (GM-022) stays R3 and needs its own threat model |
| Activity coordinator in a care home or day center | Run a 30-minute group session on a TV or iPad | Not handled | Picture bingo and Find the same for groups; AirPlay/HDMI large-screen layout test; several bounded albums (GM-021) for several residents |
| Carer at a hard hour (late afternoon, waiting rooms) | Something calm, no demands | Partial (Look together) | Calm breathing and slow picture viewing. Honest wording: "a calm, familiar activity some families use during restless times"; never "reduces agitation" (Cochrane 2025 found no music effect on agitation and nothing tests a photo app) |
| Low vision, tremor, hearing loss | Use it at all | Partial (text floor, 48px targets) | Read aloud (GM-011), per-language font and 200% text checks, switch access |
| Person who cannot use a screen any more | Still be included | Out of app | Website printable handouts and picture cards; the app does not pretend |
| Clinician, researcher | Scores, progress, diagnosis | Excluded | Stays excluded; the honest answer is "this is a recreational activity" |

Out of scope by decision and unchanged by this plan: diagnosis, cognitive
scoring, treatment or prevention claims, AI processing in the app, cloud sync,
accounts, recordings, telemetry SDKs, music licensing, medication management.

## 4. Feature plan

Everything reuses the existing content, persistence, accessibility and design
contracts. One filled button per screen, no clock, score, streak or countdown.
IDs GM-041 and up are **proposals**; they are not in the catalog until approved.

### 4.1 Make the existing promise true (prerequisite, R0 of the roadmap)

Device acceptance per `docs/release/device-acceptance.md`, VoiceOver and
TalkBack walkthroughs, airplane-mode fresh install, upgrade from the store
build, the five-caregiver comprehension test, and the Android build and Play
release. Re-answer the age-rating questionnaire truthfully (16+ is unusual for a
picture game and likely costs family installs). None of this is new work; it is
the unfinished top of WORKBOARD, and it gates every language below.

### 4.1b Lead with what the reviews ask for

The category's loudest complaints are ads, scam purchases, subscriptions,
logins, online dependency, small text, childish content and abandoned apps
([review-gap log](competitors.md)). The app already answers all of them and
says so nowhere prominent. Before any new feature: make "No ads. No
subscription. No account. Works offline." the second screenshot message and
the first line of the Play short description, within the existing claims rules,
and reply to every store review in every language.

### 4.2 Localization foundation (GM-036, R2 → promoted)

- Move every production string into ARB files under the existing `flutter_localizations`
  and `intl` setup; the generated `AppLocalizations` already exists. Add a test that
  fails on any new hardcoded string in production views.
- Pack names, captions and conversation prompts get a per-locale layer in `assets/data`
  with English fallback per item, never a mixed-language essential control.
- Pseudolocalization and a +40% text-expansion run at 100% and 200% text on the
  smallest phone and iPad; German and Portuguese are the long-string tests, Japanese
  and Chinese the short-string tests, Arabic the mirroring test if it is ever chosen.
- Fonts: Roboto already covers every Latin language here plus Vietnamese. The Fraunces
  headline subset lacks Vietnamese, Polish and Turkish letters; `gmDisplayFontFamily`
  already falls back to Roboto, so those headlines silently turn sans. Either accept
  that or add a second static Fraunces instance (about 40 KB); decide per `DESIGN.md`
  › Typography.
  For Japanese, Chinese and Korean use the platform system font through Flutter's
  font fallback rather than bundling 5-15 MB CJK fonts, and accept that headlines
  are sans in those languages. Add a design-system test that renders a sample
  string per supported locale and fails on missing glyphs (tofu).
- Store side: one canonical `metadata/app-store.<locale>.json` per language, generated
  exports, and `scripts/release_metadata.py` extended to check each locale's name
  (30), subtitle (30), keywords (100 bytes), Play short description (80) and the
  claims word-list in that language.
- Screenshots: the compose scripts take a locale and render the six approved frames
  with localized headlines from the canonical JSON. Captures come from the real
  localized build.
- Definition of done for a language (from GM-036): full journey in that language,
  200% text, native permission and share sheets, help and privacy pages, release
  notes, the six screenshots, the "not a medical device" sentence Google Play
  requires, and a human reviewer who checks adult tone, no added medical claim and
  cultural fit. A locale is not advertised before this passes.

### 4.3 GM-041 Participant language (proposal, R1)

A setting a helper can choose before handing over: the activity screens, captions
and prompts appear in the participant's language while the helper's phone stays in
its own. Rationale: in the US the buyer searches in English for a parent whose
first language is Spanish, Vietnamese, Chinese, Korean or Tagalog, and people with
dementia often lose a later-learned language first (see [evidence](evidence.md)).
No competitor found offers this. Cost is small once 4.2 exists: one locale override
on the activity routes and the stored pack layer.

### 4.4 More gentle modes, ported from the website, one at a time (R2)

The website games already follow the design contract and have logic tests. Candidate
order, chosen by group use and cultural content rather than novelty:

1. **Sort together** (GM-010): tap a picture, tap a group; neutral feedback.
2. **Finish the saying**: proverbs and song lines per language, editor-reviewed, no
   recall demand (the saying can be shown whole at any time). This is the one mode
   whose content is naturally local, so it becomes stronger with each language.
3. **Picture bingo** and **Find the same** for small groups on an iPad or TV.
4. **Calm breathing**, the one paced activity, already excepted in `DESIGN.md`.

Each ships only after the comparative pilot (GM-039) prefers it over Look together;
a mode that raises assistance is removed, not fixed with more modes.

### 4.5 Read aloud (GM-011, R2, lower priority than first assumed)

User-started reading of visible text and opted-in captions with the OS on-device
voice in the participant language; no voice download, no cloud, immediate Stop.
The [evidence](evidence.md) cuts its priority: spoken prompts were often ignored
or produced passive reliance, and older listeners understand synthetic speech
less well than natural speech. Keep it off by default, for low vision and for a
helper who cannot read the participant's language, after the speech plugin and
offline voices per platform are reviewed. Bilingual captions (4.3) do most of
the same job without audio.

### 4.6 Content that is local, not just translated (GM-025 extension)

Per language, two to three picture packs of recognizable, adult, non-clinical scenes
(festivals, foods, markets, landscapes, trades) with the same provenance register,
license check and tile-size review. Prompts are rewritten by a native reviewer, not
machine translated: "What catches your eye?" has no good literal translation in
several languages.

### 4.6b GM-042 Helper settings without a password (proposal, R1)

Several competitors lock settings behind a PIN so the participant cannot wander
into removals or purchases. The Dutch requirements study warns against passwords
and codes. Proposal: comfort settings stay one tap away as today; destructive or
helper-only actions (remove copies, reminders, rating link) sit behind a
press-and-hold "Helper" control with a plain explanation, never a code. Needs a
usability check that a participant is not locked out of "Done for now".

### 4.7 Group and large-screen use

No new feature: test the existing activities mirrored to a TV (AirPlay, HDMI,
Chromecast) at 16:9 and record the layout fixes. Add a `for-organizations` offer on
the website in each language. Several residents need several albums (GM-021, R3,
approval required).

### 4.8 Still deferred, with the reason

| Item | Why it stays out for now |
| --- | --- |
| Music, sing-along | Licensing cost and rights per territory; the user's own music app does this |
| Family sync, remote upload | Needs a backend and consent model; GM-022 file packs are the no-backend path |
| Payments (GM-035) | No willingness-to-pay evidence yet; revisit after two languages show reuse |
| Mainland China availability | Every app on the mainland store needs an ICP filing through a Chinese entity or agent; zh-Hans still serves the US and overseas storefronts; see [language markets](language-markets.md) |
| Arabic, Hindi | RTL and script cost against low iOS share and low paid intent; revisit with demand evidence |

## 5. Language plan

Full numbers and sources are in [language-markets.md](language-markets.md).
The ranking weighs people living with dementia and their caregivers, iOS share
(the app is iOS-first), store revenue as a proxy for willingness to pay, the
cost of a faithful translation, and whether the word *dementia* works in the
name.

<!-- cspell:disable -->
| Order | Locale | Storefronts | Why here | Name note |
| --- | --- | --- | --- | --- |
| 1 | en-US (done), en-GB, en-AU, en-CA | US, UK, AU, CA, IE, NZ and, for en-GB, 172 of 175 storefronts as an indexed extra language | Zero translation; UK and AU say *carer*; an en-GB listing is read almost everywhere | Keep |
| 2 | es-MX, es-ES | US (es-MX is an indexed extra language there), MX, ES and 16 storefronts where es-MX is primary | US Hispanic families and language reversion; the cheapest review; doubles the US keyword space | *Juegos para personas con alzhéimer*: searchers type *Alzheimer*, not *demencia* |
| 3 | ja | JP (ja plus en-US) | 4.7M people with dementia, the highest iOS share of any large market (60.5%), high willingness to pay, one of the three largest stores | 認知症 is the official, accepted term; never 痴呆 or ボケ; never 予防 |
| 4 | de | DE, AT, CH | 1.8M, high ARPU, strong associations; the long-string test | *Demenz* is neutral; *Beschäftigung für Menschen mit Demenz* |
| 5 | zh-Hant, with zh-Hans as a sibling for the US and overseas storefronts only | TW, HK; both scripts indexed in the US | Taiwan iOS 51.6%; the two scripts share one review; mainland is excluded by the ICP filing | 失智症 in Taiwan, 認知障礙症 in Hong Kong; never 老年痴呆 |
| 6 | fr | FR, CA-fr, BE, CH; French is indexed in 32 storefronts and in the US | 1.0-1.4M; Québec adds a second storefront | *Démence* is avoided in public copy; *maladie d'Alzheimer et maladies apparentées* |
| 7 | pt-BR | BR; indexed in the US | 1.8-2.7M, third by downloads, Android-majority (needs Play) | *Alzheimer* dominates search; pt-PT is a separate locale later |
| 8 | ko | KR; indexed in the US | About 1M, national dementia centers as partners | 치매 is stigmatized (43.8% dislike it; a rename to 인지저하증 is proposed); never in the title |
| 9 | it | IT, CH | 1.48M, about 4M caregivers | *Demenza* neutral; *giochi per anziani* is the live phrase |
| 10 | vi | VN; indexed in the US | Near-zero review cost for this team; a US differentiator through GM-041 | *Sa sút trí tuệ* is clinical; families say *Alzheimer* or *lẫn* |

Alternates: ar (17 storefronts, Gulf iOS share over 50%, needs right-to-left work),
nl and pl (small, neutral terms, cheap), hi (negligible iOS share and search).
Mainland China is excluded until a Chinese entity or agent files the ICP record.

Reality check from the [competitor log](competitors.md): tiny apps already list
11 to 22 languages, almost certainly machine-translated, and the Japanese and
Korean head terms lean on prevention (予防, 예방), a claim we will not make.
Language count is table stakes. What no competitor found does: a native-reviewed
listing per storefront, local picture packs and sayings, and a participant
language separate from the helper's.

<!-- cspell:enable -->
Per-language naming rule: the on-device name stays **Golden Moments** everywhere.
The store name and subtitle are chosen per locale from the local head term plus
*Golden Moments*, checked by a native reviewer for stigma, and recorded in the
canonical JSON. Bundle and package identifiers never change.

Cost estimate: roughly 2,400 words of app strings, 500 words of store copy and
about 150 caption and prompt lines per language. Published 2026 human rates run
$0.08-0.14 per word, so about $300 per language for translation, or less with
machine drafts and native editing, plus linguistic QA by the hour
([sources](language-markets.md)). The real cost is two to four days per language
for screenshots, 200% text checks and the native review, not translation.

## 6. Distribution per language

Founder-led and cheap first; no paid campaign without a separately approved budget.

1. **ASO per storefront:** localized name, subtitle, keywords, six screenshots,
   promotional text; record impressions, conversion and installs per storefront in
   `keyword-research.csv` with dates and sources. Search-source installs can include
   Apple Ads; label them.
2. **National associations and public programs** as the first outbound list:
   ten to thirty per country, the printable handout translated, a request to be
   listed on their technology pages. Partners are in [language-markets.md](language-markets.md).
3. **Website:** translate the home page, five activity guides, help, privacy and the
   organizations page per language with `hreflang`; the rest stays English until the
   language shows installs.
4. **Care homes and day centers:** the organizations page offer, a group-use guide and
   the large-screen test record; collect three named references per country.
5. **Ratings:** the existing platform prompt only; it works per storefront.

## 7. Sequence

| Window | Do | Gate to the next window |
| --- | --- | --- |
| Days 0-30 | Device acceptance, VoiceOver/TalkBack, Android build and Play release, age-rating re-answer, l10n foundation (4.2), GM-041 design, es and vi as the first two languages (cheapest honest review) | Device gates recorded; Play live; two languages pass the definition of done |
| Days 30-90 | ja, de, zh-Hant; localized screenshot pipeline; association outreach in five countries; Sort together ported behind the pilot | Each language live with localized listing; four weeks of per-storefront data |
| Days 90-180 | fr, pt-BR, it, ko; Finish the saying with local content; read-aloud review; group large-screen test | Reuse pilot in at least two non-English languages; first three languages measured against section 1 |
| Days 180-365 | Hold or deepen per language against the thresholds; decide the one-time unlock on observed willingness to pay; second content pack per retained language | At least four storefronts in top 3 for their head terms |

Seven-day actions, in order:

1. Run the device acceptance scenarios on one physical iPhone and record them.
2. Re-answer the App Store Connect age questionnaire and read the result back.
3. Extract the hardcoded strings into `app_en.arb` with a failing test for new literals.
   In the same week the maintainer can add an en-GB listing (*carer*, UK spelling)
   in App Store Connect from a new canonical `metadata/app-store.en-GB.json`: it is
   the indexed extra language in 172 storefronts and costs about an hour.
4. Draft `metadata/app-store.es-MX.json` and get one native Spanish caregiver to read it.
5. Ask three Vietnamese-speaking families with an elder to try the English build and
   say which words they would want in Vietnamese; this is the GM-041 falsification test.

## 8. Risks, assumptions and the cheapest tests

Load-bearing assumptions:

1. **Search demand exists in each language for the activity job** (not for *dementia* in
   general). Test: localized listing plus keyword popularity readings for eight weeks
   before any content pack is made.
2. **Less setup is a real advantage over a photo album or a printed activity.** Test:
   the GM-039 comparative pilot in two languages, against the device photo viewer.
3. **Language reversion makes GM-041 valuable to US families.** Test: the five-family
   question above, then an es and vi participant-language build with ten families.

Fat tails and failure modes:

- A translated medical claim slipping into a locale. Mitigation: per-locale claims
  word-list in the metadata check and human review; the legacy translations are never reused.
- Store rejection or a stigma complaint over *dementia* in a name. Mitigation: native
  naming review; the device name never changes.
- Ten half-maintained languages. Mitigation: hold rule in section 1; strings are
  cheap, content is gated.
- Android remains unpublished and six of ten markets are Android-majority. Mitigation:
  Play release is a gate in window one.
- Effort flows to localization while US retention stays unmeasured. Mitigation: the
  US pilot and device gates are the first window; this plan does not start language
  three until they are recorded.

Where this plan is most likely wrong: the ranking order. Japan may be slower than
expected because families trust institutional channels over App Store search, and
Brazil may be faster than its revenue rank suggests because caregiver volume is
large and competition is thin. The per-storefront data after eight weeks decides,
not this table.

## 9. Decisions requested from the maintainer

1. Approve the reframed goal and the measurable definition of number one (section 1).
2. Promote GM-036 to R1 and approve the localization foundation (4.2).
3. Approve GM-041 participant language as a catalog entry with acceptance tests.
4. Confirm the first two languages (es, vi) and the order of the next three.
5. Confirm that Play publication and device acceptance gate language three.
6. Approve a translation review budget per language before the first paid reviewer.
7. Approve GM-042 helper settings as a catalog entry, or decline it.
8. Approve the "No ads. No subscription. No account. Works offline." screenshot and
   Play short-description change through the canonical metadata and the claims check.
