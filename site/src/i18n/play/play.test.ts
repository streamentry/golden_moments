import { describe, expect, it } from 'vitest';
import en from './en.json';
import { boldRuns, fill, plural, type PluralForms } from './format';
import { GAME_TEXT, NO_LETTER_GRID, SHARED_UI, playProps, type PlayContent } from '../play';
import { LOCALES } from '../locales';
import { deepMerge } from '../ui';
import { COLORING_PAGES, PAINTS } from '../../data/coloring';
import { PICTURES } from '../../data/pictures';
import { TALK_THEME_ORDER } from '../../data/prompts';
import { lettersOf, normalizeWord } from '../../lib/games/wordsearch';

type Tree = { [key: string]: unknown };

const isTree = (v: unknown): v is Tree => typeof v === 'object' && v !== null && !Array.isArray(v);
const isPlural = (v: unknown): v is PluralForms => isTree(v) && typeof v.other === 'string';

/** Dotted paths to every leaf; plural objects and arrays count as one leaf. */
function leaves(tree: Tree, prefix = ''): string[] {
  return Object.entries(tree).flatMap(([key, value]) => {
    const path = prefix ? `${prefix}.${key}` : key;
    return isTree(value) && !isPlural(value) ? leaves(value, path) : [path];
  });
}

function at(tree: unknown, path: string): unknown {
  return path.split('.').reduce<unknown>((node, key) => (isTree(node) ? node[key] : undefined), tree);
}

const placeholders = (text: string): string[] => [...text.matchAll(/\{(\w+)(?:\|lower)?\}/g)].map((m) => m[1] as string).sort();

// Component sources, read as text for the static key check.
const sources = import.meta.glob<string>('../../games/**/*.tsx', { query: '?raw', import: 'default', eager: true });

/** Every `ui.a.b` and `content.a.b` path the components read. */
function usedPaths(root: 'ui' | 'content'): Set<string> {
  const found = new Set<string>();
  const pattern = new RegExp(`\\b${root}\\.([A-Za-z]\\w*(?:\\.[A-Za-z]\\w*)*)`, 'g');
  for (const text of Object.values(sources)) {
    for (const m of text.matchAll(pattern)) found.add(m[1] as string);
  }
  return found;
}

describe('fill', () => {
  it('replaces placeholders and leaves unknown ones visible', () => {
    expect(fill('{name}, tile {n}', { name: 'Teacup', n: 3 })).toBe('Teacup, tile 3');
    expect(fill('{a} and {missing}', { a: 'One' })).toBe('One and {missing}');
    expect(fill('No placeholders.', { a: 1 })).toBe('No placeholders.');
  });

  it('lowercases with |lower, using the language rules', () => {
    expect(fill('Two pictures of the {name|lower}, together.', { name: 'Red apple' })).toBe('Two pictures of the red apple, together.');
    expect(fill('{w|lower}', { w: 'IRMAK' }, 'tr')).toBe('ırmak');
    expect(fill('{w}', { w: 'IRMAK' }, 'tr')).toBe('IRMAK');
  });
});

describe('plural', () => {
  const forms = { one: '{n} tile', few: '{n} few', many: '{n} many', other: '{n} tiles' };

  it('picks the form by the language plural rules', () => {
    expect(plural(forms, 1)).toBe('{n} tile');
    expect(plural(forms, 4)).toBe('{n} tiles');
    expect(plural(forms, 4, 'ru')).toBe('{n} few');
    expect(plural(forms, 6, 'ru')).toBe('{n} many');
    expect(plural(forms, 1, 'ja')).toBe('{n} tiles');
  });

  it('falls back to other', () => {
    expect(plural({ other: 'x' }, 1)).toBe('x');
  });
});

describe('boldRuns', () => {
  it('splits **bold** runs', () => {
    expect(boldRuns('**Choose photos** from here.')).toEqual([
      { text: 'Choose photos', bold: true },
      { text: ' from here.', bold: false },
    ]);
    expect(boldRuns('Plain')).toEqual([{ text: 'Plain', bold: false }]);
  });
});

