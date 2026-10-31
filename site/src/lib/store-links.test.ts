import { describe, expect, it } from 'vitest';
import { playStoreUrl } from './store-links';
import { SITE } from './site';

describe('playStoreUrl', () => {
  it('tags the Play link with the website and the place on the page', () => {
    const url = new URL(playStoreUrl('home'));
    expect(url.searchParams.get('id')).toBe('com.mindfulness.golden_moments');
    expect(url.searchParams.get('referrer')).toBe('utm_source=website&utm_medium=home');
  });

  it('keeps the plain listing as the base', () => {
    expect(playStoreUrl('game').startsWith(SITE.playStoreUrl + '&referrer=')).toBe(true);
  });
});
