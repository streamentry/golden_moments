import { shuffle, type Rng } from './random';

export interface PairTile {
  /** Stable key for rendering. */
  key: string;
  /** What the tile shows: a picture id or a photo URL. */
  value: string;
  matched: boolean;
}

export interface PairsState {
  tiles: PairTile[];
  selected: number | null;
  /** Two tiles that were tapped and differ; they stay put until the next tap. */
  mismatch: [number, number] | null;
  lastMatch: number | null;
}

export function createPairs(values: readonly string[], rng: Rng): PairsState {
  const doubled = values.flatMap((value, i) => [
    { key: `${i}-a`, value, matched: false },
    { key: `${i}-b`, value, matched: false },
  ]);
  return { tiles: shuffle(doubled, rng), selected: null, mismatch: null, lastMatch: null };
}

/**
 * One tap. Nothing changes on a timer: a mismatch stays visible until the
 * next deliberate tap, which clears it and starts the next turn.
 */
export function tapPair(state: PairsState, index: number): PairsState {
  const tile = state.tiles[index];
  if (!tile || tile.matched) return state;

  if (state.mismatch) {
    return { ...state, mismatch: null, selected: index, lastMatch: null };
  }
  if (state.selected === null) {
    return { ...state, selected: index, lastMatch: null };
  }
  if (state.selected === index) {
    return { ...state, selected: null };
  }

  const first = state.tiles[state.selected];
  if (first && first.value === tile.value) {
    const tiles = state.tiles.map((t, i) => (i === index || i === state.selected ? { ...t, matched: true } : t));
    return { tiles, selected: null, mismatch: null, lastMatch: index };
  }
  return { ...state, selected: null, mismatch: [state.selected, index], lastMatch: null };
}

export function isComplete(state: PairsState): boolean {
  return state.tiles.length > 0 && state.tiles.every((t) => t.matched);
}

export function matchedPairs(state: PairsState): number {
  return state.tiles.filter((t) => t.matched).length / 2;
}

/** Columns that keep the whole board on one screen without tiny tiles. */
export function boardColumns(tileCount: number, wide: boolean): number {
  if (tileCount <= 4) return 2;
  if (tileCount <= 6) return wide ? 3 : 2;
  if (tileCount <= 8) return wide ? 4 : 2;
  return wide ? 4 : 3;
}
