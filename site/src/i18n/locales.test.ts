import { describe, expect, it } from 'vitest';
import { HELD_FROM_INDEX, INDEXED_LANGUAGES, LOCALES, isIndexable } from './locales';

describe('which languages search engines may index', () => {
  it('indexes English and the machine translations that read acceptably', () => {
    for (const code of ['en', 'es', 'ja', 'bn', 'fa']) expect(isIndexable(code), code).toBe(true);
  });

  it('holds back the languages listed as too weak to publish unread', () => {
    expect(HELD_FROM_INDEX.has('en')).toBe(false);
    for (const code of HELD_FROM_INDEX) expect(isIndexable(code), code).toBe(false);
    expect(isIndexable('ha')).toBe(false);
  });

  it('only holds back languages that exist, and every other language is indexed', () => {
    const codes = new Set(LOCALES.map((l) => l.code));
    for (const code of HELD_FROM_INDEX) expect(codes.has(code), code).toBe(true);
    expect(INDEXED_LANGUAGES.size).toBe(codes.size - HELD_FROM_INDEX.size);
  });
});
