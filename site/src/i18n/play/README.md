# Game text and content, per language

The 12 browser games read all their words from here. `en.json` is the English
source. A translation is `<code>.json` in this folder, named with a code from
`LOCALES` in `../locales.ts` (for example `es.json`, `pt-BR.json`, `ar.json`,
`vi.json`).

`../play.ts` merges a translation over English key by key, so a missing key shows
English rather than nothing. **Arrays are replaced whole**: if you give
`content.sayings`, give the complete list, never a partial one. The page passes
only one language to the browser, through `playProps(code, slug)`.

Start by copying `en.json`, keep every key and id exactly as it is, and change
only the text. Run `pnpm exec vitest run` afterwards: `play.test.ts` checks
every file in this folder against the rules below.

## Who it is for

Read `../../../CONTENT_GUIDE.md` (voice) and `../../../../DESIGN.md` first. In
short: the player is an adult living with dementia, playing with a family
member or carer. Write plain, warm, adult language.

- **Familiar, not clever.** Everyday words and sayings that older adults in
  that country grew up with. No slang, wordplay, regional rarities or
  anything that needs explaining.
- **No quizzing.** Never "Do you remember…?", "Who is this?", "What year…?" or
  anything with one right answer. Prompts are open invitations: "Tell me
  about…", "What do you like…?".
- **No scores or pressure.** No "correct", "wrong", "try harder", "well done!",
  levels, speed or counting what someone got right. Wrong choices are never
  called wrong ("That one is the pear. Take your time.").
- **No health claims.** Never say or imply the games train, improve, protect,
  test or treat memory, the brain or dementia. Avoid brain, memory, therapy,
  exercise for the mind, patients.
- **Dignity.** Not childish. No emoji, no exclamation marks in praise, no ALL
  CAPS (word search letters are the one exception), sentence case.

## What to produce for each language

| Key | How many | What it is |
| --- | --- | --- |
| `ui` | 189 strings in 16 sections | Guidance, buttons, chips, live messages, labels, print headings |
| `pictures` | 33 names | One name per picture id (list below) |
| `content.sayings` | at least 30; aim for 40–50 (English has 50) | Finish the saying |
| `content.wordSearch` | `fill` + at least 4 themes (English has 6) × at least 6 words (English has 9) | Word search |
| `content.conversation` | 9 theme labels + at least 2 cards per theme (English has 43 cards) | Conversation cards |
| `content.coloring` | 5 page names + 47 region names | Coloring |
| `content.sorting` | 3 themes × (label + 2 basket names) | Sort together |

### `ui`

- Keep every `{placeholder}` exactly as written; you may move it within the
  sentence. The test fails if a translation uses a placeholder English does
  not have.
- `{name|lower}` puts a picture or color name in lowercase inside a sentence
  ("Two pictures of the red apple"). Where your language does not lowercase
  nouns (German) or has no case, write `{name}` instead. These keys use it:
  `pairs.picturePair`, `choose.thatOne`, `findTheSame.yes`, `shadowMatch.yes`,
  `shadowMatch.foundAlt`, `sortTogether.hint`, `sortTogether.placed`,
  `picturePuzzle.whole`, `coloring.painted`, `coloring.partPainted`.
- Rephrase freely where English grammar does not carry over. "Two pictures of
  the {name}" can become "Two pictures: {name}" if articles or gender would
  otherwise be wrong.
- **Plurals.** These keys are objects of plural forms: `picturePairs.size`,
  `sortTogether.basket`, `picturePuzzle.size`, `picturePuzzle.swapped`,
  `wordSearch.size`, `photoPairs.skipped`, `pictureBingo.called`,
  `pictureBingo.cards`, `pictureBingo.print`. Give every form your language
  uses, named `zero`, `one`, `two`, `few`, `many` and `other`
  (Russian, Ukrainian and Polish need `one`, `few`, `many`, `other`; Arabic
  needs all six; Japanese, Korean, Chinese, Thai, Vietnamese and Indonesian
  need only `other`). The test checks this with `Intl.PluralRules`.
- `photoPairs.intro`: text between `**` is shown in bold. Keep one bold run.
- `finishTheSaying.gap` is what goes between the start of a saying and the
  blank: a space in English, `""` in Chinese, Japanese and Thai.
  `finishTheSaying.ending` is the revealed last word with its sentence mark
  (`"{end}."` in English, `"{end}。"` in Chinese and Japanese).
