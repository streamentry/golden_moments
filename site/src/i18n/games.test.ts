import { describe, expect, it } from 'vitest';
import { GAMES } from '../data/games';
import english from './games/en.json';
import { gameAvailable } from './games';
import { NO_LETTER_GRID, NO_SAYINGS_GAME } from './play';

describe('which games a language offers', () => {
  it('offers every game in English and in a fully translated language', () => {
    for (const g of GAMES.filter((x) => x.slug !== 'word-search')) expect(gameAvailable(g.slug, 'en'), g.slug).toBe(true);
    expect(gameAvailable('word-search', 'en')).toBe(true);
    expect(gameAvailable('finish-the-saying', 'es')).toBe(true);
  });

  it('leaves Finish the saying out of the languages listed in NO_SAYINGS_GAME, and only that game', () => {
    for (const code of NO_SAYINGS_GAME) {
      expect(gameAvailable('finish-the-saying', code), code).toBe(false);
      expect(gameAvailable('picture-pairs', code), code).toBe(true);
    }
  });

  it('still leaves the word search out where a letter grid does not suit the script', () => {
    for (const code of NO_LETTER_GRID) expect(gameAvailable('word-search', code), code).toBe(false);
  });
});

describe('game translation source', () => {
  it('matches the English game copy in data/games.ts', () => {
    for (const g of GAMES) {
      const text = (english as Record<string, Record<string, unknown>>)[g.slug];
      expect(text, g.slug).toBeDefined();
      for (const key of ['name', 'seoTitle', 'h1', 'description', 'short', 'players', 'intro', 'howTo', 'tips', 'faq'] as const) {
        expect(text?.[key], `${g.slug}.${key}`).toEqual(g[key]);
      }
    }
  });
});
