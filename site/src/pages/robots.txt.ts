import type { APIRoute } from 'astro';
import { isIndexable } from '../i18n/locales';
import { PUBLISHED } from '../i18n/ui';
import { SITE } from '../lib/site';
import { sitemapPath } from '../lib/sitemap';

// Everyone, including AI answer engines, may read and cite the public pages.
export const GET: APIRoute = () =>
  new Response(
    [
      'User-agent: *',
      'Allow: /',
      '',
      // One sitemap per language (/sitemap.xml, /vi/sitemap.xml, ...) plus the generated index.
      ...PUBLISHED.filter((l) => isIndexable(l.code)).map((l) => `Sitemap: ${SITE.url}${sitemapPath(l.code)}`),
      `Sitemap: ${SITE.url}/sitemap-index.xml`,
      '',
    ].join('\n'),
    { headers: { 'Content-Type': 'text/plain; charset=utf-8' } },
  );
