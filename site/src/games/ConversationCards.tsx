import { useEffect, useMemo, useState } from 'react';
import { pictureUrl } from '../data/pictures';
import { TALK_THEME_ORDER, type TalkTheme } from '../data/prompts';
import type { PlayProps } from '../i18n/play';
import { fill } from '../i18n/play/format';
import { createRng, randomSeed, shuffle } from '../lib/games/random';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { pictureNamer } from './shared/PictureTile';

export default function ConversationCards(props: PlayProps) {
  const { ui, lang, content } = props;
  const { cards, themes } = content.conversation;
  const pictureName = pictureNamer(props);
  const [theme, setTheme] = useState<TalkTheme | 'all'>('all');
  const [seed, setSeed] = useState(0);
  const [index, setIndex] = useState(0);

  useEffect(() => setSeed(randomSeed()), []);

  const deck = useMemo(
    () => shuffle(theme === 'all' ? cards : cards.filter((c) => c.theme === theme), createRng(seed)),
    [theme, seed, cards],
  );
  useEffect(() => setIndex(0), [theme]);
  const card = deck[index % deck.length];
  if (!card) return null;

  const themeChoices = TALK_THEME_ORDER.map((value) => ({ value, label: themes[value] }));

  return (
    <>
      <GameFrame
        ui={ui}
        lang={lang}
        guidance={ui.conversationCards.guidance}
        message={fill(ui.conversationCards.position, { n: (index % deck.length) + 1, total: deck.length })}
        options={<ChoiceChips legend={ui.conversationCards.themeLegend} choices={themeChoices} value={theme} onChange={setTheme} />}
        footer={
          <div className="btn-row">
            <button type="button" className="btn btn--primary btn--hero" onClick={() => setIndex((i) => i + 1)}>
              {ui.conversationCards.next}
              <Icon name="arrow" />
            </button>
            <button type="button" className="btn" onClick={() => setIndex((i) => (i - 1 + deck.length) % deck.length)}>
              <Icon name="back" />
              {ui.conversationCards.previous}
            </button>
            <button type="button" className="btn" onClick={() => window.print()}>
              <Icon name="print" />
              {ui.conversationCards.print}
            </button>
          </div>
        }
      >
        <article className="talk-card">
          <img src={pictureUrl(card.picture)} alt={pictureName(card.picture)} width={220} height={220} />
          <div>
            <p className="talk-card__theme">{themes[card.theme]}</p>
            <p className="talk-card__prompt">{card.prompt}</p>
          </div>
        </article>
      </GameFrame>
      <section className="sheet" aria-hidden="true">
        <h2>{ui.conversationCards.sheetTitle}</h2>
        <div className="sheet-cards">
          {cards.map((c, i) => (
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
