import { useEffect, useRef, useState } from 'react';
import type { Saying } from '../data/sayings';
import type { PlayProps } from '../i18n/play';
import { fill } from '../i18n/play/format';
import { createRng, randomSeed, shuffle } from '../lib/games/random';
import { GameFrame } from './shared/GameFrame';
import { sounds } from './shared/sound';

export default function FinishTheSaying(props: PlayProps) {
  const { ui, lang, content } = props;
  const [deck, setDeck] = useState<Saying[]>([]);
  const [index, setIndex] = useState(0);
  const [choices, setChoices] = useState<string[]>([]);
  const [revealed, setRevealed] = useState(false);
  const [message, setMessage] = useState('');
  // The choice buttons disappear once answered, so focus moves to Next saying.
  const nextButton = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    setDeck(shuffle(content.sayings, createRng(randomSeed())));
  }, [content.sayings]);

  const saying = deck[index];
  useEffect(() => {
    if (!saying) return;
    setChoices(shuffle([saying.end, ...saying.others], createRng(randomSeed())));
    setRevealed(false);
    setMessage('');
  }, [saying]);

  if (!saying) return null;
  const parts = { start: saying.start, end: saying.end };

  const choose = (word: string) => {
    if (revealed) return;
    setRevealed(true);
    nextButton.current?.focus();
    if (word === saying.end) {
      sounds.match();
      setMessage(fill(ui.finishTheSaying.yes, parts, lang));
    } else {
      sounds.tap();
      setMessage(fill(ui.finishTheSaying.otherEnding, { ...parts, word }, lang));
    }
  };

  const reveal = () => {
    setRevealed(true);
    nextButton.current?.focus();
    setMessage(fill(ui.finishTheSaying.revealed, parts, lang));
  };

  const next = () => setIndex((i) => (i + 1) % deck.length);

  return (
    <GameFrame ui={ui} lang={lang} guidance={ui.finishTheSaying.guidance} message={message}>
      <div className="say-card">
        <p className="say-card__text">
          {saying.start}
          {ui.finishTheSaying.gap}
          <span className="say-card__blank">{revealed ? fill(ui.finishTheSaying.ending, parts, lang) : '    '}</span>
        </p>
        {!revealed ? (
          <>
            <div className="say-choices" role="group" aria-label={ui.finishTheSaying.choicesLabel}>
              {choices.map((w) => (
                <button key={w} type="button" className="btn" onClick={() => choose(w)}>
                  {w}
                </button>
              ))}
            </div>
            <button type="button" className="btn btn--quiet" onClick={reveal}>
              {ui.finishTheSaying.show}
            </button>
          </>
        ) : (
          <p className="say-prompt">
            <strong>{ui.finishTheSaying.talk}</strong>
            {saying.prompt}
          </p>
        )}
      </div>
      <div className="btn-row btn-row--center">
        <button ref={nextButton} type="button" className={revealed ? 'btn btn--primary btn--hero' : 'btn'} onClick={next}>
          {ui.finishTheSaying.next}
        </button>
      </div>
    </GameFrame>
  );
}
