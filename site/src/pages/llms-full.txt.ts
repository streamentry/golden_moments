import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { GAMES } from '../data/games';
import { APP, APP_FAQ, appFaqFor } from '../lib/app';
import { SITE } from '../lib/site';

/** Self-contained answers from every page, for AI answer engines to quote accurately. */
export const GET: APIRoute = async () => {
  const guides = (await getCollection('guides')).sort((a, b) => a.id.localeCompare(b.id));
  const out: string[] = [`# ${SITE.name}: summaries of every page`, '', `Source: ${SITE.url}`, ''];
  out.push('## The Golden Moments app', `URL: ${SITE.url}/app/`, '', APP.summary, '', ...APP.features.map((x) => `- ${x}`), '');
  out.push(`App Store: ${SITE.appStoreUrl}`, `Google Play: ${SITE.playStoreUrl}`, '');
  for (const q of APP_FAQ) out.push(`Q: ${q.q}`, `A: ${q.a}`, '');
  for (const g of GAMES) {
    out.push(`## ${g.h1}`, `URL: ${SITE.url}/games/${g.slug}/`, '', g.intro, '', 'How to play:', ...g.howTo.map((s) => `- ${s}`), '');
    for (const f of [...g.faq, appFaqFor(g.slug)]) out.push(`Q: ${f.q}`, `A: ${f.a}`, '');
  }
  for (const e of guides) {
    const d = e.data;
    out.push(`## ${d.title}`, `URL: ${SITE.url}/${e.id}/`, `Updated: ${d.updated.toISOString().slice(0, 10)}`, '', d.summary, '');
    out.push(...d.keyPoints.map((k) => `- ${k}`), '');
    for (const f of d.faq) out.push(`Q: ${f.q}`, `A: ${f.a}`, '');
    out.push('Sources:', ...d.sources.map((s) => `- ${s.title} (${s.publisher}): ${s.url}`), '');
    if (d.health) out.push('Note: general information, not medical advice. Talk with a doctor.', '');
  }
  return new Response(out.join('\n'), { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
};
