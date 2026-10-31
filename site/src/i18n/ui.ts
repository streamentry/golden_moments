import en from './ui/en.json';
import { DEFAULT_LOCALE, LOCALES, type LocaleInfo } from './locales';

/** The English dictionary is the source; every other language mirrors its shape. */
export type Ui = typeof en;

type Json = string | number | boolean | null | Json[] | { [key: string]: Json };

const files = import.meta.glob<{ default: Json }>('./ui/*.json', { eager: true });

function isObject(value: unknown): value is Record<string, Json> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

/** Returns `base` with every key `over` provides; arrays are replaced whole. */
export function deepMerge<T>(base: T, over: unknown): T {
  if (!isObject(base) || !isObject(over)) return (over === undefined ? base : over) as T;
  const out: Record<string, unknown> = { ...base };
  for (const [key, value] of Object.entries(over)) {
    out[key] = key in out ? deepMerge(out[key], value) : value;
  }
  return out as T;
}

const DICTIONARIES = new Map<string, Json>(
  Object.entries(files).map(([path, mod]) => [path.replace(/^.*\/(.+)\.json$/, '$1'), mod.default]),
);

/** Languages with a dictionary, in menu order. English always comes first. */
export const PUBLISHED: readonly LocaleInfo[] = LOCALES.filter(
  (l) => l.code === DEFAULT_LOCALE || DICTIONARIES.has(l.code),
);

/** Non-English published languages, for getStaticPaths. */
export const TRANSLATED: readonly LocaleInfo[] = PUBLISHED.filter((l) => l.code !== DEFAULT_LOCALE);

const cache = new Map<string, Ui>();

/** The dictionary for `code`, with English filling any gap. */
export function ui(code: string): Ui {
  const hit = cache.get(code);
  if (hit) return hit;
  const merged = code === DEFAULT_LOCALE ? en : deepMerge(en, DICTIONARIES.get(code));
  cache.set(code, merged);
  return merged;
}

/** Replaces `{name}` placeholders. */
export function fill(text: string, values: Record<string, string | number>): string {
  return text.replace(/\{(\w+)\}/g, (match, key: string) => (key in values ? String(values[key]) : match));
}

/** getStaticPaths entries for every translated language. */
export function localeStaticPaths(): { params: { lang: string }; props: { lang: string } }[] {
  return TRANSLATED.map((l) => ({ params: { lang: l.prefix }, props: { lang: l.code } }));
}
