import { describe, expect, it } from 'vitest';
import { renderSitemap, sitemapPath } from './sitemap';

const ENTRIES = [
  { path: '/games/', lastmod: '2026-10-31', langs: ['en', 'vi', 'ar'] },
  { path: '/privacy/', lastmod: '2026-10-30', langs: ['en'] },
];

describe('renderSitemap', () => {
  it('lists only the pages of one language, with every language as an alternate', () => {
    const xml = renderSitemap(ENTRIES, 'vi');
    expect(xml).toContain('<loc>https://dementiaactivities.games/vi/games/</loc>');
    expect(xml).not.toContain('<loc>https://dementiaactivities.games/games/</loc>');
    expect(xml).not.toContain('privacy');
    expect(xml).toContain('hreflang="ar" href="https://dementiaactivities.games/ar/games/"');
    expect(xml).toContain('hreflang="x-default" href="https://dementiaactivities.games/games/"');
  });

  it('keeps English at the root and skips alternates for single-language pages', () => {
    const xml = renderSitemap(ENTRIES, 'en');
    expect(xml).toContain('<loc>https://dementiaactivities.games/privacy/</loc>');
    expect(xml.match(/<url>/g)).toHaveLength(2);
    const privacy = xml.slice(xml.indexOf('/privacy/'));
    expect(privacy.slice(0, privacy.indexOf('</url>'))).not.toContain('xhtml:link');
  });

  it('places each sitemap under its language prefix', () => {
    expect(sitemapPath('en')).toBe('/sitemap.xml');
    expect(sitemapPath('vi')).toBe('/vi/sitemap.xml');
    expect(sitemapPath('zh-Hans')).toBe('/zh-hans/sitemap.xml');
  });
});
