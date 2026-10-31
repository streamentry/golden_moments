import { useCreateStore, useSelector } from '@tanstack/react-store';
import { useEffect, useState } from 'react';
import { pictureUrl } from '../data/pictures';
import type { PlayProps } from '../i18n/play';
import { fill, plural } from '../i18n/play/format';
import { correctCount, createPuzzle, isSolved, tapPiece, type PuzzleState } from '../lib/games/puzzle';
import { createRng, randomSeed } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { pictureNamer } from './shared/PictureTile';
import { sounds } from './shared/sound';

/** Picture ids offered as puzzles; their chip labels are `ui.picturePuzzle.pictures`. */
const PUZZLE_PICTURES = ['sailboat', 'house', 'balloon', 'sunflower', 'lighthouse', 'cat'] as const;
type PuzzlePicture = (typeof PUZZLE_PICTURES)[number];

const SIZES = [2, 3] as const;

export default function PicturePuzzle(props: PlayProps) {
  const { ui, lang } = props;
  const pictureName = pictureNamer(props);
  const [picture, setPicture] = useState<PuzzlePicture>('sailboat');
  const [size, setSize] = useState<2 | 3>(2);
  const [round, setRound] = useState(0);
  const [message, setMessage] = useState('');

  const store = useCreateStore<PuzzleState, { tap: (slot: number) => void; reset: (s: 2 | 3) => void }>(
    { size: 2, order: [], selected: null },
    ({ setState }) => ({
      tap: (slot) => setState((s) => tapPiece(s, slot)),
      reset: (s) => setState(() => createPuzzle(s, createRng(randomSeed()))),
    }),
  );
  const state = useSelector(store);
  const solved = state.order.length > 0 && isSolved(state);

  useEffect(() => {
    store.actions.reset(size);
    setMessage('');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [size, picture, round]);

  /** "top left", "center": where a slot is on the board. */
  const placeName = (slot: number): string => (state.size === 2 ? ui.picturePuzzle.places4 : ui.picturePuzzle.places9)[slot] ?? '';

  const tap = (slot: number) => {
    if (solved) return;
    const before = store.state.selected;
    store.actions.tap(slot);
    if (before === null) {
      sounds.tap();
      setMessage(ui.picturePuzzle.pickedUp);
    } else if (before === slot) {
      setMessage('');
    } else if (isSolved(store.state)) {
      sounds.done();
      setMessage(fill(ui.picturePuzzle.whole, { name: pictureName(picture) }, lang));
    } else {
      sounds.tap();
      const total = store.state.order.length;
      setMessage(fill(plural(ui.picturePuzzle.swapped, total, lang), { correct: correctCount(store.state), total }));
    }
  };

  const pictures = PUZZLE_PICTURES.map((id) => ({ value: id, label: ui.picturePuzzle.pictures[id] }));
  const sizes = SIZES.map((n) => ({ value: n, label: fill(plural(ui.picturePuzzle.size, n * n, lang), { n: n * n }) }));
  const url = pictureUrl(picture);
  const pct = (n: number) => (n / (state.size - 1)) * 100;
  return (
    <GameFrame
      ui={ui}
      lang={lang}
      guidance={ui.picturePuzzle.guidance}
      message={message}
      onRestart={() => setRound((r) => r + 1)}
      restartLabel={ui.picturePuzzle.restart}
      options={
        <>
          <ChoiceChips legend={ui.picturePuzzle.pictureLegend} choices={pictures} value={picture} onChange={setPicture} />
          <ChoiceChips legend={ui.picturePuzzle.sizeLegend} choices={sizes} value={size} onChange={(v) => setSize(v as 2 | 3)} />
        </>
      }
    >
      <div className="puzzle-guide">
        <img src={url} alt={fill(ui.picturePuzzle.guideAlt, { name: pictureName(picture) })} width={96} height={96} />
        <p className="m-0">{ui.picturePuzzle.guideText}</p>
      </div>
      <div className="puzzle" data-size={state.size}>
        {state.order.map((piece, slot) => {
          const row = Math.floor(piece / state.size);
          const col = piece % state.size;
          const correct = piece === slot;
          return (
            <button
              key={slot}
              type="button"
              className={`piece${state.selected === slot ? ' piece--selected' : ''}${correct ? ' piece--correct' : ''}`}
              style={{
                backgroundImage: `url(${url})`,
                backgroundSize: `${state.size * 100}% ${state.size * 100}%`,
                backgroundPosition: `${pct(col)}% ${pct(row)}%`,
              }}
              onClick={() => tap(slot)}
              aria-label={`${fill(ui.picturePuzzle.piece, { place: placeName(slot) })}${correct ? ui.picturePuzzle.pieceInPlace : ''}${state.selected === slot ? ui.picturePuzzle.piecePickedUp : ''}`}
              aria-pressed={state.selected === slot}
            />
          );
        })}
      </div>
      {solved ? (
        <div className="game__done">
          <p>{ui.picturePuzzle.done}</p>
          <button type="button" className="btn btn--primary" onClick={() => setRound((r) => r + 1)}>
            {ui.picturePuzzle.playAgain}
          </button>
        </div>
      ) : null}
    </GameFrame>
  );
}
