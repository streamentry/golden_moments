export interface PhotoFileCandidate {
  type: string;
  size: number;
}

export interface PhotoSelection<T extends PhotoFileCandidate> {
  picked: T[];
  skipped: number;
  extra: number;
  totalBytes: number;
}

/** Select showable images within per-file, total-size, and count limits. */
export function selectPhotoFiles<T extends PhotoFileCandidate>(
  files: readonly T[],
  maxPhotos: number,
  maxFileBytes: number,
  maxTotalBytes: number,
): PhotoSelection<T> {
  const images = files.filter((file) => file.type.startsWith('image/') && file.size <= maxFileBytes);
  const picked: T[] = [];
  let skipped = files.length - images.length;
  let extra = 0;
  let totalBytes = 0;

  for (const [index, file] of images.entries()) {
    if (index >= maxPhotos) {
      extra++;
      continue;
    }
    if (totalBytes + file.size > maxTotalBytes) {
      skipped++;
      continue;
    }
    picked.push(file);
    totalBytes += file.size;
  }

  return { picked, skipped, extra, totalBytes };
}
