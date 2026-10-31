import { useEffect, type ReactNode } from 'react';
import type { PlayUi } from '../../i18n/play';
import { localePath } from '../../i18n/locales';
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
  useEffect(hydrateSettings, []);

  return (
    <section className="game" aria-label={ui.frame.region}>
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
        <a className="btn btn--quiet" href={localePath(lang, '/games/')}>
          <Icon name="door" />
          {ui.frame.done}
        </a>
      </div>
    </section>
  );
}
