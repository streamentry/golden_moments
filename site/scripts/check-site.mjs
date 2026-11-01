#!/usr/bin/env node
// Post-build checks for dist/: SEO metadata, structured data, internal links,
// image alt text and claims wording. Exits 1 on any error.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const DIST = new URL('../dist/', import.meta.url).pathname;
const SITE = 'https://dementiaactivities.games';
/** Display width: Chinese, Japanese and Korean characters count double and combining marks
    (Devanagari and Thai vowel signs, accents) count nothing, as in search results. */
const width = (s) => [...s].reduce((n, ch) => n + (/\p{M}/u.test(ch) ? 0 : /[\u1100-\u115f\u2e80-\ua4cf\uac00-\ud7a3\uf900-\ufaff\ufe30-\ufe4f\uff00-\uff60\uffe0-\uffe6]/.test(ch) ? 2 : 1), 0);
/** URL prefixes of translated languages; keep in step with src/i18n/locales.ts. */
// Languages written right to left; the checker expects dir="rtl" on exactly these.
const RTL_PREFIXES = new Set(['ar', 'fa', 'ur']);
// The language prefix at the start of a path (`vi`, `fil`, `zh-hans`), or undefined. Only registered
// prefixes count, so /app/ and /faq/ are never mistaken for languages.
const prefixIn = (path) => {
  const found = path.match(/^\/?([a-z]{2,3}(?:-[a-z]{2,4})?)\//)?.[1];
  return found && LOCALE_PREFIXES.has(found) ? found : undefined;
};
const LOCALE_PREFIXES = new Set(['es', 'pt-br', 'fr', 'de', 'it', 'nl', 'pl', 'ru', 'uk', 'tr', 'ar', 'hi', 'ja', 'ko', 'zh-hans', 'zh-hant', 'vi', 'id', 'th', 'bn', 'fa', 'ha', 'ur', 'mr', 'te', 'ta', 'gu', 'pa', 'fil', 'ro', 'ms', 'sw']);

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

// Photo pairs handles family photos, so every language copy must load no
// analytics and carry the strict second Content-Security-Policy from _headers.
// _headers rules use :placeholders (one path segment) and * (anything).
const headerRules = existsSync(join(DIST, '_headers'))
  ? readFileSync(join(DIST, '_headers'), 'utf8')
      .split(/\n\s*\n/)
      .map((block) => block.split('\n').filter((l) => l.trim() && !l.trim().startsWith('#')))
      .filter((lines) => lines.length && lines[0].startsWith('/'))
      .map(([route, ...rest]) => ({
        pattern: new RegExp(`^${route.trim().replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/:\w+/g, '[^/]+').replace(/\*/g, '.*')}$`),
        headers: rest.join('\n'),
      }))
  : [];
const strictPolicy = (urlPath) =>
  headerRules.some((r) => r.pattern.test(urlPath) && /connect-src 'self';/.test(r.headers) && !/google/.test(r.headers));

// Words a translation must not use for people living with dementia ("patients"):
// errors where a language has been cleaned, warnings where it has not.
const PATIENT_WORDS = {
  ar: { re: /مرضى/, fail: true },
  vi: { re: /người bệnh|bệnh nhân/, fail: true },
  th: { re: /ผู้ป่วย/, fail: true },
  'zh-hans': { re: /患者|病人/, fail: true },
  'zh-hant': { re: /患者|病人/, fail: false },
  ja: { re: /患者/, fail: false },
  ko: { re: /환자/, fail: false },
  hi: { re: /मरीज/, fail: false },
  ru: { re: /пациент/i, fail: false },
  uk: { re: /пацієнт/i, fail: false },
};

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
const noindexed = [];

for (const file of htmlFiles) {
  const rel = relative(DIST, file);
  const html = readFileSync(file, 'utf8');
  const path = pathFor(file);
  const is404 = rel === '404.html';

  const title = html.match(/<title>([^<]*)<\/title>/)?.[1] ?? '';
  if (!title) err(rel, 'missing <title>');
  if (width(title) > 70) warn(rel, `title is ${width(title)} chars wide: "${title}"`);
  // Duplicates matter within one language; the same words in two languages are fine.
  const langKey = (prefixIn(rel) ?? '') + '|';
  if (!is404) titles.set(langKey + title, [...(titles.get(langKey + title) ?? []), rel]);

  const desc = html.match(/<meta name="description" content="([^"]*)"/)?.[1] ?? '';
  if (width(desc) < 70 || width(desc) > 170) err(rel, `meta description is ${width(desc)} chars wide`);
  if (!is404) descriptions.set(langKey + desc, [...(descriptions.get(langKey + desc) ?? []), rel]);

  const h1s = html.match(/<h1[\s>]/g) ?? [];
  if (h1s.length !== 1) err(rel, `has ${h1s.length} <h1> elements`);

  const canonical = html.match(/<link rel="canonical" href="([^"]*)"/)?.[1];
  if (!is404) {
    if (canonical !== `${SITE}${path}`) err(rel, `canonical ${canonical} should be ${SITE}${path}`);
    if (!/noindex/.test(html)) indexable.push(`${SITE}${path}`);
    else noindexed.push(`${SITE}${path}`);
    // A page that asks not to be indexed must not advertise language alternates.
    if (/noindex/.test(html) && /rel="alternate" hreflang=/.test(html)) err(rel, 'noindex page lists hreflang alternates');

    if (/(^|\/)games\/photo-pairs\/$/.test(path)) {
      if (/googletagmanager\.com\/gtag\/js/.test(html)) err(rel, 'Photo pairs loads Google Analytics');
      if (!strictPolicy(path)) err(rel, 'Photo pairs has no strict Content-Security-Policy rule in _headers');
    }

    const prefix = prefixIn(path);
    const patient = prefix && PATIENT_WORDS[prefix];
    if (patient && patient.re.test(text(html))) (patient.fail ? err : warn)(rel, 'uses "patients" wording for people living with dementia');
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

  const htmlTag = html.match(/<html lang="([^"]+)" dir="(ltr|rtl)">/);
  const prefix = prefixIn(rel);
  const translated = prefix && prefix.length >= 2 && LOCALE_PREFIXES.has(prefix);
  if (!htmlTag) err(rel, 'missing lang or dir attribute');
  else if (!translated && htmlTag[1] !== 'en-US') err(rel, `English page has lang="${htmlTag[1]}"`);
  else if (translated && htmlTag[1].toLowerCase() !== prefix) err(rel, `lang="${htmlTag[1]}" does not match /${prefix}/`);
  else if ((htmlTag[2] === 'rtl') !== RTL_PREFIXES.has(prefix)) err(rel, `dir="${htmlTag[2]}" is wrong for this language`);
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

