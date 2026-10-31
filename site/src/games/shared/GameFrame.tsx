import { useEffect, useRef, useState, type ReactNode } from 'react';
import type { PlayUi } from '../../i18n/play';
import { localePath } from '../../i18n/locales';
import { analyticsAvailable, once, track, trackPrint, type FeedbackAnswer } from '../../lib/track';
import { Icon } from './Icon';
import { hydrateSettings, settingsStore, useSound } from './settings';

interface GameFrameProps {
  ui: PlayUi;
  lang: string;
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

export function GameFrame({ ui, lang, guidance, message, options, children, footer, onRestart, restartLabel }: GameFrameProps) {
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
    <section className="game" aria-label={ui.frame.region}>
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
            {restartLabel ?? ui.frame.restart}
          </button>
        ) : null}
        <button
          type="button"
          className="btn btn--quiet"
          aria-pressed={sound}
          onClick={() => settingsStore.actions.toggleSound()}
        >
          <Icon name={sound ? 'sound' : 'soundOff'} />
          {sound ? ui.frame.soundOn : ui.frame.soundOff}
        </button>
        <a className="btn btn--quiet" href={localePath(lang, '/games/')} onClick={() => track('activity_done')}>
          <Icon name="door" />
          {ui.frame.done}
        </a>
      </div>
      {canAsk && started ? (
        <div className="game__feedback">
          {answer ? (
            <p ref={thanks} tabIndex={-1}>
              {ui.frame.feedbackThanks}
            </p>
          ) : (
            <>
              <p id="game-feedback-question">{ui.frame.feedbackQuestion}</p>
              <div role="group" aria-labelledby="game-feedback-question" className="game__feedback-choices">
                <button type="button" className="btn btn--quiet" onClick={() => giveFeedback('yes')}>
                  {ui.frame.feedbackYes}
                </button>
                <button type="button" className="btn btn--quiet" onClick={() => giveFeedback('not_really')}>
                  {ui.frame.feedbackNo}
                </button>
              </div>
            </>
          )}
        </div>
      ) : null}
    </section>
  );
}
