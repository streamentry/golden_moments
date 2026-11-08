import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { GAMES } from '../data/games';
import { APP } from '../lib/app';
import { SECTION_META, SITE } from '../lib/site';
import { SECTIONS } from '../content.config';
import { isIndexable, localePath } from '../i18n/locales';
import { PUBLISHED } from '../i18n/ui';
import { gameAvailable } from '../i18n/games';
import { allGuides } from '../i18n/guides';
import { languageSection, type LanguageSupport } from '../lib/language-support';
import { sitemapEntries } from '../lib/sitemap-entries';
import { sitemapPath } from '../lib/sitemap';

/** Top-level paths such as `/` or `/about/`, not game or guide pages. */
const isTopLevel = (path: string): boolean => path.split('/').filter(Boolean).length <= 1;

async function languageSupport(totalGuides: number): Promise<LanguageSupport> {
  const entries = await sitemapEntries();
  const localGuides = await allGuides();
  const langs = PUBLISHED.filter((l) => isIndexable(l.code));
  return {
    siteUrl: SITE.url,
    totalGames: GAMES.length,
    totalGuides,
    everyLanguagePaths: entries.filter((e) => isTopLevel(e.path) && langs.every((l) => e.langs.includes(l.code))).map((e) => e.path),
    englishOnlyPaths: entries.filter((e) => e.langs.length === 1 && e.langs[0] === 'en').map((e) => e.path),
    rows: langs.map((l) => ({
      code: l.code,
      bcp47: l.bcp47,
      name: l.name,
      englishName: l.englishName,
      dir: l.dir,
      home: `${SITE.url}${localePath(l.code, '/')}`,
      sitemap: `${SITE.url}${sitemapPath(l.code)}`,
      pages: entries.filter((e) => e.langs.includes(l.code)).length,
      missingGames: GAMES.filter((g) => !gameAvailable(g.slug, l.code)).map((g) => g.name),
      guides: localGuides.filter((g) => g.lang === l.code).length,
    })),
  };
}

/** A plain-text map of the site for AI answer engines (llmstxt.org format). */
export const GET: APIRoute = async () => {
  const guides = (await getCollection('guides')).sort((a, b) => a.data.order - b.data.order);
  const languages = languageSection(await languageSupport(guides.length));
  const lines: string[] = [
    `# ${SITE.name} (${SITE.domain})`,
    '',
    `> Free, gentle browser games, a free mobile app and practical activity guides for people living with dementia and their caregivers. No sign-up, no timers, no scores. Recreational and informational only: not medical advice, and no claims to diagnose, treat or prevent dementia.`,
    '',
    'Key facts:',
    '- All games are free, run in a web browser and need no account.',
    '- Games have no timer, score, levels or penalties; pictures stay visible by default.',
    '- Photos used in Photo pairs stay in the browser and are never uploaded.',
    '- Guides cite public sources such as the National Institute on Aging, the Alzheimer’s Association, Cochrane and The Lancet.',
    `- The Golden Moments app ("${APP.storeName}") is free for ${APP.platforms}: ${SITE.appStoreUrl} and ${SITE.playStoreUrl}`,
    `- Full text summaries: ${SITE.url}/llms-full.txt`,
    `- Languages: the website is available in ${PUBLISHED.filter((l) => isIndexable(l.code)).length} languages; English is the original and the rest are machine translations (details under Languages below).`,
    '',
    '## Golden Moments app',
    `- [About the app](${SITE.url}/app/): ${APP.summary}`,
    ...APP.features.map((f) => `- ${f}`),
    `- Requirements: ${APP.requirements}.`,
    `- App Store: ${SITE.appStoreUrl}`,
    `- Google Play: ${SITE.playStoreUrl}`,
    '',
    '## Games',
    ...GAMES.map((g) => `- [${g.name}](${SITE.url}/games/${g.slug}/): ${g.description}`),
  ];
  for (const section of SECTIONS) {
    lines.push('', `## ${SECTION_META[section].title}`);
    for (const g of guides.filter((e) => e.data.section === section)) {
      lines.push(`- [${g.data.title}](${SITE.url}/${g.id}/): ${g.data.description}`);
    }
  }
  lines.push(
    '',
    '## About',
    `- [Our approach](${SITE.url}/about/): why the games avoid timers, scores and quizzing.`,
    `- [Editorial policy](${SITE.url}/editorial-policy/): sources, review and corrections.`,
    `- [For organizations](${SITE.url}/for-organizations/): free use in care homes, libraries and support groups, and text for resource lists.`,
    `- [Printable handout](${SITE.url}/handout/): one page for families and caregiver packets.`,
    `- [Health information notice](${SITE.url}/medical-disclaimer/)`,
    `- [Privacy](${SITE.url}/privacy/)`,
    `- [Golden Moments app](${SITE.url}/app/): iPhone, iPad and Android.`,
    `- [App help](${SITE.url}/help/): gentle games, family photos, offline play and removing copies.`,
    `- [App privacy policy](${SITE.url}/app-privacy/): family photos stay on the device; no account or photo upload.`,
    `- [Safety and intended use](${SITE.url}/safety/): recreation, not diagnosis, testing or treatment.`,
    `- [Legal and privacy information](${SITE.url}/legal/)`,
    `- [Support](${SITE.url}/support/)`,
    '',
    ...languages,
  );
  return new Response(lines.join('\n'), { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
};