describe('playProps', () => {
  it('names every picture id, matching pictures.ts in English', () => {
    const { pictureNames } = playProps('en');
    expect(Object.keys(pictureNames).sort()).toEqual(PICTURES.map((p) => p.id).sort());
    for (const p of PICTURES) expect(pictureNames[p.id]).toBe(p.name);
  });

  it('names every picture in every language, falling back to English', () => {
    for (const { code } of LOCALES) {
      const { pictureNames, lang } = playProps(code);
      expect(lang).toBe(code);
      for (const p of PICTURES) expect(pictureNames[p.id], `${code} ${p.id}`).toBeTruthy();
    }
  });

  it('gives English for an unknown code', () => {
    expect(playProps('xx').lang).toBe('en');
    expect(playProps('xx').ui).toEqual(en.ui);
  });

  it('turns the word search off where a letter grid does not suit the script', () => {
    expect(playProps('en').content.wordSearch.available).toBe(true);
    for (const code of NO_LETTER_GRID) expect(playProps(code).content.wordSearch.available, code).toBe(false);
    expect(playProps('vi').content.wordSearch.available).toBe(true);
  });

  it('returns plain JSON, so Astro can pass it to the islands', () => {
    const props = playProps('en');
    expect(JSON.parse(JSON.stringify(props))).toEqual(props);
  });
});

describe('component text keys', () => {
  it('finds component sources to check', () => {
    expect(Object.keys(sources).length).toBeGreaterThanOrEqual(12);
  });

  it('every ui key a component reads exists in en.json', () => {
    const used = usedPaths('ui');
    expect(used.size).toBeGreaterThan(50);
    for (const path of used) expect(at(en.ui, path), `ui.${path}`).toBeDefined();
  });

  it('every ui string in en.json is used by a component', () => {
    const used = [...usedPaths('ui')];
    const unused = leaves(en.ui).filter((leaf) => !used.some((u) => leaf === u || leaf.startsWith(`${u}.`)));
    expect(unused).toEqual([]);
  });

  it('every content key a component reads exists in en.json', () => {
    for (const path of usedPaths('content')) expect(at(en.content, path), `content.${path}`).toBeDefined();
  });

  it('each game reads only the sections playProps(code, slug) sends', () => {
    const sectionsIn = (text: string, root: 'ui' | 'content') =>
      [...text.matchAll(new RegExp(`\\b${root}\\.([A-Za-z]\\w*)`, 'g'))].map((m) => m[1] as string);
    const shared = (name: string) => Object.entries(sources).find(([f]) => f.endsWith(`/shared/${name}.tsx`))?.[1] ?? '';
    const pascal = (slug: string) => slug.replace(/(^|-)(\w)/g, (_, __, c: string) => c.toUpperCase());
    expect(Object.keys(GAME_TEXT)).toHaveLength(12);
    for (const [slug, need] of Object.entries(GAME_TEXT)) {
      const file = Object.entries(sources).find(([f]) => f.endsWith(`/games/${pascal(slug)}.tsx`));
      expect(file, slug).toBeDefined();
      const text = file![1] + (file![1].includes('PairsBoard') ? shared('PairsBoard') : '');
      const props = playProps('en', slug);
      for (const s of sectionsIn(text, 'ui')) expect(props.ui, `${slug} reads ui.${s}`).toHaveProperty(s);
      for (const s of sectionsIn(text, 'content')) expect(props.content, `${slug} reads content.${s}`).toHaveProperty(s);
      expect([...SHARED_UI, ...need.ui].every((s) => s in props.ui)).toBe(true);
    }
    for (const name of ['GameFrame', 'PictureTile']) {
      for (const s of sectionsIn(shared(name), 'ui')) expect(SHARED_UI, `${name} reads ui.${s}`).toContain(s);
    }
  });

  it('components contain no hard-coded user-facing English', () => {
    for (const [file, text] of Object.entries(sources)) {
      // Visible JSX text: a run of two or more capitalized words between tags.
      const jsxText = [...text.matchAll(/>\s*([A-Z][a-z]+(?: [a-z]+)+)\s*</g)].map((m) => m[1]);
      expect(jsxText, file).toEqual([]);
      // String attributes people hear or see.
      const attrs = [...text.matchAll(/(?:aria-label|alt|label|legend|guidance|restartLabel)="([^"]+)"/g)].map((m) => m[1]);
      expect(attrs, file).toEqual([]);
    }
  });
});

const playFiles = import.meta.glob<{ default: unknown }>('./*.json', { eager: true });
const FILES = Object.entries(playFiles).map(([path, mod]) => ({ code: path.replace(/^.*\/(.+)\.json$/, '$1'), data: mod.default }));
const pictureIds = new Set(PICTURES.map((p) => p.id));

