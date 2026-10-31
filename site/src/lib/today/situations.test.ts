import { existsSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { GAMES } from '../../data/games';
import { SITUATIONS, SITUATION_IDS } from './situations';

const GUIDES = new URL('../../content/guides/', import.meta.url);

describe('situations', () => {
  it('has one answer per id, in order', () => {
    expect(SITUATIONS.map((s) => s.id)).toEqual([...SITUATION_IDS]);
  });

  it('links only to games and guides that exist', () => {
    const games = new Set(GAMES.map((g) => `/games/${g.slug}/`));
    for (const s of SITUATIONS) {
      expect(games.has(s.activity.href), s.activity.href).toBe(true);
      expect(existsSync(new URL(`${s.guide.href.slice(1, -1)}.md`, GUIDES)), s.guide.href).toBe(true);
    }
  });

  it('always says when to get help, with an emergency number', () => {
    for (const s of SITUATIONS) expect(s.help).toMatch(/911/);
  });
});
