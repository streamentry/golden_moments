import { useEffect, type ReactNode } from 'react';
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
  useEffect(hydrateSettings, []);

  return (
    <section className="game" aria-label="Game">
      {options ? <div className="game__options">{options}</div> : null}
      <p className="game__guidance">{guidance}</p>
      <div className="game__board">{children}</div>
      <p className="game__message" role="status" aria-live="polite">
        {message ?? ''}
      </p>
      {footer}
      <div className="game__bar">
        {onRestart ? (
          <button type="button" className="btn" onClick={onRestart}>
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
        <a className="btn btn--quiet" href="/games/">
          <Icon name="door" />
          Done for now
        </a>
      </div>
    </section>
  );
}
