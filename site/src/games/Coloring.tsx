import { useEffect, useState, type KeyboardEvent } from 'react';
import { COLORING_PAGES, PAINTS } from '../data/coloring';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { sounds } from './shared/sound';

const INK = '#2b2b2b';

export default function Coloring() {
  const [pageId, setPageId] = useState(COLORING_PAGES[0]!.id);
  const [paint, setPaint] = useState(PAINTS[2]!);
  const [fills, setFills] = useState<Record<string, string>>({});
  const [message, setMessage] = useState('');
  const page = COLORING_PAGES.find((p) => p.id === pageId) ?? COLORING_PAGES[0]!;

  useEffect(() => {
    setFills({});
    setMessage('');
  }, [pageId]);

  const fill = (id: string, label: string) => {
    setFills((f) => ({ ...f, [id]: paint.value }));
    sounds.tap();
    setMessage(`${label} is now ${paint.label.toLowerCase()}.`);
  };

  const onKey = (e: KeyboardEvent, id: string, label: string) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      fill(id, label);
    }
  };

  const art = (interactive: boolean) => (
    <svg viewBox="0 0 400 400" role={interactive ? 'group' : 'img'} aria-label={interactive ? `${page.name}, ${page.regions.length} parts to color` : page.name}>
      {page.regions.map((r) => (
        <path
          key={r.id}
          d={r.d}
          data-region={interactive ? r.id : undefined}
          fill={interactive ? (fills[r.id] ?? '#FFFFFF') : '#FFFFFF'}
          stroke={INK}
          strokeWidth={4}
          strokeLinejoin="round"
          {...(interactive
            ? {
                role: 'button',
                tabIndex: 0,
                'aria-label': `${r.label}${fills[r.id] ? `, ${PAINTS.find((p) => p.value === fills[r.id])?.label.toLowerCase()}` : ', not colored'}`,
                onClick: () => fill(r.id, r.label),
                onKeyDown: (e: KeyboardEvent) => onKey(e, r.id, r.label),
              }
            : {})}
        />
      ))}
      {page.details ? <path d={page.details} fill="none" stroke={INK} strokeWidth={4} strokeLinecap="round" pointerEvents="none" /> : null}
    </svg>
  );

  return (
    <>
      <GameFrame
        guidance="Tap a color, then tap a part of the picture."
        message={message}
        onRestart={() => { setFills({}); setMessage('The page is blank again.'); }}
        restartLabel="Clear the colors"
        options={
          <ChoiceChips
            legend="Page"
            choices={COLORING_PAGES.map((p) => ({ value: p.id, label: p.name }))}
            value={pageId}
            onChange={setPageId}
          />
        }
        footer={
          <div className="btn-row">
            <button type="button" className="btn" onClick={() => window.print()}>
              <Icon name="print" />
              Print this page
            </button>
          </div>
        }
      >
        <div className="palette" role="group" aria-label="Colors">
          {PAINTS.map((p) => (
            <button
              key={p.value}
              type="button"
              className="swatch"
              aria-pressed={p.value === paint.value}
              onClick={() => { setPaint(p); setMessage(`${p.label} chosen.`); }}
            >
              <span className="swatch__dot" data-paint={p.label} aria-hidden="true" />
              {p.label}
            </button>
          ))}
        </div>
        <div className="color-page">{art(true)}</div>
      </GameFrame>
      <section className="sheet sheet-color" aria-hidden="true">
        <h2>{page.name}</h2>
        {art(false)}
      </section>
    </>
  );
}
