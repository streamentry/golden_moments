// IndexNow accepts at most 10,000 URLs in one POST and rejects the whole request
// above that (https://www.indexnow.org/documentation).
export const INDEXNOW_MAX_URLS = 10_000;

/**
 * Splits URLs into IndexNow-sized batches, dropping duplicates and keeping order.
 * @param {string[]} urls
 * @param {number} [size]
 * @returns {string[][]}
 */
export function indexNowBatches(urls, size = INDEXNOW_MAX_URLS) {
  if (!Number.isInteger(size) || size < 1 || size > INDEXNOW_MAX_URLS) {
    throw new RangeError(`Batch size must be 1 to ${INDEXNOW_MAX_URLS}, got ${size}`);
  }
  const unique = [...new Set(urls)];
  return Array.from({ length: Math.ceil(unique.length / size) }, (_, i) => unique.slice(i * size, (i + 1) * size));
}
