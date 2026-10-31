import { sample, shuffle, type Rng } from './random';

/** Pictures whose shadow is easy to recognise (checked on a contact sheet). */
export const SHADOW_IDS: readonly string[] = [
  'teacup', 'kettle', 'frying-pan', 'cake', 'sunflower', 'tulip', 'watering-can', 'potted-plant',
  'tree', 'bird', 'butterfly', 'cat', 'fish', 'apple', 'pear', 'strawberry', 'banana', 'cherries',
  'house', 'lamp', 'armchair', 'key', 'umbrella', 'sailboat', 'car', 'bicycle', 'balloon',
  'lighthouse', 'sun', 'moon',
];

export interface ShadowRound {
  /** The picture whose shadow is shown. */
  target: string;
  /** Pictures to choose from, including the target, in shuffled order. */
  options: string[];
}

/**
 * A round with [count] different pictures, one of which casts the shadow.
 * The previous target is not used again straight away.
 */
export function createShadowRound(count: number, rng: Rng, previous?: string, pool: readonly string[] = SHADOW_IDS): ShadowRound {
  const choices = pool.filter((id) => id !== previous);
  const picked = sample(choices, Math.max(2, Math.min(count, choices.length)), rng);
  return { target: picked[0] as string, options: shuffle(picked, rng) };
}
