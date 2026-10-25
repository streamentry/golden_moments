import { useCreateStore, useSelector } from '@tanstack/react-store';
import { useEffect } from 'react';
import { boardColumns, createPairs, isComplete, tapPair, type PairsState } from '../../lib/games/pairs';
import { createRng, randomSeed } from '../../lib/games/random';
import { PictureTile, pictureName, type TileState } from './PictureTile';
import { sounds } from './sound';
import { useWide } from './useWide';

interface PairsBoardProps {
  values: readonly string[];
  hidden: boolean;
  photos?: boolean;
  /** Changing this starts a new board. */
  round: number;
  onMessage: (message: string) => void;
  onComplete: () => void;
}

function tileState(state: PairsState, i: number, hidden: boolean): TileState {
  const t = state.tiles[i];
  if (!t) return 'resting';
  if (t.matched) return 'matched';
  if (state.mismatch?.includes(i)) return 'mismatch';
  if (state.selected === i) return 'selected';
  return hidden ? 'hidden' : 'resting';
}

export function PairsBoard({ values, hidden, photos = false, round, onMessage, onComplete }: PairsBoardProps) {
  const wide = useWide();
  const store = useCreateStore<PairsState, { tap: (i: number) => void; reset: (v: readonly string[]) => void }>(
    { tiles: [], selected: null, mismatch: null, lastMatch: null },
    ({ setState }) => ({
      tap: (i) => setState((s) => tapPair(s, i)),
      reset: (v) => setState(() => createPairs(v, createRng(randomSeed()))),
    }),
  );
  const state = useSelector(store);

  useEffect(() => {
    store.actions.reset(values);
    onMessage('');
    // `round` intentionally restarts the board.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [values, round]);

  const label = (v: string) => (photos ? `Photo ${values.indexOf(v) + 1}` : pictureName(v));

  const onTap = (i: number) => {
    const before = store.state;
    if (before.tiles[i]?.matched) return;
    store.actions.tap(i);
    const after = store.state;
    if (after === before) return;
    if (after.lastMatch !== null) {
      const v = after.tiles[i]?.value ?? '';
      if (isComplete(after)) {
        sounds.done();
        onMessage('All pairs together. Play again or take a break.');
        onComplete();
      } else {
        sounds.match();
        onMessage(photos ? 'A pair of photos, together.' : `Two pictures of the ${pictureName(v).toLowerCase()}, together.`);
      }
    } else if (after.mismatch) {
      onMessage('Take your time. Tap a picture to continue.');
    } else {
      sounds.tap();
      const v = after.tiles[i]?.value ?? '';
      onMessage(after.selected === i ? `${label(v)}. Now find its pair.` : '');
    }
  };

  const cols = boardColumns(state.tiles.length, wide);
  return (
    <div className="board" data-cols={cols} data-width={state.tiles.length <= 4 ? 'small' : 'large'}>
      {state.tiles.map((t, i) => (
        <PictureTile
          key={t.key}
          value={t.value}
          photo={photos}
          label={photos ? label(t.value) : undefined}
          position={i + 1}
          state={tileState(state, i, hidden)}
          onTap={() => onTap(i)}
        />
      ))}
    </div>
  );
}
