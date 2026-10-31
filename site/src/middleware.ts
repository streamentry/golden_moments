import { defineMiddleware } from 'astro:middleware';
import { DEFAULT_LOCALE, href, splitLocale } from './i18n/locales';

/** Files served the same for every language. */
const ASSET = /^\/(?:pictures|og|fonts|icons|_astro)\/|^\/(?:favicon|manifest|sitemap|llms|robots)/;

/**
 * Keeps readers in their language: on a translated page, internal links
 * (including those inside translated Markdown) point to the same language.
 * Links that name a language with `hreflang` (the language menu, "read the
 * original"), assets and English-only pages are left alone.
 */
export const onRequest = defineMiddleware(async (context, next) => {
  const response = await next();
  const { code } = splitLocale(context.url.pathname);
  const type = response.headers.get('content-type') ?? '';
  if (code === DEFAULT_LOCALE || !type.includes('text/html')) return response;
  const html = await response.text();
  const localized = html.replace(/<a\b[^>]*>/g, (tag) => {
    if (/\shreflang=/.test(tag)) return tag;
    return tag.replace(/\shref="(\/[^"]*)"/, (attr, path: string) => {
      if (ASSET.test(path) || splitLocale(path).code !== DEFAULT_LOCALE) return attr;
      return ` href="${href(code, path)}"`;
    });
  });
  return new Response(localized, { status: response.status, headers: response.headers });
});
