// Tells IndexNow search engines (Bing and others; not Google) about every page in
// every live sitemap (one per language, listed in /sitemap.xml). Run after a deploy: `pnpm indexnow`. The key file in public/
// is meant to be public: it proves this site owns the submissions.
import { readdirSync } from 'node:fs';
import { indexNowBatches } from './indexnow-batches.mjs';

const SITE = 'https://dementiaactivities.games';
const keyFile = readdirSync(new URL('../public/', import.meta.url)).find((f) => /^[0-9a-f]{32}\.txt$/.test(f));
if (!keyFile) throw new Error('No IndexNow key file (32 hex characters + .txt) in public/');
const key = keyFile.slice(0, -4);

const index = await fetch(`${SITE}/sitemap.xml`);
if (!index.ok) throw new Error(`Could not fetch the live sitemap index: HTTP ${index.status}`);
const sitemaps = [...(await index.text()).matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]);
if (sitemaps.length === 0) throw new Error('The sitemap index lists no sitemaps');

const urlList = [];
for (const url of sitemaps) {
  const sitemap = await fetch(url);
  if (!sitemap.ok) throw new Error(`Could not fetch ${url}: HTTP ${sitemap.status}`);
  urlList.push(...[...(await sitemap.text()).matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]));
}

// One request per batch; a failed batch does not stop the rest, but fails the run.
const batches = indexNowBatches(urlList);
let failed = 0;
for (const [i, batch] of batches.entries()) {
  const res = await fetch('https://api.indexnow.org/indexnow', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({ host: new URL(SITE).host, key, keyLocation: `${SITE}/${keyFile}`, urlList: batch }),
  });
  console.log(`IndexNow batch ${i + 1}/${batches.length}: ${batch.length} URLs, HTTP ${res.status} ${res.statusText}`);
  if (!res.ok) {
    failed += 1;
    console.error(await res.text());
  }
}
console.log(`IndexNow: ${batches.flat().length} unique URLs in ${batches.length} requests, ${failed} failed`);
if (failed > 0) process.exit(1);
