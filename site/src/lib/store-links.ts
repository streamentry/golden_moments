import { SITE } from './site';

/** Where on the website an install link sits; shows up as `utm_medium` in Play Console. */
export type StorePlacement = 'home' |'game' | 'game-aside' | 'guide' | 'section' | 'app-page';

/**
 * The Google Play listing tagged with Play's install referrer, so Play Console's
 * acquisition reports can separate installs that came from this website. Nothing
 * is sent from the site itself. The App Store link stays plain: Apple only
 * reports a campaign (`ct`) together with a provider token (`pt`), which we have
 * not created yet.
 */
export function playStoreUrl(placement: StorePlacement): string {
  const referrer = `utm_source=website&utm_medium=${placement}`;
  return `${SITE.playStoreUrl}&referrer=${encodeURIComponent(referrer)}`;
}
