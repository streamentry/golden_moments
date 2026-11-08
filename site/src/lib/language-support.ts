/**
 * The "Languages" part of /llms.txt: what the website offers in each language,
 * built from the same data as the pages and sitemaps so it can never claim a
 * page that does not exist.
 */

/** One published language and what exists in it. */
export interface LanguageRow {
  code: string;
  bcp47: string;
  name: string;
  englishName: string;
  dir: 'ltr' | 'rtl';
  /** Absolute URL of the language's home page. */
  home: string;
  /** Absolute URL of the language's sitemap. */
  sitemap: string;
  /** Indexable pages in this language. */
  pages: number;
  /** Names of games left out of this language, if any. */
  missingGames: readonly string[];
  /** Guides translated into this language. */
  guides: number;
}

export interface LanguageSupport {
  siteUrl: string;
  /** Every published language, English first. */
  rows: readonly LanguageRow[];
  totalGames: number;
  totalGuides: number;
  /** English paths that exist in every language, such as `/games/`. */
  everyLanguagePaths: readonly string[];
  /** English paths that exist only in English, such as `/privacy/`. */
  englishOnlyPaths: readonly string[];
}

const DEFAULT = 'en';

function plural(n: number, word: string): string {
  return `${n} ${word}${n === 1 ? '' : 's'}`;
}

/** One line per language, readable by people and parseable by machines. */
export function languageRow(row: LanguageRow, totalGames: number, totalGuides: number): string {
  const games = totalGames - row.missingGames.length;
  const gameNote = row.missingGames.length ? ` (not ${row.missingGames.join(', ')})` : '';
  const status = row.code === DEFAULT ? 'original' : 'machine translated, not yet reviewed';
  return [
    `- [${row.name} (${row.englishName})](${row.home})`,
    `code \`${row.bcp47}\``,
    row.dir === 'rtl' ? 'right to left' : 'left to right',
    status,
    plural(row.pages, 'page'),
    `${games}/${totalGames} games${gameNote}`,
    `${row.guides}/${totalGuides} guides`,
    `sitemap: ${row.sitemap}`,
  ].join(' · ');
}

/** The full section, summary first and then every language. */
export function languageSection(s: LanguageSupport): string[] {
  if (s.rows.length < 2) return [];
  const translated = s.rows.filter((r) => r.code !== DEFAULT);
  const rtl = s.rows.filter((r) => r.dir === 'rtl');
  const allGames = s.rows.filter((r) => r.missingGames.length === 0).length;
  const allGuides = s.rows.filter((r) => r.guides === s.totalGuides).length;
  const pages = s.rows.reduce((n, r) => n + r.pages, 0);
  const example = translated[0];
  return [
    '## Languages',
    '',
    `The website is published in ${s.rows.length} languages: English and ${translated.length} translations, ${pages} indexable pages in all.${rtl.length ? ` ${plural(rtl.length, 'language')} ${rtl.length === 1 ? 'is' : 'are'} written right to left (${rtl.map((r) => r.englishName).join(', ')}).` : ''}`,
    '',
    '- English is the original. Every other language is a machine translation that has not yet been checked by a native speaker; each translated page says so and links to the English original.',
    `- URLs: English is at the root (${s.siteUrl}/games/). Other languages use a language prefix with the same English slug${example ? ` (${s.siteUrl}/${example.home.slice(s.siteUrl.length + 1)}games/)` : ''}.`,
    `- Every language is indexable, has its own sitemap (all listed in ${s.siteUrl}/sitemap.xml) and declares hreflang alternates for the others, with English as x-default.`,
    `- In every language: ${s.everyLanguagePaths.join(', ')}, plus the game pages and translated guides.`,
    `- English only, linked from every language: ${s.englishOnlyPaths.join(', ')}.`,
    `- Games: ${allGames} of ${s.rows.length} languages have all ${s.totalGames} games. A game is left out of a language rather than shown empty or invented (Word search needs an alphabet that suits a letter grid; Finish the saying needs genuine sayings in that language).`,
    `- Guides: ${allGuides} of ${s.rows.length} languages have all ${s.totalGuides} guides.`,
    '- Language choice: a first visit to the English home page may open the language the browser prefers; a language picked in the menu is remembered and always wins.',
    '',
    '### Every language',
    '',
    ...s.rows.map((r) => languageRow(r, s.totalGames, s.totalGuides)),
    '',
  ];
}
