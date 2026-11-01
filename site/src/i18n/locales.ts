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
  { code: 'bn', prefix: 'bn', bcp47: 'bn', htmlLang: 'bn', og: 'bn_BD', name: 'বাংলা', englishName: 'Bengali', dir: 'ltr' },
  { code: 'fa', prefix: 'fa', bcp47: 'fa', htmlLang: 'fa', og: 'fa_IR', name: 'فارسی', englishName: 'Persian', dir: 'rtl' },
  { code: 'ha', prefix: 'ha', bcp47: 'ha', htmlLang: 'ha', og: 'ha_NG', name: 'Hausa', englishName: 'Hausa', dir: 'ltr' },
  { code: 'ur', prefix: 'ur', bcp47: 'ur', htmlLang: 'ur', og: 'ur_PK', name: 'اردو', englishName: 'Urdu', dir: 'rtl' },
  { code: 'mr', prefix: 'mr', bcp47: 'mr', htmlLang: 'mr', og: 'mr_IN', name: 'मराठी', englishName: 'Marathi', dir: 'ltr' },
  { code: 'te', prefix: 'te', bcp47: 'te', htmlLang: 'te', og: 'te_IN', name: 'తెలుగు', englishName: 'Telugu', dir: 'ltr' },
  { code: 'ta', prefix: 'ta', bcp47: 'ta', htmlLang: 'ta', og: 'ta_IN', name: 'தமிழ்', englishName: 'Tamil', dir: 'ltr' },
  { code: 'gu', prefix: 'gu', bcp47: 'gu', htmlLang: 'gu', og: 'gu_IN', name: 'ગુજરાતી', englishName: 'Gujarati', dir: 'ltr' },
  { code: 'pa', prefix: 'pa', bcp47: 'pa', htmlLang: 'pa', og: 'pa_IN', name: 'ਪੰਜਾਬੀ', englishName: 'Punjabi (Gurmukhi)', dir: 'ltr' },
  { code: 'fil', prefix: 'fil', bcp47: 'fil', htmlLang: 'fil', og: 'fil_PH', name: 'Filipino', englishName: 'Filipino', dir: 'ltr' },
  { code: 'ro', prefix: 'ro', bcp47: 'ro', htmlLang: 'ro', og: 'ro_RO', name: 'Română', englishName: 'Romanian', dir: 'ltr' },
  { code: 'ms', prefix: 'ms', bcp47: 'ms', htmlLang: 'ms', og: 'ms_MY', name: 'Bahasa Melayu', englishName: 'Malay', dir: 'ltr' },
  { code: 'sw', prefix: 'sw', bcp47: 'sw', htmlLang: 'sw', og: 'sw_KE', name: 'Kiswahili', englishName: 'Swahili', dir: 'ltr' },
  { code: 'kn', prefix: 'kn', bcp47: 'kn', htmlLang: 'kn', og: 'kn_IN', name: 'ಕನ್ನಡ', englishName: 'Kannada', dir: 'ltr' },
  { code: 'ml', prefix: 'ml', bcp47: 'ml', htmlLang: 'ml', og: 'ml_IN', name: 'മലയാളം', englishName: 'Malayalam', dir: 'ltr' },
  { code: 'ne', prefix: 'ne', bcp47: 'ne', htmlLang: 'ne', og: 'ne_NP', name: 'नेपाली', englishName: 'Nepali', dir: 'ltr' },
  { code: 'az', prefix: 'az', bcp47: 'az', htmlLang: 'az', og: 'az_AZ', name: 'Azərbaycan dili', englishName: 'Azerbaijani', dir: 'ltr' },
  { code: 'am', prefix: 'am', bcp47: 'am', htmlLang: 'am', og: 'am_ET', name: 'አማርኛ', englishName: 'Amharic', dir: 'ltr' },
  { code: 'my', prefix: 'my', bcp47: 'my', htmlLang: 'my', og: 'my_MM', name: 'မြန်မာ', englishName: 'Burmese', dir: 'ltr' },
  { code: 'uz', prefix: 'uz', bcp47: 'uz', htmlLang: 'uz', og: 'uz_UZ', name: 'Oʻzbekcha', englishName: 'Uzbek', dir: 'ltr' },
  { code: 'or', prefix: 'or', bcp47: 'or', htmlLang: 'or', og: 'or_IN', name: 'ଓଡ଼ିଆ', englishName: 'Odia', dir: 'ltr' },
  { code: 'as', prefix: 'as', bcp47: 'as', htmlLang: 'as', og: 'as_IN', name: 'অসমীয়া', englishName: 'Assamese', dir: 'ltr' },
  { code: 'ps', prefix: 'ps', bcp47: 'ps', htmlLang: 'ps', og: 'ps_AF', name: 'پښتو', englishName: 'Pashto', dir: 'rtl' },
  { code: 'yo', prefix: 'yo', bcp47: 'yo', htmlLang: 'yo', og: 'yo_NG', name: 'Yorùbá', englishName: 'Yoruba', dir: 'ltr' },
  { code: 'ig', prefix: 'ig', bcp47: 'ig', htmlLang: 'ig', og: 'ig_NG', name: 'Igbo', englishName: 'Igbo', dir: 'ltr' },
  { code: 'zu', prefix: 'zu', bcp47: 'zu', htmlLang: 'zu', og: 'zu_ZA', name: 'isiZulu', englishName: 'Zulu', dir: 'ltr' },
  { code: 'so', prefix: 'so', bcp47: 'so', htmlLang: 'so', og: 'so_SO', name: 'Soomaali', englishName: 'Somali', dir: 'ltr' },
  { code: 'om', prefix: 'om', bcp47: 'om', htmlLang: 'om', og: 'om_ET', name: 'Afaan Oromoo', englishName: 'Oromo', dir: 'ltr' },
  { code: 'jv', prefix: 'jv', bcp47: 'jv', htmlLang: 'jv', og: 'jv_ID', name: 'Basa Jawa', englishName: 'Javanese', dir: 'ltr' },
  { code: 'su', prefix: 'su', bcp47: 'su', htmlLang: 'su', og: 'su_ID', name: 'Basa Sunda', englishName: 'Sundanese', dir: 'ltr' },
  { code: 'sd', prefix: 'sd', bcp47: 'sd', htmlLang: 'sd', og: 'sd_PK', name: 'سنڌي', englishName: 'Sindhi', dir: 'rtl' },
];

