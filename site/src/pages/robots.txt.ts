import type { APIRoute } from 'astro';
import { SITE } from '../lib/site';

// Everyone, including AI answer engines, may read and cite the public pages.
export const GET: APIRoute = () =>
  new Response(
    [
      'User-agent: *',
      'Allow: /',
      '',
      // The index points to one sitemap per language (/sitemap-en.xml, /vi/sitemap.xml, ...).
      `Sitemap: ${SITE.url}/sitemap.xml`,
      '',
    ].join('\n'),
    { headers: { 'Content-Type': 'text/plain; charset=utf-8' } },
  );
