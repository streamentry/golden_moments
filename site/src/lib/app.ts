import { SITE, absoluteUrl } from './site';
import type { FaqItem } from './schema';

/**
 * Facts about the Golden Moments mobile app, written once so the app page,
 * structured data, llms.txt and game pages say the same thing. Keep them in
 * step with metadata/app-store.en-US.json and only describe released features.
 */
export const APP = {
  storeName: 'Dementia Games: Golden Moments',
  platforms: 'iPhone, iPad and Android',
  requirements: 'iOS 15 or later; Android 7.0 or later',
  summary:
    'A free app for iPhone, iPad and Android with gentle picture matching on four to twelve large tiles, ' +
    'matching and viewing with family photos you choose, and eight included picture packs that work without ' +
    'internet. No account, ads, timer or score.',
  features: [
    'Gentle picture matching with 4, 6, 8 or 12 large tiles; pictures stay visible unless you choose to hide them',
    'Family photos you select are copied into the app for matching and for looking at together',
    'Look together: one picture at a time with optional conversation prompts',
    'Eight picture packs included with the app; they work offline',
    'No account, ads, in-app purchases, timer, score or penalty',
  ],
} as const;

export const APP_FAQ: readonly FaqItem[] = [
  {
    q: 'Is there a dementia activities app?',
    a: `Yes. Golden Moments (listed as "${APP.storeName}") is free on the App Store and Google Play. It offers gentle picture matching with large tiles, games with family photos you choose, and picture packs that work offline.`,
  },
  {
    q: 'Is the Golden Moments app free?',
    a: 'Yes. It is free to download, with no ads, account or in-app purchases.',
  },
  {
    q: 'Does the app work without internet?',
    a: 'Yes. The starter pictures and all eight picture packs are included with the app, and family photos work offline once they are copied into the app. Choosing a photo stored only in iCloud may need a connection.',
  },
  {
    q: 'Can I use our own family photos?',
    a: 'Yes. Choose photos with your device’s photo picker. The app keeps smaller copies on the device for its activities, does not upload them and never changes the originals. You can remove the copies at any time.',
  },
  {
    q: 'Is it a brain-training or memory-test app?',
    a: 'No. Golden Moments is for enjoyment and time together. It has no scores or tests, and it does not diagnose, treat, prevent or measure dementia or Alzheimer’s disease.',
  },
  {
    q: 'Which devices does it work on?',
    a: `${APP.platforms}: ${APP.requirements}.`,
  },
];

/** Games whose activity is in the app as well as on the website. */
const IN_APP = new Set(['picture-pairs', 'photo-pairs']);

/** One honest answer per game page about the app. */
export function appFaqFor(slug: string): FaqItem {
  return IN_APP.has(slug)
    ? {
        q: 'Is there an app version of this game?',
        a: 'Yes. The free Golden Moments app for iPhone, iPad and Android has the same gentle picture matching, can use family photos you choose, and works offline. No account, ads or score.',
      }
    : {
        q: 'Is there an app version of this game?',
        a: 'Not of this game. The free Golden Moments app for iPhone, iPad and Android has gentle picture matching with large tiles and family photos you choose, and it works offline. This game stays free here in your browser.',
      };
}

/** schema.org MobileApplication for the app page. */
export function mobileApplication(): Record<string, unknown> {
  return {
    '@type': 'MobileApplication',
    name: APP.storeName,
    alternateName: 'Golden Moments',
    description: APP.summary,
    operatingSystem: APP.requirements,
    applicationCategory: 'GameApplication',
    applicationSubCategory: 'Puzzle',
    featureList: [...APP.features],
    isAccessibleForFree: true,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    installUrl: SITE.appStoreUrl,
    downloadUrl: [SITE.appStoreUrl, SITE.playStoreUrl],
    url: absoluteUrl('/app/'),
    image: absoluteUrl('/icons/icon-512.png'),
    publisher: { '@type': 'Organization', name: 'Cloudjet Solutions Pte. Ltd.' },
    sameAs: [SITE.appStoreUrl, SITE.playStoreUrl],
  };
}