/**
 * Languages search engines may index, listed in sitemaps, hreflang and
 * llms.txt. Every published language is indexed (maintainer decision,
 * 2026-11-01), including the machine translations: those pages still say they
 * are unreviewed and link to the English original. Remove a code to make that
 * language `noindex` again; TRANSLATING.md tracks which are reviewed.
 *
 * `HELD_FROM_INDEX` is the way to pull a language back out: its pages stay
 * reachable and labelled but become `noindex` and drop out of the sitemaps,
 * hreflang and llms.txt. It is empty: on 2026-11-01 the maintainer chose to
 * index every language, including the weakest machine translations (Hausa,
 * Amharic, Burmese, Pashto, Sindhi, Somali, Oromo), which native speakers
 * should review first.
 */
export const HELD_FROM_INDEX: ReadonlySet<string> = new Set([]);

export const INDEXED_LANGUAGES: ReadonlySet<string> = new Set(
  LOCALES.map((l) => l.code).filter((code) => !HELD_FROM_INDEX.has(code)),
);

export function isIndexable(code: string): boolean {
  return INDEXED_LANGUAGES.has(code);
}

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
  // Two- and three-letter codes (Filipino is `fil`); an unknown prefix such as /app/ is not a language.
  const match = pathname.match(/^\/([a-z]{2,3}(?:-[a-z]{2,4})?)(\/.*)?$/);
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
