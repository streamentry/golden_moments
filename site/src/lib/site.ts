/** Site-wide facts. Change them here, never inline in pages. */
export const SITE = {
  url: 'https://dementiaactivities.games',
  domain: 'dementiaactivities.games',
  name: 'Golden Moments',
  titleSuffix: ' | Golden Moments',
  homeTitle: 'Dementia Games & Activities Online | Golden Moments',
  description:
    'Free, gentle picture games and activity ideas for people living with dementia and the people who care for them. No sign-up, no timers, no scores.',
  locale: 'en_US',
  /** Live US listing, read back from App Store Connect on 2026-10-21. */
  appStoreUrl: 'https://apps.apple.com/us/app/dementia-games-golden-moments/id6749312459',
  /** Production listing for the Android package com.mindfulness.golden_moments. */
  playStoreUrl: 'https://play.google.com/store/apps/details?id=com.mindfulness.golden_moments',
  appPrivacyUrl: 'https://streamentry.github.io/golden-moments-web/app-privacy/',
  /** Support address published in the mobile app's Help page. */
  supportEmail: 'apple@locuno.com',
  updated: '2026-10-25',
} as const;

export interface NavItem {
  href: string;
  label: string;
}

export const NAV: readonly NavItem[] = [
  { href: '/games/', label: 'Games' },
  { href: '/activities/', label: 'Activities' },
  { href: '/caregiving/', label: 'Caregiving' },
  { href: '/brain-health/', label: 'Brain health' },
];

export const SECTION_META = {
  activities: {
    label: 'Activities',
    href: '/activities/',
    title: 'Activities for People with Dementia',
  },
  caregiving: {
    label: 'Caregiving',
    href: '/caregiving/',
    title: 'Caregiving Guides',
  },
  'brain-health': {
    label: 'Brain health',
    href: '/brain-health/',
    title: 'Brain Health: What the Research Says',
  },
} as const;

export type SectionKey = keyof typeof SECTION_META;

export function absoluteUrl(path: string): string {
  return new URL(path, SITE.url).toString();
}
