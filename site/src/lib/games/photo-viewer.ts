/** Move through selected photos without showing a match task or a score. */
export function movePhotoIndex(current: number, total: number, direction: -1 | 1): number {
  if (total <= 0) return 0;
  return (current + direction + total) % total;
}
