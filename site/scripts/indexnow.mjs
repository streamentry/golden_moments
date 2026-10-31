// Tells IndexNow search engines (Bing and others; not Google) about every page in
// every live sitemap (one per language, listed in robots.txt). Run after a deploy: `pnpm indexnow`. The key file in public/
// is meant to be public: it proves this site owns the submissions.
import { readdirSync } from 'node:fs';

const SITE = 'https://dementiaactivities.games';
const keyFile = readdirSync(new URL('../public/', import.meta.url)).find((f) => /^[0-9a-f]{32}\.txt$/.test(f));
if (!keyFile) throw new Error('No IndexNow key file (32 hex characters + .txt) in public/');
const key = keyFile.slice(0, -4);

const robots = await fetch(`${SITE}/robots.txt`);
if (!robots.ok) throw new Error(`Could not fetch the live robots.txt: HTTP ${robots.status}`);
const sitemaps = [...(await robots.text()).matchAll(/^Sitemap:\s*(\S+\/sitemap\.xml)\s*$/gim)].map((m) => m[1]);
if (sitemaps.length === 0) throw new Error('robots.txt lists no per-language sitemaps');

const urlList = [];
for (const url of sitemaps) {
  const sitemap = await fetch(url);
  if (!sitemap.ok) throw new Error(`Could not fetch ${url}: HTTP ${sitemap.status}`);
  urlList.push(...[...(await sitemap.text()).matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]));
}

const res = await fetch('https://api.indexnow.org/indexnow', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json; charset=utf-8' },
  body: JSON.stringify({ host: new URL(SITE).host, key, keyLocation: `${SITE}/${keyFile}`, urlList }),
});
console.log(`IndexNow: submitted ${urlList.length} URLs, HTTP ${res.status} ${res.statusText}`);
if (!res.ok) {
  console.error(await res.text());
  process.exit(1);
}
