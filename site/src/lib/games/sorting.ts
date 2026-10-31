import { sample, shuffle, type Rng } from './random';

export interface SortItem {
  id: string;
  basket: 0 | 1;
}

export interface SortState {
  items: SortItem[];
  placed: Record<string, 0 | 1>;
  selected: string | null;
  /** The item that was offered to the other basket, for a gentle hint. */
  hint: { id: string; basket: 0 | 1 } | null;
}

export function createSort(groupA: readonly string[], groupB: readonly string[], perGroup: number, rng: Rng): SortState {
  const items: SortItem[] = shuffle(
    [
      ...sample(groupA, perGroup, rng).map((id) => ({ id, basket: 0 as const })),
      ...sample(groupB, perGroup, rng).map((id) => ({ id, basket: 1 as const })),
    ],
    rng,
  );
  return { items, placed: {}, selected: null, hint: null };
}

export function selectItem(state: SortState, id: string): SortState {
  if (state.placed[id] !== undefined) return state;
  return { ...state, selected: state.selected === id ? null : id, hint: null };
}

export function dropInBasket(state: SortState, basket: 0 | 1): SortState {
  const id = state.selected;
  if (!id) return state;
  const item = state.items.find((i) => i.id === id);
  if (!item) return state;
  if (item.basket !== basket) return { ...state, hint: { id, basket: item.basket } };
  return { ...state, placed: { ...state.placed, [id]: basket }, selected: null, hint: null };
}

export function isSorted(state: SortState): boolean {
  return state.items.every((i) => state.placed[i.id] !== undefined);
}
