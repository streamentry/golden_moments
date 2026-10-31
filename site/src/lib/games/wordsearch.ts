import { shuffle, type Rng } from './random';

export interface PlacedWord {
  word: string;
  row: number;
  col: number;
  dir: 'across' | 'down';
}

export interface WordGrid {
  size: number;
  cells: string[][];
  words: PlacedWord[];
}

/** Letters that are easy to tell apart in large print (no Q, X, Z, J). */
const FILL = 'ABCDEFGHIKLMNOPRSTUVWY';

export function cellsOf(w: PlacedWord): [number, number][] {
  return Array.from(w.word, (_, i) => (w.dir === 'across' ? [w.row, w.col + i] : [w.row + i, w.col]));
}

/**
 * Places words across (left to right) and down (top to bottom) only, never
 * backwards or diagonal. Words that do not fit are skipped.
 */
export function createWordSearch(words: readonly string[], size: number, rng: Rng): WordGrid {
  const cells: string[][] = Array.from({ length: size }, () => Array<string>(size).fill(''));
  const placed: PlacedWord[] = [];
  const candidates = shuffle(
    words.map((w) => w.toUpperCase().replace(/[^A-Z]/g, '')).filter((w) => w.length >= 3 && w.length <= size),
    rng,
  ).sort((a, b) => b.length - a.length);

  for (const word of candidates) {
    const options: PlacedWord[] = [];
    for (const dir of ['across', 'down'] as const) {
      for (let row = 0; row < size; row++) {
        for (let col = 0; col < size; col++) {
          const pw = { word, row, col, dir };
          const coords = cellsOf(pw);
          const fits = coords.every(([r, c], i) => r < size && c < size && (cells[r]?.[c] === '' || cells[r]?.[c] === word[i]));
          if (fits) options.push(pw);
        }
      }
    }
    if (options.length === 0) continue;
    const choice = options[Math.floor(rng() * options.length)] as PlacedWord;
    cellsOf(choice).forEach(([r, c], i) => {
      (cells[r] as string[])[c] = word[i] as string;
    });
    placed.push(choice);
  }

  for (const row of cells) {
    for (let c = 0; c < size; c++) {
      if (row[c] === '') row[c] = FILL[Math.floor(rng() * FILL.length)] as string;
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
