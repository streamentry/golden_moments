import { describe, expect, it } from 'vitest';
import { createRng, shuffle } from './random';
import { boardColumns, createPairs, isComplete, matchedPairs, tapPair } from './pairs';
import { correctCount, createPuzzle, isSolved, tapPiece } from './puzzle';
import { cellsOf, createWordSearch, lettersOf, normalizeWord, wordBetween } from './wordsearch';
import { createBingoCards } from './bingo';
import { createSort, dropInBasket, isSorted, selectItem } from './sorting';
import { SHADOW_IDS, createShadowRound } from './shadow';
import { PICTURE_BY_ID } from '../../data/pictures';

describe('random', () => {
  it('shuffles a copy without touching the input', () => {
    const input = [1, 2, 3, 4, 5];
    const out = shuffle(input, createRng(1));
    expect(input).toEqual([1, 2, 3, 4, 5]);
    expect([...out].sort()).toEqual(input);
  });

  it('is reproducible for a seed', () => {
    expect(shuffle([1, 2, 3, 4, 5, 6], createRng(42))).toEqual(shuffle([1, 2, 3, 4, 5, 6], createRng(42)));
  });
});

describe('pairs', () => {
  const findPair = (state: ReturnType<typeof createPairs>, index: number) =>
    state.tiles.findIndex((t, i) => i !== index && t.value === state.tiles[index]?.value);

  it('creates two tiles per value', () => {
    const state = createPairs(['a', 'b'], createRng(3));
    expect(state.tiles).toHaveLength(4);
    expect(state.tiles.filter((t) => t.value === 'a')).toHaveLength(2);
  });

  it('matches two equal tiles and keeps them matched', () => {
    let state = createPairs(['a', 'b'], createRng(3));
    const other = findPair(state, 0);
    state = tapPair(tapPair(state, 0), other);
    expect(state.tiles[0]?.matched).toBe(true);
    expect(state.tiles[other]?.matched).toBe(true);
    expect(state.lastMatch).toBe(other);
    expect(matchedPairs(state)).toBe(1);
  });

  it('leaves a mismatch visible until the next deliberate tap', () => {
    let state = createPairs(['a', 'b'], createRng(3));
    const different = state.tiles.findIndex((t) => t.value !== state.tiles[0]?.value);
    state = tapPair(tapPair(state, 0), different);
    expect(state.mismatch).toEqual([0, different]);
    // Nothing else changes until another tap; that tap clears and selects.
    const next = tapPair(state, 0);
    expect(next.mismatch).toBeNull();
    expect(next.selected).toBe(0);
  });

  it('ignores taps on matched tiles and deselects on a second tap', () => {
    let state = createPairs(['a', 'b'], createRng(5));
    state = tapPair(state, 1);
    expect(tapPair(state, 1).selected).toBeNull();
    const other = findPair(state, 1);
    state = tapPair(state, other);
    expect(tapPair(state, 1)).toBe(state);
  });

  it('completes when every pair is matched', () => {
    let state = createPairs(['a', 'b', 'c'], createRng(9));
    for (let i = 0; i < state.tiles.length; i++) {
      if (state.tiles[i]?.matched) continue;
      state = tapPair(tapPair(state, i), findPair(state, i));
    }
    expect(isComplete(state)).toBe(true);
  });

  it('keeps small boards in two columns', () => {
    expect(boardColumns(4, true)).toBe(2);
    expect(boardColumns(12, false)).toBe(3);
  });
});

describe('puzzle', () => {
  it('never starts solved', () => {
    for (let seed = 0; seed < 50; seed++) {
      expect(isSolved(createPuzzle(2, createRng(seed)))).toBe(false);
    }
  });

  it('swaps two tapped pieces', () => {
    const start = createPuzzle(3, createRng(7));
    const after = tapPiece(tapPiece(start, 0), 4);
    expect(after.order[0]).toBe(start.order[4]);
    expect(after.order[4]).toBe(start.order[0]);
    expect(after.selected).toBeNull();
  });

  it('can always be solved by swapping', () => {
    let state = createPuzzle(3, createRng(11));
    for (let slot = 0; slot < state.order.length; slot++) {
      const where = state.order.indexOf(slot);
      if (where !== slot) state = tapPiece(tapPiece(state, slot), where);
    }
    expect(isSolved(state)).toBe(true);
    expect(correctCount(state)).toBe(9);
  });
});

