import { useEffect, useState } from 'react';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';

type Phase = 'ready' | 'in' | 'hold' | 'out';

const PACES = [
  { value: 'slow', label: 'Slow (5 seconds each way)' },
  { value: 'gentle', label: 'Gentle (4 seconds each way)' },
] as const;

const SECONDS: Record<'slow' | 'gentle', Record<Exclude<Phase, 'ready'>, number>> = {
  slow: { in: 5, hold: 1, out: 5 },
  gentle: { in: 4, hold: 1, out: 4 },
};

/** The pause ends on its own after this many breaths, about a minute. */
const BREATHS = 6;

const WORDS: Record<Phase, string> = {
  ready: 'Ready when you are',
  in: 'Breathe in',
  hold: 'Rest',
  out: 'Breathe out',
};

/**
 * The one paced activity on the site (a recorded exception in DESIGN.md): it
 * starts only on a tap, stops on a tap or after six breaths, and announces only
 * starting and stopping, never each breath.
 */
export default function CalmBreathing() {
  const [pace, setPace] = useState<'slow' | 'gentle'>('slow');
  const [phase, setPhase] = useState<Phase>('ready');
  const [breath, setBreath] = useState(0);
  const [message, setMessage] = useState('');

  useEffect(() => {
    if (phase === 'ready') return;
    const id = window.setTimeout(() => {
      if (phase === 'in') setPhase('hold');
      else if (phase === 'hold') setPhase('out');
      else if (breath + 1 >= BREATHS) {
        setPhase('ready');
        setBreath(0);
        setMessage('That was six slow breaths. Start again whenever you like.');
      } else {
        setBreath((b) => b + 1);
        setPhase('in');
      }
    }, SECONDS[pace][phase] * 1000);
    return () => window.clearTimeout(id);
  }, [phase, pace, breath]);

  const running = phase !== 'ready';
  const toggle = () => {
    if (running) {
      setPhase('ready');
      setBreath(0);
      setMessage('Stopped.');
    } else {
      setPhase('in');
      setMessage('Started. Breathe in as the circle grows.');
    }
  };

  return (
    <GameFrame
      guidance="Breathe in as the circle grows, and out as it gets smaller. It stops by itself after six breaths."
      message={message}
      options={<ChoiceChips legend="Pace" choices={PACES} value={pace} onChange={(v) => { setPace(v); setPhase('ready'); setBreath(0); }} />}
    >
      <div className="breathe">
        <div className="breathe__stage" aria-hidden="true">
          <div className="breathe__circle" data-phase={phase} data-pace={pace} />
          <span className="breathe__word">{WORDS[phase]}</span>
        </div>
        <button type="button" className={running ? 'btn btn--hero' : 'btn btn--primary btn--hero'} onClick={toggle}>
          <Icon name={running ? 'door' : 'play'} />
          {running ? 'Stop' : 'Start'}
        </button>
      </div>
    </GameFrame>
  );
}
