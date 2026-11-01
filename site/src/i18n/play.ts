import en from './play/en.json';
import type { Saying } from '../data/sayings';
import type { TalkCard, TalkTheme } from '../data/prompts';
import type { WordTheme } from '../data/wordthemes';
import { localeInfo } from './locales';
import { deepMerge } from './ui';

/**
 * Text for the 12 game islands, one language at a time.
 *
 * English is the source (`./play/en.json`); `./play/<code>.json` holds a
 * translation with the same shape and is deep-merged over English, so a
 * missing key shows English rather than nothing. Arrays (sayings, word themes,
 * cards, plural-free lists) are replaced whole, never merged item by item.
 * See `./play/README.md` for what a translation must contain.
 */

/** Every guidance line, button, chip, live message and label the games show. */
export type PlayUi = typeof en.ui;

/** Language-specific game material, not just translated labels. */
export interface PlayContent {
  /** Finish the saying: familiar sayings in this language. */
  sayings: Saying[];
  wordSearch: {
    /** False where a letter grid does not suit the script (Chinese, Japanese, Korean, Thai). */
    available: boolean;
    /** Filler letters for the grid: easy to tell apart in large print. */
    fill: string;
    themes: WordTheme[];
  };
  conversation: {
    /** Chip label for each theme, plus `all`. */
    themes: Record<TalkTheme | 'all', string>;
    cards: TalkCard[];
  };
  coloring: {
    /** Page name and a plain name for every region, keyed by the ids in `src/data/coloring.ts`. */
    pages: Record<string, { name: string; regions: Record<string, string> }>;
  };
  sorting: {
    /** Chip label and the two basket names, keyed by the theme ids in `SortTogether.tsx`. */
    themes: Record<string, { label: string; baskets: [string, string] }>;
  };
}

/** Props every game component takes. Plain JSON for one language only. */
export interface PlayProps {
  ui: PlayUi;
  /** A display name for every picture id in `src/data/pictures.ts`. */
  pictureNames: Record<string, string>;
  content: PlayContent;
  /** Our locale code (`en`, `vi`, `zh-Hans`), used for plural rules, lowercasing and links. */
  lang: string;
}

interface PlayFile {
  ui: PlayUi;
  pictures: Record<string, string>;
  content: PlayContent;
}

const EN = en as unknown as PlayFile;

const files = import.meta.glob<{ default: unknown }>('./play/*.json', { eager: true });
const TRANSLATIONS = new Map(
  Object.entries(files).map(([path, mod]) => [path.replace(/^.*\/(.+)\.json$/, '$1'), mod.default]),
);

/**
 * Scripts where a letter-by-letter grid does not work well. A translation can
 * still turn the word search on by setting `content.wordSearch.available`.
 */
export const NO_LETTER_GRID: readonly string[] = ['zh-Hans', 'zh-Hant', 'ja', 'ko', 'th', 'my', 'yo'];

/**
 * Languages that leave Finish the saying out because a translator could not
 * supply 30 sayings they were sure are genuine. Padding the list with invented
 * proverbs would put made-up "familiar" sayings in front of people with
 * dementia, so the game is omitted instead (no page, card or hreflang) until a
 * native speaker adds real ones and removes the language from this list.
 */
export const NO_SAYINGS_GAME: readonly string[] = ['ha', 'fil', 'pa', 'ne', 'az', 'kn', 'am', 'my', 'uz', 'or', 'as', 'ps', 'yo', 'ig', 'zu', 'so', 'om'];

/** `ui` sections every game uses (the frame and picture tiles). */
export const SHARED_UI: readonly (keyof PlayUi)[] = ['frame', 'tile'];

/**
 * The text each game reads, by slug, beyond `SHARED_UI` and `pictureNames`.
 * `playProps(code, slug)` sends only these, which keeps each game page about
 * 30 KB lighter. A test checks every component against this list.
 */
export const GAME_TEXT: Readonly<Record<string, { ui: readonly (keyof PlayUi)[]; content: readonly (keyof PlayContent)[] }>> = {
  'picture-pairs': { ui: ['pairs', 'picturePairs'], content: [] },
  'find-the-same': { ui: ['choose', 'findTheSame'], content: [] },
  'shadow-match': { ui: ['choose', 'shadowMatch'], content: [] },
  'sort-together': { ui: ['sortTogether'], content: ['sorting'] },
  'picture-puzzle': { ui: ['picturePuzzle'], content: [] },
  'finish-the-saying': { ui: ['finishTheSaying'], content: ['sayings'] },
  'word-search': { ui: ['wordSearch'], content: ['wordSearch'] },
  coloring: { ui: ['coloring'], content: ['coloring'] },
  'conversation-cards': { ui: ['conversationCards'], content: ['conversation'] },
  'photo-pairs': { ui: ['pairs', 'photoPairs'], content: [] },
  'picture-bingo': { ui: ['pictureBingo'], content: [] },
  'calm-breathing': { ui: ['calmBreathing'], content: [] },
};

function pick<T extends object>(source: T, keys: readonly (keyof T)[]): T {
  return Object.fromEntries(keys.map((k) => [k, source[k]])) as T;
}

const cache = new Map<string, PlayProps>();

function fullProps(lang: string): PlayProps {
  const hit = cache.get(lang);
  if (hit) return hit;

  let file: PlayFile = EN;
  if (NO_LETTER_GRID.includes(lang)) {
    file = deepMerge(file, { content: { wordSearch: { available: false } } });
  }
  if (lang !== 'en') file = deepMerge(file, TRANSLATIONS.get(lang));

  const props: PlayProps = { ui: file.ui, pictureNames: file.pictures, content: file.content, lang };
  cache.set(lang, props);
  return props;
}

/**
 * Game props for `code`, English filling any gap. Unknown codes get English.
 * Pass the game's `slug` to send only the text that game reads; without it
 * (or for an unknown slug) every game's text is included.
 */
export function playProps(code: string, slug?: string): PlayProps {
  const full = fullProps(localeInfo(code).code);
  const need = slug ? GAME_TEXT[slug] : undefined;
  if (!need) return full;
  return {
    ...full,
    ui: pick(full.ui, [...SHARED_UI, ...need.ui]),
    content: pick(full.content, need.content),
  };
}
