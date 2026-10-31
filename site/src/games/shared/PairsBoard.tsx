import { useCreateStore, useSelector } from '@tanstack/react-store';
import { useEffect } from 'react';
import type { PlayProps } from '../../i18n/play';
import { fill } from '../../i18n/play/format';
import { boardColumns, createPairs, isComplete, tapPair, type PairsState } from '../../lib/games/pairs';
import { createRng, randomSeed } from '../../lib/games/random';
import { PictureTile, pictureNamer, type TileState } from './PictureTile';
import { sounds } from './sound';
import { useWide } from './useWide';

interface PairsBoardProps {
  play: PlayProps;
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

export function PairsBoard({ play, values, hidden, photos = false, round, onMessage, onComplete }: PairsBoardProps) {
  const { ui, lang } = play;
  const pictureName = pictureNamer(play);
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

  const label = (v: string) => (photos ? fill(ui.tile.photoNumber, { n: values.indexOf(v) + 1 }) : pictureName(v));

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
        onMessage(ui.pairs.allTogether);
        onComplete();
      } else {
        sounds.match();
        onMessage(photos ? ui.pairs.photoPair : fill(ui.pairs.picturePair, { name: pictureName(v) }, lang));
      }
    } else if (after.mismatch) {
      // With hidden tiles a screen reader user cannot see what turned over, so name both.
      const [a, b] = after.mismatch;
      onMessage(
        hidden
          ? fill(ui.pairs.mismatchNamed, { a: label(after.tiles[a]?.value ?? ''), b: label(after.tiles[b]?.value ?? '') })
          : ui.pairs.mismatch,
      );
    } else {
      sounds.tap();
      const v = after.tiles[i]?.value ?? '';
      onMessage(after.selected === i ? fill(ui.pairs.selected, { name: label(v) }) : '');
    }
  };

  const cols = boardColumns(state.tiles.length, wide);
  return (
    <div className="board" data-cols={cols} data-width={state.tiles.length <= 4 ? 'small' : 'large'}>
      {state.tiles.map((t, i) => (
        <PictureTile
          key={t.key}
          ui={ui}
          value={t.value}
          photo={photos}
          name={label(t.value)}
          position={i + 1}
          state={tileState(state, i, hidden)}
          onTap={() => onTap(i)}
        />
      ))}
    </div>
  );
}
