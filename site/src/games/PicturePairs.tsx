import { useMemo, useState } from 'react';
import { PICTURES } from '../data/pictures';
import { createRng, randomSeed, sample } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { PairsBoard } from './shared/PairsBoard';

const SIZES = [
  { value: 4, label: '4 tiles' },
  { value: 6, label: '6 tiles' },
  { value: 8, label: '8 tiles' },
  { value: 12, label: '12 tiles' },
] as const;

const VIEW = [
  { value: 'showing', label: 'Pictures showing' },
  { value: 'hidden', label: 'Hidden pictures' },
] as const;

export default function PicturePairs() {
  const [size, setSize] = useState<number>(4);
  const [view, setView] = useState<'showing' | 'hidden'>('showing');
  const [round, setRound] = useState(0);
  const [message, setMessage] = useState('');
  const [done, setDone] = useState(false);

  // A fresh set of pictures each round.
  const values = useMemo(
    () => sample(PICTURES.map((p) => p.id), size / 2, createRng(randomSeed())),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [size, round],
  );

  const restart = () => {
    setDone(false);
    setRound((r) => r + 1);
  };

  return (
    <GameFrame
      guidance={view === 'showing' ? 'Tap a picture, then tap the one that matches it.' : 'Tap two tiles to turn them over. Look for two the same.'}
      message={message}
      onRestart={restart}
      restartLabel="New pictures"
      options={
        <>
          <ChoiceChips legend="How many tiles" choices={SIZES} value={size} onChange={(v) => { setSize(v); setDone(false); }} />
          <ChoiceChips legend="How to play" choices={VIEW} value={view} onChange={(v) => { setView(v); restart(); }} />
        </>
      }
      footer={
        done ? (
          <div className="game__done">
            <div className="btn-row">
              <button type="button" className="btn btn--primary" onClick={restart}>
                Play again with new pictures
              </button>
              <a className="btn" href="/games/conversation-cards/">
                Talk about pictures together
              </a>
            </div>
          </div>
        ) : null
      }
    >
      <PairsBoard values={values} hidden={view === 'hidden'} round={round} onMessage={setMessage} onComplete={() => setDone(true)} />
    </GameFrame>
  );
}
