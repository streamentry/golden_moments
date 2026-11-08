import { describe, expect, it } from 'vitest';
import { choiceCookie, detectPathLocale, matchPreferred, readCookie, type Offer } from './language-choice';

const offers: Offer[] = [
  { code: 'es', prefix: 'es' },
  { code: 'pt-BR', prefix: 'pt-br' },
  { code: 'pt-PT', prefix: 'pt-pt' },
  { code: 'zh-Hans', prefix: 'zh-hans' },
  { code: 'zh-Hant', prefix: 'zh-hant' },
  { code: 'nb', prefix: 'nb' },
  { code: 'mn', prefix: 'mn' },
];

describe('matchPreferred', () => {
  it('takes the first preference the site offers', () => {
    expect(matchPreferred(['mn-MN', 'es'], offers)?.prefix).toBe('mn');
    expect(matchPreferred(['fr', 'es'], offers)?.prefix).toBe('es');
  });

  it('keeps English when English comes first', () => {
    expect(matchPreferred(['en-US', 'mn'], offers)).toBeNull();
  });

  it('keeps English when nothing offered matches', () => {
    expect(matchPreferred(['xx-YY'], offers)).toBeNull();
    expect(matchPreferred([], offers)).toBeNull();
  });

  it('sends Portuguese by region: Portugal to pt-PT, everything else to pt-BR', () => {
    expect(matchPreferred(['pt-PT'], offers)?.code).toBe('pt-PT');
    expect(matchPreferred(['pt-BR'], offers)?.code).toBe('pt-BR');
    expect(matchPreferred(['pt'], offers)?.code).toBe('pt-BR');
  });

  it('sends Chinese by script or region: Traditional for TW, HK and MO', () => {
    expect(matchPreferred(['zh-TW'], offers)?.code).toBe('zh-Hant');
    expect(matchPreferred(['zh-HK'], offers)?.code).toBe('zh-Hant');
    expect(matchPreferred(['zh-Hant-TW'], offers)?.code).toBe('zh-Hant');
    expect(matchPreferred(['zh-CN'], offers)?.code).toBe('zh-Hans');
    expect(matchPreferred(['zh'], offers)?.code).toBe('zh-Hans');
  });

  it('sends Norwegian, in either tag, to the Bokmål page', () => {
    expect(matchPreferred(['no'], offers)?.code).toBe('nb');
    expect(matchPreferred(['nb-NO'], offers)?.code).toBe('nb');
  });
});

describe('cookie', () => {
  it('reads one named cookie from a document.cookie string', () => {
    expect(readCookie('a=1; gm_lang=mn; b=2')).toBe('mn');
    expect(readCookie('a=1')).toBeNull();
    expect(readCookie('gm_lang=')).toBeNull();
  });

  it('writes a site-wide, one-year cookie that a reader can read back', () => {
    const written = choiceCookie('pt-PT');
    expect(written).toContain('Path=/');
    expect(written).toContain('Max-Age=31536000');
    expect(readCookie(written)).toBe('pt-PT');
  });
});

describe('detectPathLocale', () => {
  const locales = ['es', 'de', 'fr', 'pt-BR', 'zh-Hans'];

  it('detects a known locale prefix at the start of a pathname', () => {
    expect(detectPathLocale('/es/activities/gardening', locales)).toBe('es');
    expect(detectPathLocale('/de/games/', locales)).toBe('de');
    expect(detectPathLocale('/pt-br/help', locales)).toBe('pt-BR');
  });

  it('returns null for un-prefixed English or unknown routes', () => {
    expect(detectPathLocale('/activities/gardening', locales)).toBeNull();
    expect(detectPathLocale('/', locales)).toBeNull();
    expect(detectPathLocale('/unknown/route', locales)).toBeNull();
  });
});
