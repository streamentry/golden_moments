/**
 * Read a sentence aloud with the browser's SpeechSynthesis API, if available.
 * The browser may use a local or remote voice, depending on its configuration.
 * A browser without speech, or with it blocked, simply shows no button.
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
  pending?: boolean;
}

export interface VisibilityTargetLike {
  readonly hidden: boolean;
  addEventListener(type: 'visibilitychange', listener: () => void): void;
  removeEventListener(type: 'visibilitychange', listener: () => void): void;
}

const speechRuns = new WeakMap<SpeechLike, number>();

function nextSpeechRun(synth: SpeechLike): number {
  const run = (speechRuns.get(synth) ?? 0) + 1;
  speechRuns.set(synth, run);
  return run;
}

/** True while the browser is speaking or has an utterance waiting to start. */
export function hasQueuedOrActiveSpeech(synth: SpeechLike): boolean {
  return synth.speaking || synth.pending === true;
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
  const run = nextSpeechRun(synth);
  try {
    synth.cancel();
    const utterance = createUtterance(text, lang, 0.85);
    if (onEnd) {
      let finished = false;
      const finish = () => {
        if (finished || speechRuns.get(synth) !== run) return;
        finished = true;
        onEnd();
      };
      utterance.onend = finish;
      utterance.onerror = finish;
    }
    synth.speak(utterance);
    return true;
  } catch {
    return false;
  }
}

/** Toggle spoken guidance without layering a game tone over successful speech. */
export function toggleReadAloud(
  synth: SpeechLike,
  speaking: boolean,
  text: string,
  lang: string,
  setSpeaking: (speaking: boolean) => void,
  playTap: () => void,
): void {
  if (speaking) {
    stopReading(synth);
    setSpeaking(false);
    playTap();
    return;
  }

  const started = readAloud(synth, text, lang, () => setSpeaking(false));
  setSpeaking(started);
  if (!started) playTap();
}

/** Stop any speech in progress. */
export function stopReading(synth: SpeechLike): void {
  nextSpeechRun(synth);
  try {
    synth.cancel();
  } catch {
    /* nothing to stop */
  }
}

/** Stop spoken guidance when the user leaves the visible page. */
export function stopReadingWhenHidden(
  synth: SpeechLike,
  hidden: boolean,
  setSpeaking: (speaking: boolean) => void,
): boolean {
  if (!hidden) return false;
  stopReading(synth);
  setSpeaking(false);
  return true;
}

/** Stop active narration when the page becomes hidden. */
export function watchReadAloudVisibility(
  synth: SpeechLike,
  target: VisibilityTargetLike,
  isSpeaking: () => boolean,
  setSpeaking: (speaking: boolean) => void,
): () => void {
  const stopIfHidden = () => {
    if (target.hidden && isSpeaking()) stopReadingWhenHidden(synth, true, setSpeaking);
  };
  target.addEventListener('visibilitychange', stopIfHidden);
  return () => target.removeEventListener('visibilitychange', stopIfHidden);
}
