import { isIndexable, localeInfo, localePath } from '../i18n/locales';
import { absoluteUrl } from './site';

/** One page, in every language it exists in. */
export interface SitemapEntry {
  /** English path, such as `/games/`. */
  path: string;
  lastmod: string;
  /** Language codes the page exists in. */
  langs: readonly string[];
}

/** `/sitemap.xml` for English, `/<prefix>/sitemap.xml` for every other language. */
export function sitemapPath(lang: string): string {
  return localePath(lang, '/sitemap.xml');
}

function escapeXml(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function urlBlock(entry: SitemapEntry, lang: string): string {
  const langs = entry.langs.filter(isIndexable);
  const alternates =
    langs.length > 1
      ? [
          ...langs.map(
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

/**
 * The sitemap for one language: only that language's pages, so each one sits
 * under its own prefix, each with hreflang alternates to the others.
 */
export function renderSitemap(entries: readonly SitemapEntry[], lang: string): string {
  const pages = isIndexable(lang) ? entries.filter((e) => e.langs.includes(lang)) : [];
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">',
    ...pages.map((e) => urlBlock(e, lang)),
    '</urlset>',
    '',
  ].join('\n');
}
