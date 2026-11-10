import { existsSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { GAMES } from '../../data/games';
import { PICTURES } from '../../data/pictures';
import { SITUATIONS, SITUATION_IDS } from './situations';

const GUIDES = new URL('../../content/guides/', import.meta.url);

describe('situations', () => {
  it('has one answer per id, in order', () => {
    expect(SITUATIONS.map((s) => s.id)).toEqual([...SITUATION_IDS]);
  });

  it('links only to games and guides that exist', () => {
    const games = new Set(GAMES.map((g) => `/games/${g.slug}/`));
    const pictures = new Set(PICTURES.map((picture) => picture.id));
    for (const s of SITUATIONS) {
      if (s.activity) expect(games.has(s.activity.href), s.activity.href).toBe(true);
      for (const choice of s.choices ?? []) {
        if (typeof choice === 'string') {
          expect(games.has(`/games/${choice}/`), choice).toBe(true);
        } else {
          expect(existsSync(new URL(`${choice.href.slice(1, -1)}.md`, GUIDES)), choice.href).toBe(true);
          expect(pictures.has(choice.picture), choice.picture).toBe(true);
        }
      }
      expect(existsSync(new URL(`${s.guide.href.slice(1, -1)}.md`, GUIDES)), s.guide.href).toBe(true);
    }
  });

  it('provides either one activity link or one pair of picture choices per situation', () => {
    for (const situation of SITUATIONS) {
      expect(Number(Boolean(situation.activity)) + Number(Boolean(situation.choices)), situation.id).toBe(1);
      if (situation.choices) expect(situation.choices).toHaveLength(2);
    }
  });

  it('offers one pictured game and one familiar-music choice for the nothing-to-do situation', () => {
    const situation = SITUATIONS.find((s) => s.id === 'nothing-to-do');
    const games = new Map(GAMES.map((game) => [game.slug, game]));
    const pictures = new Set(PICTURES.map((picture) => picture.id));

    expect(situation?.activity).toBeUndefined();
    expect(situation?.choices).toHaveLength(2);
    expect(situation?.choices?.[0]).toBe('picture-pairs');
    expect(situation?.choices?.[1]).toEqual({
      type: 'guide',
      href: '/activities/music/',
      label: 'Listen to a familiar song',
      description: 'Choose music they enjoy. Listening together is enough.',
      picture: 'radio',
    });
    expect(games.get('picture-pairs')?.cardPictures.length).toBeGreaterThan(0);
    expect(pictures.has(games.get('picture-pairs')?.cardPictures[0] ?? '')).toBe(true);
  });

  it('always says when to get help, with an emergency number', () => {
    for (const s of SITUATIONS) expect(s.help).toMatch(/911/);
  });
});
