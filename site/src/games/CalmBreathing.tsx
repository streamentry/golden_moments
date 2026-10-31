import { useEffect, useState } from 'react';
import type { PlayProps } from '../i18n/play';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';

type Phase = 'ready' | 'in' | 'hold' | 'out';

const SECONDS: Record<'slow' | 'gentle', Record<Exclude<Phase, 'ready'>, number>> = {
  slow: { in: 5, hold: 1, out: 5 },
  gentle: { in: 4, hold: 1, out: 4 },
};

/** The pause ends on its own after this many breaths, about a minute. */
const BREATHS = 6;

/**
 * The one paced activity on the site (a recorded exception in DESIGN.md): it
 * starts only on a tap, stops on a tap or after six breaths, and announces only
 * starting and stopping, never each breath.
 */
export default function CalmBreathing(props: PlayProps) {
  const { ui, lang } = props;
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
        setMessage(ui.calmBreathing.finished);
      } else {
        setBreath((b) => b + 1);
        setPhase('in');
      }
    }, SECONDS[pace][phase] * 1000);
    return () => window.clearTimeout(id);
  }, [phase, pace, breath, ui]);

  const running = phase !== 'ready';
  const toggle = () => {
    if (running) {
      setPhase('ready');
      setBreath(0);
      setMessage(ui.calmBreathing.stopped);
    } else {
      setPhase('in');
      setMessage(ui.calmBreathing.started);
    }
  };

  const paces = [
    { value: 'slow', label: ui.calmBreathing.paceSlow },
    { value: 'gentle', label: ui.calmBreathing.paceGentle },
  ] as const;
  const words: Record<Phase, string> = {
    ready: ui.calmBreathing.ready,
    in: ui.calmBreathing.in,
    hold: ui.calmBreathing.hold,
    out: ui.calmBreathing.out,
  };

  return (
    <GameFrame
      ui={ui}
      lang={lang}
      guidance={ui.calmBreathing.guidance}
      message={message}
      options={<ChoiceChips legend={ui.calmBreathing.paceLegend} choices={paces} value={pace} onChange={(v) => { setPace(v); setPhase('ready'); setBreath(0); }} />}
    >
      <div className="breathe">
        <div className="breathe__stage" aria-hidden="true">
          <div className="breathe__circle" data-phase={phase} data-pace={pace} />
          <span className="breathe__word">{words[phase]}</span>
        </div>
        <button type="button" className={running ? 'btn btn--hero' : 'btn btn--primary btn--hero'} onClick={toggle}>
          <Icon name={running ? 'door' : 'play'} />
          {running ? ui.calmBreathing.stop : ui.calmBreathing.start}
        </button>
      </div>
    </GameFrame>
  );
}
