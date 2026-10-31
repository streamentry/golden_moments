/**
 * A word search theme. Short, familiar words; the generator uses the ones
 * that fit the grid.
 *
 * Themes are language-specific content: English lives in
 * `src/i18n/play/en.json` (`content.wordSearch.themes`), other languages in
 * `src/i18n/play/<code>.json`.
 */
export interface WordTheme {
  value: string;
  label: string;
  words: string[];
}
