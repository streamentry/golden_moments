# Translating the website

English (`en.json`, `src/content/guides/`) is the source. Every other language
is a machine translation published as **unreviewed**: each translated page says
so and links to the English original. A native speaker can review a language
later. Every published language is indexed: it has its own sitemap
(`/<prefix>/sitemap.xml`, English at `/sitemap-en.xml`) with hreflang alternates,
listed by the index at `/sitemap.xml`, and appears in `llms.txt`. To pull a language back out, remove
its code from `INDEXED_LANGUAGES` in `src/i18n/locales.ts`; its pages become
`noindex` and its sitemap empties.

## Files per language (`<code>` as in `locales.ts`)

| File | Source | Check |
| --- | --- | --- |
| `src/i18n/ui/<code>.json` | `src/i18n/ui/en.json` | `node scripts/check-translation.mjs src/i18n/ui/en.json src/i18n/ui/<code>.json` |
| `src/i18n/games/<code>.json` | `src/i18n/games/en.json` | same script with the games files |
| `src/i18n/play/<code>.json` | `src/i18n/play/en.json` (see `play/README.md`) | same script |
| `src/content/guides-i18n/<code>/<section>/<slug>.md` | `src/content/guides/<section>/<slug>.md` | `python3 scripts/check-guide-translation.py <code>`, then `pnpm exec astro build` |

A language goes live when `ui/<code>.json` exists, so add the games file in the
same change. A translated guide keeps the English frontmatter for `section`,
`order`, dates, `sources`, `relatedGames`, `related` and `health`, adds
`translatedFrom` (the English `updated` it was made from), and keeps every
link target in the same order; links stay English paths and the site points
them at the reader's language when that page exists.

## Rules

- **Who reads it:** family caregivers, often anxious and on a phone, and
  activity staff. Warm, plain, adult language at about a grade 6–8 level. Write
  what a native speaker would naturally say; never translate word for word.
- **Respect:** say the local equivalent of "people living with dementia" or
  "the person you care for". Never "patients", "sufferers", "victims", "the
  demented" or baby talk. Use the polite but warm form of address that the
  language uses for adults (for example `Sie` in German, `vous` in French,
  `Bạn` in Vietnamese, です/ます in Japanese).
- **No claims:** never say or imply that a game or activity treats, slows,
  prevents, cures or "trains" anything, gives "results" or measures anyone. Keep
  every hedge ("may", "linked with", "the evidence is mixed").
- **Keep exactly:** JSON keys, `{placeholders}`, HTML tags and every `href`
  value, `href`/`icon`/`id` fields, the brand name `Golden Moments` and the
  store name `Dementia Games: Golden Moments`.
- **Localize, don't transplant:** replace US-only details with local ones where
  the text gives advice (for example "call 911" becomes "call your local
  emergency number"). Keep source titles, publishers and URLs of cited studies
  as they are.
- **Search wording:** titles (`title`, `seoTitle`) and `description` fields are
  what search engines and AI assistants show. Use the words people in that
  language actually search for (for example dementia *games*, *activities*,
  *Alzheimer's*), keep `seoTitle`/`title` under about 60 characters and
  descriptions under about 160 where the language allows.
- **Typography:** use the language's own quotation marks and punctuation, and
  no exclamation-mark praise or emoji. In Arabic, write the arrow in "… →"
  labels as "←", since the text reads right to left.
