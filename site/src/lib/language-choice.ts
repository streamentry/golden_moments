/**
 * Choosing a language on the website: which language a first visit should
 * use, and how the reader's own choice is remembered.
 *
 * Detection runs only on the English home page and only when the reader has
 * made no choice yet. A choice made in the language menu (or an English
 * choice) is stored in a cookie, and that cookie always wins.
 */

export const LANGUAGE_COOKIE = 'gm_lang';

/** A language the site can show: its code (BCP 47 style) and URL prefix. */
export interface Offer {
  code: string;
  prefix: string;
}

/**
 * The language a browser's preference list points to, or null to stay in
 * English. Preferences are checked in order: the first one that matches an
 * offered language wins, and an English preference stops the search, so an
 * English-first reader keeps English.
 */
export function matchPreferred(preferred: readonly string[], offers: readonly Offer[]): Offer | null {
  for (const tag of preferred) {
    const parts = tag.toLowerCase().split(/[-_]/);
    const base = parts[0] ?? '';
    const region = parts.find((p, i) => i > 0 && /^[a-z]{2}$/.test(p) && p !== 'hans' && p !== 'hant') ?? '';
    if (base === 'en') return null;
    const wanted = wantedCode(base, parts, region);
    const hit = offers.find((o) => o.code.toLowerCase() === wanted);
    if (hit) return hit;
    const sameBase = offers.find((o) => o.code.toLowerCase().split('-')[0] === base);
    if (sameBase) return sameBase;
  }
  return null;
}

/** The offered code a tag names, using the app's rules for the awkward cases. */
function wantedCode(base: string, parts: readonly string[], region: string): string {
  if (base === 'zh') {
    if (parts.includes('hant')) return 'zh-hant';
    if (parts.includes('hans')) return 'zh-hans';
    return ['tw', 'hk', 'mo'].includes(region) ? 'zh-hant' : 'zh-hans';
  }
  if (base === 'pt') return region === 'pt' ? 'pt-pt' : 'pt-br';
  if (base === 'no' || base === 'nb') return 'nb';
  return base;
}

/** The value of one cookie from a `document.cookie` string, or null. */
export function readCookie(cookies: string, name: string = LANGUAGE_COOKIE): string | null {
  for (const part of cookies.split(';')) {
    const [key, ...rest] = part.trim().split('=');
    if (key === name) return decodeURIComponent(rest.join('=')) || null;
  }
  return null;
}

/** The cookie that records the reader's choice of language. One year, site-wide. */
export function choiceCookie(code: string): string {
  return `${LANGUAGE_COOKIE}=${encodeURIComponent(code)}; Path=/; Max-Age=31536000; SameSite=Lax`;
}
