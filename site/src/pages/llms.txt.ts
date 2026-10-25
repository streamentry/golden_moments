import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { GAMES } from '../data/games';
import { SECTION_META, SITE } from '../lib/site';
import { SECTIONS } from '../content.config';

/** A plain-text map of the site for AI answer engines (llmstxt.org format). */
export const GET: APIRoute = async () => {
  const guides = (await getCollection('guides')).sort((a, b) => a.data.order - b.data.order);
  const lines: string[] = [
    `# ${SITE.name} (${SITE.domain})`,
    '',
    `> Free, gentle browser games and practical activity guides for people living with dementia and their caregivers. No sign-up, no timers, no scores. Recreational and informational only: not medical advice, and no claims to diagnose, treat or prevent dementia.`,
    '',
    'Key facts:',
    '- All games are free, run in a web browser and need no account.',
    '- Games have no timer, score, levels or penalties; pictures stay visible by default.',
    '- Photos used in Photo pairs stay in the browser and are never uploaded.',
    '- Guides cite public sources such as the National Institute on Aging, the Alzheimer’s Association, Cochrane and The Lancet.',
    `- Full text summaries: ${SITE.url}/llms-full.txt`,
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
    `- [Health information notice](${SITE.url}/medical-disclaimer/)`,
    `- [Privacy](${SITE.url}/privacy/)`,
    `- [Golden Moments app](${SITE.url}/app/): iPhone, iPad and Android.`,
    `- [App help](${SITE.url}/help/): gentle games, family photos, offline play and removing copies.`,
    `- [App privacy policy](${SITE.url}/app-privacy/): family photos stay on the device; no account or photo upload.`,
    `- [Safety and intended use](${SITE.url}/safety/): recreation, not diagnosis, testing or treatment.`,
    `- [Legal and privacy information](${SITE.url}/legal/)`,
    `- [Support](${SITE.url}/support/)`,
    '',
  );
  return new Response(lines.join('\n'), { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
};