for (const [key, pages] of titles) if (pages.length > 1) err(pages.join(', '), `duplicate title "${key.split('|').slice(1).join('|')}"`);
for (const [desc, pages] of descriptions) if (pages.length > 1) err(pages.join(', '), `duplicate description`);

// One sitemap per language, all listed by the index at /sitemap.xml:
// /sitemap-en.xml for English, /<prefix>/sitemap.xml for the rest.
const sitemapName = (prefix) => (prefix ? `${prefix}/sitemap.xml` : 'sitemap-en.xml');
const readDist = (name) => (existsSync(join(DIST, name)) ? readFileSync(join(DIST, name), 'utf8') : '');
const prefixOf = (url) => prefixIn(url.replace(SITE, ''));
const owner = (url) => {
  const prefix = prefixOf(url);
  return LOCALE_PREFIXES.has(prefix) ? prefix : '';
};
const langSitemaps = new Map(['', ...LOCALE_PREFIXES].map((prefix) => [prefix, readDist(sitemapName(prefix))]));
for (const [prefix, xml] of langSitemaps) {
  const name = sitemapName(prefix);
  if (!xml) err(name, 'missing');
  for (const m of xml.matchAll(/<loc>([^<]+)<\/loc>/g)) {
    if (owner(m[1]) !== prefix) err(name, `lists a page from another language: ${m[1]}`);
    if (!resolves(m[1].replace(SITE, ''))) err(name, `lists a page that does not exist: ${m[1]}`);
  }
}
for (const url of indexable) {
  const prefix = owner(url);
  if (!langSitemaps.get(prefix)?.includes(`<loc>${url}</loc>`)) err(sitemapName(prefix), `missing ${url}`);
}
for (const url of noindexed) {
  if ([...langSitemaps.values()].some((xml) => xml.includes(`<loc>${url}</loc>`))) err('sitemap', `lists a noindex page: ${url}`);
}
const sitemapIndex = readDist('sitemap.xml');
for (const [prefix, xml] of langSitemaps) {
  if (!xml.includes('<loc>')) continue; // a language held from the index has an empty sitemap, not listed
  if (!sitemapIndex.includes(`<loc>${SITE}/${sitemapName(prefix)}</loc>`)) err('sitemap.xml', `index does not list ${sitemapName(prefix)}`);
}
if (!readDist('robots.txt').includes(`Sitemap: ${SITE}/sitemap.xml`)) err('robots.txt', 'does not list /sitemap.xml');

