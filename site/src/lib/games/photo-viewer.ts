/** Move through selected photos without showing a match task or a score. */
export function initialPhotoMode(total: number): 'empty' | 'look' | 'match' {
  if (total <= 0) return 'empty';
  return total === 1 ? 'look' : 'match';
}

export function hasPhotoNavigation(total: number): boolean {
  return total > 1;
}

export function movePhotoIndex(current: number, total: number, direction: -1 | 1): number {
  if (total <= 0) return 0;
  return (current + direction + total) % total;
}
