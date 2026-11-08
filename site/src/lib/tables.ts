/**
 * Enables keyboard scrollability on wide data tables by ensuring they can receive focus.
 * Under WCAG 2.1.1 (Keyboard) and W3C COGA Obj 4, tables that scroll sideways within
 * a bounded container need tabindex="0" so keyboard and switch users can scroll them.
 */

export interface FocusableTarget {
  hasAttribute(name: string): boolean;
  tabIndex: number;
}

export interface FocusableQueryRoot {
  querySelectorAll<T>(selector: string): Iterable<T>;
}

export function makeTablesFocusable(root?: FocusableQueryRoot): number {
  const doc = root ?? (typeof document !== 'undefined' ? document : undefined);
  if (!doc) return 0;
  const tables = doc.querySelectorAll<FocusableTarget>('.prose table, .stage-table table');
  let updated = 0;
  for (const table of tables) {
    if (!table.hasAttribute('tabindex')) {
      table.tabIndex = 0;
      updated++;
    }
  }
  return updated;
}
