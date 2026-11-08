import { describe, expect, it } from 'vitest';
import { makeTablesFocusable } from './tables';

describe('makeTablesFocusable', () => {
  it('adds tabindex 0 to tables without tabindex in .prose and .stage-table', () => {
    const table1 = {
      attrs: new Set<string>(),
      tabIndex: -1,
      hasAttribute(k: string) {
        return this.attrs.has(k);
      },
    };
    const table2 = {
      attrs: new Set<string>(['tabindex']),
      tabIndex: 0,
      hasAttribute(k: string) {
        return this.attrs.has(k);
      },
    };

    let queriedSelector = '';
    const mockRoot = {
      querySelectorAll<T>(selector: string) {
        queriedSelector = selector;
        return [table1, table2] as unknown as Iterable<T>;
      },
    };

    const count = makeTablesFocusable(mockRoot);
    expect(queriedSelector).toBe('.prose table, .stage-table table');
    expect(count).toBe(1);
    expect(table1.tabIndex).toBe(0);
    expect(table2.tabIndex).toBe(0);
  });

  it('handles missing document in non-browser environments gracefully', () => {
    expect(makeTablesFocusable(undefined)).toBe(0);
  });
});
