import { describe, expect, it } from 'vitest';
import { analyticsAvailable, once, track, trackPrint } from './track';

describe('track', () => {
  it('does nothing where Analytics is not loaded, such as Photo pairs', () => {
    expect(analyticsAvailable({})).toBe(false);
    expect(track('activity_start', undefined, {})).toBe(false);
  });

  it('sends only the event name and the fixed feedback answer', () => {
    const calls: unknown[][] = [];
    const w = { gtag: (...args: unknown[]) => void calls.push(args) };
    expect(analyticsAvailable(w)).toBe(true);
    expect(track('activity_start', undefined, w)).toBe(true);
    expect(track('activity_feedback', { answer: 'not_really' }, w)).toBe(true);
    expect(calls).toEqual([
      ['event', 'activity_start', undefined],
      ['event', 'activity_feedback', { answer: 'not_really' }],
    ]);
  });

  it('counts a start once per page view, however often the board is used', () => {
    let starts = 0;
    const start = once(() => void starts++);
    expect([start(), start(), start()]).toEqual([true, false, false]);
    expect(starts).toBe(1);
  });

  it('counts prints only where the game has a printable sheet', () => {
    const calls: unknown[][] = [];
    const w = { gtag: (...args: unknown[]) => void calls.push(args) };
    expect(trackPrint({ querySelector: () => null }, w)).toBe(false);
    expect(trackPrint({ querySelector: () => ({}) }, w)).toBe(true);
    expect(calls).toEqual([['event', 'activity_print', undefined]]);
  });
});
