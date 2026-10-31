import { useEffect, useRef, useState } from 'react';
import type { PlayProps, PlayUi } from '../i18n/play';
import { boldRuns, fill, plural } from '../i18n/play/format';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { PairsBoard } from './shared/PairsBoard';

const MAX_PHOTOS = 6;
const MAX_BYTES = 40 * 1024 * 1024;

function pickNote(ui: PlayUi, lang: string, skipped: number, extra: number): string {
  return [
    extra > 0 ? fill(ui.photoPairs.usingFirst, { max: MAX_PHOTOS }) : '',
    skipped > 0 ? fill(plural(ui.photoPairs.skipped, skipped, lang), { count: skipped }) : '',
  ]
    .filter(Boolean)
    .join(' ');
}

/**
 * Photos are read with object URLs that exist only in this tab. Nothing is
 * uploaded or stored; the URLs are revoked when cleared or when the page closes.
 * The picker stays in one place so keyboard focus is never lost.
 */
export default function PhotoPairs(props: PlayProps) {
  const { ui, lang } = props;
  const [urls, setUrls] = useState<string[]>([]);
  const [round, setRound] = useState(0);
  const [message, setMessage] = useState('');
  const [note, setNote] = useState('');
  const [done, setDone] = useState(false);
  const input = useRef<HTMLInputElement>(null);

  useEffect(() => () => urls.forEach((u) => URL.revokeObjectURL(u)), [urls]);

  const resetInput = () => {
    if (input.current) input.current.value = '';
  };

  const choose = (files: FileList | null) => {
    if (!files) return;
    const images = Array.from(files).filter((f) => f.type.startsWith('image/') && f.size <= MAX_BYTES);
    const skipped = files.length - images.length;
    const picked = images.slice(0, MAX_PHOTOS);
    // Clear the input so choosing the same files again still fires a change.
    resetInput();
    if (picked.length < 2) {
      setNote([ui.photoPairs.atLeastTwo, pickNote(ui, lang, skipped, 0)].filter(Boolean).join(' '));
      return;
    }
    setNote(pickNote(ui, lang, skipped, images.length - picked.length));
    setUrls(picked.map((f) => URL.createObjectURL(f)));
    setMessage('');
    setDone(false);
    setRound((r) => r + 1);
  };

  const clear = () => {
    setUrls([]);
    setMessage(ui.photoPairs.cleared);
    setNote('');
    setDone(false);
    resetInput();
    input.current?.focus();
  };

  const hasPhotos = urls.length > 0;
  return (
    <GameFrame
      ui={ui}
      lang={lang}
      guidance={hasPhotos ? ui.photoPairs.guidance : ui.photoPairs.guidanceEmpty}
      message={message}
      onRestart={hasPhotos ? () => { setDone(false); setMessage(''); setRound((r) => r + 1); } : undefined}
      restartLabel={ui.photoPairs.restart}
      options={
        <div className="photo-pick">
          <p className="m-0">
            {boldRuns(ui.photoPairs.intro).map((run, i) => (run.bold ? <strong key={i}>{run.text}</strong> : run.text))}
          </p>
          <label className="btn btn--primary">
            <Icon name="photo" />
            {hasPhotos ? ui.photoPairs.chooseDifferent : ui.photoPairs.choose}
            <input ref={input} type="file" accept="image/*" multiple onChange={(e) => choose(e.currentTarget.files)} />
          </label>
          {note ? <p role="status" className="m-0">{note}</p> : null}
          {hasPhotos ? (
            <button type="button" className="btn btn--quiet" onClick={clear}>
              {ui.photoPairs.clear}
            </button>
          ) : null}
        </div>
      }
      footer={
        done ? (
          <div className="game__done">
            <button type="button" className="btn btn--primary" onClick={() => { setDone(false); setMessage(''); setRound((r) => r + 1); }}>
              {ui.photoPairs.playAgain}
            </button>
          </div>
        ) : null
      }
    >
      {hasPhotos ? (
        <PairsBoard play={props} values={urls} photos hidden={false} round={round} onMessage={setMessage} onComplete={() => setDone(true)} />
      ) : (
        <p className="muted">{ui.photoPairs.empty}</p>
      )}
    </GameFrame>
  );
}
