import type { APIRoute } from 'astro';
import { PUBLISHED } from '../i18n/ui';
import { SITE } from '../lib/site';
import { renderSitemapIndex } from '../lib/sitemap';

/** /sitemap.xml: the index of every language's sitemap (/sitemap-en.xml, /vi/sitemap.xml, ...). */
export const GET: APIRoute = () =>
  new Response(renderSitemapIndex(PUBLISHED.map((l) => l.code), SITE.updated), {
    headers: { 'Content-Type': 'application/xml; charset=utf-8' },
  });
