// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';

export const SITE_URL = 'https://dementiaactivities.games';

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
  ],
});