- `picturePuzzle.places4` (4 items) and `places9` (9 items) name the board
  positions in reading order: top row first, left to right. Keep the counts.
  The puzzle board itself stays left to right in every language, because the
  pieces are slices of a picture.
- `picturePuzzle.pictures` are short chip labels for six puzzle pictures; they
  may be shorter than the full picture names.
- `coloring.paints`: 12 color names. Keep them distinct and common
  ("Sky blue", not "Cerulean").
- `wordSearch.unavailable` is shown instead of the game where the word search
  is off (see below).

### `pictures`

A short, concrete name for each drawing (look at `/pictures/<id>.svg` on the
site): `teacup`, `kettle`, `bread` (loaf of bread), `frying-pan` (with an egg),
`cake` (birthday cake), `sunflower`, `tulip` (red), `watering-can`,
`potted-plant`, `tree`, `bird` (robin on a branch), `butterfly`, `dog`, `cat`,
`fish` (goldfish), `apple` (red), `pear`, `strawberry`, `banana`, `lemon`,
`cherries`, `house`, `lamp` (table lamp), `armchair`, `key` (old key),
`umbrella`, `sailboat`, `car` (classic car), `bicycle`, `balloon` (hot air
balloon), `lighthouse`, `sun`, `moon` (moon and stars).

Names are also read aloud as tile labels ("Teacup, tile 3"), so start with
the noun people would say first.

### `content.sayings` (Finish the saying)

Each item is `{ "start", "end", "others": [two words], "prompt" }`.

- A **traditional, widely known saying or proverb in that language**, not a
  translation of an English one. Public domain only: no song lyrics, poems,
  slogans or advertising lines.
- `end` is the usual last word (or short phrase); the player picks it from
  three buttons, so it must be the natural ending and fit on a large button
  (1–2 words).
- `others`: two friendly alternatives that are plausible and gentle, never
  silly at the person's expense, never a trick. All three must differ.
- `prompt`: one open, everyday conversation starter linked to the saying.
  Never a memory question.
- Avoid sayings about illness, death, old age, losing your mind, money worries
  or anything that could sting.
- For languages written without spaces, set `ui.finishTheSaying.gap` to `""`.

### `content.wordSearch`

- `available`: leave `true` unless a letter grid does not suit the script.
  It is already `false` for Chinese (both scripts), Japanese, Korean and Thai
  (`NO_LETTER_GRID` in `../play.ts`); delete `content.wordSearch` from those
  files, or copying `"available": true` from English would turn it back on.
- `fill`: at least 10 different letters used to fill empty squares. Pick
  letters that are easy to tell apart in large print (English leaves out Q, X,
  Z, J). For scripts with joined letters or vowel signs (Arabic, Hindi), each
  cell holds one letter as a reader sees it (a whole syllable with its vowel
  sign in Hindi).
- `themes`: each `{ "value", "label", "words" }`. Keep the English `value`
  ids (`fruit`, `garden`, `kitchen`, `weather`, `animals`, `home`) where the
  theme still fits; replace a theme only if it would feel foreign.
- `words`: common nouns of **3 to 6 letters** (as the reader counts them),
  no spaces or hyphens, at least 6 per theme. Words read in the language's
  direction: across means right to left in Arabic. Words are shown in
  capitals where the script has them.

### `content.conversation`

- `themes`: chip labels for `all`, `food`, `home`, `outdoors`, `animals`,
  `travel`, `work`, `music`, `seasons`.
- `cards`: each `{ "theme", "picture", "prompt" }`. Use a theme id and a
  picture id from the lists above. At least 2 cards per theme; matching the
  43 English cards is ideal. Adapt rather than translate: food, seasons,
  music and work should feel local. Open invitations only, no right answers.

### `content.coloring`

Five pages keyed by id (`flower`, `house`, `teacup`, `butterfly`,
`sailboat`), each with a `name` and a `regions` map giving every region a
plain name that is read aloud ("Left window"). Keep all region ids:
flower 16, house 10, teacup 6, butterfly 8, sailboat 7.

### `content.sorting`

`kitchen-garden`, `fruit-animals`, `home-travel`: a chip `label` and two
`baskets` names, in that order (the pictures sorted into each basket are
fixed).

## Right-to-left languages

`ar` pages get `<html dir="rtl">`. The games use logical CSS properties, so
the layout mirrors; the picture puzzle stays left to right on purpose. Write
Arabic text normally; do not add direction marks unless a mixed-direction
string displays wrongly.
