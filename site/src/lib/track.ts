/**
 * Activity events for the site's existing Google Analytics 4 tag
 * (components/Analytics.astro). They answer one question the page views
 * cannot: did a visit become a shared activity, and did it help?
 *
 * Only an event name and, for feedback, a fixed answer are sent. Never what
 * someone tapped, typed, drew or chose, and nothing about the person playing.
 * Where Analytics is not loaded (Photo pairs), every call does nothing.
 */
export type ActivityEvent =
  | 'activity_start'
  | 'activity_restart'
  | 'activity_done'
  | 'activity_print'
  | 'activity_feedback';

export type FeedbackAnswer = 'yes' | 'not_really';

interface GtagWindow {
  gtag?: (command: 'event', name: string, params?: Record<string, string>) => void;
}

const browser = (): GtagWindow => (typeof window === 'undefined' ? {} : (window as GtagWindow));

export function analyticsAvailable(w: GtagWindow = browser()): boolean {
  return typeof w.gtag === 'function';
}

/** Sends one activity event; returns whether it was handed to Analytics. */
export function track(event: ActivityEvent, params?: { answer: FeedbackAnswer }, w: GtagWindow = browser()): boolean {
  if (typeof w.gtag !== 'function') return false;
  w.gtag('event', event, params);
  return true;
}

/** Wraps a callback so only its first call runs: one start per page view. */
export function once(fn: () => void): () => boolean {
  let done = false;
  return () => {
    if (done) return false;
    done = true;
    fn();
    return true;
  };
}

interface SheetDocument {
  querySelector: (selector: string) => unknown;
}

/**
 * Counts a print only on games with a printable sheet. Other game pages print
 * blank (games.css hides the board), so their prints say nothing about use.
 */
export function trackPrint(doc: SheetDocument = document, w: GtagWindow = browser()): boolean {
  return doc.querySelector('.sheet') ? track('activity_print', undefined, w) : false;
}
