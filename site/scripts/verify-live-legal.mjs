#!/usr/bin/env node
// Checks that the deployed legal pages answer over HTTPS with the expected
// heading and canonical link. Run after a deploy: `pnpm check:live`.
// This is availability QA, not legal approval or a native-app privacy audit.
const site = new URL(process.env.SITE_URL ?? 'https://dementiaactivities.games/');
if (site.protocol !== 'https:') throw new Error('Published site must use HTTPS');

const routes = new Map([
  ['app-privacy/', 'Mobile App Privacy Policy'],
  ['privacy-choices/', 'Privacy Choices and Deletion'],
  ['terms/', 'Terms of Use and App License'],
  ['safety/', 'Safety and Intended Use'],
  ['support/', 'Support'],
  ['help/', 'Help with the Golden Moments App'],
  ['privacy/', 'Privacy'],
  ['legal/', 'Legal and Privacy Information'],
]);
const pause = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function inspect([relativePath, heading]) {
  const url = new URL(relativePath, site);
  const response = await fetch(url, {
    redirect: 'follow',
    signal: AbortSignal.timeout(10000),
    headers: { 'Cache-Control': 'no-cache' },
  });
  const html = await response.text();
  if (!response.ok) throw new Error(`${relativePath}: HTTP ${response.status}`);
  if (response.url !== url.href) throw new Error(`${relativePath}: unexpected redirect to ${response.url}`);
  const h1 = html.match(/<h1\b[^>]*>([\s\S]*?)<\/h1>/i)?.[1]?.replace(/<[^>]*>/g, '').replace(/&amp;/g, '&').trim();
  if (h1 !== heading) throw new Error(`${relativePath}: expected heading "${heading}", received "${h1}"`);
  if (!html.includes(`<link rel="canonical" href="${url.href}"`)) throw new Error(`${relativePath}: canonical URL missing or wrong`);
}

let failures = [];
for (let attempt = 1; attempt <= 5; attempt++) {
  const settled = await Promise.allSettled([...routes].map(inspect));
  failures = settled.filter((item) => item.status === 'rejected').map((item) => String(item.reason));
  if (failures.length === 0) {
    console.log(`${routes.size} live HTTPS legal pages verified:`);
    for (const route of routes.keys()) console.log(`  ${new URL(route, site).href}`);
    process.exit(0);
  }
  console.warn(`Attempt ${attempt}/5: ${failures.join('; ')}`);
  if (attempt < 5) await pause(4000);
}
console.error(`Legal page check failed:\n${failures.join('\n')}`);
process.exit(1);
