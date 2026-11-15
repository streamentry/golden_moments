import { describe, expect, it } from 'vitest';
import { clearColoringPage, coloringPageFills, colorRegion, justCompleted } from './coloring-progress';

describe('coloring progress', () => {
  it("keeps each page's colors when changing pages", () => {
    const flower = colorRegion({}, 'flower', 'stem', 'blue');
    const house = colorRegion(flower, 'house', 'roof', 'red');

    expect(coloringPageFills(house, 'flower')).toEqual({ stem: 'blue' });
    expect(coloringPageFills(house, 'house')).toEqual({ roof: 'red' });
    expect(coloringPageFills(house, 'teacup')).toEqual({});
  });

  it('clears only the selected page', () => {
    const progress = colorRegion(
      colorRegion({}, 'flower', 'stem', 'blue'),
      'house',
      'roof',
      'red',
    );
    const cleared = clearColoringPage(progress, 'house');

    expect(coloringPageFills(cleared, 'flower')).toEqual({ stem: 'blue' });
    expect(coloringPageFills(cleared, 'house')).toEqual({});
  });

  it('marks completion only on the incomplete-to-complete transition', () => {
    expect(justCompleted(false, false)).toBe(false);
    expect(justCompleted(false, true)).toBe(true);
    expect(justCompleted(true, true)).toBe(false);
    expect(justCompleted(true, false)).toBe(false);
  });
});
