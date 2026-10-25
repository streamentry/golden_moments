import { useEffect, useRef, useState } from 'react';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { PairsBoard } from './shared/PairsBoard';

const MAX_PHOTOS = 6;
const MAX_BYTES = 40 * 1024 * 1024;

/**
 * Photos are read with object URLs that exist only in this tab. Nothing is
 * uploaded or stored; the URLs are revoked when cleared or when the page closes.
 */
export default function PhotoPairs() {
  const [urls, setUrls] = useState<string[]>([]);
  const [round, setRound] = useState(0);
  const [message, setMessage] = useState('');
  const [note, setNote] = useState('');
  const [done, setDone] = useState(false);
  const input = useRef<HTMLInputElement>(null);

  useEffect(() => () => urls.forEach((u) => URL.revokeObjectURL(u)), [urls]);

  const choose = (files: FileList | null) => {
    if (!files) return;
    const images = Array.from(files).filter((f) => f.type.startsWith('image/') && f.size <= MAX_BYTES);
    const skipped = files.length - images.length;
    const picked = images.slice(0, MAX_PHOTOS);
    if (picked.length < 2) {
      setNote('Please choose at least two photos.');
      return;
    }
    const extra = images.length - picked.length;
    setNote(
      [
        extra > 0 ? `Using the first ${MAX_PHOTOS} photos.` : '',
        skipped > 0 ? `${skipped} file${skipped === 1 ? ' was' : 's were'} not a photo we can show.` : '',
      ]
        .filter(Boolean)
        .join(' '),
    );
    setUrls(picked.map((f) => URL.createObjectURL(f)));
    setDone(false);
    setRound((r) => r + 1);
  };

  const clear = () => {
    setUrls([]);
    setMessage('');
    setNote('Photos cleared from this page.');
    setDone(false);
    if (input.current) input.current.value = '';
  };

  const picker = (
    <div className="photo-pick">
      <p className="m-0">
        <strong>Choose 2 to 6 photos</strong> from this device. They are shown only on this page and are never uploaded
        or saved.
      </p>
      <label className="btn btn--primary">
        <Icon name="photo" />
        {urls.length ? 'Choose different photos' : 'Choose photos'}
        <input
          ref={input}
          type="file"
          accept="image/*"
          multiple
          onChange={(e) => choose(e.currentTarget.files)}
        />
      </label>
      {note ? <p role="status" className="m-0">{note}</p> : null}
    </div>
  );

  if (urls.length === 0) {
    return (
      <GameFrame guidance="Start by choosing your photos." message={message}>
        {picker}
      </GameFrame>
    );
  }

  return (
    <GameFrame
      guidance="Tap a photo, then tap the one that matches it."
      message={done ? '' : message}
      onRestart={() => { setDone(false); setRound((r) => r + 1); }}
      restartLabel="Mix them again"
      options={picker}
      footer={
        <>
          {done ? (
            <div className="game__done" role="status">
              <p>All pairs together. Play again or take a break.</p>
            </div>
          ) : null}
          <button type="button" className="btn btn--quiet" onClick={clear}>
            Clear photos
          </button>
        </>
      }
    >
      <PairsBoard values={urls} photos hidden={false} round={round} onMessage={setMessage} onComplete={() => setDone(true)} />
    </GameFrame>
  );
}
