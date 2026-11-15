import { describe, expect, it } from 'vitest';
import { selectPhotoFiles } from './photo-selection';

const MiB = 1024 * 1024;
const photo = (name: string, size: number, type = 'image/jpeg') => ({ name, size, type });

describe('photo selection limits', () => {
  it('keeps selected files within individual and total-size limits in order', () => {
    const files = [
      photo('first', 40 * MiB),
      photo('second', 30 * MiB),
      photo('third', 20 * MiB),
      photo('fourth', 10 * MiB),
      photo('fifth', 3 * MiB),
      photo('sixth', 3 * MiB),
      photo('seventh', 1 * MiB),
      photo('too-large', 41 * MiB),
      photo('not-image', 1, 'text/plain'),
    ];

    const selection = selectPhotoFiles(files, 6, 40 * MiB, 80 * MiB);

    expect(selection.picked.map((file) => file.name)).toEqual(['first', 'second', 'fourth']);
    expect(selection.totalBytes).toBe(80 * MiB);
    expect(selection.skipped).toBe(5);
    expect(selection.extra).toBe(1);
  });

  it('reports valid images beyond the photo-count limit separately', () => {
    const files = Array.from({ length: 7 }, (_, index) => photo(`photo-${index + 1}`, 5 * MiB));

    const selection = selectPhotoFiles(files, 6, 40 * MiB, 80 * MiB);

    expect(selection.picked.map((file) => file.name)).toEqual([
      'photo-1', 'photo-2', 'photo-3', 'photo-4', 'photo-5', 'photo-6',
    ]);
    expect(selection.skipped).toBe(0);
    expect(selection.extra).toBe(1);
  });
});
