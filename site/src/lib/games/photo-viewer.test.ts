import { describe, expect, it } from 'vitest';
import { movePhotoIndex } from './photo-viewer';

describe('photo viewer navigation', () => {
  it('moves through the selected photos in either direction and wraps at the ends', () => {
    expect(movePhotoIndex(0, 3, -1)).toBe(2);
    expect(movePhotoIndex(1, 3, 1)).toBe(2);
    expect(movePhotoIndex(2, 3, 1)).toBe(0);
  });

  it('stays at the first index if no photos are available', () => {
    expect(movePhotoIndex(0, 0, 1)).toBe(0);
  });
});
