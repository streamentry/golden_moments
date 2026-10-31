import { getCollection, type CollectionEntry } from 'astro:content';
import { DEFAULT_LOCALE, LOCALES } from './locales';
import { PUBLISHED } from './ui';

export type GuideEntry = CollectionEntry<'guides'> | CollectionEntry<'guidesI18n'>;

/** A guide in one language: `id` is the shared `<section>/<slug>`. */
export interface LocalGuide {
  id: string;
  lang: string;
  entry: GuideEntry;
}

const CODES = new Set(LOCALES.map((l) => l.code));
const PUBLISHED_CODES = new Set(PUBLISHED.map((l) => l.code));

let cache: LocalGuide[] | undefined;

/** Every guide in every published language, English first. */
export async function allGuides(): Promise<LocalGuide[]> {
  if (cache) return cache;
  const english = (await getCollection('guides')).map((entry) => ({ id: entry.id, lang: DEFAULT_LOCALE, entry }));
  const translated = (await getCollection('guidesI18n'))
    .map((entry) => {
      const [code, ...rest] = entry.id.split('/');
      return { id: rest.join('/'), lang: code as string, entry };
    })
    .filter((g) => CODES.has(g.lang) && PUBLISHED_CODES.has(g.lang) && english.some((e) => e.id === g.id));
  cache = [...english, ...translated];
  return cache;
}

/** Languages a guide exists in. */
export async function guideLanguages(id: string): Promise<string[]> {
  return (await allGuides()).filter((g) => g.id === id).map((g) => g.lang);
}

/** The guide in `lang`, or `undefined` when it is not translated. */
export async function findGuide(lang: string, id: string): Promise<LocalGuide | undefined> {
  return (await allGuides()).find((g) => g.lang === lang && g.id === id);
}

/** Guides of one section in `lang`, falling back to English per guide. */
export async function sectionGuides(lang: string, section: string): Promise<LocalGuide[]> {
  const all = await allGuides();
  return all
    .filter((g) => g.lang === DEFAULT_LOCALE && g.entry.data.section === section)
    .map((en) => all.find((g) => g.lang === lang && g.id === en.id) ?? en)
    .sort((a, b) => a.entry.data.order - b.entry.data.order);
}
