import { sample, shuffle, type Rng } from './random';

export type BingoCard = string[];

/** Unique cards (no two share the same set of pictures) drawn from `pool`. */
export function createBingoCards(pool: readonly string[], squares: number, count: number, rng: Rng): BingoCard[] {
  const cards: BingoCard[] = [];
  const seen = new Set<string>();
  for (let attempt = 0; cards.length < count && attempt < count * 50; attempt++) {
    const card = sample(pool, squares, rng);
    const signature = [...card].sort().join('|');
    if (seen.has(signature)) continue;
    seen.add(signature);
    cards.push(card);
  }
  return cards;
}

export function createCallOrder(pool: readonly string[], rng: Rng): string[] {
  return shuffle(pool, rng);
}