describe('play files (English and every translation)', () => {
  it('are named after a site language', () => {
    const codes = new Set(LOCALES.map((l) => l.code));
    for (const { code } of FILES) expect(codes.has(code), code).toBe(true);
    expect(FILES.some((f) => f.code === 'en')).toBe(true);
  });

  for (const { code, data } of FILES) {
    describe(code, () => {
      const raw = data as Tree;
      const merged = code === 'en' ? (raw as unknown as typeof en) : deepMerge(en, raw);
      const content = playProps(code).content as PlayContent;

      it('only uses keys English has, with the same placeholders', () => {
        if (!isTree(raw.ui)) return;
        for (const path of leaves(raw.ui)) {
          const source = at(en.ui, path);
          expect(source, `ui.${path} is not an English key`).toBeDefined();
          const value = at(raw.ui, path);
          const texts = (v: unknown): string[] => (typeof v === 'string' ? [v] : isTree(v) ? Object.values(v).flatMap(texts) : Array.isArray(v) ? v.flatMap(texts) : []);
          const expected = [...new Set(texts(source).flatMap(placeholders))].sort();
          for (const t of texts(value)) {
            for (const p of placeholders(t)) expect(expected, `ui.${path} uses {${p}}`).toContain(p);
          }
        }
      });

      it('gives every plural form the language needs', () => {
        if (code === 'en' || !isTree(raw.ui)) return;
        const needed = new Intl.PluralRules(code).resolvedOptions().pluralCategories;
        for (const path of leaves(raw.ui)) {
          const value = at(raw.ui, path);
          if (!isPlural(value)) continue;
          for (const category of needed) expect(value[category], `ui.${path}.${category}`).toBeTypeOf('string');
        }
      });

      it('keeps the puzzle place names complete', () => {
        expect(merged.ui.picturePuzzle.places4).toHaveLength(4);
        expect(merged.ui.picturePuzzle.places9).toHaveLength(9);
      });

      it('only names pictures that exist', () => {
        for (const id of Object.keys((raw.pictures as Tree | undefined) ?? {})) expect(pictureIds.has(id), id).toBe(true);
      });

      it('has enough familiar sayings, each with two other endings', () => {
        expect(content.sayings.length).toBeGreaterThanOrEqual(30);
        const starts = new Set<string>();
        for (const s of content.sayings) {
          expect(s.start && s.end && s.prompt, JSON.stringify(s)).toBeTruthy();
          expect(s.others).toHaveLength(2);
          expect(new Set([s.end, ...s.others]).size, s.start).toBe(3);
          expect(starts.has(s.start), `duplicate ${s.start}`).toBe(false);
          starts.add(s.start);
        }
      });

      it('has word themes that fit the grid, unless the word search is off', () => {
        const ws = content.wordSearch;
        if (!ws.available) return;
        expect(new Set(lettersOf(ws.fill)).size).toBeGreaterThanOrEqual(10);
        expect(ws.themes.length).toBeGreaterThanOrEqual(4);
        for (const t of ws.themes) {
          expect(t.value && t.label, JSON.stringify(t)).toBeTruthy();
          const fitting = t.words.filter((w) => {
            const n = lettersOf(normalizeWord(w, code)).length;
            return n >= 3 && n <= 6;
          });
          expect(fitting.length, `${t.value}: words of 3 to 6 letters`).toBeGreaterThanOrEqual(6);
        }
      });

      it('has a conversation card for every theme, each on a real picture', () => {
        const { themes, cards } = content.conversation;
        for (const t of TALK_THEME_ORDER) expect(themes[t], `theme ${t}`).toBeTruthy();
        for (const c of cards) {
          expect(pictureIds.has(c.picture), c.picture).toBe(true);
          expect(TALK_THEME_ORDER, c.theme).toContain(c.theme);
          expect(c.prompt).toBeTruthy();
        }
        for (const t of TALK_THEME_ORDER.filter((x) => x !== 'all')) {
          expect(cards.filter((c) => c.theme === t).length, `cards for ${t}`).toBeGreaterThanOrEqual(2);
        }
      });

      it('names every coloring page, region and paint', () => {
        for (const page of COLORING_PAGES) {
          const text = content.coloring.pages[page.id];
          expect(text?.name, page.id).toBeTruthy();
          for (const r of page.regions) expect(text?.regions[r.id], `${page.id}.${r.id}`).toBeTruthy();
        }
        for (const p of PAINTS) expect((merged.ui.coloring.paints as Record<string, string>)[p.id], p.id).toBeTruthy();
      });

      it('names every sorting theme and both baskets', () => {
        for (const id of ['kitchen-garden', 'fruit-animals', 'home-travel']) {
          const t = content.sorting.themes[id];
          expect(t?.label, id).toBeTruthy();
          expect(t?.baskets.filter(Boolean), id).toHaveLength(2);
        }
      });
    });
  }

  it('English prompts invite, never quiz', () => {
    const prompts = [...en.content.sayings.map((s) => s.prompt), ...en.content.conversation.cards.map((c) => c.prompt)];
    for (const p of prompts) expect(p, p).not.toMatch(/remember|who is this|score|brain|memory/i);
  });
});
