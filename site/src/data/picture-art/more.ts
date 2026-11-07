import { ANIMALS } from './animals.ts';
import { FRUIT } from './fruit.ts';
import { GARDEN } from './garden.ts';
import { HOME } from './home.ts';
import { KITCHEN } from './kitchen.ts';
import { SKY } from './sky.ts';
import { TRAVEL } from './travel.ts';
import type { Picture } from './kit.ts';

/** Pictures drawn after the first set, in one list. */
export const MORE_PICTURES: readonly Picture[] = [
  ...KITCHEN,
  ...FRUIT,
  ...GARDEN,
  ...ANIMALS,
  ...HOME,
  ...TRAVEL,
  ...SKY,
];
