/**
 * Read a sentence aloud with the browser's own speech, if the browser has it.
 * Nothing is sent anywhere: speech is generated on the device. Every call is
 * guarded, so a browser without speech, or with it blocked, simply shows no
 * button.
 */

export interface SpeechLike {
  speak(utterance: { text: string; lang: string; rate?: number }): void;
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

/** Speak `text` in `lang` at a slow, gentle pace. Returns false if it could not. */
export function readAloud(synth: SpeechLike, text: string, lang: string): boolean {
  try {
    synth.cancel();
    synth.speak({ text, lang, rate: 0.85 });
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
