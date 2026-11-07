import { BG, C, INK, S, SHADE, SHINE, type Picture } from './kit.ts';

/** Garden and outdoor pictures, drawn after the first set. */
export const GARDEN: readonly Picture[] = [
  {
    id: 'rose',
    name: 'Rose',
    category: 'garden',
    bg: BG.blush,
    body: `
      <path d="M60 64v46" stroke="${C.deepGreen}" stroke-width="6" stroke-linecap="round"/>
      <path d="M60 92c-16-2-26-12-28-22 14 0 24 8 28 22zM60 82c14-2 22-10 24-18-12 0-20 6-24 18z" fill="${C.green}" ${S}/>
      <path d="M32 34c-2 20 10 34 28 34s30-14 28-34c-6 6-14 8-20 6-4-2-6-6-8-6s-4 4-8 6c-6 2-14 0-20-6z" fill="${C.red}" ${S}/>
      <path d="M40 30c0-12 8-20 20-20s20 8 20 20c0 8-8 14-20 14s-20-6-20-14z" fill="${C.deepRed}" ${S}/>
      <path d="M50 30c0-6 4-10 10-10s10 4 10 10c0 4-4 6-8 6" fill="none" ${S}/>
      <path d="M56 28c0-2 2-4 4-4" fill="none" ${S} stroke-width="2.5"/>
      <path d="M32 34c4 10 12 16 22 18M88 34c-4 10-12 16-22 18" fill="none" ${S}/>
      <path d="M82 40c-2 14-10 24-24 28 16 0 28-12 30-32z" ${SHADE}/>
      <path d="M38 44c2 6 6 10 10 12" ${SHINE}/>`,
  },
  {
    id: 'daisies',
    name: 'Daisies',
    category: 'garden',
    bg: BG.sky,
    body: `
      <path d="M40 60v50M80 52v58M60 74v36" stroke="${C.deepGreen}" stroke-width="5" stroke-linecap="round"/>
      <path d="M40 92c-12 0-18-8-18-14 10 0 16 6 18 14zM80 86c12-2 18-10 18-16-10 0-16 6-18 16z" fill="${C.green}" ${S}/>
      <g fill="${C.paper}" ${S} stroke-width="2.5">
        <g transform="translate(40 46)"><ellipse rx="5" ry="13" cy="-11"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(60)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(120)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(180)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(240)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(300)"/></g>
        <g transform="translate(80 38)"><ellipse rx="5" ry="13" cy="-11" transform="rotate(30)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(90)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(150)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(210)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(270)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(330)"/></g>
        <g transform="translate(60 66) scale(.7)"><ellipse rx="5" ry="13" cy="-11"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(60)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(120)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(180)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(240)"/><ellipse rx="5" ry="13" cy="-11" transform="rotate(300)"/></g>
      </g>
      <g fill="${C.mustard}" ${S} stroke-width="2.5"><circle cx="40" cy="46" r="7"/><circle cx="80" cy="38" r="7"/><circle cx="60" cy="66" r="5"/></g>`,
  },
  {
    id: 'mushroom',
    name: 'Mushroom',
    category: 'garden',
    bg: BG.sage,
    ground: 100,
    body: `
      <path d="M8 100c20-8 84-8 104 0" fill="none" stroke="${C.green}" stroke-width="4" stroke-linecap="round"/>
      <path d="M48 62h24c0 14 4 26 8 36H40c4-10 8-22 8-36z" fill="${C.paper}" ${S}/>
      <path d="M66 64c2 12 6 24 10 34h-8c-2-10-4-22-2-34z" ${SHADE}/>
      <path d="M16 62c0-26 20-42 44-42s44 16 44 42z" fill="${C.red}" ${S}/>
      <path d="M86 32c12 10 16 20 18 30H84c2-10 2-20 2-30z" ${SHADE}/>
      <g fill="${C.paper}" ${S} stroke-width="2"><circle cx="40" cy="44" r="6"/><circle cx="62" cy="32" r="5"/><circle cx="80" cy="48" r="7"/><circle cx="28" cy="58" r="3.5"/></g>
      <path d="M26 46c4-10 10-16 18-20" ${SHINE}/>`,
  },
  {
    id: 'wheelbarrow',
    name: 'Wheelbarrow',
    category: 'garden',
    bg: BG.cream,
    ground: 104,
    body: `
      <path d="M58 76l50-22" stroke="${C.brown}" stroke-width="6" stroke-linecap="round"/>
      <path d="M70 86l-4 16M40 86l-4 16" stroke="${INK}" stroke-width="4" stroke-linecap="round"/>
      <path d="M14 50h76l-12 32H30z" fill="${C.green}" ${S}/>
      <path d="M72 52h18l-12 30h-12z" ${SHADE}/>
      <g fill="${C.brown}" ${S} stroke-width="2.5"><circle cx="34" cy="46" r="8"/><circle cx="52" cy="42" r="9"/><circle cx="70" cy="46" r="8"/></g>
      <circle cx="26" cy="92" r="12" fill="${C.grey}" ${S}/>
      <circle cx="26" cy="92" r="4" fill="${INK}"/>
      <path d="M20 58h50" ${SHINE}/>`,
  },
  {
    id: 'birdhouse',
    name: 'Birdhouse',
    category: 'garden',
    bg: BG.sky,
    body: `
      <path d="M60 86v30" stroke="${C.brown}" stroke-width="8"/>
      <path d="M32 52h56v40H32z" fill="${C.mustard}" ${S}/>
      <path d="M74 52h14v40H74z" ${SHADE}/>
      <path d="M24 56 60 22l36 34" fill="none" stroke="${C.red}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round"/>
      <path d="M24 56 60 22l36 34" fill="none" ${S}/>
      <circle cx="60" cy="68" r="9" fill="${INK}"/>
      <path d="M52 84h16" stroke="${C.brown}" stroke-width="5" stroke-linecap="round"/>
      <path d="M36 60v26" ${SHINE}/>`,
  },
  {
    id: 'cactus',
    name: 'Cactus in a pot',
    category: 'garden',
    bg: BG.blush,
    ground: 104,
    body: `
      <path d="M48 76V28c0-14 24-14 24 0v48z" fill="${C.green}" ${S}/>
      <path d="M48 60H38c-8 0-10-6-10-12V40c0-6 10-6 10 0v8h10M72 54h10V36c0-6 10-6 10 0v14c0 6-4 10-10 10H72" fill="${C.green}" ${S}/>
      <path d="M64 22c6 6 8 34 8 54h-6c0-20 0-44-2-54z" ${SHADE}/>
      <path d="M56 34v34M64 34v34" stroke="${C.deepGreen}" stroke-width="2" stroke-linecap="round"/>
      <circle cx="60" cy="16" r="5" fill="${C.pink}" ${S} stroke-width="2.5"/>
      <path d="M38 76h44l-6 26H44z" fill="${C.wood}" ${S}/>
      <rect x="34" y="72" width="52" height="10" rx="3" fill="${C.wood}" ${S}/>`,
  },
  {
    id: 'acorn',
    name: 'Acorn',
    category: 'garden',
    bg: BG.cream,
    ground: 104,
    body: `
      <path d="M38 54h44c0 26-10 44-22 46-12-2-22-20-22-46z" fill="${C.tan}" ${S}/>
      <path d="M72 58c2 18-2 34-10 40 12-2 18-20 18-40z" ${SHADE}/>
      <path d="M30 56c0-18 12-28 30-28s30 10 30 28z" fill="${C.brown}" ${S}/>
      <path d="M40 38l6 10M52 32l4 12M66 32l-2 12M78 38l-6 10M34 48l50 0" stroke="${INK}" stroke-opacity=".35" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M60 28c0-8 4-14 10-16" fill="none" ${S} stroke-width="4"/>
      <path d="M46 64c0 10 2 18 6 24" ${SHINE}/>`,
  },
  {
    id: 'autumn-leaf',
    name: 'Autumn leaf',
    category: 'garden',
    bg: BG.sage,
    body: `
      <path d="M60 104V92" stroke="${C.brown}" stroke-width="5" stroke-linecap="round"/>
      <path d="M60 92 40 96l6-12-24-4 10-10-16-14 18-2-6-20 18 10 4-22 10 14 10-14 4 22 18-10-6 20 18 2-16 14 10 10-24 4 6 12z" fill="${C.orange}" ${S}/>
      <path d="M60 92 60 22M60 72 34 52M60 60 82 40M60 80 86 62M60 52 42 34" fill="none" stroke="${C.wood}" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M60 92 80 96l-6-12 24-4-10-10 16-14-18-2 6-20-18 10-4-22-10 14z" ${SHADE}/>`,
  },
];
