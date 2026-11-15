import { useCallback, useEffect, useRef, useState } from 'react';
import { hasQueuedOrActiveSpeech, speechOf, stopReading, toggleReadAloud, watchReadAloudVisibility, type SpeechLike } from '../../lib/games/readAloud';
import type { PlayUi } from '../../i18n/play';
import { Icon } from './Icon';
import { sounds } from './sound';

interface ReadAloudProps {
  ui: PlayUi;
  lang: string;
  text: string;
}

/**
 * A button that reads the game's guidance aloud. Off until pressed, and not
 * shown at all where the browser has no speech. The label changes to "Stop
 * reading" while it speaks, so the state is shown in words.
 */
export function ReadAloud({ ui, lang, text }: ReadAloudProps) {
  const [synth, setSynth] = useState<SpeechLike | null>(null);
  const [speaking, setSpeaking] = useState(false);
  const speakingRef = useRef(false);
  const setSpeechActive = useCallback((active: boolean) => {
    speakingRef.current = active;
    setSpeaking(active);
  }, []);

  useEffect(() => {
    const currentSynth = speechOf();
    setSynth(currentSynth);
    if (!currentSynth) return;
    const stopWatchingVisibility = watchReadAloudVisibility(
      currentSynth,
      document,
      () => speakingRef.current,
      setSpeechActive,
    );
    return () => {
      stopWatchingVisibility();
      stopReading(currentSynth);
    };
  }, [setSpeechActive]);

  useEffect(() => {
    if (!synth || !speaking) return;
    const timer = window.setInterval(() => {
      if (!hasQueuedOrActiveSpeech(synth)) setSpeechActive(false);
    }, 400);
    return () => window.clearInterval(timer);
  }, [synth, speaking, setSpeechActive]);

  useEffect(() => {
    if (speakingRef.current && synth) {
      stopReading(synth);
      setSpeechActive(false);
    }
  }, [text, synth, setSpeechActive]);

  if (!synth) return null;

  const toggle = () => {
    toggleReadAloud(synth, speaking, text, lang, setSpeechActive, sounds.tap);
  };

  return (
    <button type="button" className="btn btn--quiet read-aloud" aria-pressed={speaking} onClick={toggle}>
      <Icon name={speaking ? 'soundOff' : 'sound'} />
      {speaking ? ui.frame.stopReading : ui.frame.readAloud}
    </button>
  );
}
