/**
 * Page titles that fit in a search result. Search engines cut titles at
 * roughly 60–70 characters, so a long translated title loses its end. When
 * the brand suffix would push a title past the limit, the suffix is dropped:
 * the words that say what the page is matter more than the site name, which
 * search results already show and the page's metadata already carries.
 */

/** The widest title (in display width) that keeps its brand suffix. */
export const MAX_TITLE_WIDTH = 70;

// Chinese, Japanese and Korean characters take two columns; combining marks take none.
// Keep in step with `width` in scripts/check-site.mjs.
const WIDE = /[ᄀ-ᅟ⺀-꓏가-힣豈-﫿︰-﹏＀-｠￠-￦]/;

/** Display width of `text`, measured the way the site checker measures it. */
export function displayWidth(text: string): number {
  return [...text].reduce((n, ch) => n + (/\p{M}/u.test(ch) ? 0 : WIDE.test(ch) ? 2 : 1), 0);
}

/** `title` plus `suffix`, or `title` alone when the two together are too wide. */
export function composeTitle(title: string, suffix: string, max: number = MAX_TITLE_WIDTH): string {
  const full = `${title}${suffix}`;
  return displayWidth(full) <= max ? full : title;
}
