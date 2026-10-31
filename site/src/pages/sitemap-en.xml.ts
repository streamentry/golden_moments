import type { APIRoute } from 'astro';
import { DEFAULT_LOCALE } from '../i18n/locales';
import { renderSitemap } from '../lib/sitemap';
import { sitemapEntries } from '../lib/sitemap-entries';

/** /sitemap-en.xml: the English pages. Each other language has /<prefix>/sitemap.xml. */
export const GET: APIRoute = async () =>
  new Response(renderSitemap(await sitemapEntries(), DEFAULT_LOCALE), {
    headers: { 'Content-Type': 'application/xml; charset=utf-8' },
  });
