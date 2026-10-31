import { useEffect, useMemo, useState } from 'react';
import { pictureUrl } from '../data/pictures';
import { TALK_CARDS, TALK_THEMES, type TalkTheme } from '../data/prompts';
import { createRng, randomSeed, shuffle } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { pictureName } from './shared/PictureTile';

const themeLabel = (t: TalkTheme) => TALK_THEMES.find((x) => x.value === t)?.label ?? '';

export default function ConversationCards() {
  const [theme, setTheme] = useState<TalkTheme | 'all'>('all');
  const [seed, setSeed] = useState(0);
  const [index, setIndex] = useState(0);

  useEffect(() => setSeed(randomSeed()), []);

  const deck = useMemo(
    () => shuffle(theme === 'all' ? TALK_CARDS : TALK_CARDS.filter((c) => c.theme === theme), createRng(seed)),
    [theme, seed],
  );
  useEffect(() => setIndex(0), [theme]);
  const card = deck[index % deck.length];
  if (!card) return null;

  return (
    <>
      <GameFrame
        guidance="Read the card out loud. There are no right answers."
        message={`Card ${(index % deck.length) + 1} of ${deck.length}`}
        options={<ChoiceChips legend="Theme" choices={TALK_THEMES} value={theme} onChange={setTheme} />}
        footer={
          <div className="btn-row">
            <button type="button" className="btn btn--primary btn--hero" onClick={() => setIndex((i) => i + 1)}>
              Next card
              <Icon name="arrow" />
            </button>
            <button type="button" className="btn" onClick={() => setIndex((i) => (i - 1 + deck.length) % deck.length)}>
              <Icon name="back" />
              Previous card
            </button>
            <button type="button" className="btn" onClick={() => window.print()}>
              <Icon name="print" />
              Print all cards
            </button>
          </div>
        }
      >
        <article className="talk-card">
          <img src={pictureUrl(card.picture)} alt={pictureName(card.picture)} width={220} height={220} />
          <div>
            <p className="talk-card__theme">{themeLabel(card.theme)}</p>
            <p className="talk-card__prompt">{card.prompt}</p>
          </div>
        </article>
      </GameFrame>
      <section className="sheet" aria-hidden="true">
        <h2>Conversation cards</h2>
        <div className="sheet-cards">
          {TALK_CARDS.map((c, i) => (
            <article key={i}>
              <img src={pictureUrl(c.picture)} alt="" />
              <span>{c.prompt}</span>
            </article>
          ))}
        </div>
      </section>
    </>
  );
}
