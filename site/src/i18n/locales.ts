/**
 * The site's languages. English lives at the root (`/games/`); every other
 * language has a path prefix (`/vi/games/`). Slugs stay English in every
 * language so one page has one slug everywhere.
 *
 * A language is published only once its UI dictionary exists in
 * `src/i18n/ui/<code>.json`, so half-finished languages never ship as
 * duplicate English pages.
 */
export interface LocaleInfo {
  /** Our code, also the dictionary file name. */
  code: string;
  /** URL prefix without slashes; '' for English. */
  prefix: string;
  /** Value for hreflang and Intl formatting. */
  bcp47: string;
  /** Value for <html lang>; English pages keep their US English tag. */
  htmlLang: string;
  /** Open Graph locale. */
  og: string;
  /** Native name, for the language menu. */
  name: string;
  /** English name, for records and alt text. */
  englishName: string;
  dir: 'ltr' | 'rtl';
}

export const DEFAULT_LOCALE = 'en';

export const LOCALES: readonly LocaleInfo[] = [
  { code: 'en', prefix: '', bcp47: 'en', htmlLang: 'en-US', og: 'en_US', name: 'English', englishName: 'English', dir: 'ltr' },
  { code: 'es', prefix: 'es', bcp47: 'es', htmlLang: 'es', og: 'es_ES', name: 'Español', englishName: 'Spanish', dir: 'ltr' },
  { code: 'pt-BR', prefix: 'pt-br', bcp47: 'pt-BR', htmlLang: 'pt-BR', og: 'pt_BR', name: 'Português (Brasil)', englishName: 'Portuguese (Brazil)', dir: 'ltr' },
  { code: 'fr', prefix: 'fr', bcp47: 'fr', htmlLang: 'fr', og: 'fr_FR', name: 'Français', englishName: 'French', dir: 'ltr' },
  { code: 'de', prefix: 'de', bcp47: 'de', htmlLang: 'de', og: 'de_DE', name: 'Deutsch', englishName: 'German', dir: 'ltr' },
  { code: 'it', prefix: 'it', bcp47: 'it', htmlLang: 'it', og: 'it_IT', name: 'Italiano', englishName: 'Italian', dir: 'ltr' },
  { code: 'nl', prefix: 'nl', bcp47: 'nl', htmlLang: 'nl', og: 'nl_NL', name: 'Nederlands', englishName: 'Dutch', dir: 'ltr' },
  { code: 'pl', prefix: 'pl', bcp47: 'pl', htmlLang: 'pl', og: 'pl_PL', name: 'Polski', englishName: 'Polish', dir: 'ltr' },
  { code: 'ru', prefix: 'ru', bcp47: 'ru', htmlLang: 'ru', og: 'ru_RU', name: 'Русский', englishName: 'Russian', dir: 'ltr' },
  { code: 'uk', prefix: 'uk', bcp47: 'uk', htmlLang: 'uk', og: 'uk_UA', name: 'Українська', englishName: 'Ukrainian', dir: 'ltr' },
  { code: 'tr', prefix: 'tr', bcp47: 'tr', htmlLang: 'tr', og: 'tr_TR', name: 'Türkçe', englishName: 'Turkish', dir: 'ltr' },
  { code: 'ar', prefix: 'ar', bcp47: 'ar', htmlLang: 'ar', og: 'ar_AR', name: 'العربية', englishName: 'Arabic', dir: 'rtl' },
  { code: 'hi', prefix: 'hi', bcp47: 'hi', htmlLang: 'hi', og: 'hi_IN', name: 'हिन्दी', englishName: 'Hindi', dir: 'ltr' },
  { code: 'ja', prefix: 'ja', bcp47: 'ja', htmlLang: 'ja', og: 'ja_JP', name: '日本語', englishName: 'Japanese', dir: 'ltr' },
  { code: 'ko', prefix: 'ko', bcp47: 'ko', htmlLang: 'ko', og: 'ko_KR', name: '한국어', englishName: 'Korean', dir: 'ltr' },
  { code: 'zh-Hans', prefix: 'zh-hans', bcp47: 'zh-Hans', htmlLang: 'zh-Hans', og: 'zh_CN', name: '简体中文', englishName: 'Chinese (Simplified)', dir: 'ltr' },
  { code: 'zh-Hant', prefix: 'zh-hant', bcp47: 'zh-Hant', htmlLang: 'zh-Hant', og: 'zh_TW', name: '繁體中文', englishName: 'Chinese (Traditional)', dir: 'ltr' },
  { code: 'vi', prefix: 'vi', bcp47: 'vi', htmlLang: 'vi', og: 'vi_VN', name: 'Tiếng Việt', englishName: 'Vietnamese', dir: 'ltr' },
  { code: 'id', prefix: 'id', bcp47: 'id', htmlLang: 'id', og: 'id_ID', name: 'Bahasa Indonesia', englishName: 'Indonesian', dir: 'ltr' },
  { code: 'th', prefix: 'th', bcp47: 'th', htmlLang: 'th', og: 'th_TH', name: 'ไทย', englishName: 'Thai', dir: 'ltr' },
];

const BY_CODE = new Map(LOCALES.map((l) => [l.code, l]));
const BY_PREFIX = new Map(LOCALES.filter((l) => l.prefix).map((l) => [l.prefix, l]));

export function localeInfo(code: string): LocaleInfo {
  return BY_CODE.get(code) ?? (BY_CODE.get(DEFAULT_LOCALE) as LocaleInfo);
}

/** `/games/` in `vi` becomes `/vi/games/`. External and anchor links are untouched. */
export function localePath(code: string, path: string): string {
  if (!path.startsWith('/') || path.startsWith('//')) return path;
  const { prefix } = localeInfo(code);
  return prefix ? `/${prefix}${path}` : path;
}

/** Splits `/vi/games/` into `{ code: 'vi', path: '/games/' }`. */
export function splitLocale(pathname: string): { code: string; path: string } {
  const match = pathname.match(/^\/([a-z]{2}(?:-[a-z]{2,4})?)(\/.*)?$/);
  const info = match ? BY_PREFIX.get(match[1] as string) : undefined;
  if (!info || !match) return { code: DEFAULT_LOCALE, path: pathname };
  return { code: info.code, path: match[2] ?? '/' };
}

/** Paths that exist only in English, linked as such from every language. */
export const ENGLISH_ONLY = [
  '/privacy/',
  '/app-privacy/',
  '/privacy-choices/',
  '/terms/',
  '/safety/',
  '/accessibility/',
  '/medical-disclaimer/',
  '/legal/',
  '/support/',
  '/help/',
];

export function isEnglishOnly(path: string): boolean {
  return ENGLISH_ONLY.some((p) => path === p || path.startsWith(p));
}

/**
 * Link to `path` from a page in `code`: language-prefixed, except pages that
 * exist only in English.
 */
export function href(code: string, path: string): string {
  return isEnglishOnly(path) ? path : localePath(code, path);
}

/** Rewrites root-relative links inside trusted dictionary HTML for `code`. */
export function localizeHtml(code: string, html: string): string {
  if (code === DEFAULT_LOCALE) return html;
  return html.replace(/href="(\/[^"]*)"/g, (_, p: string) => `href="${href(code, p)}"`);
}
