import { BG, C, INK, S, SHADE, SHINE, type Picture } from './kit.ts';

/** Fruit pictures, drawn after the first set. */
export const FRUIT: readonly Picture[] = [
  {
    id: 'orange',
    name: 'Orange',
    category: 'fruit',
    bg: BG.sky,
    ground: 104,
    body: `
      <circle cx="60" cy="64" r="38" fill="${C.orange}" ${S}/>
      <path d="M88 44c10 18 6 42-14 52 18-14 22-34 14-52z" ${SHADE}/>
      <g fill="${INK}" fill-opacity=".18"><circle cx="48" cy="56" r="1.6"/><circle cx="62" cy="50" r="1.6"/><circle cx="74" cy="62" r="1.6"/><circle cx="54" cy="74" r="1.6"/><circle cx="68" cy="82" r="1.6"/><circle cx="40" cy="70" r="1.6"/><circle cx="80" cy="76" r="1.6"/></g>
      <path d="M60 28c0-6 2-10 6-12" fill="none" ${S}/>
      <path d="M62 24c8-12 26-12 30-6-10 10-22 10-30 6z" fill="${C.green}" ${S}/>
      <path d="M36 52c2-8 8-14 14-16" ${SHINE}/>`,
  },
  {
    id: 'grapes',
    name: 'Bunch of grapes',
    category: 'fruit',
    bg: BG.sage,
    body: `
      <path d="M60 30c0-8 2-12 8-16" fill="none" ${S} stroke-width="4"/>
      <path d="M62 26c10-12 30-10 34 0-12 8-24 8-34 0z" fill="${C.green}" ${S}/>
      <g fill="${C.plum}" ${S}>
        <circle cx="44" cy="40" r="10"/><circle cx="64" cy="38" r="10"/><circle cx="80" cy="44" r="9"/>
        <circle cx="52" cy="56" r="10"/><circle cx="72" cy="58" r="10"/>
        <circle cx="42" cy="70" r="9"/><circle cx="62" cy="74" r="10"/><circle cx="80" cy="72" r="8"/>
        <circle cx="52" cy="88" r="9"/><circle cx="70" cy="90" r="9"/>
        <circle cx="61" cy="104" r="8"/>
      </g>
      <g ${SHINE} stroke-width="2.5"><path d="M40 37a5 5 0 0 1 4-3"/><path d="M48 53a5 5 0 0 1 4-3"/><path d="M58 71a5 5 0 0 1 4-3"/><path d="M48 85a5 5 0 0 1 4-3"/></g>`,
  },
  {
    id: 'watermelon',
    name: 'Slice of watermelon',
    category: 'fruit',
    bg: BG.blush,
    ground: 98,
    body: `
      <path d="M12 46h96c0 30-22 50-48 50S12 76 12 46z" fill="${C.green}" ${S}/>
      <path d="M20 46h80c0 24-18 42-40 42S20 70 20 46z" fill="${C.paper}"/>
      <path d="M24 46h72c0 22-16 38-36 38S24 68 24 46z" fill="${C.red}"/>
      <path d="M12 46h96" ${S}/>
      <g fill="${INK}"><ellipse cx="42" cy="58" rx="2.4" ry="4" transform="rotate(20 42 58)"/><ellipse cx="60" cy="66" rx="2.4" ry="4"/><ellipse cx="78" cy="58" rx="2.4" ry="4" transform="rotate(-20 78 58)"/><ellipse cx="50" cy="74" rx="2.4" ry="4" transform="rotate(15 50 74)"/><ellipse cx="70" cy="74" rx="2.4" ry="4" transform="rotate(-15 70 74)"/></g>
      <path d="M30 52c4 10 10 16 18 20" ${SHINE}/>`,
  },
  {
    id: 'pineapple',
    name: 'Pineapple',
    category: 'fruit',
    bg: BG.cream,
    ground: 108,
    body: `
      <path d="M60 46 46 14l10 8 4-14 4 14 10-8z" fill="${C.green}" ${S}/>
      <path d="M58 46 34 26l16 4M62 46l24-20-16 4" fill="${C.deepGreen}" ${S}/>
      <ellipse cx="60" cy="78" rx="28" ry="32" fill="${C.mustard}" ${S}/>
      <clipPath id="pine-body"><ellipse cx="60" cy="78" rx="28" ry="32"/></clipPath>
      <g clip-path="url(#pine-body)" stroke="${C.brown}" stroke-width="2.5" fill="none">
        <path d="M20 58l60 60M20 74l50 50M24 46l70 70M40 44l60 60M56 44l50 50"/>
        <path d="M100 58l-60 60M100 74l-50 50M96 46l-70 70M80 44l-60 60M64 44l-50 50"/>
      </g>
      <path d="M78 54c10 14 10 36-2 52 14-10 18-36 2-52z" ${SHADE}/>`,
  },
  {
    id: 'peach',
    name: 'Peach',
    category: 'fruit',
    bg: BG.sage,
    ground: 104,
    body: `
      <path d="M60 34c-26-8-44 12-40 36 4 26 26 34 40 34s36-8 40-34c4-24-14-44-40-36z" fill="${C.peach}" ${S}/>
      <path d="M60 36c-8 20-8 44 0 66" fill="none" stroke="${INK}" stroke-opacity=".35" stroke-width="3" stroke-linecap="round"/>
      <path d="M86 46c12 22 4 50-22 56 22-12 28-36 22-56z" fill="${C.red}" fill-opacity=".35"/>
      <path d="M60 34c0-8 2-12 6-16" fill="none" ${S}/>
      <path d="M64 26c6-12 24-14 30-8-8 10-22 12-30 8z" fill="${C.green}" ${S}/>
      <path d="M30 56c2-8 6-12 12-14" ${SHINE}/>`,
  },
];
