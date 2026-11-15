/**
 * Analytics consent for the website's Google Analytics 4 tag
 * (components/Analytics.astro).
 *
 * In the regions below Google Analytics loads only after the visitor chooses
 * "Allow". Elsewhere it loads as before. These are the regions Google's EU user
 * consent policy names (EEA, UK, Switzerland), where the ePrivacy rules and the
 * GDPR require consent before analytics cookies are set.
 *
 * The country comes from our host's /cdn-cgi/trace response, a same-origin
 * request that adds no third party. When the country is unknown the visitor is
 * asked, so a failed lookup never loads Analytics without a choice.
 */

/** EU 27, then Iceland, Liechtenstein, Norway (EEA), then the UK and Switzerland. */
export const CONSENT_REGIONS: readonly string[] = [
  'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE',
  'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE',
  'IS', 'LI', 'NO',
  'GB', 'CH',
];

/** Where the choice is kept: this browser only, never sent anywhere. */
export const CHOICE_KEY = 'gm-analytics-choice';

export type Choice = 'granted' | 'denied';
export type Decision = 'load' | 'ask' | 'skip';

/** Reads `loc=XX` from a Cloudflare trace. Unknown (XX) and Tor (T1) give null. */
export function countryFromTrace(text: string): string | null {
  const match = /^loc=([A-Z]{2})$/m.exec(text);
  if (!match) return null;
  const code = match[1]!;
  return code === 'XX' || code === 'T1' ? null : code;
}

/** True where consent is needed first, or where the country is unknown. */
export function needsConsent(country: string | null): boolean {
  return country === null || CONSENT_REGIONS.includes(country);
}

/** A saved choice always wins; without one, ask only where consent is needed. */
export function decide(choice: Choice | null, country: string | null): Decision {
  if (choice === 'granted') return 'load';
  if (choice === 'denied') return 'skip';
  return needsConsent(country) ? 'ask' : 'load';
}

interface ChoiceStorage {
  getItem(key: string): string | null;
  setItem(key: string, value: string): void;
}

/** The saved choice, or null when there is none or storage is blocked. */
export function readChoice(storage: ChoiceStorage | undefined): Choice | null {
  try {
    const value = storage?.getItem(CHOICE_KEY);
    return value === 'granted' || value === 'denied' ? value : null;
  } catch {
    return null;
  }
}

/** Saves the choice; returns false when storage is blocked (the choice then lasts for this page only). */
export function saveChoice(storage: ChoiceStorage | undefined, choice: Choice): boolean {
  try {
    if (!storage) return false;
    storage.setItem(CHOICE_KEY, choice);
    return true;
  } catch {
    return false;
  }
}

/** Names of the Google Analytics cookies (`_ga`, `_ga_<id>`) in a cookie string. */
export function analyticsCookieNames(cookies: string): string[] {
  return cookies
    .split(';')
    .map((part) => part.split('=')[0]!.trim())
    .filter((name) => name === '_ga' || name.startsWith('_ga_'));
}

/**
 * Cookie strings that expire `name` on this host and on its parent domains.
 * Google Analytics sets its cookies on the widest domain it can, so each
 * candidate is cleared; the browser ignores the ones that do not match.
 */
export function expireCookieStrings(name: string, hostname: string): string[] {
  const parts = hostname.split('.');
  const domains = parts.map((_, i) => parts.slice(i).join('.')).filter((d) => d.includes('.'));
  const base = `${name}=; Path=/; Max-Age=0; SameSite=Lax`;
  return [base, ...domains.map((d) => `${base}; Domain=.${d}`)];
}
