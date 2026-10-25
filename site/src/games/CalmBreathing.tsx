import { useEffect, useRef, useState } from 'react';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';

type Phase = 'ready' | 'in' | 'hold' | 'out';

const PACES = [
  { value: 'slow', label: 'Slow (5 seconds each way)' },
  { value: 'gentle', label: 'Gentle (4 seconds each way)' },
] as const;

const SECONDS: Record<string, { in: number; hold: number; out: number }> = {
  slow: { in: 5, hold: 1, out: 5 },
  gentle: { in: 4, hold: 1, out: 4 },
};

const WORDS: Record<Phase, string> = {
  ready: 'Ready when you are',
  in: 'Breathe in',
  hold: 'Rest',
  out: 'Breathe out',
};

/** Starts only on a tap and stops on a tap. Nothing moves on its own. */
export default function CalmBreathing() {
  const [pace, setPace] = useState<'slow' | 'gentle'>('slow');
  const [phase, setPhase] = useState<Phase>('ready');
  const timer = useRef<number | null>(null);
  const t = SECONDS[pace] ?? { in: 5, hold: 1, out: 5 };

  useEffect(() => {
    if (phase === 'ready') return;
    const nextPhase: Phase = phase === 'in' ? 'hold' : phase === 'hold' ? 'out' : 'in';
    timer.current = window.setTimeout(() => setPhase(nextPhase), t[phase] * 1000);
    return () => {
      if (timer.current) window.clearTimeout(timer.current);
    };
  }, [phase, t]);

  const running = phase !== 'ready';
  return (
    <GameFrame
      guidance="Breathe in as the circle grows, and out as it gets smaller."
      message={running ? WORDS[phase] : ''}
      options={<ChoiceChips legend="Pace" choices={PACES} value={pace} onChange={(v) => { setPace(v); setPhase('ready'); }} />}
    >
      <div className="breathe">
        <div className="breathe__stage">
          <div className="breathe__circle" data-phase={phase} data-pace={pace} aria-hidden="true" />
          <span className="breathe__word" aria-hidden="true">{WORDS[phase]}</span>
        </div>
        <button
          type="button"
          className={running ? 'btn btn--hero' : 'btn btn--primary btn--hero'}
          onClick={() => setPhase(running ? 'ready' : 'in')}
        >
          <Icon name={running ? 'door' : 'play'} />
          {running ? 'Stop' : 'Start'}
        </button>
      </div>
    </GameFrame>
  );
}
