/**
 * Meta descriptions must be 70 to 170 characters wide (scripts/check-site.mjs).
 * Translations often run longer, so the layout fits them to the limit: whole
 * sentences when they fit, otherwise a word-boundary cut with an ellipsis.
 */

export const META_DESCRIPTION_MAX = 170;

const WIDE =
  /[ᄀ-ᅟ⺀-꓏가-힣豈-﫿︰-﹏＀-｠￠-￦]/;

/** Display width: CJK characters count two, combining marks none. */
export function displayWidth(text: string): number {
  let width = 0;
  for (const ch of text) {
    if (/\p{M}/u.test(ch)) continue;
    width += WIDE.test(ch) ? 2 : 1;
  }
  return width;
}

/** Sentences with their trailing spaces; ends at . ! ? and their CJK and Devanagari forms. */
const SENTENCE = /[^.!?。！？।]*[.!?。！？।]+\s*/gu;

export function fitDescription(text: string, max = META_DESCRIPTION_MAX): string {
  if (displayWidth(text) <= max) return text;

  let whole = '';
  for (const match of text.matchAll(SENTENCE)) {
    const next = whole + match[0];
    if (displayWidth(next.trimEnd()) > max) break;
    whole = next;
  }
  if (whole.trim() && displayWidth(whole.trimEnd()) >= 70) return whole.trimEnd();

  const chars = Array.from(text);
  let cut = '';
  let i = 0;
  for (; i < chars.length; i++) {
    const candidate = cut + chars[i];
    if (displayWidth(candidate.trimEnd() + '…') > max) break;
    cut = candidate;
  }
  // Do not leave a half word behind when there is a space to end on.
  if (i < chars.length && !/\s/.test(chars[i] ?? '') && /\s/.test(cut)) {
    cut = cut.replace(/\s*\S*$/u, '');
  }
  return cut.trimEnd() + '…';
}
