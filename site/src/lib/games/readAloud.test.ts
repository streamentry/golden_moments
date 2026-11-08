import { describe, expect, it, vi } from 'vitest';
import { createUtterance, readAloud, speechOf, stopReading, type SpeechLike, type UtteranceLike } from './readAloud';

function fakeSynth(): SpeechLike & { spoken: UtteranceLike[]; cancelled: number } {
  return {
    spoken: [] as UtteranceLike[],
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

describe('createUtterance', () => {
  it('returns fallback object when SpeechSynthesisUtterance is not globally defined', () => {
    const u = createUtterance('Test fallback', 'en', 0.85);
    expect(u.text).toBe('Test fallback');
    expect(u.lang).toBe('en');
    expect(u.rate).toBe(0.85);
  });

  it('instantiates SpeechSynthesisUtterance when available', () => {
    class MockUtterance {
      text: string;
      lang = '';
      rate = 1;
      constructor(text: string) {
        this.text = text;
      }
    }
    vi.stubGlobal('SpeechSynthesisUtterance', MockUtterance);
    try {
      const u = createUtterance('Native utterance', 'fr', 0.85);
      expect(u).toBeInstanceOf(MockUtterance);
      expect(u.text).toBe('Native utterance');
      expect(u.lang).toBe('fr');
      expect(u.rate).toBe(0.85);
    } finally {
      vi.unstubAllGlobals();
    }
  });
});

describe('readAloud', () => {
  it('cancels any earlier speech, then speaks slowly in the page language', () => {
    const synth = fakeSynth();
    expect(readAloud(synth, 'Find the same picture.', 'de')).toBe(true);
    expect(synth.cancelled).toBe(1);
    expect(synth.spoken).toEqual([{ text: 'Find the same picture.', lang: 'de', rate: 0.85 }]);
  });

  it('attaches onEnd handler to onend and onerror events', () => {
    const synth = fakeSynth();
    const onEnd = vi.fn();
    expect(readAloud(synth, 'Guidance text', 'en', onEnd)).toBe(true);
    expect(synth.spoken.length).toBe(1);
    const utterance = synth.spoken[0];
    expect(typeof utterance.onend).toBe('function');
    expect(typeof utterance.onerror).toBe('function');

    utterance.onend!();
    expect(onEnd).toHaveBeenCalledTimes(1);

    utterance.onerror!();
    expect(onEnd).toHaveBeenCalledTimes(2);
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
