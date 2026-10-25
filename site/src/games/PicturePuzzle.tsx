import { useCreateStore, useSelector } from '@tanstack/react-store';
import { useEffect, useState } from 'react';
import { pictureUrl } from '../data/pictures';
import { correctCount, createPuzzle, isSolved, tapPiece, type PuzzleState } from '../lib/games/puzzle';
import { createRng, randomSeed } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { pictureName } from './shared/PictureTile';
import { sounds } from './shared/sound';

const PICTURE_CHOICES = [
  { value: 'sailboat', label: 'Sailboat' },
  { value: 'house', label: 'House' },
  { value: 'balloon', label: 'Balloon' },
  { value: 'sunflower', label: 'Sunflower' },
  { value: 'lighthouse', label: 'Lighthouse' },
  { value: 'cat', label: 'Cat' },
] as const;

const SIZES = [
  { value: 2, label: '4 pieces' },
  { value: 3, label: '9 pieces' },
] as const;

const ROW_WORDS = ['top', 'middle', 'bottom'];
const COL_WORDS = ['left', 'center', 'right'];

function placeName(slot: number, size: 2 | 3): string {
  const row = Math.floor(slot / size);
  const col = slot % size;
  const r = size === 2 ? ['top', 'bottom'][row] : ROW_WORDS[row];
  const c = size === 2 ? ['left', 'right'][col] : COL_WORDS[col];
  return r === 'middle' && c === 'center' ? 'center' : `${r} ${c}`;
}

export default function PicturePuzzle() {
  const [picture, setPicture] = useState<string>('sailboat');
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

  const tap = (slot: number) => {
    if (solved) return;
    const before = store.state.selected;
    store.actions.tap(slot);
    if (before === null) {
      sounds.tap();
      setMessage(`Piece picked up. Now tap where it should go.`);
    } else if (before === slot) {
      setMessage('');
    } else if (isSolved(store.state)) {
      sounds.done();
      setMessage(`The ${pictureName(picture).toLowerCase()} is whole again. Choose another picture whenever you like.`);
    } else {
      sounds.tap();
      setMessage(`Swapped. ${correctCount(store.state)} of ${store.state.order.length} pieces are in place.`);
    }
  };

  const url = pictureUrl(picture);
  const pct = (n: number) => (n / (state.size - 1)) * 100;
  return (
    <GameFrame
      guidance="Tap one piece, then tap another. They swap places."
      message={message}
      onRestart={() => setRound((r) => r + 1)}
      restartLabel="Mix up again"
      options={
        <>
          <ChoiceChips legend="Picture" choices={PICTURE_CHOICES} value={picture} onChange={setPicture} />
          <ChoiceChips legend="Pieces" choices={SIZES} value={size} onChange={(v) => setSize(v as 2 | 3)} />
        </>
      }
    >
      <div className="puzzle-guide">
        <img src={url} alt={`The whole picture: ${pictureName(picture)}`} width={96} height={96} />
        <p className="m-0">This is how the picture looks when it is whole.</p>
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
              aria-label={`Piece in the ${placeName(slot, state.size)}${correct ? ', in the right place' : ''}${state.selected === slot ? ', picked up' : ''}`}
              aria-pressed={state.selected === slot}
            />
          );
        })}
      </div>
      {solved ? (
        <div className="game__done">
          <p>The picture is whole again. Play again or take a break.</p>
          <button type="button" className="btn btn--primary" onClick={() => setRound((r) => r + 1)}>
            Mix it up again
          </button>
        </div>
      ) : null}
    </GameFrame>
  );
}
