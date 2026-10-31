import { useCreateStore, useSelector } from '@tanstack/react-store';
import { useEffect, useState } from 'react';
import { picturesIn, pictureUrl, type PictureCategory } from '../data/pictures';
import { createRng, randomSeed } from '../lib/games/random';
import { createSort, dropInBasket, isSorted, selectItem, type SortState } from '../lib/games/sorting';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { PictureTile, pictureName } from './shared/PictureTile';
import { sounds } from './shared/sound';

interface Theme {
  value: string;
  label: string;
  baskets: [{ category: PictureCategory; name: string }, { category: PictureCategory; name: string }];
}

const THEMES: readonly Theme[] = [
  { value: 'kitchen-garden', label: 'Kitchen and garden', baskets: [{ category: 'kitchen', name: 'In the kitchen' }, { category: 'garden', name: 'In the garden' }] },
  { value: 'fruit-animals', label: 'Fruit and animals', baskets: [{ category: 'fruit', name: 'Fruit' }, { category: 'animals', name: 'Animals' }] },
  { value: 'home-travel', label: 'Home and travel', baskets: [{ category: 'home', name: 'At home' }, { category: 'travel', name: 'Out and about' }] },
];

const ids = (c: PictureCategory) => picturesIn(c).map((p) => p.id);

export default function SortTogether() {
  const [themeKey, setThemeKey] = useState(THEMES[0]!.value);
  const [round, setRound] = useState(0);
  const [message, setMessage] = useState('');
  const theme = THEMES.find((t) => t.value === themeKey) ?? THEMES[0]!;

  const store = useCreateStore<SortState, { select: (id: string) => void; drop: (b: 0 | 1) => void; reset: (t: Theme) => void }>(
    { items: [], placed: {}, selected: null, hint: null },
    ({ setState }) => ({
      select: (id) => setState((s) => selectItem(s, id)),
      drop: (b) => setState((s) => dropInBasket(s, b)),
      reset: (t) => setState(() => createSort(ids(t.baskets[0].category), ids(t.baskets[1].category), 3, createRng(randomSeed()))),
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
    setMessage(sel ? `${pictureName(sel)}. Now tap the basket it goes in.` : '');
  };

  const drop = (b: 0 | 1) => {
    const id = store.state.selected;
    if (!id) {
      setMessage('First tap a picture, then tap a basket.');
      return;
    }
    store.actions.drop(b);
    const after = store.state;
    if (after.hint) {
      setMessage(`The ${pictureName(id).toLowerCase()} could go in "${theme.baskets[after.hint.basket].name}". Tap that basket to put it there.`);
    } else if (isSorted(after)) {
      sounds.done();
      setMessage('Everything is sorted. Look through the baskets together, or try another theme.');
    } else {
      sounds.match();
      setMessage(`The ${pictureName(id).toLowerCase()} is in "${theme.baskets[b].name}".`);
    }
  };

  const waiting = state.items.filter((i) => state.placed[i.id] === undefined);
  return (
    <GameFrame
      guidance="Tap a picture, then tap the basket it belongs in."
      message={message}
      onRestart={() => setRound((r) => r + 1)}
      restartLabel="New pictures"
      options={<ChoiceChips legend="Theme" choices={THEMES} value={themeKey} onChange={setThemeKey} />}
    >
      {waiting.length > 0 ? (
        <div className="board" data-cols={3} data-width="medium">
          {waiting.map((item, i) => (
            <PictureTile
              key={item.id}
              value={item.id}
              position={i + 1}
              state={state.selected === item.id ? 'selected' : 'resting'}
              onTap={() => select(item.id)}
            />
          ))}
        </div>
      ) : null}
      <div className="baskets">
        {theme.baskets.map((basket, b) => {
          const inside = state.items.filter((i) => state.placed[i.id] === b);
          return (
            <button
              key={basket.name}
              type="button"
              className={`basket${state.selected ? ' basket--ready' : ''}`}
              onClick={() => drop(b as 0 | 1)}
              aria-label={`${basket.name} basket, ${inside.length} picture${inside.length === 1 ? '' : 's'} inside`}
            >
              <span className="basket__title">{basket.name}</span>
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
