import { useEffect, useState } from 'react';
import { pictureShadowUrl } from '../data/pictures';
import type { PlayProps } from '../i18n/play';
import { fill } from '../i18n/play/format';
import { createRng, randomSeed } from '../lib/games/random';
import { createShadowRound, type ShadowRound } from '../lib/games/shadow';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { PictureTile, pictureNamer } from './shared/PictureTile';
import { sounds } from './shared/sound';

const COUNTS = [2, 3, 4] as const;

const newRound = (count: number, previous?: string): ShadowRound => createShadowRound(count, createRng(randomSeed()), previous);

export default function ShadowMatch(props: PlayProps) {
  const { ui, lang } = props;
  const pictureName = pictureNamer(props);
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
  const counts = COUNTS.map((n) => ({ value: n, label: fill(ui.choose.count, { n }) }));

  const tap = (id: string) => {
    if (found) return;
    setTapped(id);
    if (id === round.target) {
      sounds.match();
      setFound(true);
      setMessage(fill(ui.shadowMatch.yes, { name: targetName }, lang));
    } else {
      sounds.tap();
      setMessage(fill(ui.choose.thatOne, { name: pictureName(id) }, lang));
    }
  };

  return (
    <GameFrame
      ui={ui}
      lang={lang}
      guidance={ui.shadowMatch.guidance}
      message={message}
      options={<ChoiceChips legend={ui.choose.countLegend} choices={counts} value={count} onChange={setCount} />}
      footer={
        <div className="btn-row btn-row--center">
          <button type="button" className={found ? 'btn btn--primary btn--hero' : 'btn'} onClick={next}>
            {ui.shadowMatch.next}
          </button>
        </div>
      }
    >
      <div className="target">
        <div className="target__print target__print--shadow">
          <img
            src={pictureShadowUrl(round.target)}
            alt={found ? fill(ui.shadowMatch.foundAlt, { name: targetName }, lang) : ui.shadowMatch.shadowAlt}
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
            ui={ui}
            value={id}
            name={pictureName(id)}
            position={i + 1}
            state={found && id === round.target ? 'matched' : tapped === id ? 'selected' : 'resting'}
            onTap={() => tap(id)}
          />
        ))}
      </div>
    </GameFrame>
  );
}
