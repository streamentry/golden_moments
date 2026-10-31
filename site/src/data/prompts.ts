/**
 * Conversation cards. Open invitations only: nothing to get right, no
 * "Do you remember…?" and no "Who is this?".
 *
 * The cards and theme labels are language-specific content: English lives in
 * `src/i18n/play/en.json` (`content.conversation`), other languages in
 * `src/i18n/play/<code>.json`. Each card's `picture` is an id from
 * `src/data/pictures.ts`.
 */
export interface TalkCard {
  theme: TalkTheme;
  picture: string;
  prompt: string;
}

export type TalkTheme = 'food' | 'home' | 'outdoors' | 'animals' | 'travel' | 'work' | 'music' | 'seasons';

/** Theme chips, in order. */
export const TALK_THEME_ORDER: readonly (TalkTheme | 'all')[] = [
  'all',
  'food',
  'home',
  'outdoors',
  'animals',
  'travel',
  'work',
  'music',
  'seasons',
];
