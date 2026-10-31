import { useEffect, useState, type KeyboardEvent } from 'react';
import { COLORING_PAGES, PAINTS, type Paint } from '../data/coloring';
import type { PlayProps } from '../i18n/play';
import { fill } from '../i18n/play/format';
import { ChoiceChips } from './shared/ChoiceChips';
import { GameFrame } from './shared/GameFrame';
import { Icon } from './shared/Icon';
import { sounds } from './shared/sound';

const INK = '#2b2b2b';

export default function Coloring(props: PlayProps) {
  const { ui, lang, content } = props;
  const [pageId, setPageId] = useState(COLORING_PAGES[0]!.id);
  const [paint, setPaint] = useState(PAINTS[2]!);
  const [fills, setFills] = useState<Record<string, string>>({});
  const [message, setMessage] = useState('');
  const page = COLORING_PAGES.find((p) => p.id === pageId) ?? COLORING_PAGES[0]!;
  const pageText = (id: string) => content.coloring.pages[id] ?? { name: id, regions: {} };
  const pageName = pageText(page.id).name;
  const partName = (id: string) => pageText(page.id).regions[id] ?? id;
  const paintName = (p: Paint) => (ui.coloring.paints as Record<string, string>)[p.id] ?? p.id;

  useEffect(() => {
    setFills({});
    setMessage('');
  }, [pageId]);

  const paintPart = (id: string) => {
    setFills((f) => ({ ...f, [id]: paint.value }));
    sounds.tap();
    setMessage(fill(ui.coloring.painted, { part: partName(id), paint: paintName(paint) }, lang));
  };

  const onKey = (e: KeyboardEvent, id: string) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      paintPart(id);
    }
  };

  const partLabel = (id: string) => {
    const color = PAINTS.find((p) => p.value === fills[id]);
    return color
      ? fill(ui.coloring.partPainted, { part: partName(id), paint: paintName(color) }, lang)
      : fill(ui.coloring.partBlank, { part: partName(id) });
  };

  const art = (interactive: boolean) => (
    <svg
      viewBox="0 0 400 400"
      role={interactive ? 'group' : 'img'}
      aria-label={interactive ? fill(ui.coloring.artLabel, { page: pageName, count: page.regions.length }) : pageName}
    >
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
                'aria-label': partLabel(r.id),
                onClick: () => paintPart(r.id),
                onKeyDown: (e: KeyboardEvent) => onKey(e, r.id),
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
        ui={ui}
        lang={lang}
        guidance={ui.coloring.guidance}
        message={message}
        onRestart={() => { setFills({}); setMessage(ui.coloring.cleared); }}
        restartLabel={ui.coloring.restart}
        options={
          <ChoiceChips
            legend={ui.coloring.pageLegend}
            choices={COLORING_PAGES.map((p) => ({ value: p.id, label: pageText(p.id).name }))}
            value={pageId}
            onChange={setPageId}
          />
        }
        footer={
          <div className="btn-row">
            <button type="button" className="btn" onClick={() => window.print()}>
              <Icon name="print" />
              {ui.coloring.print}
            </button>
          </div>
        }
      >
        <div className="palette" role="group" aria-label={ui.coloring.colorsLabel}>
          {PAINTS.map((p) => (
            <button
              key={p.value}
              type="button"
              className="swatch"
              aria-pressed={p.value === paint.value}
              onClick={() => { setPaint(p); setMessage(fill(ui.coloring.paintChosen, { paint: paintName(p) })); }}
            >
              <span className="swatch__dot" data-paint={p.id} aria-hidden="true" />
              {paintName(p)}
            </button>
          ))}
        </div>
        <div className="color-page">{art(true)}</div>
      </GameFrame>
      <section className="sheet sheet-color" aria-hidden="true">
        <h2>{pageName}</h2>
        {art(false)}
      </section>
    </>
  );
}
