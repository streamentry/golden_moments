/** Fonts every page preloads: the Latin headline and body faces. */
export const BASE_FONT_PRELOADS: readonly string[] = [
  '/fonts/fraunces-latin-700-normal.woff2',
  '/fonts/roboto-latin-400-normal.woff2',
  '/fonts/roboto-latin-700-normal.woff2',
];

/**
 * Extra faces a language bundles for its own script, preloaded only on that
 * language's pages. Keep to the body face and the headline face.
 */
export const LOCALE_FONT_PRELOADS: Readonly<Record<string, readonly string[]>> = {
  am: ['/fonts/noto-serif-ethiopic-ethiopic-700-normal.woff2', '/fonts/noto-sans-ethiopic-ethiopic-400-normal.woff2'],
};

export function fontPreloads(lang: string): readonly string[] {
  return [...BASE_FONT_PRELOADS, ...(LOCALE_FONT_PRELOADS[lang] ?? [])];
}