for (const required of ['sitemap.xml', 'sitemap-en.xml', 'vi/sitemap.xml', 'robots.txt', 'llms.txt', 'llms-full.txt', 'manifest.webmanifest', '_headers', 'favicon.svg', 'favicon.ico']) {
  if (!existsSync(join(DIST, required))) err('dist', `missing ${required}`);
}

// Legal pages linked from the app and both store listings (moved here from
// streamentry/golden-moments-web). Their paths are public contracts; the
// phrases keep the app license, consumer rights and deletion facts in place.
const LEGAL_PAGES = {
  'app-privacy/': ['Cloudjet Solutions Pte. Ltd.', 'Remove all photo copies', 'device backup', 'Firebase', '/privacy-choices/', '/privacy/'],
  'privacy-choices/': ['Remove this copy', 'Remove all photo copies', 'Offload App', 'Delete App', 'does not automatically delete'],
  'privacy/': ['Cloudflare', 'IP address', 'email address', '/app-privacy/'],
  'terms/': [
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
    'does not replace or amend Apple',
    'Nothing on this page excludes a consumer right',
  ],
  'safety/': ['not intended for medical diagnosis', 'Stop, take a break, or change activities', 'local emergency number', 'not a measure of their intelligence'],
  'support/': ['/privacy-choices/', 'Avoid deleting or reinstalling'],
  'help/': ['Start a gentle game', 'Your family photos', 'Remove this copy'],
  'legal/': ['/app-privacy/', '/privacy-choices/', '/terms/', '/safety/', '/support/'],
};
const LEGAL_BANNED = /We collect no data|No data is ever shared|HIPAA|100% secure|guaranteed deletion|binding arbitration|waive your rights|FDA[ -](?:approved|cleared)|\[COMPANY\]|\[DATE\]|TODO:/i;
for (const [page, phrases] of Object.entries(LEGAL_PAGES)) {
  const file = join(DIST, page, 'index.html');
  if (!existsSync(file)) {
    err(page, 'legal page is missing');
    continue;
  }
  const html = readFileSync(file, 'utf8').replace(/&#39;|&rsquo;|’/g, "'");
  for (const phrase of phrases) if (!html.includes(phrase.replace(/’/g, "'"))) err(page, `legal page lost "${phrase}"`);
  const banned = text(html).match(LEGAL_BANNED);
  if (banned) err(page, `legal page says "${banned[0]}"`);
}

for (const w of warnings) console.warn(`warn  ${w}`);
for (const e of errors) console.error(`error ${e}`);
console.log(`Checked ${htmlFiles.length} pages: ${errors.length} errors, ${warnings.length} warnings.`);
process.exit(errors.length ? 1 : 0);
