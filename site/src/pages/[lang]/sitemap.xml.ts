import type { APIRoute } from 'astro';
import { localeStaticPaths } from '../../i18n/ui';
import { renderSitemap } from '../../lib/sitemap';
import { sitemapEntries } from '../../lib/sitemap-entries';

export function getStaticPaths() {
  return localeStaticPaths();
}

/** /<prefix>/sitemap.xml: the pages of one translated language, such as /vi/sitemap.xml. */
export const GET: APIRoute = async ({ props }) =>
  new Response(renderSitemap(await sitemapEntries(), props.lang as string), {
    headers: { 'Content-Type': 'application/xml; charset=utf-8' },
  });
