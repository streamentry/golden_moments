import { createHash } from 'node:crypto';
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { PICTURES, pictureShadowSvg, pictureSvg } from './pictures';

/** Every element's attributes, so a repeated one (invalid XML) is caught. */
function duplicateAttributes(svg: string): string[] {
  const found: string[] = [];
  for (const tag of svg.match(/<[a-zA-Z][^>]*>/g) ?? []) {
    const names = [...tag.matchAll(/\s([a-zA-Z:-]+)=/g)].map((m) => m[1]);
    const seen = new Set<string>();
    for (const name of names) {
      if (seen.has(name)) found.push(`${tag.slice(0, 40)}… ${name}`);
      seen.add(name);
    }
  }
  return found;
}

describe('pictures', () => {
  it('have unique, URL-safe ids and names', () => {
    const ids = PICTURES.map((p) => p.id);
    expect(new Set(ids).size).toBe(ids.length);
    for (const p of PICTURES) {
      expect(p.id, p.id).toMatch(/^[a-z]+(-[a-z]+)*$/);
      expect(p.name.trim(), p.id).not.toBe('');
    }
  });

  it('are a large library', () => {
    expect(PICTURES.length).toBeGreaterThanOrEqual(80);
  });

  it('are well-formed: no repeated attribute on any element', () => {
    for (const p of PICTURES) {
      expect(duplicateAttributes(pictureSvg(p)), p.id).toEqual([]);
      expect(duplicateAttributes(pictureShadowSvg(p)), p.id).toEqual([]);
    }
  });

  it('keep ids inside one picture unique to that picture', () => {
    // Pictures are shown side by side inline; a shared clip or gradient id
    // would let one picture borrow another's shape.
    const owner = new Map<string, string>();
    for (const p of PICTURES) {
      for (const [, id] of pictureSvg(p).matchAll(/\sid="([^"]+)"/g)) {
        expect(owner.get(id) ?? p.id, `${id} in ${p.id}`).toBe(p.id);
        owner.set(id, p.id);
      }
    }
  });

  it('stay within the shared palette and canvas', () => {
    for (const p of PICTURES) {
      expect(pictureSvg(p), p.id).toContain('viewBox="0 0 120 120"');
      expect(p.body, p.id).not.toMatch(/<(image|script|foreignObject|text)\b/);
      expect(p.body, p.id).not.toMatch(/https?:/);
    }
  });

  it('match the copies bundled in the app (run scripts/export-pictures.mjs)', () => {
    const dir = fileURLToPath(new URL('../../../assets/images/pictures/', import.meta.url));
    const manifest = JSON.parse(readFileSync(`${dir}manifest.json`, 'utf8')) as {
      pictures: { id: string; svg: string }[];
    };
    const hash = (svg: string) => createHash('sha256').update(svg).digest('hex').slice(0, 16);
    expect(manifest.pictures).toEqual(
      PICTURES.map((p) => expect.objectContaining({ id: p.id, svg: hash(pictureSvg(p)) })),
    );
    for (const p of PICTURES) expect(existsSync(`${dir}${p.id}.webp`), p.id).toBe(true);
  });
});
