import { SECTIONS } from '../content.config';
import { GAMES } from '../data/games';
import { gameLanguages } from '../i18n/games';
import { allGuides } from '../i18n/guides';
import { PUBLISHED } from '../i18n/ui';
import type { SitemapEntry } from './sitemap';
import { SITE } from './site';

const EVERY = PUBLISHED.map((l) => l.code);

// Every non-dynamic page in src/pages, so new pages are listed automatically.
const STATIC_PAGES = Object.keys(import.meta.glob('../pages/**/*.astro'))
  .map((file) => file.replace(/^\.\.\/pages/, ''))
  .filter((file) => !file.includes('[') && file !== '/404.astro')
  .map((file) => file.replace(/index\.astro$/, '').replace(/\.astro$/, '/'));

// Pages that also exist under /<language>/ (src/pages/[lang]/*.astro).
const LOCALIZED = new Set(
  Object.keys(import.meta.glob('../pages/\\[lang\\]/**/*.astro'))
    .map((file) => file.replace(/^\.\.\/pages\/\[lang\]/, ''))
    .filter((file) => !file.includes('['))
    .map((file) => file.replace(/index\.astro$/, '').replace(/\.astro$/, '/')),
);
const GAMES_LOCALIZED = Object.keys(import.meta.glob('../pages/\\[lang\\]/games/\\[slug\\].astro')).length > 0;

/** Every page on the site with the languages it exists in, sorted by path. */
export async function sitemapEntries(): Promise<SitemapEntry[]> {
  const guides = await allGuides();
  const entries: SitemapEntry[] = [
    ...STATIC_PAGES.map((path) => ({ path, lastmod: SITE.updated, langs: LOCALIZED.has(path) ? EVERY : ['en'] })),
    ...GAMES.map((g) => ({ path: `/games/${g.slug}/`, lastmod: SITE.updated, langs: GAMES_LOCALIZED ? gameLanguages(g.slug) : ['en'] })),
    ...SECTIONS.map((s) => ({ path: `/${s}/`, lastmod: SITE.updated, langs: EVERY })),
    ...guides
      .filter((g) => g.lang === 'en')
      .map((g) => ({
        path: `/${g.id}/`,
        lastmod: g.entry.data.updated.toISOString().slice(0, 10),
        langs: guides.filter((x) => x.id === g.id).map((x) => x.lang),
      })),
  ];
  return [...new Map(entries.map((e) => [e.path, e])).values()].sort((a, b) => a.path.localeCompare(b.path));
}
