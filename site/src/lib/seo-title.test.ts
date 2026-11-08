import { describe, expect, it } from 'vitest';
import { composeTitle, displayWidth, MAX_TITLE_WIDTH } from './seo-title';

const SUFFIX = ' | Golden Moments';

describe('displayWidth', () => {
  it('counts Latin letters once and CJK characters twice', () => {
    expect(displayWidth('Games')).toBe(5);
    expect(displayWidth('日本語')).toBe(6);
  });

  it('ignores combining marks', () => {
    expect(displayWidth('é')).toBe(1);
  });
});

describe('composeTitle', () => {
  it('keeps the brand suffix on a short title', () => {
    expect(composeTitle('Picture Pairs', SUFFIX)).toBe('Picture Pairs | Golden Moments');
  });

  it('drops the suffix when the full title would be too wide', () => {
    const long = 'Guias para cuidadores de pessoas com demência: ajuda prática no dia a dia';
    expect(composeTitle(long, SUFFIX)).toBe(long);
  });

  it('keeps the suffix at exactly the limit', () => {
    const title = 'x'.repeat(MAX_TITLE_WIDTH - SUFFIX.length);
    expect(composeTitle(title, SUFFIX)).toBe(`${title}${SUFFIX}`);
    expect(composeTitle(`${title}x`, SUFFIX)).toBe(`${title}x`);
  });

  it('measures CJK titles by display width', () => {
    const title = '認知症'.repeat(9); // 27 characters, 54 columns
    expect(composeTitle(title, SUFFIX)).toBe(title);
  });
});
