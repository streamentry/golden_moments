import { SITE, absoluteUrl } from './site';
import type { FaqItem } from './schema';
import { localePath } from '../i18n/locales';
import { fill, ui } from '../i18n/ui';

/**
 * Facts about the Golden Moments mobile app, written once (in the `appFacts`
 * dictionary) so the app page, structured data, llms.txt and game pages say
 * the same thing in every language. Keep them in step with
 * metadata/app-store.en-US.json and only describe released features.
 */
export const STORE_NAME = 'Dementia Games: Golden Moments';

export interface AppFacts {
  storeName: string;
  platforms: string;
  requirements: string;
  summary: string;
  features: readonly string[];
}

export function appFacts(lang = 'en'): AppFacts {
  const t = ui(lang).appFacts;
  return { storeName: STORE_NAME, platforms: t.platforms, requirements: t.requirements, summary: t.summary, features: t.features };
}

export function appFaq(lang = 'en'): FaqItem[] {
  const t = ui(lang).appFacts;
  return t.faq.map((f) => ({
    q: f.q,
    a: fill(f.a, { storeName: STORE_NAME, platforms: t.platforms, requirements: t.requirements }),
  }));
}

/** English facts, for callers that are not yet language-aware. */
export const APP = appFacts('en');
export const APP_FAQ: readonly FaqItem[] = appFaq('en');

/** Games whose activity is in the app as well as on the website. */
const IN_APP = new Set(['picture-pairs', 'photo-pairs']);

/** One honest answer per game page about the app. */
export function appFaqFor(slug: string, lang = 'en'): FaqItem {
  const t = ui(lang).appFacts;
  return IN_APP.has(slug) ? t.gameFaqYes : t.gameFaqNo;
}

/** schema.org MobileApplication for the app page. */
export function mobileApplication(lang = 'en'): Record<string, unknown> {
  const facts = appFacts(lang);
  return {
    '@type': 'MobileApplication',
    name: facts.storeName,
    alternateName: 'Golden Moments',
    description: facts.summary,
    operatingSystem: facts.requirements,
    applicationCategory: 'GameApplication',
    applicationSubCategory: 'Puzzle',
    featureList: [...facts.features],
    isAccessibleForFree: true,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    installUrl: SITE.appStoreUrl,
    downloadUrl: [SITE.appStoreUrl, SITE.playStoreUrl],
    url: absoluteUrl(localePath(lang, '/app/')),
    image: absoluteUrl('/icons/icon-512.png'),
    publisher: { '@type': 'Organization', name: 'Cloudjet Solutions Pte. Ltd.' },
    sameAs: [SITE.appStoreUrl, SITE.playStoreUrl],
  };
}
