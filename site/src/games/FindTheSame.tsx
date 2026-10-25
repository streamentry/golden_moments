import { useEffect, useState } from 'react';
import { PICTURES, pictureUrl } from '../data/pictures';
import { createRng, randomSeed, sample, shuffle } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { PictureTile, pictureName } from './shared/PictureTile';
import { sounds } from './shared/sound';

interface Round {
  target: string;
  options: string[];
}

const COUNTS = [
  { value: 2, label: '2 to choose from' },
  { value: 3, label: '3 to choose from' },
  { value: 4, label: '4 to choose from' },
] as const;

function newRound(count: number, previous?: string): Round {
  const rng = createRng(randomSeed());
  const pool = PICTURES.map((p) => p.id).filter((id) => id !== previous);
  const picked = sample(pool, count, rng);
  return { target: picked[0] as string, options: shuffle(picked, rng) };
}

export default function FindTheSame() {
  const [count, setCount] = useState<number>(2);
  const [round, setRound] = useState<Round | null>(null);
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
      setMessage(`Yes, the same ${targetName.toLowerCase()}.`);
    } else {
      sounds.tap();
      setMessage(`That one is the ${pictureName(id).toLowerCase()}. Take your time.`);
    }
  };

  return (
    <GameFrame
      guidance="Look at the picture at the top. Tap the same one below."
      message={message}
      options={<ChoiceChips legend="How many pictures" choices={COUNTS} value={count} onChange={setCount} />}
      footer={
        <div className="btn-row btn-row--center">
          <button type="button" className={found ? 'btn btn--primary btn--hero' : 'btn'} onClick={next}>
            Next picture
          </button>
        </div>
      }
    >
      <div className="target">
        <div className="target__print">
          <img src={pictureUrl(round.target)} alt={targetName} width={196} height={196} />
        </div>
        <span className="target__name">{targetName}</span>
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
