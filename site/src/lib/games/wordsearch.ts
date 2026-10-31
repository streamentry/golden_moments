import { shuffle, type Rng } from './random';

export interface PlacedWord {
  /** The word as shown in the list, in capitals where the script has them. */
  word: string;
  row: number;
  col: number;
  dir: 'across' | 'down';
}

export interface WordGrid {
  size: number;
  /** One letter per cell; a "letter" is a user-perceived character (grapheme). */
  cells: string[][];
  words: PlacedWord[];
}

export interface WordSearchOptions {
  /** Filler letters, easy to tell apart in large print. Defaults to English. */
  fill?: string;
  /** Language for capitals (Turkish dotted İ, German ß). Defaults to English. */
  locale?: string;
}

/** English letters that are easy to tell apart in large print (no Q, X, Z, J). */
export const ENGLISH_FILL = 'ABCDEFGHIKLMNOPRSTUVWY';

const graphemes =
  typeof Intl !== 'undefined' && 'Segmenter' in Intl ? new Intl.Segmenter(undefined, { granularity: 'grapheme' }) : null;

/**
 * Splits text into the letters a reader sees, so a Hindi syllable with its
 * vowel sign, or a Vietnamese letter with two accents, stays in one cell.
 */
export function lettersOf(text: string): string[] {
  return graphemes ? Array.from(graphemes.segment(text), (s) => s.segment) : Array.from(text);
}

/** Capitals in the page language, with spaces, hyphens and other non-letters removed. */
export function normalizeWord(word: string, locale = 'en'): string {
  return word.toLocaleUpperCase(locale).replace(/[^\p{L}\p{M}]/gu, '');
}

export function cellsOf(w: PlacedWord): [number, number][] {
  return lettersOf(w.word).map((_, i) => (w.dir === 'across' ? [w.row, w.col + i] : [w.row + i, w.col]));
}

/**
 * Places words across (in reading order) and down (top to bottom) only, never
 * backwards or diagonal. Words that do not fit are skipped.
 */
export function createWordSearch(words: readonly string[], size: number, rng: Rng, options: WordSearchOptions = {}): WordGrid {
  const { fill = ENGLISH_FILL, locale = 'en' } = options;
  const cells: string[][] = Array.from({ length: size }, () => Array<string>(size).fill(''));
  const placed: PlacedWord[] = [];
  const candidates = shuffle(
    words
      .map((w) => normalizeWord(w, locale))
      .filter((w) => {
        const n = lettersOf(w).length;
        return n >= 3 && n <= size;
      }),
    rng,
  ).sort((a, b) => lettersOf(b).length - lettersOf(a).length);

  for (const word of candidates) {
    const letters = lettersOf(word);
    const spots: PlacedWord[] = [];
    for (const dir of ['across', 'down'] as const) {
      for (let row = 0; row < size; row++) {
        for (let col = 0; col < size; col++) {
          const pw = { word, row, col, dir };
          const coords = cellsOf(pw);
          const fits = coords.every(([r, c], i) => r < size && c < size && (cells[r]?.[c] === '' || cells[r]?.[c] === letters[i]));
          if (fits) spots.push(pw);
        }
      }
    }
    if (spots.length === 0) continue;
    const choice = spots[Math.floor(rng() * spots.length)] as PlacedWord;
    cellsOf(choice).forEach(([r, c], i) => {
      (cells[r] as string[])[c] = letters[i] as string;
    });
    placed.push(choice);
  }

  const filler = lettersOf(fill);
  for (const row of cells) {
    for (let c = 0; c < size; c++) {
      if (row[c] === '') row[c] = filler[Math.floor(rng() * filler.length)] as string;
    }
  }
  return { size, cells, words: placed };
}

/** Finds the placed word whose first and last letters are these two cells, in either order. */
export function wordBetween(grid: WordGrid, a: [number, number], b: [number, number]): PlacedWord | null {
  for (const w of grid.words) {
    const coords = cellsOf(w);
    const first = coords[0] as [number, number];
    const last = coords[coords.length - 1] as [number, number];
    const same = (p: [number, number], q: [number, number]) => p[0] === q[0] && p[1] === q[1];
    if ((same(first, a) && same(last, b)) || (same(first, b) && same(last, a))) return w;
  }
  return null;
}
