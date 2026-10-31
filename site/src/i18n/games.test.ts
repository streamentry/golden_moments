import { describe, expect, it } from 'vitest';
import { GAMES } from '../data/games';
import english from './games/en.json';

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
