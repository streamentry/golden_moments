import { useEffect, useRef, useState } from 'react';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { PairsBoard } from './shared/PairsBoard';

const MAX_PHOTOS = 6;
const MAX_BYTES = 40 * 1024 * 1024;

function pickNote(skipped: number, extra: number): string {
  return [
    extra > 0 ? `Using the first ${MAX_PHOTOS} photos.` : '',
    skipped > 0 ? `${skipped} file${skipped === 1 ? ' was' : 's were'} not a photo we can show.` : '',
  ]
    .filter(Boolean)
    .join(' ');
}

/**
 * Photos are read with object URLs that exist only in this tab. Nothing is
 * uploaded or stored; the URLs are revoked when cleared or when the page closes.
 * The picker stays in one place so keyboard focus is never lost.
 */
export default function PhotoPairs() {
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
      setNote(['Please choose at least two photos.', pickNote(skipped, 0)].filter(Boolean).join(' '));
      return;
    }
    setNote(pickNote(skipped, images.length - picked.length));
    setUrls(picked.map((f) => URL.createObjectURL(f)));
    setMessage('');
    setDone(false);
    setRound((r) => r + 1);
  };

  const clear = () => {
    setUrls([]);
    setMessage('Photos cleared from this page.');
    setNote('');
    setDone(false);
    resetInput();
    input.current?.focus();
  };

  const hasPhotos = urls.length > 0;
  return (
    <GameFrame
      guidance={hasPhotos ? 'Tap a photo, then tap the one that matches it.' : 'Start by choosing your photos.'}
      message={message}
      onRestart={hasPhotos ? () => { setDone(false); setMessage(''); setRound((r) => r + 1); } : undefined}
      restartLabel="Mix them again"
      options={
        <div className="photo-pick">
          <p className="m-0">
            <strong>Choose 2 to 6 photos</strong> from this device. They are shown only on this page and are never
            uploaded or saved.
          </p>
          <label className="btn btn--primary">
            <Icon name="photo" />
            {hasPhotos ? 'Choose different photos' : 'Choose photos'}
            <input ref={input} type="file" accept="image/*" multiple onChange={(e) => choose(e.currentTarget.files)} />
          </label>
          {note ? <p role="status" className="m-0">{note}</p> : null}
          {hasPhotos ? (
            <button type="button" className="btn btn--quiet" onClick={clear}>
              Clear photos
            </button>
          ) : null}
        </div>
      }
      footer={
        done ? (
          <div className="game__done">
            <button type="button" className="btn btn--primary" onClick={() => { setDone(false); setMessage(''); setRound((r) => r + 1); }}>
              Play again with these photos
            </button>
          </div>
        ) : null
      }
    >
      {hasPhotos ? (
        <PairsBoard values={urls} photos hidden={false} round={round} onMessage={setMessage} onComplete={() => setDone(true)} />
      ) : (
        <p className="muted">Your photos will appear here, each one twice.</p>
      )}
    </GameFrame>
  );
}
