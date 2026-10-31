# Native review of translations

All 19 translations (app, store listings, website, games, guides) are machine
made and unreviewed by maintainer decision (2026-10-31, GM-036). This guide
says what a native reader checks, in what order, and how a language is marked
reviewed. Nobody has signed off any language yet; the record is
`localization.languages` in `docs/specs/release-status.json`.

## Why review matters here

- The audience is families of people living with dementia. A wrong tone,
  a medical promise, or a wrong emergency number does more harm than an
  awkward sentence.
- The translated website stays out of search, sitemaps and language
  alternates until its language is reviewed (`REVIEWED_LANGUAGES` in
  `site/src/i18n/locales.ts`, website branch `feat/i18n-site`). So review is
  what unlocks the website's search value.
- Store listings are drafts. They should be reviewed before anyone pastes them
  into App Store Connect or Play Console.

## Review order

The order is the order of the list in `release-status.json`. It follows the
market research in `docs/plan/language-markets.md`: first the languages that
are searchable in the US store as well as at home (Spanish, Vietnamese, then
Traditional and Simplified Chinese, French, Korean, Portuguese, Arabic,
Russian), then the largest home markets (Japanese, German, Italian), then the
rest.

| Order | Language | Why this position |
| --- | --- | --- |
| 1 | Spanish | US bilingual families; Mexican Spanish is searchable in the US store |
| 2 | Vietnamese | Searchable in the US store; review cost is low |
| 3 | Japanese | Highest iOS share of any large market |
| 4 | Traditional Chinese | Taiwan and Hong Kong; also searchable in the US store |
| 5 | German | Large Western European market |
| 6 | French | France and Canada; searchable in many stores |
| 7 | Korean | Searchable in the US store |
| 8 | Simplified Chinese | US diaspora; the mainland store cannot be reached by Google Play |
| 9 | Portuguese (Brazil) | Searchable in the US store |
| 10 | Italian | Large home market |
| 11 | Arabic | Needs the right-to-left layout check as well |
| 12 | Russian | Searchable in the US store; payments are restricted |
| 13 to 19 | Polish, Dutch, Turkish, Indonesian, Thai, Ukrainian, Hindi | Smaller or later markets |

## What to review, per language

A reviewer needs about one working day for the short surfaces and a few more
days for the 40 guides (roughly 75,000 words). Tier 1 is the short list that
matters most; do it first.

**Tier 1: app and store**
- App text: `lib/l10n/arb/app_<locale>.arb` (320 messages). Run the app in
  that language at 200% text and check nothing is cut off.
- Picture-pack text: `assets/data/i18n/packs_<locale>.json` (names, themes and
  the captions that are read aloud).
- Photo permission text: `ios/Runner/<lang>.lproj/InfoPlist.strings`. It must
  say that only chosen photos are copied, on this device, and that the library
  is not scanned.
- Store listing: `metadata/i18n/<language>.json` (name, subtitle, keywords,
  descriptions). Check that the name and subtitle use the phrase a family would
  type into a store search.

**Tier 2: website**
- Interface text, games and game instructions: `site/src/i18n/ui/<code>.json`,
  `games/<code>.json`, `play/<code>.json` on the website branch.
- The 40 guides: `site/src/content/guides-i18n/<code>/`. Start with the eight
  most visited: ideas, Alzheimer's, memory games, printable activities, music,
  reminiscence, late stage, how to play together.

## Checklist for every surface

1. **Dignity and tone.** Warm, plain, adult language. No word that labels the
   person as a patient, no baby talk, no exclamation praise.
2. **No claims.** Nothing says or implies that an activity treats, slows,
   prevents or improves dementia beyond what the English page says. Every hedge
   in the English ("may", "linked with", "evidence is mixed") is still a hedge.
3. **Numbers and sources.** Study figures, percentages and dates match the
   English. Source titles and links are unchanged.
4. **Emergency numbers and local services.** Where the English says 911, the
   translation names the right local number or says "your local emergency
   number". Check every local helpline or agency the translator added; they are
   marked in the guides as local pointers.
5. **Quiz answers.** Translators replaced US-only quiz questions with local
   ones. Check each answer is correct, the wrong options are clearly wrong, and
   the conversation prompt still fits the question.
6. **Phone menus.** The tablets and screens guide names iOS and Android
   settings. Check each name on a phone set to that language; many are from
   memory or left in English.
7. **Local swaps.** Examples, foods, holidays and sayings that replaced US ones
   still feel natural and are not religious or political.

## Known points for reviewers

These were noticed while translating; none is decided.

- Spanish: examples lean Mexican and Latin American; check they suit US Spanish
  speakers too.
- Vietnamese: the music list includes a revolution-era genre next to others;
  decide whether to keep it for readers abroad. The word for dementia in titles
  was chosen from the site's own search wording.
- Japanese: the activity guide for men has a row about military service and
  uniformed work, which is a sensitive area. The poison information wording
  in the outdoor guide needs a native check.
- Traditional Chinese: Taiwan wording is used, so the Hong Kong listing is not
  separate. The music guide lists Buddhist chants among religious music.
- Simplified Chinese: the listing uses the formal term for dementia rather than
  the older, more stigmatizing everyday one, which may cost some search
  traffic. Android menu names vary a lot by phone maker.
- German: lines said by a family member to a parent use the informal form while
  the guides use the formal form; decide which the reader expects.
- French: two evidence hedges in the brain health guides (about what has not
  been shown) should be read for strength. One quilting word leans Canadian.
- Italian: a flower in the picture-pack captions is associated with funerals in
  Italy; consider a different caption or picture.
- Arabic: check right-to-left layout in the app, arrow direction in link
  labels, and the address form (masculine singular is used throughout).
- Thai: the app rating label uses a word that also means "score"; consider a
  wording that means stars. There is no Thai word search, so guides say so.
- Russian and Ukrainian: avoid war and political examples; the Ukrainian text
  was written from English, not from Russian.

## How a language becomes reviewed

1. The reviewer sends corrections as a pull request, or as a marked-up copy
   that someone applies.
2. In `docs/specs/release-status.json`, set that language's `status` to
   `reviewed` and fill `reviewer`, `evidence` (a link to the sign-off) and
   `date`. In `metadata/i18n/<language>.json`, set `review` to `reviewed`. The
   test `tests/test_localization_status.py` fails if the two disagree or if a
   reviewed language lacks a reviewer or evidence.
3. On the website branch, add the language to `REVIEWED_LANGUAGES` in
   `site/src/i18n/locales.ts`. That makes its pages indexable and adds them to
   the sitemaps and language alternates. The flag covers a whole language, so a
   partly reviewed language cannot be unlocked page by page.
4. Release notes and the store listing may then say the language is available
   without the unreviewed caveat.

A reviewer sign-off does not authorize a release, an upload or a deploy; those
stay separate approvals.
