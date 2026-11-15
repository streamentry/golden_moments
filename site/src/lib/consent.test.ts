import { describe, expect, it } from 'vitest';
import {
  CHOICE_KEY,
  CONSENT_REGIONS,
  analyticsCookieNames,
  countryFromTrace,
  decide,
  expireCookieStrings,
  needsConsent,
  readChoice,
  saveChoice,
} from './consent';

const TRACE = 'fl=413f342\nh=dementiaactivities.games\nip=192.0.2.1\nloc=DE\ntls=TLSv1.3\n';

describe('consent regions', () => {
  it('covers the EU 27, the rest of the EEA, the UK and Switzerland, once each', () => {
    expect(CONSENT_REGIONS).toHaveLength(32);
    expect(new Set(CONSENT_REGIONS).size).toBe(32);
    for (const code of ['DE', 'FR', 'IE', 'NO', 'IS', 'LI', 'GB', 'CH']) expect(CONSENT_REGIONS).toContain(code);
  });

  it('asks in a consent region and when the country is unknown, nowhere else', () => {
    expect(needsConsent('DE')).toBe(true);
    expect(needsConsent('GB')).toBe(true);
    expect(needsConsent(null)).toBe(true);
    expect(needsConsent('US')).toBe(false);
    expect(needsConsent('VN')).toBe(false);
  });
});

describe('countryFromTrace', () => {
  it('reads the loc line', () => {
    expect(countryFromTrace(TRACE)).toBe('DE');
  });

  it('gives null for unknown, Tor, missing or malformed answers', () => {
    expect(countryFromTrace('loc=XX\n')).toBeNull();
    expect(countryFromTrace('loc=T1\n')).toBeNull();
    expect(countryFromTrace('<!doctype html><title>Not found</title>')).toBeNull();
    expect(countryFromTrace('loc=de\n')).toBeNull();
    expect(countryFromTrace('xloc=US\n')).toBeNull();
  });
});

describe('decide', () => {
  it('honours a saved choice in every country', () => {
    expect(decide('granted', 'DE')).toBe('load');
    expect(decide('denied', 'US')).toBe('skip');
    expect(decide('denied', null)).toBe('skip');
  });

  it('asks only where consent is needed when nothing is saved', () => {
    expect(decide(null, 'FR')).toBe('ask');
    expect(decide(null, null)).toBe('ask');
    expect(decide(null, 'US')).toBe('load');
  });
});

describe('choice storage', () => {
  const memory = () => {
    const data = new Map<string, string>();
    return { getItem: (k: string) => data.get(k) ?? null, setItem: (k: string, v: string) => void data.set(k, v), data };
  };
  const blocked = {
    getItem: () => {
      throw new Error('SecurityError');
    },
    setItem: () => {
      throw new Error('QuotaExceededError');
    },
  };

  it('saves and reads back a choice under one key', () => {
    const store = memory();
    expect(saveChoice(store, 'denied')).toBe(true);
    expect(store.data.get(CHOICE_KEY)).toBe('denied');
    expect(readChoice(store)).toBe('denied');
  });

  it('ignores unexpected values', () => {
    const store = memory();
    store.setItem(CHOICE_KEY, 'yes');
    expect(readChoice(store)).toBeNull();
  });

  it('treats blocked or missing storage as no choice, without throwing', () => {
    expect(readChoice(blocked)).toBeNull();
    expect(saveChoice(blocked, 'granted')).toBe(false);
    expect(readChoice(undefined)).toBeNull();
    expect(saveChoice(undefined, 'granted')).toBe(false);
  });
});

describe('analytics cookies', () => {
  it('finds only the Google Analytics cookies', () => {
    expect(analyticsCookieNames('_ga=GA1.1.1; gm-lang=fr; _ga_X4CNGM5F8Z=GS1; _gat=1; x_ga=2')).toEqual([
      '_ga',
      '_ga_X4CNGM5F8Z',
    ]);
    expect(analyticsCookieNames('')).toEqual([]);
  });

  it('expires a cookie on the host and each parent domain', () => {
    expect(expireCookieStrings('_ga', 'www.dementiaactivities.games')).toEqual([
      '_ga=; Path=/; Max-Age=0; SameSite=Lax',
      '_ga=; Path=/; Max-Age=0; SameSite=Lax; Domain=.www.dementiaactivities.games',
      '_ga=; Path=/; Max-Age=0; SameSite=Lax; Domain=.dementiaactivities.games',
    ]);
    expect(expireCookieStrings('_ga', 'localhost')).toEqual(['_ga=; Path=/; Max-Age=0; SameSite=Lax']);
  });
});
