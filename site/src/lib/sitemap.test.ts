import { describe, expect, it } from 'vitest';
import { LOCALES, isIndexable } from '../i18n/locales';
import { PUBLISHED } from '../i18n/ui';
import { renderSitemap, renderSitemapIndex, sitemapPath } from './sitemap';

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
    expect(sitemapPath('en')).toBe('/sitemap-en.xml');
    expect(sitemapPath('vi')).toBe('/vi/sitemap.xml');
    expect(sitemapPath('zh-Hans')).toBe('/zh-hans/sitemap.xml');
  });

  it('indexes every language in a sitemap index', () => {
    const xml = renderSitemapIndex(['en', 'vi', 'zh-Hans'], '2026-11-01');
    expect(xml).toContain('<sitemapindex');
    expect(xml).toContain('<loc>https://dementiaactivities.games/sitemap-en.xml</loc>');
    expect(xml).toContain('<loc>https://dementiaactivities.games/vi/sitemap.xml</loc>');
    expect(xml).toContain('<loc>https://dementiaactivities.games/zh-hans/sitemap.xml</loc>');
    expect(xml.match(/<sitemap>/g)).toHaveLength(3);
  });
});

describe('the root sitemap', () => {
  it('links to a sitemap for every published, indexable language', () => {
    const xml = renderSitemapIndex(PUBLISHED.map((l) => l.code), '2026-11-06');
    const linked = [...xml.matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]);
    const expected = PUBLISHED.filter((l) => isIndexable(l.code)).map((l) => {
      const path = l.code === 'en' ? '/sitemap-en.xml' : `/${l.prefix}/sitemap.xml`;
      return `https://dementiaactivities.games${path}`;
    });
    expect(linked).toEqual(expected);
    expect(linked).toHaveLength(LOCALES.filter((l) => isIndexable(l.code)).length);
  });
});
