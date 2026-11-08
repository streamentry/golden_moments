import { describe, expect, it, vi } from 'vitest';
import { readAloud, speechOf, stopReading, type SpeechLike } from './readAloud';

function fakeSynth(): SpeechLike & { spoken: unknown[]; cancelled: number } {
  return {
    spoken: [] as unknown[],
    cancelled: 0,
    speaking: false,
    speak(u) {
      this.spoken.push(u);
    },
    cancel() {
      this.cancelled++;
    },
  };
}

describe('speechOf', () => {
  it('returns null when the browser has no speech synthesis', () => {
    expect(speechOf({})).toBeNull();
    expect(speechOf(undefined)).toBeNull();
  });

  it('returns the synthesizer when it can speak', () => {
    const synth = fakeSynth();
    expect(speechOf({ speechSynthesis: synth })).toBe(synth);
  });

  it('treats a broken property as no speech', () => {
    const throwing = {
      get speechSynthesis(): never {
        throw new Error('blocked');
      },
    };
    expect(speechOf(throwing)).toBeNull();
  });
});

describe('readAloud', () => {
  it('cancels any earlier speech, then speaks slowly in the page language', () => {
    const synth = fakeSynth();
    expect(readAloud(synth, 'Find the same picture.', 'de')).toBe(true);
    expect(synth.cancelled).toBe(1);
    expect(synth.spoken).toEqual([{ text: 'Find the same picture.', lang: 'de', rate: 0.85 }]);
  });

  it('reports failure instead of throwing', () => {
    const synth = fakeSynth();
    synth.speak = vi.fn(() => {
      throw new Error('not allowed');
    });
    expect(readAloud(synth, 'Hello', 'en')).toBe(false);
  });
});

describe('stopReading', () => {
  it('cancels speech and never throws', () => {
    const synth = fakeSynth();
    stopReading(synth);
    expect(synth.cancelled).toBe(1);
    synth.cancel = () => {
      throw new Error('gone');
    };
    expect(() => stopReading(synth)).not.toThrow();
  });
});
