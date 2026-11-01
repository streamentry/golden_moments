import { describe, expect, it } from 'vitest';
import { HELD_FROM_INDEX, INDEXED_LANGUAGES, LOCALES, isIndexable, splitLocale } from './locales';

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
