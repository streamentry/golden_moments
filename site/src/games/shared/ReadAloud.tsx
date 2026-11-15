import { useEffect, useState } from 'react';
import { hasQueuedOrActiveSpeech, speechOf, stopReading, stopReadingWhenHidden, toggleReadAloud, type SpeechLike } from '../../lib/games/readAloud';
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

  useEffect(() => {
    setSynth(speechOf());
    return () => {
      const s = speechOf();
      if (s) stopReading(s);
    };
  }, []);

  useEffect(() => {
    if (!synth || !speaking) return;
    const stopIfHidden = () => {
      stopReadingWhenHidden(synth, document.hidden, setSpeaking);
    };
    document.addEventListener('visibilitychange', stopIfHidden);
    const timer = window.setInterval(() => {
      if (!hasQueuedOrActiveSpeech(synth)) setSpeaking(false);
    }, 400);
    return () => {
      document.removeEventListener('visibilitychange', stopIfHidden);
      window.clearInterval(timer);
    };
  }, [synth, speaking]);

  useEffect(() => {
    if (speaking && synth) {
      stopReading(synth);
      setSpeaking(false);
    }
  }, [text]);

  if (!synth) return null;

  const toggle = () => {
    toggleReadAloud(synth, speaking, text, lang, setSpeaking, sounds.tap);
  };

  return (
    <button type="button" className="btn btn--quiet read-aloud" aria-pressed={speaking} onClick={toggle}>
      <Icon name={speaking ? 'soundOff' : 'sound'} />
      {speaking ? ui.frame.stopReading : ui.frame.readAloud}
    </button>
  );
}
