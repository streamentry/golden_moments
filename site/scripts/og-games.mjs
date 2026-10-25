#!/usr/bin/env node
// Writes scripts/og-games.json (titles and pictures for share images) from the
// game registry. Node 24 strips the TypeScript types on import.
import { writeFileSync } from 'node:fs';
import { GAMES } from '../src/data/games.ts';

const FALLBACK = ['teacup', 'sunflower', 'dog'];
const games = GAMES.map((g) => ({
  slug: g.slug,
  title: g.h1,
  subtitle: g.short,
  pictures: [...new Set([...g.cardPictures, ...FALLBACK])].slice(0, 3),
}));
writeFileSync(new URL('./og-games.json', import.meta.url), `${JSON.stringify(games, null, 2)}\n`);
console.log(`Wrote ${games.length} games.`);
