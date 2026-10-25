import { useEffect, useState } from 'react';
import { WORD_THEMES } from '../data/wordthemes';
import { createRng, randomSeed, sample } from '../lib/games/random';
import { cellsOf, createWordSearch, wordBetween, type WordGrid } from '../lib/games/wordsearch';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { sounds } from './shared/sound';

const SIZES = [
  { value: 6, label: '6 by 6 (4 words)' },
  { value: 8, label: '8 by 8 (6 words)' },
] as const;

const WORDS_FOR: Record<number, number> = { 6: 4, 8: 6 };

export default function WordSearch() {
  const [theme, setTheme] = useState(WORD_THEMES[0]!.value);
  const [size, setSize] = useState<number>(6);
  const [round, setRound] = useState(0);
  const [grid, setGrid] = useState<WordGrid | null>(null);
  const [start, setStart] = useState<[number, number] | null>(null);
  const [found, setFound] = useState<string[]>([]);
  const [message, setMessage] = useState('');

  useEffect(() => {
    const t = WORD_THEMES.find((w) => w.value === theme) ?? WORD_THEMES[0]!;
    const rng = createRng(randomSeed());
    const words = sample(t.words, WORDS_FOR[size] ?? 4, rng);
    setGrid(createWordSearch(words, size, rng));
    setStart(null);
    setFound([]);
    setMessage('');
  }, [theme, size, round]);

  if (!grid) return null;

  const foundCells = new Set(
    grid.words.filter((w) => found.includes(w.word)).flatMap((w) => cellsOf(w).map(([r, c]) => `${r}-${c}`)),
  );

  const tap = (r: number, c: number) => {
    if (!start) {
      sounds.tap();
      setStart([r, c]);
      setMessage(`Letter ${grid.cells[r]?.[c]} chosen. Now tap the last letter of the word.`);
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
        setMessage(`${w.word} found. That is every word. Play again or take a break.`);
      } else {
        sounds.match();
        setMessage(`${w.word} found.`);
      }
    } else {
      setMessage('Take your time. Tap the first letter of a word, then its last letter.');
    }
  };

  const allFound = found.length === grid.words.length;
  return (
    <>
      <GameFrame
        guidance="Words go across or down. Tap the first letter of a word, then its last letter."
        message={message}
        onRestart={() => setRound((n) => n + 1)}
        restartLabel="New puzzle"
        options={
          <>
            <ChoiceChips legend="Theme" choices={WORD_THEMES} value={theme} onChange={setTheme} />
            <ChoiceChips legend="Grid size" choices={SIZES} value={size} onChange={setSize} />
          </>
        }
        footer={
          <div className="btn-row">
            <button type="button" className={allFound ? 'btn btn--primary' : 'btn'} onClick={() => window.print()}>
              <Icon name="print" />
              Print this puzzle
            </button>
          </div>
        }
      >
        <div className="ws" role="group" aria-label={`Letter grid, ${grid.size} rows of ${grid.size} letters`} data-size={grid.size}>
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
                    aria-label={`${ch}, row ${r + 1}, column ${c + 1}${foundCells.has(key) ? ', part of a found word' : ''}`}
                    aria-pressed={isStart}
                    onClick={() => tap(r, c)}
                  >
                    {ch}
                  </button>
                );
              })}
            </div>
          ))}
        </div>
        <h2 className="visually-hidden">Words to find</h2>
        <ul className="ws-words">
          {grid.words.map((w) => (
            <li key={w.word} data-found={found.includes(w.word)}>
              {found.includes(w.word) ? <Icon name="check" size={20} /> : null}
              {w.word}
              {found.includes(w.word) ? <span className="visually-hidden"> (found)</span> : null}
            </li>
          ))}
        </ul>
      </GameFrame>
      <section className="sheet" aria-hidden="true">
        <h2>Word search: {WORD_THEMES.find((t) => t.value === theme)?.label}</h2>
        <div className="sheet-ws" data-size={grid.size}>
          {grid.cells.flat().map((ch, i) => (
            <span key={i}>{ch}</span>
          ))}
        </div>
        <p>Words go across or down.</p>
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
