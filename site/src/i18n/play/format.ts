/**
 * Tiny text helpers for the game islands. Kept apart from `../ui.ts`, which
 * loads every UI dictionary, so the browser bundle stays one language.
 */

type Values = Record<string, string | number>;

/**
 * Replaces `{name}` placeholders. `{name|lower}` lowercases the value with the
 * page language's rules, for a picture name inside a sentence ("the teacup").
 * Unknown placeholders are left as they are, so a missing value is visible.
 */
export function fill(text: string, values: Values, locale = 'en'): string {
  return text.replace(/\{(\w+)(\|lower)?\}/g, (match, key: string, lower?: string) => {
    if (!(key in values)) return match;
    const value = String(values[key]);
    return lower ? value.toLocaleLowerCase(locale) : value;
  });
}

/** `other` is required; add `zero`, `one`, `two`, `few` or `many` where the language uses them. */
export type PluralForms = { other: string } & Partial<Record<Intl.LDMLPluralRule, string>>;

/** The plural form for `count`, chosen by the language's own plural rules. */
export function plural(forms: PluralForms, count: number, locale = 'en'): string {
  const rule = new Intl.PluralRules(locale).select(count);
  return forms[rule] ?? forms.other;
}

/** Splits `**bold** rest` into plain and bold runs; odd runs are bold. */
export function boldRuns(text: string): { text: string; bold: boolean }[] {
  return text
    .split('**')
    .map((part, i) => ({ text: part, bold: i % 2 === 1 }))
    .filter((run) => run.text !== '');
}
