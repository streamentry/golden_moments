import { describe, expect, it } from 'vitest';
import { displayWidth, fitDescription } from './meta-description';

describe('displayWidth (same rule as scripts/check-site.mjs)', () => {
  it('counts Latin characters as one', () => {
    expect(displayWidth('Golden Moments')).toBe(14);
  });

  it('counts CJK characters as two and combining marks as none', () => {
    expect(displayWidth('写真')).toBe(4);
    expect(displayWidth('é')).toBe(1);
  });
});

describe('fitDescription', () => {
  it('leaves a description within 170 unchanged', () => {
    const text = 'A free large-print word search for seniors and people living with dementia.';
    expect(fitDescription(text)).toBe(text);
  });

  it('keeps whole sentences when they fit', () => {
    const first = 'A calm and gentle activity for people living with dementia, played together. ';
    const text = first + 'Ö'.repeat(10) + ' ' + 'word '.repeat(40);
    const out = fitDescription(text);
    expect(out).toBe(first.trim());
    expect(displayWidth(out)).toBeLessThanOrEqual(170);
  });

  it('cuts at a word boundary with an ellipsis when one sentence is too long', () => {
    const text = 'word '.repeat(80).trim();
    const out = fitDescription(text);
    expect(out.endsWith('…')).toBe(true);
    expect(out.endsWith('word…')).toBe(true);
    expect(displayWidth(out)).toBeLessThanOrEqual(170);
  });

  it('cuts text with no spaces by character, still within 170', () => {
    const out = fitDescription('写'.repeat(120));
    expect(out.endsWith('…')).toBe(true);
    expect(displayWidth(out)).toBeLessThanOrEqual(170);
  });

  it('always returns at most 170 for long input in any script', () => {
    for (const text of ['ж'.repeat(300), 'a. '.repeat(200), 'ਸ਼ਬਦ '.repeat(100)]) {
      expect(displayWidth(fitDescription(text))).toBeLessThanOrEqual(170);
    }
  });
});
