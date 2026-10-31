import { useEffect, useState } from 'react';
import { PICTURES, pictureUrl } from '../data/pictures';
import type { PlayProps } from '../i18n/play';
import { fill, plural } from '../i18n/play/format';
import { createBingoCards, createCallOrder } from '../lib/games/bingo';
import { createRng, randomSeed } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { pictureNamer } from './shared/PictureTile';
import { sounds } from './shared/sound';

const POOL = PICTURES.map((p) => p.id);

const SQUARES = [9, 16] as const;
const PLAYERS = [4, 8, 12, 20] as const;

export default function PictureBingo(props: PlayProps) {
  const { ui, lang } = props;
  const pictureName = pictureNamer(props);
  const [squares, setSquares] = useState<number>(9);
  const [players, setPlayers] = useState<number>(8);
  const [cards, setCards] = useState<string[][]>([]);
  const [calls, setCalls] = useState<string[]>(() => createCallOrder(POOL, createRng(randomSeed())));
  const [called, setCalled] = useState(0);

  useEffect(() => {
    setCards(createBingoCards(POOL, squares, players, createRng(randomSeed())));
  }, [squares, players]);

  const newGame = () => {
    setCalls(createCallOrder(POOL, createRng(randomSeed())));
    setCalled(0);
  };

  const current = called > 0 ? calls[called - 1] : undefined;
  const next = () => {
    if (called >= calls.length) return;
    sounds.tap();
    setCalled((n) => n + 1);
  };

  const squareChoices = SQUARES.map((n) => ({ value: n, label: fill(ui.pictureBingo.squares, { n, side: Math.sqrt(n) }) }));
  const playerChoices = PLAYERS.map((n) => ({ value: n, label: fill(plural(ui.pictureBingo.cards, n, lang), { n }) }));

  return (
    <>
      <GameFrame
        ui={ui}
        lang={lang}
        guidance={ui.pictureBingo.guidance}
        message={
          current
            ? fill(plural(ui.pictureBingo.called, calls.length, lang), { name: pictureName(current), called, total: calls.length })
            : ui.pictureBingo.start
        }
        onRestart={newGame}
        restartLabel={ui.pictureBingo.restart}
        options={
          <>
            <ChoiceChips legend={ui.pictureBingo.squaresLegend} choices={squareChoices} value={squares} onChange={setSquares} />
            <ChoiceChips legend={ui.pictureBingo.cardsLegend} choices={playerChoices} value={players} onChange={setPlayers} />
            <div className="btn-row">
              <button type="button" className="btn" onClick={() => window.print()}>
                <Icon name="print" />
                {fill(plural(ui.pictureBingo.print, players, lang), { n: players })}
              </button>
            </div>
          </>
        }
      >
        <div className="caller">
          {current ? (
            <>
              <div className="caller__print">
                <img src={pictureUrl(current)} alt="" width={312} height={312} />
              </div>
              <p className="caller__name">{pictureName(current)}</p>
            </>
          ) : (
            <p className="caller__name">{ui.pictureBingo.ready}</p>
          )}
          <button type="button" className="btn btn--primary btn--hero" onClick={next} aria-disabled={called >= calls.length}>
            {called >= calls.length ? ui.pictureBingo.allCalled : ui.pictureBingo.next}
          </button>
          {called > 1 ? (
            <div>
              <h2 className="caller__heading">{ui.pictureBingo.alreadyCalled}</h2>
              <ul className="called">
                {calls.slice(0, called - 1).reverse().map((id) => (
                  <li key={id}>
                    <img src={pictureUrl(id)} alt={pictureName(id)} width={52} height={52} />
                  </li>
                ))}
              </ul>
            </div>
          ) : null}
        </div>
      </GameFrame>
      <section className="sheet" aria-hidden="true">
        {cards.map((card, i) => (
          <div className="sheet__page" key={i}>
            <h2>{fill(ui.pictureBingo.sheetTitle, { n: i + 1 })}</h2>
            <div className="sheet-bingo" data-cols={Math.sqrt(squares)}>
              {card.map((id) => (
                <div key={id}>
                  <img src={pictureUrl(id)} alt="" />
                  {pictureName(id)}
                </div>
              ))}
            </div>
            <p>dementiaactivities.games</p>
          </div>
        ))}
      </section>
    </>
  );
}
