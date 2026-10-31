import { GAMES, type GameInfo, type Stage } from '../data/games';
import { DEFAULT_LOCALE, localeInfo } from './locales';
import { PUBLISHED, deepMerge, fill, ui } from './ui';
import { playProps } from './play';

/** Translatable fields of a game; everything else (slug, pictures, stages) is shared. */
export type GameText = Partial<
  Pick<GameInfo, 'name' | 'seoTitle' | 'h1' | 'description' | 'short' | 'players' | 'intro' | 'howTo' | 'tips' | 'faq'>
>;

const files = import.meta.glob<{ default: Record<string, GameText> }>('./games/*.json', { eager: true });
const OVERLAYS = new Map(
  Object.entries(files).map(([path, mod]) => [path.replace(/^.*\/(.+)\.json$/, '$1'), mod.default]),
);

/** `game` with its text in `code`, English where a translation is missing. */
export function localizeGame(game: GameInfo, code: string): GameInfo {
  if (code === DEFAULT_LOCALE) return game;
  const text = OVERLAYS.get(code)?.[game.slug];
  return text ? deepMerge(game, text) : game;
}

/**
 * Whether a game is offered in `code`. Word search needs a letter grid, which
 * Chinese, Japanese, Korean and Thai do not have, so those languages leave it
 * out entirely (no page, card or hreflang) rather than show an empty game.
 */
export function gameAvailable(slug: string, code: string): boolean {
  if (slug !== 'word-search') return true;
  return playProps(code, slug).content.wordSearch.available;
}

/** Languages a game page exists in. */
export function gameLanguages(slug: string): string[] {
  return PUBLISHED.map((l) => l.code).filter((code) => gameAvailable(slug, code));
}

export function localizedGames(code: string): GameInfo[] {
  return GAMES.filter((g) => gameAvailable(g.slug, code)).map((g) => localizeGame(g, code));
}

/** "Often suits early and middle stages", in `code`. Never a promise. */
export function localStageHint(stages: readonly Stage[], code: string): string {
  const t = ui(code).stage;
  const words = stages.map((s) => t[s]);
  // House style has no serial comma in English; other languages follow Intl.
  const list =
    code === DEFAULT_LOCALE && words.length > 1
      ? `${words.slice(0, -1).join(', ')} and ${words[words.length - 1]}`
      : new Intl.ListFormat(localeInfo(code).bcp47, { type: 'conjunction' }).format(words);
  return fill(words.length > 1 ? t.hintMany : t.hintOne, { list });
}
