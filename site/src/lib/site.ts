/** Site-wide facts. Change them here, never inline in pages. */
export const SITE = {
  url: 'https://dementiaactivities.games',
  domain: 'dementiaactivities.games',
  name: 'Golden Moments',
  titleSuffix: ' | Golden Moments',
  homeTitle: "Dementia & Alzheimer's Games and Activities | Golden Moments",
  description:
    "Free, gentle picture games to play online and activity ideas for people living with dementia or Alzheimer's and their caregivers. No sign-up, timers or scores.",
  locale: 'en_US',
  /** Live US listing, read back from App Store Connect on 2026-10-21. */
  appStoreUrl: 'https://apps.apple.com/us/app/dementia-games-golden-moments/id6749312459',
  /** Production listing for the Android package com.mindfulness.golden_moments. */
  playStoreUrl: 'https://play.google.com/store/apps/details?id=com.mindfulness.golden_moments',
  /** Public contact for the website, chosen by the maintainer on 2026-10-25. */
  supportEmail: 'web@dementiaactivities.games',
  /** Google Analytics 4 web stream, added by the maintainer on 2026-10-25. */
  gaMeasurementId: 'G-X4CNGM5F8Z',
  updated: '2026-10-25',
} as const;

export interface NavItem {
  href: string;
  /** Key in the `common.nav` dictionary. */
  key: 'games' | 'activities' | 'caregiving' | 'brainHealth';
}

export const NAV: readonly NavItem[] = [
  { href: '/games/', key: 'games' },
  { href: '/activities/', key: 'activities' },
  { href: '/caregiving/', key: 'caregiving' },
  { href: '/brain-health/', key: 'brainHealth' },
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
