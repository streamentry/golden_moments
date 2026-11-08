import { describe, expect, it } from 'vitest';
import { INDEXNOW_MAX_URLS, indexNowBatches } from '../../scripts/indexnow-batches.mjs';

const urls = (n: number) => Array.from({ length: n }, (_, i) => `https://example.test/${i}/`);

describe('indexNowBatches', () => {
  // IndexNow rejects a whole request with HTTP 400 above 10,000 URLs; the site passed
  // 11,000 in 2026-11 and every deploy's submission had been failing silently.
  it('keeps every batch at or under the IndexNow limit', () => {
    const batches = indexNowBatches(urls(23_456));
    expect(INDEXNOW_MAX_URLS).toBe(10_000);
    expect(batches.map((b) => b.length)).toEqual([10_000, 10_000, 3_456]);
  });

  it('submits every URL once, in order', () => {
    const list = urls(12_000);
    const withDuplicates = [...list, list[0], list[11_999]];
    expect(indexNowBatches(withDuplicates).flat()).toEqual(list);
  });

  it('returns one batch for a small site and none for an empty list', () => {
    expect(indexNowBatches(urls(3))).toHaveLength(1);
    expect(indexNowBatches([])).toEqual([]);
  });

  it('rejects a batch size the API would refuse', () => {
    expect(() => indexNowBatches(urls(3), 10_001)).toThrow();
    expect(() => indexNowBatches(urls(3), 0)).toThrow();
  });
});
