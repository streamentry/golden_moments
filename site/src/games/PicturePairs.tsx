import { useMemo, useState } from 'react';
import { PICTURES } from '../data/pictures';
import type { PlayProps } from '../i18n/play';
import { localePath } from '../i18n/locales';
import { fill, plural } from '../i18n/play/format';
import { createRng, randomSeed, sample } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { PairsBoard } from './shared/PairsBoard';

const SIZES = [4, 6, 8, 12] as const;

export default function PicturePairs(props: PlayProps) {
  const { ui, lang } = props;
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

  const sizes = SIZES.map((n) => ({ value: n, label: fill(plural(ui.picturePairs.size, n, lang), { n }) }));
  const views = [
    { value: 'showing', label: ui.picturePairs.viewShowing },
    { value: 'hidden', label: ui.picturePairs.viewHidden },
  ] as const;

  return (
    <GameFrame
      ui={ui}
      lang={lang}
      guidance={view === 'showing' ? ui.picturePairs.guidanceShowing : ui.picturePairs.guidanceHidden}
      message={message}
      onRestart={restart}
      restartLabel={ui.picturePairs.restart}
      options={
        <>
          <ChoiceChips legend={ui.picturePairs.sizeLegend} choices={sizes} value={size} onChange={(v) => { setSize(v); setDone(false); }} />
          <ChoiceChips legend={ui.picturePairs.viewLegend} choices={views} value={view} onChange={(v) => { setView(v); restart(); }} />
        </>
      }
      footer={
        done ? (
          <div className="game__done">
            <div className="btn-row">
              <button type="button" className="btn btn--primary" onClick={restart}>
                {ui.picturePairs.playAgain}
              </button>
              <a className="btn" href={localePath(lang, '/games/conversation-cards/')}>
                {ui.picturePairs.talk}
              </a>
            </div>
          </div>
        ) : null
      }
    >
      <PairsBoard play={props} values={values} hidden={view === 'hidden'} round={round} onMessage={setMessage} onComplete={() => setDone(true)} />
    </GameFrame>
  );
}
