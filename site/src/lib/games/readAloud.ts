/**
 * Read a sentence aloud with the browser's own speech, if the browser has it.
 * Nothing is sent anywhere: speech is generated on the device. Every call is
 * guarded, so a browser without speech, or with it blocked, simply shows no
 * button.
 */

export interface UtteranceLike {
  text: string;
  lang: string;
  rate?: number;
  onend?: (() => void) | null;
  onerror?: (() => void) | null;
}

export interface SpeechLike {
  speak(utterance: UtteranceLike): void;
  cancel(): void;
  speaking: boolean;
}

/** The browser's speech synthesizer, or null when it has none. */
export function speechOf(win: unknown = typeof window === 'undefined' ? undefined : window): SpeechLike | null {
  try {
    const synth = (win as { speechSynthesis?: SpeechLike } | undefined)?.speechSynthesis;
    return synth && typeof synth.speak === 'function' ? synth : null;
  } catch {
    return null;
  }
}

/** Creates a speech utterance using native SpeechSynthesisUtterance if available in the environment. */
export function createUtterance(text: string, lang: string, rate: number = 0.85): UtteranceLike {
  if (typeof SpeechSynthesisUtterance !== 'undefined') {
    const u = new SpeechSynthesisUtterance(text);
    u.lang = lang;
    u.rate = rate;
    return u as unknown as UtteranceLike;
  }
  return { text, lang, rate };
}

/** Speak `text` in `lang` at a slow, gentle pace. Returns false if it could not. */
export function readAloud(
  synth: SpeechLike,
  text: string,
  lang: string,
  onEnd?: () => void,
): boolean {
  try {
    synth.cancel();
    const utterance = createUtterance(text, lang, 0.85);
    if (onEnd) {
      utterance.onend = onEnd;
      utterance.onerror = onEnd;
    }
    synth.speak(utterance);
    return true;
  } catch {
    return false;
  }
}

/** Stop any speech in progress. */
export function stopReading(synth: SpeechLike): void {
  try {
    synth.cancel();
  } catch {
    /* nothing to stop */
  }
}
