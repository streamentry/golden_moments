import { SECTIONS } from '../content.config';
import { GAMES } from '../data/games';
import { DEFAULT_LOCALE } from './locales';
import { allGuides } from './guides';
import { PUBLISHED } from './ui';

/** Pages under src/pages/[lang]/ that are not dynamic (home, games index, app…). */
export const LOCALIZED_STATIC = new Set(
  Object.keys(import.meta.glob('../pages/\\[lang\\]/**/*.astro'))
    .map((file) => file.replace(/^\.\.\/pages\/\[lang\]/, ''))
    .filter((file) => !file.includes('['))
    .map((file) => file.replace(/index\.astro$/, '').replace(/\.astro$/, '/')),
);

const cache = new Map<string, Set<string>>();

/** Every path (without prefix) that exists in `code`. */
export async function pathsIn(code: string): Promise<Set<string>> {
  const hit = cache.get(code);
  if (hit) return hit;
  const guides = await allGuides();
  const english = code === DEFAULT_LOCALE;
  const published = PUBLISHED.some((l) => l.code === code);
  const paths = new Set<string>(
    english || published
      ? [
          ...LOCALIZED_STATIC,
          ...GAMES.map((g) => `/games/${g.slug}/`),
          ...SECTIONS.map((s) => `/${s}/`),
          ...guides.filter((g) => g.lang === code).map((g) => `/${g.id}/`),
        ]
      : [],
  );
  cache.set(code, paths);
  return paths;
}
