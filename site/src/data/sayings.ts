/**
 * A saying for Finish the saying. `start` is shown with a blank, `end` is the
 * usual ending, `others` are two friendly alternatives that also make sense.
 *
 * The sayings themselves are language-specific content: English lives in
 * `src/i18n/play/en.json` (`content.sayings`), other languages in
 * `src/i18n/play/<code>.json`.
 */
export interface Saying {
  start: string;
  end: string;
  others: [string, string];
  prompt: string;
}
