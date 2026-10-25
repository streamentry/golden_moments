#!/usr/bin/env node
// Post-build checks for dist/: SEO metadata, structured data, internal links,
// image alt text and claims wording. Exits 1 on any error.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const DIST = new URL('../dist/', import.meta.url).pathname;
const SITE = 'https://dementiaactivities.games';

/** Phrases that would make a medical or performance claim. Matched case-insensitively. */
const BANNED = [
  /\b(?:prevents?|cures?|reverses?|treats?) (?:dementia|alzheimer)/i,
  /\bbrain age\b/i,
  /\btrain your brain\b/i,
  /\bclinically proven\b/i,
  /\bboost(?:s)? (?:your )?(?:memory|brain)/i,
  /\bsharpen(?:s)? (?:your )?(?:memory|mind|brain)/i,
  /\bimproves? (?:your )?memory\b/i,
  /\bdementia sufferers?\b/i,
];
/** Context that makes a banned phrase acceptable (it is being denied or quoted as a question). */
const ALLOWED_CONTEXT = /\b(no|none|unproven|not|never|nor|don[’']t|doesn[’']t|does not|cannot|can[’']t|without|claim|claims|claimed|claiming|unsupported|deceptive|whether|if|ftc|lumosity|marketing|be wary|be cautious|beware|watch out|promise|promises|promising)\b|\?/i;

const errors = [];
const warnings = [];
const err = (file, msg) => errors.push(`${file}: ${msg}`);
const warn = (file, msg) => warnings.push(`${file}: ${msg}`);

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const p = join(dir, name);
    return statSync(p).isDirectory() ? walk(p) : [p];
  });
}

const files = walk(DIST);
const htmlFiles = files.filter((f) => f.endsWith('.html'));

function pathFor(file) {
  const rel = '/' + relative(DIST, file).replace(/index\.html$/, '');
  return rel;
}

function resolves(href) {
  const clean = decodeURI(href.split('#')[0].split('?')[0]);
  if (clean === '' || clean === '/') return existsSync(join(DIST, 'index.html'));
  const target = join(DIST, clean);
  if (clean.endsWith('/')) return existsSync(join(target, 'index.html'));
  return existsSync(target);
}

function attr(tag, name) {
  const m = tag.match(new RegExp(`\\s${name}="([^"]*)"`, 'i'));
  return m ? m[1] : null;
}

function text(html) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&[a-z#0-9]+;/gi, ' ')
    .replace(/\s+/g, ' ');
}

const titles = new Map();
const descriptions = new Map();
const indexable = [];

for (const file of htmlFiles) {
  const rel = relative(DIST, file);
  const html = readFileSync(file, 'utf8');
  const path = pathFor(file);
  const is404 = rel === '404.html';

  const title = html.match(/<title>([^<]*)<\/title>/)?.[1] ?? '';
  if (!title) err(rel, 'missing <title>');
  if (title.length > 70) warn(rel, `title is ${title.length} chars: "${title}"`);
  if (!is404) titles.set(title, [...(titles.get(title) ?? []), rel]);

  const desc = html.match(/<meta name="description" content="([^"]*)"/)?.[1] ?? '';
  if (desc.length < 70 || desc.length > 170) err(rel, `meta description is ${desc.length} chars`);
  if (!is404) descriptions.set(desc, [...(descriptions.get(desc) ?? []), rel]);

  const h1s = html.match(/<h1[\s>]/g) ?? [];
  if (h1s.length !== 1) err(rel, `has ${h1s.length} <h1> elements`);

  const canonical = html.match(/<link rel="canonical" href="([^"]*)"/)?.[1];
  if (!is404) {
    if (canonical !== `${SITE}${path}`) err(rel, `canonical ${canonical} should be ${SITE}${path}`);
    if (!/noindex/.test(html)) indexable.push(`${SITE}${path}`);
  }

  const og = html.match(/<meta property="og:image" content="([^"]*)"/)?.[1];
  if (!og) err(rel, 'missing og:image');
  else if (!resolves(og.replace(SITE, ''))) err(rel, `og:image not found: ${og}`);

  for (const m of html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)) {
    try {
      const data = JSON.parse(m[1]);
      if (!data['@context'] || !data['@graph']) err(rel, 'JSON-LD missing @context or @graph');
    } catch (e) {
      err(rel, `JSON-LD does not parse: ${e.message}`);
    }
  }

  if (!/<html lang="en-US">/.test(html)) err(rel, 'missing lang attribute');
  // The CSP only allows hashed <style> blocks, so a style attribute would be blocked.
  if (/\sstyle="/.test(html)) err(rel, 'inline style attribute (blocked by the CSP); use a class');

  for (const m of html.matchAll(/<a\s[^>]*>/g)) {
    const href = attr(m[0], 'href');
    if (!href || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) continue;
    if (/^https?:\/\//.test(href)) {
      if (href.startsWith(SITE)) err(rel, `absolute internal link ${href}; use a relative path`);
      continue;
    }
    if (!href.startsWith('/')) {
      err(rel, `relative link without leading slash: ${href}`);
      continue;
    }
    const bare = href.split('#')[0];
    if (!bare.endsWith('/') && !/\.[a-z0-9]+$/i.test(bare)) err(rel, `internal link without trailing slash: ${href}`);
    if (!resolves(href)) err(rel, `broken internal link: ${href}`);
  }

  for (const m of html.matchAll(/<img\s[^>]*>/g)) {
    if (attr(m[0], 'alt') === null) err(rel, `image without alt: ${m[0].slice(0, 80)}`);
    const src = attr(m[0], 'src');
    if (src?.startsWith('/') && !resolves(src)) err(rel, `missing image ${src}`);
  }

  const body = text(html);
  for (const re of BANNED) {
    for (const m of body.matchAll(new RegExp(re.source, 'gi'))) {
      const start = Math.max(0, m.index - 90);
      const context = body.slice(start, m.index + m[0].length + 40);
      if (!ALLOWED_CONTEXT.test(context)) err(rel, `claims wording "${m[0]}" in: …${context.trim()}…`);
    }
  }
}

for (const [title, pages] of titles) if (pages.length > 1) err(pages.join(', '), `duplicate title "${title}"`);
for (const [desc, pages] of descriptions) if (pages.length > 1) err(pages.join(', '), `duplicate description`);

const sitemapFiles = files.filter((f) => /sitemap-\d+\.xml$/.test(f));
const sitemap = sitemapFiles.map((f) => readFileSync(f, 'utf8')).join('\n');
for (const url of indexable) if (!sitemap.includes(`<loc>${url}</loc>`)) err('sitemap', `missing ${url}`);

for (const required of ['robots.txt', 'llms.txt', 'llms-full.txt', 'manifest.webmanifest', '_headers', 'favicon.svg', 'favicon.ico']) {
  if (!existsSync(join(DIST, required))) err('dist', `missing ${required}`);
}

for (const w of warnings) console.warn(`warn  ${w}`);
for (const e of errors) console.error(`error ${e}`);
console.log(`Checked ${htmlFiles.length} pages: ${errors.length} errors, ${warnings.length} warnings.`);
process.exit(errors.length ? 1 : 0);
