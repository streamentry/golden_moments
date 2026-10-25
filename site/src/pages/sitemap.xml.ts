import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { SECTIONS } from '../content.config';
import { GAMES } from '../data/games';
import { SITE, absoluteUrl } from '../lib/site';

interface Entry {
  path: string;
  lastmod: string;
}

// Every non-dynamic page in src/pages, so new pages are listed automatically.
const STATIC_PAGES = Object.keys(import.meta.glob('./**/*.astro'))
  .filter((file) => !file.includes('[') && file !== './404.astro')
  .map((file) => file.replace(/^\./, '').replace(/index\.astro$/, '').replace(/\.astro$/, '/'));

function escapeXml(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/** A single /sitemap.xml with every indexable page, alongside @astrojs/sitemap's index. */
export const GET: APIRoute = async () => {
  const guides = await getCollection('guides');
  const entries: Entry[] = [
    ...STATIC_PAGES.map((path) => ({ path, lastmod: SITE.updated })),
    ...GAMES.map((g) => ({ path: `/games/${g.slug}/`, lastmod: SITE.updated })),
    ...SECTIONS.map((s) => ({ path: `/${s}/`, lastmod: SITE.updated })),
    ...guides.map((g) => ({ path: `/${g.id}/`, lastmod: g.data.updated.toISOString().slice(0, 10) })),
  ];
  const unique = [...new Map(entries.map((e) => [e.path, e])).values()].sort((a, b) => a.path.localeCompare(b.path));
  const body = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ...unique.map((e) => `  <url><loc>${escapeXml(absoluteUrl(e.path))}</loc><lastmod>${e.lastmod}</lastmod></url>`),
    '</urlset>',
    '',
  ].join('\n');
  return new Response(body, { headers: { 'Content-Type': 'application/xml; charset=utf-8' } });
};
