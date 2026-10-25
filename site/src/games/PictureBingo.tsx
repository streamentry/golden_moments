import { useEffect, useState } from 'react';
import { PICTURES, pictureUrl } from '../data/pictures';
import { createBingoCards, createCallOrder } from '../lib/games/bingo';
import { createRng, randomSeed } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { pictureName } from './shared/PictureTile';
import { sounds } from './shared/sound';

const POOL = PICTURES.map((p) => p.id);

const SQUARES = [
  { value: 9, label: '9 squares (3 by 3)' },
  { value: 16, label: '16 squares (4 by 4)' },
] as const;

const PLAYERS = [
  { value: 4, label: '4 cards' },
  { value: 8, label: '8 cards' },
  { value: 12, label: '12 cards' },
  { value: 20, label: '20 cards' },
] as const;

export default function PictureBingo() {
  const [squares, setSquares] = useState<number>(9);
  const [players, setPlayers] = useState<number>(8);
  const [cards, setCards] = useState<string[][]>([]);
  const [calls, setCalls] = useState<string[]>([]);
  const [called, setCalled] = useState(0);

  useEffect(() => {
    setCards(createBingoCards(POOL, squares, players, createRng(randomSeed())));
  }, [squares, players]);

  const newGame = () => {
    setCalls(createCallOrder(POOL, createRng(randomSeed())));
    setCalled(0);
  };
  useEffect(newGame, []);

  const current = called > 0 ? calls[called - 1] : undefined;
  const next = () => {
    if (called >= calls.length) return;
    sounds.tap();
    setCalled((n) => n + 1);
  };

  return (
    <>
      <GameFrame
        guidance="Print the cards first. Then show this caller on the biggest screen you have."
        message={current ? `${pictureName(current)}. ${called} of ${calls.length} pictures called.` : 'Tap "Next picture" to call the first picture.'}
        onRestart={newGame}
        restartLabel="Start a new game"
        options={
          <>
            <ChoiceChips legend="Squares on each card" choices={SQUARES} value={squares} onChange={setSquares} />
            <ChoiceChips legend="How many cards to print" choices={PLAYERS} value={players} onChange={setPlayers} />
            <div className="btn-row">
              <button type="button" className="btn" onClick={() => window.print()}>
                <Icon name="print" />
                Print {players} bingo cards
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
            <p className="caller__name">Ready when you are</p>
          )}
          <button type="button" className="btn btn--primary btn--hero" onClick={next} disabled={called >= calls.length}>
            {called >= calls.length ? 'Every picture has been called' : 'Next picture'}
          </button>
          {called > 1 ? (
            <div>
              <h2 className="caller__heading">Already called</h2>
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
            <h2>Picture bingo · card {i + 1}</h2>
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
