import { shuffle, type Rng } from './random';

/** order[i] is the piece currently sitting in slot i. Solved when order[i] === i. */
export interface PuzzleState {
  size: 2 | 3;
  order: number[];
  selected: number | null;
}

export function createPuzzle(size: 2 | 3, rng: Rng): PuzzleState {
  const solved = Array.from({ length: size * size }, (_, i) => i);
  let order = shuffle(solved, rng);
  // Never start solved, and start with at least half the pieces out of place.
  for (let tries = 0; tries < 20 && correctCount({ size, order, selected: null }) > solved.length / 2; tries++) {
    order = shuffle(solved, rng);
  }
  if (order.every((p, i) => p === i)) order = [...order.slice(1), order[0] as number];
  return { size, order, selected: null };
}

export function tapPiece(state: PuzzleState, slot: number): PuzzleState {
  if (slot < 0 || slot >= state.order.length) return state;
  if (state.selected === null) return { ...state, selected: slot };
  if (state.selected === slot) return { ...state, selected: null };
  const order = [...state.order];
  const a = state.selected;
  [order[a], order[slot]] = [order[slot] as number, order[a] as number];
  return { ...state, order, selected: null };
}

export function correctCount(state: PuzzleState): number {
  return state.order.filter((piece, slot) => piece === slot).length;
}

export function isSolved(state: PuzzleState): boolean {
  return correctCount(state) === state.order.length;
}
