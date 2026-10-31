import { useEffect, useState } from 'react';
import { pictureShadowUrl } from '../data/pictures';
import { createRng, randomSeed } from '../lib/games/random';
import { createShadowRound, type ShadowRound } from '../lib/games/shadow';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { PictureTile, pictureName } from './shared/PictureTile';
import { sounds } from './shared/sound';

const COUNTS = [
  { value: 2, label: '2 to choose from' },
  { value: 3, label: '3 to choose from' },
  { value: 4, label: '4 to choose from' },
] as const;

const newRound = (count: number, previous?: string): ShadowRound => createShadowRound(count, createRng(randomSeed()), previous);

export default function ShadowMatch() {
  const [count, setCount] = useState<number>(2);
  const [round, setRound] = useState<ShadowRound | null>(null);
  const [found, setFound] = useState(false);
  const [tapped, setTapped] = useState<string | null>(null);
  const [message, setMessage] = useState('');

  useEffect(() => {
    setRound(newRound(count));
    setFound(false);
    setTapped(null);
    setMessage('');
  }, [count]);

  const next = () => {
    setRound((r) => newRound(count, r?.target));
    setFound(false);
    setTapped(null);
    setMessage('');
  };

  if (!round) return null;
  const targetName = pictureName(round.target);

  const tap = (id: string) => {
    if (found) return;
    setTapped(id);
    if (id === round.target) {
      sounds.match();
      setFound(true);
      setMessage(`Yes, the ${targetName.toLowerCase()} makes that shadow.`);
    } else {
      sounds.tap();
      setMessage(`That one is the ${pictureName(id).toLowerCase()}. Take your time.`);
    }
  };

  return (
    <GameFrame
      guidance="Look at the shadow at the top. Tap the picture that makes it."
      message={message}
      options={<ChoiceChips legend="How many pictures" choices={COUNTS} value={count} onChange={setCount} />}
      footer={
        <div className="btn-row btn-row--center">
          <button type="button" className={found ? 'btn btn--primary btn--hero' : 'btn'} onClick={next}>
            Next shadow
          </button>
        </div>
      }
    >
      <div className="target">
        <div className="target__print target__print--shadow">
          <img
            src={pictureShadowUrl(round.target)}
            alt={found ? `The shadow of the ${targetName.toLowerCase()}` : 'A shadow to match'}
            width={196}
            height={196}
          />
        </div>
        {found && <span className="target__name">{targetName}</span>}
      </div>
      <div className="board" data-cols={2} data-width="small">
        {round.options.map((id, i) => (
          <PictureTile
            key={`${round.target}-${id}`}
            value={id}
            position={i + 1}
            state={found && id === round.target ? 'matched' : tapped === id ? 'selected' : 'resting'}
            onTap={() => tap(id)}
          />
        ))}
      </div>
    </GameFrame>
  );
}
