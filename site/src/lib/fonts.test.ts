import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { BASE_FONT_PRELOADS, LOCALE_FONT_PRELOADS, fontPreloads } from './fonts';

const publicDir = fileURLToPath(new URL('../../public', import.meta.url));

describe('fontPreloads', () => {
  it('preloads only the Latin faces for languages without their own', () => {
    expect(fontPreloads('en')).toEqual(BASE_FONT_PRELOADS);
    expect(fontPreloads('ar')).toEqual(BASE_FONT_PRELOADS);
  });

  it('adds the Ethiopic faces on Amharic pages only', () => {
    const am = fontPreloads('am');
    expect(am.filter((f) => f.includes('ethiopic'))).toHaveLength(2);
    expect(am.slice(0, BASE_FONT_PRELOADS.length)).toEqual(BASE_FONT_PRELOADS);
  });

  it('points every preload at a bundled file', () => {
    const all = [...BASE_FONT_PRELOADS, ...Object.values(LOCALE_FONT_PRELOADS).flat()];
    for (const f of all) expect(existsSync(publicDir + f), f).toBe(true);
  });
});
