import { useEffect, useRef, useState } from 'react';
import type { PlayProps, PlayUi } from '../i18n/play';
import { boldRuns, fill, plural } from '../i18n/play/format';
import { movePhotoIndex } from '../lib/games/photo-viewer';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { PairsBoard } from './shared/PairsBoard';
import { sounds } from './shared/sound';

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
  const [captions, setCaptions] = useState<string[]>([]);
  const [lookOnly, setLookOnly] = useState(false);
  const [photoIndex, setPhotoIndex] = useState(0);
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
    setCaptions(picked.map(() => ''));
    setLookOnly(false);
    setPhotoIndex(0);
    setMessage('');
    setDone(false);
    setRound((r) => r + 1);
  };

  const clear = () => {
    sounds.tap();
    setUrls([]);
    setCaptions([]);
    setLookOnly(false);
    setPhotoIndex(0);
    setMessage(ui.photoPairs.cleared);
    setNote('');
    setDone(false);
    resetInput();
    input.current?.focus();
  };

  const hasPhotos = urls.length > 0;
  const guidance = hasPhotos
    ? lookOnly
      ? ui.photoPairs.lookGuidance
      : ui.photoPairs.guidance
    : ui.photoPairs.guidanceEmpty;
  const currentCaption = captions[photoIndex]?.trim() ?? '';

  return (
    <GameFrame
      ui={ui}
      lang={lang}
      guidance={guidance}
      readAloudText={message || guidance}
      message={message}
      onRestart={
        hasPhotos && !lookOnly
          ? () => {
              sounds.tap();
              setDone(false);
              setMessage('');
              setRound((r) => r + 1);
            }
          : undefined
      }
      restartLabel={ui.photoPairs.restart}
      options={
        <div className="photo-pick">
          <p className="m-0">
            {boldRuns(ui.photoPairs.intro).map((run, i) => (run.bold ? <strong key={i}>{run.text}</strong> : run.text))}
          </p>
          <p className="m-0">{ui.photoPairs.photoComfort}</p>
          <label className={hasPhotos ? 'btn' : 'btn btn--primary'}>
            <Icon name="photo" />
            {hasPhotos ? ui.photoPairs.chooseDifferent : ui.photoPairs.choose}
            <input ref={input} type="file" accept="image/*" multiple onChange={(e) => choose(e.currentTarget.files)} />
          </label>
          {note ? <p role="status" className="m-0">{note}</p> : null}
          {hasPhotos ? (
            <details className="photo-pick__caption-details">
              <summary>{ui.photoPairs.captionSummary}</summary>
              <p className="photo-pick__caption-help">{ui.photoPairs.captionHelp}</p>
              <div className="photo-pick__caption-list">
                {urls.map((url, index) => {
                  const id = `photo-caption-${round}-${index + 1}`;
                  return (
                    <div className="photo-pick__caption-row" key={id}>
                      <img className="photo-pick__caption-thumb" src={url} alt="" />
                      <label className="photo-pick__caption-field" htmlFor={id}>
                        <span>{fill(ui.photoPairs.captionLabel, { n: index + 1 })}</span>
                        <input
                          id={id}
                          className="photo-pick__caption-input"
                          type="text"
                          maxLength={80}
                          value={captions[index] ?? ''}
                          onChange={(event) => {
                            const value = event.currentTarget.value;
                            setCaptions((current) => current.map((caption, i) => (i === index ? value : caption)));
                          }}
                        />
                      </label>
                    </div>
                  );
                })}
              </div>
            </details>
          ) : null}
          {hasPhotos ? (
            <label className="chip photo-pick__look-toggle">
              <input
                type="checkbox"
                checked={lookOnly}
                onChange={(event) => {
                  sounds.tap();
                  const enabled = event.currentTarget.checked;
                  setLookOnly(enabled);
                  setPhotoIndex(0);
                  setMessage(enabled ? fill(ui.photoPairs.photoPosition, { n: 1, total: urls.length }) : '');
                  setDone(false);
                }}
              />
              <span>{ui.photoPairs.lookOnly}</span>
            </label>
          ) : null}
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
            <button
              type="button"
              className="btn btn--primary"
              onClick={() => {
                sounds.tap();
                setDone(false);
                setMessage('');
                setRound((r) => r + 1);
              }}
            >
              {ui.photoPairs.playAgain}
            </button>
          </div>
        ) : null
      }
    >
      {hasPhotos ? (
        lookOnly ? (
          <figure className="photo-pairs__viewer">
            <img
              src={urls[photoIndex] ?? urls[0] ?? ''}
              alt={currentCaption ? '' : fill(ui.tile.photoNumber, { n: photoIndex + 1 })}
            />
            {currentCaption ? <figcaption aria-live="polite" aria-atomic="true">{currentCaption}</figcaption> : null}
            <div className="btn-row">
              <button
                type="button"
                className="btn"
                onClick={() => {
                  sounds.tap();
                  const index = movePhotoIndex(photoIndex, urls.length, -1);
                  setPhotoIndex(index);
                  setMessage(fill(ui.photoPairs.photoPosition, { n: index + 1, total: urls.length }));
                }}
              >
                <Icon name="back" />
                {ui.photoPairs.previousPhoto}
              </button>
              <button
                type="button"
                className="btn btn--primary"
                onClick={() => {
                  sounds.tap();
                  const index = movePhotoIndex(photoIndex, urls.length, 1);
                  setPhotoIndex(index);
                  setMessage(fill(ui.photoPairs.photoPosition, { n: index + 1, total: urls.length }));
                }}
              >
                {ui.photoPairs.nextPhoto}
                <Icon name="arrow" />
              </button>
            </div>
          </figure>
        ) : (
          <PairsBoard
            play={props}
            values={urls}
            photoLabels={captions}
            photos
            hidden={false}
            round={round}
            onMessage={setMessage}
            onComplete={() => setDone(true)}
          />
        )
      ) : (
        <p className="muted">{ui.photoPairs.empty}</p>
      )}
    </GameFrame>
  );
}
