import { useEffect, useRef, useState, type ReactNode } from 'react';
import { analyticsAvailable, once, track, trackPrint, type FeedbackAnswer } from '../../lib/track';
import { Icon } from './Icon';
import { hydrateSettings, settingsStore, useSound } from './settings';

interface GameFrameProps {
  /** One plain sentence of guidance, always visible. */
  guidance: string;
  /** Polite live message after each turn. */
  message?: string;
  options?: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
  onRestart?: () => void;
  restartLabel?: string;
}

export function GameFrame({ guidance, message, options, children, footer, onRestart, restartLabel = 'Start again' }: GameFrameProps) {
  const sound = useSound();
  const [started, setStarted] = useState(false);
  const [answer, setAnswer] = useState<FeedbackAnswer | null>(null);
  const [canAsk, setCanAsk] = useState(false);
  const thanks = useRef<HTMLParagraphElement>(null);
  useEffect(hydrateSettings, []);
  // The answer buttons disappear on a tap, so keep focus on the reply.
  useEffect(() => {
    if (answer) thanks.current?.focus();
  }, [answer]);
  useEffect(() => {
    const onPrint = () => trackPrint();
    window.addEventListener('beforeprint', onPrint);
    return () => window.removeEventListener('beforeprint', onPrint);
  }, []);
  const [sendStart] = useState(() => once(() => track('activity_start')));

  // A click is a real choice on the board; Tab, arrow keys and scrolling
  // touches are not. Keyboard activation of a tile also fires click.
  const markStarted = () => {
    if (!sendStart()) return;
    setStarted(true);
    // Checked now, not at load: the Analytics script may finish after hydration.
    setCanAsk(analyticsAvailable());
  };
  const giveFeedback = (value: FeedbackAnswer) => {
    setAnswer(value);
    track('activity_feedback', { answer: value });
  };

  return (
    <section className="game" aria-label="Game">
      {options ? <div className="game__options">{options}</div> : null}
      <p className="game__guidance">{guidance}</p>
      <div className="game__board" onClickCapture={markStarted}>
        {children}
      </div>
      <p className="game__message" role="status" aria-live="polite">
        {message ?? ''}
      </p>
      {footer}
      <div className="game__bar">
        {onRestart ? (
          <button
            type="button"
            className="btn"
            onClick={() => {
              track('activity_restart');
              onRestart();
            }}
          >
            <Icon name="refresh" />
            {restartLabel}
          </button>
        ) : null}
        <button
          type="button"
          className="btn btn--quiet"
          aria-pressed={sound}
          onClick={() => settingsStore.actions.toggleSound()}
        >
          <Icon name={sound ? 'sound' : 'soundOff'} />
          {sound ? 'Soft sounds on' : 'Soft sounds off'}
        </button>
        <a className="btn btn--quiet" href="/games/" onClick={() => track('activity_done')}>
          <Icon name="door" />
          Done for now
        </a>
      </div>
      {canAsk && started ? (
        <div className="game__feedback">
          {answer ? (
            <p ref={thanks} tabIndex={-1}>
              Thank you for telling us.
            </p>
          ) : (
            <>
              <p id="game-feedback-question">Did this help today?</p>
              <div role="group" aria-labelledby="game-feedback-question" className="game__feedback-choices">
                <button type="button" className="btn btn--quiet" onClick={() => giveFeedback('yes')}>
                  Yes
                </button>
                <button type="button" className="btn btn--quiet" onClick={() => giveFeedback('not_really')}>
                  Not really
                </button>
              </div>
            </>
          )}
        </div>
      ) : null}
    </section>
  );
}
