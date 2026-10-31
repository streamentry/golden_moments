import { defineMiddleware } from 'astro:middleware';
import { DEFAULT_LOCALE, localePath, splitLocale } from './i18n/locales';
import { pathsIn } from './i18n/pages';

/** Files served the same for every language. */
const ASSET = /^\/(?:pictures|og|fonts|icons|_astro)\/|^\/(?:favicon|manifest|sitemap|llms|robots)/;

/**
 * Keeps readers in their language: on a translated page, internal links
 * (including those inside translated Markdown) point to the same page in that
 * language when it exists, and to English when it does not. Links that name
 * a language with `hreflang` (the language menu, "read the original") and
 * assets are left alone.
 */
export const onRequest = defineMiddleware(async (context, next) => {
  const response = await next();
  const { code } = splitLocale(context.url.pathname);
  const type = response.headers.get('content-type') ?? '';
  if (code === DEFAULT_LOCALE || !type.includes('text/html')) return response;
  const html = await response.text();
  const existing = await pathsIn(code);
  const localized = html.replace(/<a\b[^>]*>/g, (tag) => {
    if (/\shreflang=/.test(tag)) return tag;
    return tag.replace(/\shref="(\/[^"]*)"/, (attr, target: string) => {
      if (ASSET.test(target)) return attr;
      const [pathPart, rest = ''] = target.split(/(?=[#?])/);
      const { code: linkCode, path } = splitLocale(pathPart as string);
      if (linkCode !== DEFAULT_LOCALE && linkCode !== code) return attr;
      const next = existing.has(path) ? localePath(code, path) : path;
      return ` href="${next}${rest}"`;
    });
  });
  return new Response(localized, { status: response.status, headers: response.headers });
});
