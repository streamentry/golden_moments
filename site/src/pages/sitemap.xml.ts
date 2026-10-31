import type { APIRoute } from 'astro';
import { SECTIONS } from '../content.config';
import { GAMES } from '../data/games';
import { SITE, absoluteUrl } from '../lib/site';
import { isIndexable, localeInfo, localePath } from '../i18n/locales';
import { allGuides } from '../i18n/guides';
import { gameLanguages } from '../i18n/games';
import { PUBLISHED } from '../i18n/ui';

interface Entry {
  path: string;
  lastmod: string;
  /** Language codes the page exists in. */
  langs: string[];
}

const EVERY = PUBLISHED.map((l) => l.code);

// Every non-dynamic page in src/pages, so new pages are listed automatically.
const STATIC_PAGES = Object.keys(import.meta.glob('./**/*.astro'))
  .filter((file) => !file.includes('[') && file !== './404.astro')
  .map((file) => file.replace(/^\./, '').replace(/index\.astro$/, '').replace(/\.astro$/, '/'));

// Pages that also exist under /<language>/ (src/pages/[lang]/*.astro).
const LOCALIZED = new Set(
  Object.keys(import.meta.glob('./\\[lang\\]/**/*.astro')).filter((file) => !file.slice(8).includes('[')).map((file) =>
    file.replace(/^\.\/\[lang\]/, '').replace(/index\.astro$/, '').replace(/\.astro$/, '/'),
  ),
);
const GAMES_LOCALIZED = Object.keys(import.meta.glob('./\\[lang\\]/games/\\[slug\\].astro')).length > 0;

function escapeXml(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function urlBlock(entry: Entry, lang: string): string {
  const alternates =
    entry.langs.length > 1
      ? [
          ...entry.langs.map(
            (code) =>
              `    <xhtml:link rel="alternate" hreflang="${localeInfo(code).bcp47}" href="${escapeXml(absoluteUrl(localePath(code, entry.path)))}"/>`,
          ),
          `    <xhtml:link rel="alternate" hreflang="x-default" href="${escapeXml(absoluteUrl(entry.path))}"/>`,
        ]
      : [];
  return [
    '  <url>',
    `    <loc>${escapeXml(absoluteUrl(localePath(lang, entry.path)))}</loc>`,
    `    <lastmod>${entry.lastmod}</lastmod>`,
    ...alternates,
    '  </url>',
  ].join('\n');
}

/** A single /sitemap.xml with every indexable page in every language, with hreflang alternates. */
export const GET: APIRoute = async () => {
  const guides = await allGuides();
  const english = guides.filter((g) => g.lang === 'en');
  const entries: Entry[] = [
    ...STATIC_PAGES.map((path) => ({ path, lastmod: SITE.updated, langs: LOCALIZED.has(path) ? EVERY : ['en'] })),
    ...GAMES.map((g) => ({ path: `/games/${g.slug}/`, lastmod: SITE.updated, langs: GAMES_LOCALIZED ? gameLanguages(g.slug) : ['en'] })),
    ...SECTIONS.map((s) => ({ path: `/${s}/`, lastmod: SITE.updated, langs: EVERY })),
    ...english.map((g) => ({
      path: `/${g.id}/`,
      lastmod: g.entry.data.updated.toISOString().slice(0, 10),
      langs: guides.filter((x) => x.id === g.id).map((x) => x.lang),
    })),
  ];
  const unique = [...new Map(entries.map((e) => [e.path, e])).values()].sort((a, b) => a.path.localeCompare(b.path));
  const body = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">',
    // Only reviewed languages are listed; machine translations are noindex (see locales.ts).
    ...unique.map((e) => ({ ...e, langs: e.langs.filter(isIndexable) })).flatMap((e) => e.langs.map((lang) => urlBlock(e, lang))),
    '</urlset>',
    '',
  ].join('\n');
  return new Response(body, { headers: { 'Content-Type': 'application/xml; charset=utf-8' } });
};
