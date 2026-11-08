import { describe, expect, it } from 'vitest';
import { languageRow, languageSection, type LanguageRow, type LanguageSupport } from './language-support';

const URL = 'https://example.test';

const row = (over: Partial<LanguageRow>): LanguageRow => ({
  code: 'en',
  bcp47: 'en',
  name: 'English',
  englishName: 'English',
  dir: 'ltr',
  home: `${URL}/`,
  sitemap: `${URL}/sitemap-en.xml`,
  pages: 100,
  missingGames: [],
  guides: 40,
  ...over,
});

const support = (rows: LanguageRow[]): LanguageSupport => ({
  siteUrl: URL,
  rows,
  totalGames: 12,
  totalGuides: 40,
  everyLanguagePaths: ['/', '/games/'],
  englishOnlyPaths: ['/privacy/'],
});

describe('languageRow', () => {
  it('marks English as the original with full counts', () => {
    const line = languageRow(row({}), 12, 40);
    expect(line).toContain('[English (English)](https://example.test/)');
    expect(line).toContain('original');
    expect(line).toContain('12/12 games');
    expect(line).toContain('40/40 guides');
    expect(line).toContain('left to right');
  });

  it('names missing games, direction and machine-translation status', () => {
    const line = languageRow(
      row({ code: 'ar', bcp47: 'ar', name: 'العربية', englishName: 'Arabic', dir: 'rtl', pages: 1, missingGames: ['Word search'], guides: 39 }),
      12,
      40,
    );
    expect(line).toContain('right to left');
    expect(line).toContain('machine translated, not yet reviewed');
    expect(line).toContain('11/12 games (not Word search)');
    expect(line).toContain('39/40 guides');
    expect(line).toContain('1 page ·');
  });
});

describe('languageSection', () => {
  it('is empty when only English is published', () => {
    expect(languageSection(support([row({})]))).toEqual([]);
  });

  it('summarises totals, right-to-left languages and English-only pages', () => {
    const text = languageSection(
      support([
        row({}),
        row({ code: 'es', bcp47: 'es', name: 'Español', englishName: 'Spanish', home: `${URL}/es/`, pages: 90 }),
        row({ code: 'ar', bcp47: 'ar', name: 'العربية', englishName: 'Arabic', dir: 'rtl', home: `${URL}/ar/`, pages: 80, missingGames: ['Word search'] }),
      ]),
    ).join('\n');
    expect(text).toContain('published in 3 languages: English and 2 translations, 270 indexable pages');
    expect(text).toContain('1 language is written right to left (Arabic)');
    expect(text).toContain('https://example.test/es/games/');
    expect(text).toContain('English only, linked from every language: /privacy/');
    expect(text).toContain('2 of 3 languages have all 12 games');
    expect(text).toContain('### Every language');
    expect(text.match(/^- \[/gm)).toHaveLength(3);
  });
});
