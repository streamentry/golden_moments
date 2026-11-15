import { describe, expect, it, vi } from 'vitest';
import { createUtterance, hasQueuedOrActiveSpeech, readAloud, speechOf, stopReading, stopReadingWhenHidden, toggleReadAloud, watchReadAloudVisibility, type SpeechLike, type UtteranceLike, type VisibilityTargetLike } from './readAloud';

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

function fakeVisibilityTarget(initiallyHidden = false) {
  let hidden = initiallyHidden;
  const listeners = new Set<() => void>();
  return {
    get hidden() {
      return hidden;
    },
    setHidden(value: boolean) {
      hidden = value;
    },
    addEventListener(_type: 'visibilitychange', listener: () => void) {
      listeners.add(listener);
    },
    removeEventListener(_type: 'visibilitychange', listener: () => void) {
      listeners.delete(listener);
    },
    dispatchVisibilityChange() {
      for (const listener of listeners) listener();
    },
    get listenerCount() {
      return listeners.size;
    },
  } satisfies VisibilityTargetLike & {
    setHidden(value: boolean): void;
    dispatchVisibilityChange(): void;
    readonly listenerCount: number;
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

describe('hasQueuedOrActiveSpeech', () => {
  it('treats queued speech as active before playback begins', () => {
    const synth = fakeSynth();
    expect(hasQueuedOrActiveSpeech(synth)).toBe(false);

    synth.pending = true;
    expect(hasQueuedOrActiveSpeech(synth)).toBe(true);

    synth.pending = false;
    synth.speaking = true;
    expect(hasQueuedOrActiveSpeech(synth)).toBe(true);
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
    expect(onEnd).toHaveBeenCalledTimes(1);
  });

  it('reports failure instead of throwing', () => {
    const synth = fakeSynth();
    synth.speak = vi.fn(() => {
      throw new Error('not allowed');
    });
    expect(readAloud(synth, 'Hello', 'en')).toBe(false);
  });
});

describe('toggleReadAloud', () => {
  it('starts speech without a tap tone over the first words', () => {
    const synth = fakeSynth();
    const setSpeaking = vi.fn();
    const playTap = vi.fn();

    toggleReadAloud(synth, false, 'Tap a color.', 'en', setSpeaking, playTap);

    expect(synth.spoken).toHaveLength(1);
    expect(synth.spoken[0]).toMatchObject({ text: 'Tap a color.', lang: 'en', rate: 0.85 });
    expect(synth.spoken[0].onend).toBeTypeOf('function');
    expect(setSpeaking).toHaveBeenCalledWith(true);
    expect(playTap).not.toHaveBeenCalled();
  });

  it('stops speech before optional tap feedback', () => {
    const synth = fakeSynth();
    const order: string[] = [];
    synth.cancel = () => { order.push('stop'); };

    toggleReadAloud(synth, true, 'Tap a color.', 'en', vi.fn(), () => order.push('tap'));

    expect(order).toEqual(['stop', 'tap']);
  });

  it('ignores a canceled utterance error after newer speech starts', () => {
    const synth = fakeSynth();
    const states: boolean[] = [];
    const setSpeaking = (active: boolean) => states.push(active);
    const noTone = vi.fn();

    toggleReadAloud(synth, false, 'First prompt.', 'en', setSpeaking, noTone);
    const first = synth.spoken[0]!;
    toggleReadAloud(synth, true, 'First prompt.', 'en', setSpeaking, noTone);
    toggleReadAloud(synth, false, 'Second prompt.', 'en', setSpeaking, noTone);

    first.onerror!();
    expect(states).toEqual([true, false, true]);

    synth.spoken[1]!.onend!();
    expect(states).toEqual([true, false, true, false]);
  });

  it('uses a tap tone if speech could not start', () => {
    const synth = fakeSynth();
    synth.speak = vi.fn(() => { throw new Error('speech unavailable'); });
    const setSpeaking = vi.fn();
    const playTap = vi.fn();

    toggleReadAloud(synth, false, 'Tap a color.', 'en', setSpeaking, playTap);

    expect(setSpeaking).toHaveBeenCalledWith(false);
    expect(playTap).toHaveBeenCalledOnce();
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

describe('stopReadingWhenHidden', () => {
  it('leaves speech alone while the page is visible', () => {
    const synth = fakeSynth();
    const setSpeaking = vi.fn();

    expect(stopReadingWhenHidden(synth, false, setSpeaking)).toBe(false);
    expect(synth.cancelled).toBe(0);
    expect(setSpeaking).not.toHaveBeenCalled();
  });

  it('stops queued speech and clears the stop state when the page is hidden', () => {
    const synth = fakeSynth();
    synth.pending = true;
    const setSpeaking = vi.fn();

    expect(stopReadingWhenHidden(synth, true, setSpeaking)).toBe(true);
    expect(synth.cancelled).toBe(1);
    expect(setSpeaking).toHaveBeenCalledWith(false);
  });
});

describe('watchReadAloudVisibility', () => {
  it('subscribes while idle so a hidden change after speech starts is not missed', () => {
    const synth = fakeSynth();
    synth.pending = true;
    const target = fakeVisibilityTarget();
    let speaking = false;
    const setSpeaking = vi.fn((active: boolean) => {
      speaking = active;
    });

    const stopWatching = watchReadAloudVisibility(synth, target, () => speaking, setSpeaking);

    expect(target.listenerCount).toBe(1);
    expect(synth.cancelled).toBe(0);

    speaking = true;
    target.setHidden(true);
    target.dispatchVisibilityChange();
    expect(synth.cancelled).toBe(1);
    expect(setSpeaking).toHaveBeenCalledWith(false);

    stopWatching();
    expect(target.listenerCount).toBe(0);
  });

  it('does not cancel speech when a hidden page has no active narration', () => {
    const synth = fakeSynth();
    const target = fakeVisibilityTarget(true);
    const setSpeaking = vi.fn();

    const stopWatching = watchReadAloudVisibility(synth, target, () => false, setSpeaking);
    expect(target.listenerCount).toBe(1);

    target.dispatchVisibilityChange();
    expect(synth.cancelled).toBe(0);
    expect(setSpeaking).not.toHaveBeenCalled();

    stopWatching();
    expect(target.listenerCount).toBe(0);
  });
});
