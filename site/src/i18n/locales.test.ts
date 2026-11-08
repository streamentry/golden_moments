import { readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { HELD_FROM_INDEX, INDEXED_LANGUAGES, LOCALES, isIndexable, localeOfContentDir, splitLocale } from './locales';

describe('which languages search engines may index', () => {
  it('indexes English and the machine translations that read acceptably', () => {
    for (const code of ['en', 'es', 'ja', 'bn', 'fa']) expect(isIndexable(code), code).toBe(true);
  });

  it('indexes even the weakest machine translations (maintainer decision, 2026-11-01)', () => {
    for (const code of ['ha', 'am', 'my', 'ps', 'so', 'om', 'sd']) expect(isIndexable(code), code).toBe(true);
    expect(HELD_FROM_INDEX.size).toBe(0);
  });

  it('keeps a held language out of the index', () => {
    expect(HELD_FROM_INDEX.has('en')).toBe(false);
    for (const code of HELD_FROM_INDEX) expect(isIndexable(code), code).toBe(false);
  });

  it('only holds back languages that exist, and every other language is indexed', () => {
    const codes = new Set(LOCALES.map((l) => l.code));
    for (const code of HELD_FROM_INDEX) expect(codes.has(code), code).toBe(true);
    expect(INDEXED_LANGUAGES.size).toBe(codes.size - HELD_FROM_INDEX.size);
  });
});

describe('splitLocale', () => {
  it('splits a language prefix from the path, including a three-letter code', () => {
    expect(splitLocale('/vi/games/')).toEqual({ code: 'vi', path: '/games/' });
    expect(splitLocale('/zh-hans/')).toEqual({ code: 'zh-Hans', path: '/' });
    expect(splitLocale('/fil/games/picture-pairs/')).toEqual({ code: 'fil', path: '/games/picture-pairs/' });
  });

  it('leaves English paths alone, even ones that look like a short prefix', () => {
    for (const path of ['/', '/games/', '/app/', '/faq/', '/for-organizations/', '/handout/']) {
      expect(splitLocale(path), path).toEqual({ code: 'en', path });
    }
  });

  it('knows every registered language by its own prefix', () => {
    for (const l of LOCALES.filter((x) => x.prefix)) {
      expect(splitLocale(`/${l.prefix}/games/`), l.code).toEqual({ code: l.code, path: '/games/' });
    }
  });
});

describe('localeOfContentDir', () => {
  // Astro's glob loader lowercases entry ids, so guides-i18n/pt-BR/ arrives as `pt-br/...`.
  // Matching the code exactly dropped every guide in pt-BR, pt-PT, zh-Hans and zh-Hant
  // (23 pages built for pt-br against 62 for ja), which kept them out of search.
  it('maps a lowercased folder back to a mixed-case language code', () => {
    expect(localeOfContentDir('pt-br')).toBe('pt-BR');
    expect(localeOfContentDir('pt-pt')).toBe('pt-PT');
    expect(localeOfContentDir('zh-hans')).toBe('zh-Hans');
    expect(localeOfContentDir('zh-hant')).toBe('zh-Hant');
    expect(localeOfContentDir('ja')).toBe('ja');
  });

  it('finds every language in either case', () => {
    for (const { code } of LOCALES) {
      expect(localeOfContentDir(code), code).toBe(code);
      expect(localeOfContentDir(code.toLowerCase()), code).toBe(code);
    }
  });

  it('recognises every translated guide folder, as the loader reports it', () => {
    const base = fileURLToPath(new URL('../content/guides-i18n/', import.meta.url));
    const dirs = readdirSync(base, { withFileTypes: true }).filter((d) => d.isDirectory());
    expect(dirs.length).toBeGreaterThan(0);
    for (const { name } of dirs) expect(localeOfContentDir(name.toLowerCase()), name).toBe(name);
  });

  it('is undefined for a folder that is not a language', () => {
    expect(localeOfContentDir('activities')).toBeUndefined();
    expect(localeOfContentDir('')).toBeUndefined();
  });
});
