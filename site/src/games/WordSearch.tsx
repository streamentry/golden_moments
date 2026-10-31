import { useEffect, useRef, useState, type KeyboardEvent } from 'react';
import type { PlayProps } from '../i18n/play';
import { fill, plural } from '../i18n/play/format';
import { createRng, randomSeed, sample } from '../lib/games/random';
import { cellsOf, createWordSearch, wordBetween, type WordGrid } from '../lib/games/wordsearch';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { sounds } from './shared/sound';
import { useWide } from './shared/useWide';

const SIZES = [6, 8] as const;

/** Row and column steps for the arrow keys, in left-to-right layout. */
const MOVES: Record<string, [number, number]> = {
  ArrowUp: [-1, 0],
  ArrowDown: [1, 0],
  ArrowLeft: [0, -1],
  ArrowRight: [0, 1],
};

const WORDS_FOR: Record<number, number> = { 6: 4, 8: 6 };

export default function WordSearch(props: PlayProps) {
  if (!props.content.wordSearch.available) {
    return <p className="notice">{props.ui.wordSearch.unavailable}</p>;
  }
  return <WordSearchGame {...props} />;
}

function WordSearchGame(props: PlayProps) {
  const { ui, lang, content } = props;
  const themes = content.wordSearch.themes;
  const [theme, setTheme] = useState(themes[0]!.value);
  const [size, setSize] = useState<number>(6);
  const [round, setRound] = useState(0);
  const [grid, setGrid] = useState<WordGrid | null>(null);
  const [start, setStart] = useState<[number, number] | null>(null);
  const [found, setFound] = useState<string[]>([]);
  const [message, setMessage] = useState('');
  // One tab stop for the grid; arrow keys move between letters.
  const [cursor, setCursor] = useState<[number, number]>([0, 0]);
  const cells = useRef(new Map<string, HTMLButtonElement>());
  // 8 by 8 letters only stay 48px or larger on wider screens.
  const wide = useWide(560);
  const effectiveSize = wide ? size : 6;

  useEffect(() => {
    const t = themes.find((w) => w.value === theme) ?? themes[0]!;
    const rng = createRng(randomSeed());
    const words = sample(t.words, WORDS_FOR[effectiveSize] ?? 4, rng);
    setGrid(createWordSearch(words, effectiveSize, rng, { fill: content.wordSearch.fill, locale: lang }));
    setStart(null);
    setFound([]);
    setCursor([0, 0]);
    setMessage('');
  }, [theme, effectiveSize, round, themes, content.wordSearch.fill, lang]);

  if (!grid) return null;

  const foundCells = new Set(
    grid.words.filter((w) => found.includes(w.word)).flatMap((w) => cellsOf(w).map(([r, c]) => `${r}-${c}`)),
  );

  const tap = (r: number, c: number) => {
    if (!start) {
      sounds.tap();
      setStart([r, c]);
      setMessage(fill(ui.wordSearch.letterChosen, { letter: grid.cells[r]?.[c] ?? '' }));
      return;
    }
    if (start[0] === r && start[1] === c) {
      setStart(null);
      setMessage('');
      return;
    }
    const w = wordBetween(grid, start, [r, c]);
    setStart(null);
    if (w && !found.includes(w.word)) {
      const next = [...found, w.word];
      setFound(next);
      if (next.length === grid.words.length) {
        sounds.done();
        setMessage(fill(ui.wordSearch.foundAll, { word: w.word }));
      } else {
        sounds.match();
        setMessage(fill(ui.wordSearch.found, { word: w.word }));
      }
    } else {
      setMessage(ui.wordSearch.tryAgain);
    }
  };

  const onKey = (e: KeyboardEvent<HTMLButtonElement>, r: number, c: number) => {
    const move = MOVES[e.key];
    if (!move) return;
    e.preventDefault();
    // In right-to-left pages the first column is on the right, so left and right swap.
    const rtl = getComputedStyle(e.currentTarget).direction === 'rtl';
    const dc = rtl ? -move[1] : move[1];
    const nr = Math.min(grid.size - 1, Math.max(0, r + move[0]));
    const nc = Math.min(grid.size - 1, Math.max(0, c + dc));
    setCursor([nr, nc]);
    cells.current.get(`${nr}-${nc}`)?.focus();
  };

  const sizes = SIZES.map((n) => {
    const words = WORDS_FOR[n] ?? 4;
    return { value: n, label: fill(plural(ui.wordSearch.size, words, lang), { n, words }) };
  });
  const themeChoices = themes.map((t) => ({ value: t.value, label: t.label }));
  const allFound = found.length === grid.words.length;
  return (
    <>
      <GameFrame
        ui={ui}
        lang={lang}
        guidance={ui.wordSearch.guidance}
        message={message}
        onRestart={() => setRound((n) => n + 1)}
        restartLabel={ui.wordSearch.restart}
        options={
          <>
            <ChoiceChips legend={ui.wordSearch.themeLegend} choices={themeChoices} value={theme} onChange={setTheme} />
            {wide ? <ChoiceChips legend={ui.wordSearch.sizeLegend} choices={sizes} value={size} onChange={setSize} /> : null}
          </>
        }
        footer={
          <div className="btn-row">
            <button type="button" className={allFound ? 'btn btn--primary' : 'btn'} onClick={() => window.print()}>
              <Icon name="print" />
              {ui.wordSearch.print}
            </button>
          </div>
        }
      >
        <div className="ws" role="group" aria-label={fill(ui.wordSearch.gridLabel, { n: grid.size })} data-size={grid.size}>
          {grid.cells.map((row, r) => (
            <div key={r} className="ws__row">
              {row.map((ch, c) => {
                const key = `${r}-${c}`;
                const isStart = start?.[0] === r && start?.[1] === c;
                return (
                  <button
                    key={key}
                    type="button"
                    className={`ws__cell${isStart ? ' ws__cell--start' : ''}${foundCells.has(key) ? ' ws__cell--found' : ''}`}
                    aria-label={`${fill(ui.wordSearch.cell, { letter: ch, row: r + 1, col: c + 1 })}${foundCells.has(key) ? ui.wordSearch.cellFound : ''}`}
                    aria-pressed={isStart}
                    tabIndex={cursor[0] === r && cursor[1] === c ? 0 : -1}
                    ref={(el) => {
                      if (el) cells.current.set(key, el);
                      else cells.current.delete(key);
                    }}
                    onFocus={() => setCursor([r, c])}
                    onKeyDown={(e) => onKey(e, r, c)}
                    onClick={() => tap(r, c)}
                  >
                    {ch}
                  </button>
                );
              })}
            </div>
          ))}
        </div>
        <h2 className="visually-hidden">{ui.wordSearch.wordsHeading}</h2>
        <ul className="ws-words">
          {grid.words.map((w) => (
            <li key={w.word} data-found={found.includes(w.word)}>
              {found.includes(w.word) ? <Icon name="check" size={20} /> : null}
              {w.word}
              {found.includes(w.word) ? <span className="visually-hidden">{ui.wordSearch.wordFound}</span> : null}
            </li>
          ))}
        </ul>
      </GameFrame>
      <section className="sheet" aria-hidden="true">
        <h2>{fill(ui.wordSearch.sheetTitle, { theme: themes.find((t) => t.value === theme)?.label ?? '' })}</h2>
        <div className="sheet-ws" data-size={grid.size}>
          {grid.cells.flat().map((ch, i) => (
            <span key={i}>{ch}</span>
          ))}
        </div>
        <p>{ui.wordSearch.sheetNote}</p>
        <ul className="sheet-words">
          {grid.words.map((w) => (
            <li key={w.word}>☐ {w.word}</li>
          ))}
        </ul>
        <p>dementiaactivities.games</p>
      </section>
    </>
  );
}