describe('word search', () => {
  const words = ['APPLE', 'PEAR', 'LEMON', 'PLUM'];

  it('places words across or down only, readable forwards', () => {
    const grid = createWordSearch(words, 7, createRng(2));
    expect(grid.words.length).toBeGreaterThanOrEqual(3);
    for (const w of grid.words) {
      expect(['across', 'down']).toContain(w.dir);
      const read = cellsOf(w)
        .map(([r, c]) => grid.cells[r]?.[c])
        .join('');
      expect(read).toBe(w.word);
    }
  });

  it('fills every cell with a capital letter', () => {
    const grid = createWordSearch(words, 7, createRng(4));
    expect(grid.cells.flat().every((ch) => /^[A-Z]$/.test(ch))).toBe(true);
  });

  it('finds a word from its first and last letters in either order', () => {
    const grid = createWordSearch(words, 7, createRng(6));
    const w = grid.words[0]!;
    const coords = cellsOf(w);
    expect(wordBetween(grid, coords[0]!, coords[coords.length - 1]!)).toBe(w);
    expect(wordBetween(grid, coords[coords.length - 1]!, coords[0]!)).toBe(w);
    expect(wordBetween(grid, coords[0]!, coords[0]!)).toBeNull();
  });

  it('keeps accented and non-Latin letters, in the language capitals', () => {
    const grid = createWordSearch(['ırmak', 'çiçek', 'elma'], 6, createRng(8), { fill: 'ABCÇDEFGĞHIİ', locale: 'tr' });
    expect(grid.words.map((w) => w.word).sort()).toEqual(['ELMA', 'IRMAK', 'ÇİÇEK']);
    for (const w of grid.words) {
      expect(cellsOf(w).map(([r, c]) => grid.cells[r]?.[c]).join('')).toBe(w.word);
    }
    expect(grid.cells.flat().every((ch) => [...'ABCÇDEFGĞHIİKLMRŞEÜ'].includes(ch) || /\p{L}/u.test(ch))).toBe(true);
  });

  it('keeps a letter with its marks in one cell', () => {
    expect(lettersOf('किताब')).toEqual(['कि', 'ता', 'ब']);
    expect(lettersOf('NGƯỜI')).toHaveLength(5);
    const grid = createWordSearch(['किताब', 'अनार', 'कमल'], 6, createRng(3), { fill: 'कखगचजतदनपबमरलवस', locale: 'hi' });
    expect(grid.words).toHaveLength(3);
    for (const w of grid.words) {
      expect(cellsOf(w)).toHaveLength(lettersOf(w.word).length);
      expect(cellsOf(w).map(([r, c]) => grid.cells[r]?.[c]).join('')).toBe(w.word);
    }
  });

  it('drops spaces and punctuation from words', () => {
    expect(normalizeWord("tea-pot's", 'en')).toBe('TEAPOTS');
  });
});

describe('bingo', () => {
  it('makes distinct cards of the requested size', () => {
    const pool = Array.from({ length: 24 }, (_, i) => `p${i}`);
    const cards = createBingoCards(pool, 9, 20, createRng(8));
    expect(cards).toHaveLength(20);
    const signatures = new Set(cards.map((c) => [...c].sort().join()));
    expect(signatures.size).toBe(20);
    expect(cards.every((c) => c.length === 9 && new Set(c).size === 9)).toBe(true);
  });
});

describe('sorting', () => {
  it('accepts the right basket and offers a hint for the other one', () => {
    let state = createSort(['k1', 'k2', 'k3'], ['g1', 'g2', 'g3'], 2, createRng(1));
    const item = state.items[0]!;
    state = selectItem(state, item.id);
    const wrong = dropInBasket(state, item.basket === 0 ? 1 : 0);
    expect(wrong.placed[item.id]).toBeUndefined();
    expect(wrong.hint).toEqual({ id: item.id, basket: item.basket });
    const right = dropInBasket(wrong, item.basket);
    expect(right.placed[item.id]).toBe(item.basket);
    expect(right.hint).toBeNull();
  });

  it('is sorted when every item has a basket', () => {
    let state = createSort(['k1', 'k2'], ['g1', 'g2'], 2, createRng(3));
    for (const item of state.items) state = dropInBasket(selectItem(state, item.id), item.basket);
    expect(isSorted(state)).toBe(true);
  });
});

describe('shadow match', () => {
  it('offers distinct pictures that include the shadow', () => {
    for (let seed = 0; seed < 50; seed++) {
      for (const count of [2, 3, 4]) {
        const round = createShadowRound(count, createRng(seed));
        expect(round.options).toHaveLength(count);
        expect(new Set(round.options).size).toBe(count);
        expect(round.options).toContain(round.target);
      }
    }
  });

  it('does not repeat the last shadow straight away', () => {
    for (let seed = 0; seed < 50; seed++) {
      const first = createShadowRound(3, createRng(seed));
      expect(createShadowRound(3, createRng(seed + 1000), first.target).target).not.toBe(first.target);
    }
  });

  it('uses only real pictures, leaving out shapes that read as blobs', () => {
    for (const id of SHADOW_IDS) expect(PICTURE_BY_ID.has(id)).toBe(true);
    for (const blob of ['bread', 'dog', 'lemon']) expect(SHADOW_IDS).not.toContain(blob);
  });
});
