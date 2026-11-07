/**
 * Drawing kit shared by every picture (src/data/pictures.ts). One ink, one
 * line weight, one palette and one way of showing light, so a picture drawn
 * today sits beside the first ones without looking borrowed.
 *
 * - Outline: `S` (3px ink, round joins). Use `stroke-width` to vary.
 * - Shade: `SHADE` on a path without stroke, over the side away from the
 *   light (light comes from the upper left).
 * - Shine: `SHINE` for a small paper-white highlight stroke (3px unless a
 *   `stroke-width` follows it).
 */
export const INK = '#2b2b2b';
export const S = `stroke="${INK}" stroke-linejoin="round" stroke-linecap="round"`;
export const SHADE = `fill="${INK}" fill-opacity=".16"`;
export const SHINE = `fill="none" stroke="#FFFDF7" stroke-opacity=".85" stroke-linecap="round"`;

export const BG = {
  cream: '#F9E7C3',
  sky: '#DCEBF2',
  sage: '#E3EDD5',
  blush: '#F6DCD3',
  night: '#34506F',
} as const;

export const C = {
  paper: '#FFFDF7',
  brown: '#8A5A2B',
  wood: '#B0552B',
  tan: '#D9A15B',
  sand: '#E8C9A0',
  red: '#C8473A',
  deepRed: '#B3262E',
  pink: '#E58FA0',
  orange: '#E07B28',
  mustard: '#E0A526',
  yellow: '#F2D03B',
  green: '#4E8A3E',
  deepGreen: '#3E7A30',
  leaf: '#9BBF6A',
  blue: '#2F6F9E',
  sky: '#8DB8D6',
  plum: '#7B4A8C',
  peach: '#F2A26B',
  grey: '#8C8C8C',
  silver: '#C8C8C8',
  white: '#FFFFFF',
} as const;

export type PictureCategory =
  | 'kitchen'
  | 'garden'
  | 'animals'
  | 'fruit'
  | 'home'
  | 'travel'
  | 'sky';

export interface Picture {
  id: string;
  /**
   * English name, used in the SVG title. The games show the name from
   * `src/i18n/play/<code>.json` (`pictures`); `en.json` must match this exactly.
   */
  name: string;
  category: PictureCategory;
  bg: string;
  body: string;
  /** Where the subject rests (y), for a soft contact shadow under it. */
  ground?: number;
}
