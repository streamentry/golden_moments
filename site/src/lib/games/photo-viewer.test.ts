import { describe, expect, it } from 'vitest';
import { hasPhotoNavigation, initialPhotoMode, movePhotoIndex } from './photo-viewer';

describe('photo viewer navigation', () => {
  it('allows one photo for viewing and needs two before offering matching', () => {
    expect(initialPhotoMode(0)).toBe('empty');
    expect(initialPhotoMode(1)).toBe('look');
    expect(initialPhotoMode(2)).toBe('match');
    expect(initialPhotoMode(6)).toBe('match');
  });

  it('shows navigation only when there is another photo to visit', () => {
    expect(hasPhotoNavigation(1)).toBe(false);
    expect(hasPhotoNavigation(2)).toBe(true);
  });

  it('moves through the selected photos in either direction and wraps at the ends', () => {
    expect(movePhotoIndex(0, 3, -1)).toBe(2);
    expect(movePhotoIndex(1, 3, 1)).toBe(2);
    expect(movePhotoIndex(2, 3, 1)).toBe(0);
  });

  it('stays at the first index if no photos are available', () => {
    expect(movePhotoIndex(0, 0, 1)).toBe(0);
  });
});
