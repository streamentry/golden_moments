import { useCreateStore, useSelector } from '@tanstack/react-store';
import { useEffect, useState } from 'react';
import { picturesIn, pictureUrl, type PictureCategory } from '../data/pictures';
import type { PlayProps } from '../i18n/play';
import { fill, plural } from '../i18n/play/format';
import { createRng, randomSeed } from '../lib/games/random';
import { createSort, dropInBasket, isSorted, selectItem, type SortState } from '../lib/games/sorting';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { PictureTile, pictureNamer } from './shared/PictureTile';
import { sounds } from './shared/sound';

interface Theme {
  /** Key for the chip label and basket names in `content.sorting.themes`. */
  value: string;
  categories: [PictureCategory, PictureCategory];
}

const THEMES: readonly Theme[] = [
  { value: 'kitchen-garden', categories: ['kitchen', 'garden'] },
  { value: 'fruit-animals', categories: ['fruit', 'animals'] },
  { value: 'home-travel', categories: ['home', 'travel'] },
];

const ids = (c: PictureCategory) => picturesIn(c).map((p) => p.id);

export default function SortTogether(props: PlayProps) {
  const { ui, lang, content } = props;
  const pictureName = pictureNamer(props);
  const [themeKey, setThemeKey] = useState(THEMES[0]!.value);
  const [round, setRound] = useState(0);
  const [message, setMessage] = useState('');
  const theme = THEMES.find((t) => t.value === themeKey) ?? THEMES[0]!;
  const text = (t: Theme) => content.sorting.themes[t.value] ?? { label: t.value, baskets: t.categories };
  const baskets = text(theme).baskets;

  const store = useCreateStore<SortState, { select: (id: string) => void; drop: (b: 0 | 1) => void; reset: (t: Theme) => void }>(
    { items: [], placed: {}, selected: null, hint: null },
    ({ setState }) => ({
      select: (id) => setState((s) => selectItem(s, id)),
      drop: (b) => setState((s) => dropInBasket(s, b)),
      reset: (t) => setState(() => createSort(ids(t.categories[0]), ids(t.categories[1]), 3, createRng(randomSeed()))),
    }),
  );
  const state = useSelector(store);

  useEffect(() => {
    store.actions.reset(theme);
    setMessage('');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [themeKey, round]);

  const select = (id: string) => {
    store.actions.select(id);
    sounds.tap();
    const sel = store.state.selected;
    setMessage(sel ? fill(ui.sortTogether.selected, { name: pictureName(sel) }) : '');
  };

  const drop = (b: 0 | 1) => {
    const id = store.state.selected;
    if (!id) {
      setMessage(ui.sortTogether.pickFirst);
      return;
    }
    store.actions.drop(b);
    const after = store.state;
    if (after.hint) {
      setMessage(fill(ui.sortTogether.hint, { name: pictureName(id), basket: baskets[after.hint.basket] }, lang));
    } else if (isSorted(after)) {
      sounds.done();
      setMessage(ui.sortTogether.sorted);
    } else {
      sounds.match();
      setMessage(fill(ui.sortTogether.placed, { name: pictureName(id), basket: baskets[b] }, lang));
    }
  };

  const choices = THEMES.map((t) => ({ value: t.value, label: text(t).label }));
  const waiting = state.items.filter((i) => state.placed[i.id] === undefined);
  return (
    <GameFrame
      ui={ui}
      lang={lang}
      guidance={ui.sortTogether.guidance}
      message={message}
      onRestart={() => setRound((r) => r + 1)}
      restartLabel={ui.sortTogether.restart}
      options={<ChoiceChips legend={ui.sortTogether.themeLegend} choices={choices} value={themeKey} onChange={setThemeKey} />}
    >
      {waiting.length > 0 ? (
        <div className="board" data-cols={3} data-width="medium">
          {waiting.map((item, i) => (
            <PictureTile
              key={item.id}
              ui={ui}
              value={item.id}
              name={pictureName(item.id)}
              position={i + 1}
              state={state.selected === item.id ? 'selected' : 'resting'}
              onTap={() => select(item.id)}
            />
          ))}
        </div>
      ) : null}
      <div className="baskets">
        {baskets.map((name, b) => {
          const inside = state.items.filter((i) => state.placed[i.id] === b);
          return (
            <button
              key={`${theme.value}-${b}`}
              type="button"
              className={`basket${state.selected ? ' basket--ready' : ''}`}
              onClick={() => drop(b as 0 | 1)}
              aria-label={fill(plural(ui.sortTogether.basket, inside.length, lang), { basket: name, count: inside.length })}
            >
              <span className="basket__title">{name}</span>
              <span className="basket__items">
                {inside.map((i) => (
                  <img key={i.id} src={pictureUrl(i.id)} alt="" width={48} height={48} />
                ))}
              </span>
            </button>
          );
        })}
      </div>
    </GameFrame>
  );
}
