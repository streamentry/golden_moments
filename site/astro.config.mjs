// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import { readdirSync, readFileSync } from 'node:fs';

export const SITE_URL = 'https://dementiaactivities.games';

/** Each guide's frontmatter `updated` date, keyed by URL path, for the sitemap's <lastmod>. */
function guideDates() {
  const base = new URL('./src/content/guides/', import.meta.url);
  const dates = new Map();
  for (const section of readdirSync(base, { withFileTypes: true }).filter((d) => d.isDirectory())) {
    for (const file of readdirSync(new URL(`${section.name}/`, base)).filter((f) => f.endsWith('.md'))) {
      const text = readFileSync(new URL(`${section.name}/${file}`, base), 'utf8');
      const updated = text.match(/^updated:\s*(\d{4}-\d{2}-\d{2})/m);
      if (updated) dates.set(`/${section.name}/${file.slice(0, -3)}/`, updated[1]);
    }
  }
  return dates;
}

const GUIDE_DATES = guideDates();

export default defineConfig({
  site: SITE_URL,
  trailingSlash: 'always',
  build: { format: 'directory', inlineStylesheets: 'auto' },
  // Hash-based meta CSP; the only outside script is the Google tag loader.
  security: {
    csp: { scriptDirective: { resources: ["'self'", 'https://www.googletagmanager.com'] } },
  },
  // No code blocks on this site; Shiki's inline styles would conflict with the CSP.
  markdown: { syntaxHighlight: false },
  integrations: [
    react(),
    sitemap({
      filter: (page) => !page.endsWith('/404/'),
      changefreq: 'weekly',
      // Only guides carry a real edit date; other pages get no <lastmod> rather than a made-up one.
      serialize: (item) => {
        const lastmod = GUIDE_DATES.get(new URL(item.url).pathname);
        return lastmod ? { ...item, lastmod } : item;
      },
    }),
  ],
});
