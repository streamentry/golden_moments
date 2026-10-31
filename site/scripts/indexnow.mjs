// Tells IndexNow search engines (Bing and others; not Google) about every page in
// the live sitemap. Run after a deploy: `pnpm indexnow`. The key file in public/
// is meant to be public: it proves this site owns the submissions.
import { readdirSync } from 'node:fs';

const SITE = 'https://dementiaactivities.games';
const keyFile = readdirSync(new URL('../public/', import.meta.url)).find((f) => /^[0-9a-f]{32}\.txt$/.test(f));
if (!keyFile) throw new Error('No IndexNow key file (32 hex characters + .txt) in public/');
const key = keyFile.slice(0, -4);

const sitemap = await fetch(`${SITE}/sitemap.xml`);
if (!sitemap.ok) throw new Error(`Could not fetch the live sitemap: HTTP ${sitemap.status}`);
const urlList = [...(await sitemap.text()).matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]);

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
