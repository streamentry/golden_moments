import { useEffect, useRef, useState } from 'react';
import { SAYINGS, type Saying } from '../data/sayings';
import { createRng, randomSeed, shuffle } from '../lib/games/random';
import { GameFrame } from './shared/GameFrame';
import { sounds } from './shared/sound';

export default function FinishTheSaying() {
  const [deck, setDeck] = useState<Saying[]>([]);
  const [index, setIndex] = useState(0);
  const [choices, setChoices] = useState<string[]>([]);
  const [revealed, setRevealed] = useState(false);
  const [message, setMessage] = useState('');
  // The choice buttons disappear once answered, so focus moves to Next saying.
  const nextButton = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    setDeck(shuffle(SAYINGS, createRng(randomSeed())));
  }, []);

  const saying = deck[index];
  useEffect(() => {
    if (!saying) return;
    setChoices(shuffle([saying.end, ...saying.others], createRng(randomSeed())));
    setRevealed(false);
    setMessage('');
  }, [saying]);

  if (!saying) return null;

  const choose = (word: string) => {
    if (revealed) return;
    setRevealed(true);
    nextButton.current?.focus();
    if (word === saying.end) {
      sounds.match();
      setMessage(`Yes, "${saying.start} ${saying.end}."`);
    } else {
      sounds.tap();
      setMessage(`"${word}" works too. The usual saying ends with "${saying.end}".`);
    }
  };

  const reveal = () => {
    setRevealed(true);
    nextButton.current?.focus();
    setMessage(`The saying is "${saying.start} ${saying.end}."`);
  };

  const next = () => setIndex((i) => (i + 1) % deck.length);

  return (
    <GameFrame guidance="Read the saying together, then tap the word that finishes it." message={message}>
      <div className="say-card">
        <p className="say-card__text">
          {saying.start}{' '}
          <span className="say-card__blank">{revealed ? `${saying.end}.` : '    '}</span>
        </p>
        {!revealed ? (
          <>
            <div className="say-choices" role="group" aria-label="Choose the last word">
              {choices.map((w) => (
                <button key={w} type="button" className="btn" onClick={() => choose(w)}>
                  {w}
                </button>
              ))}
            </div>
            <button type="button" className="btn btn--quiet" onClick={reveal}>
              Show the ending
            </button>
          </>
        ) : (
          <p className="say-prompt">
            <strong>Talk about it: </strong>
            {saying.prompt}
          </p>
        )}
      </div>
      <div className="btn-row btn-row--center">
        <button ref={nextButton} type="button" className={revealed ? 'btn btn--primary btn--hero' : 'btn'} onClick={next}>
          Next saying
        </button>
      </div>
    </GameFrame>
  );
}
