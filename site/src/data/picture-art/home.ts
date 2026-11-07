import { BG, C, INK, S, SHADE, SHINE, type Picture } from './kit.ts';

/** Things around the house, drawn after the first set. */
export const HOME: readonly Picture[] = [
  {
    id: 'clock',
    name: 'Mantel clock',
    category: 'home',
    bg: BG.cream,
    ground: 102,
    body: `
      <path d="M22 100V70c0-30 16-50 38-50s38 20 38 50v30z" fill="${C.wood}" ${S}/>
      <path d="M80 30c10 12 14 26 14 40v30H84V70c0-16-2-28-4-40z" ${SHADE}/>
      <rect x="16" y="96" width="88" height="8" rx="3" fill="${C.brown}" ${S}/>
      <circle cx="60" cy="62" r="24" fill="${C.paper}" ${S}/>
      <g stroke="${INK}" stroke-width="3" stroke-linecap="round"><path d="M60 42v4M60 78v4M40 62h4M76 62h4"/></g>
      <path d="M60 62V48M60 62l10 6" stroke="${INK}" stroke-width="3.5" stroke-linecap="round"/>
      <circle cx="60" cy="62" r="3" fill="${C.mustard}" ${S} stroke-width="1.5"/>
      <path d="M30 70c0-14 4-26 12-34" ${SHINE}/>`,
  },
  {
    id: 'vase-of-flowers',
    name: 'Vase of flowers',
    category: 'home',
    bg: BG.blush,
    ground: 104,
    body: `
      <path d="M60 64 46 30M60 64V22M60 64l16-30M60 64 34 46M60 64l26-14" stroke="${C.deepGreen}" stroke-width="3.5" stroke-linecap="round"/>
      <path d="M50 46c-10-2-16 2-18 8 8 2 14 0 18-8zM70 44c10-4 16 0 18 6-8 2-14 0-18-6z" fill="${C.green}" ${S} stroke-width="2.5"/>
      <g ${S} stroke-width="2.5">
        <circle cx="46" cy="28" r="9" fill="${C.red}"/>
        <circle cx="60" cy="20" r="9" fill="${C.mustard}"/>
        <circle cx="77" cy="32" r="9" fill="${C.pink}"/>
        <circle cx="33" cy="45" r="7" fill="${C.paper}"/>
        <circle cx="88" cy="49" r="7" fill="${C.paper}"/>
      </g>
      <g fill="${INK}" fill-opacity=".35"><circle cx="46" cy="28" r="3"/><circle cx="60" cy="20" r="3"/><circle cx="77" cy="32" r="3"/></g>
      <g fill="${C.mustard}"><circle cx="33" cy="45" r="2.5"/><circle cx="88" cy="49" r="2.5"/></g>
      <path d="M46 62h28c0 6 10 12 10 24 0 10-8 16-24 16S36 96 36 86c0-12 10-18 10-24z" fill="${C.blue}" ${S}/>
      <path d="M72 66c6 6 10 12 10 20 0 8-6 14-16 15 8-4 12-10 12-16 0-8-4-14-6-19z" ${SHADE}/>
      <path d="M40 84c6 4 34 4 40 0" fill="none" stroke="${C.paper}" stroke-width="3" stroke-linecap="round"/>
      <path d="M44 74c-2 4-2 8-1 11" ${SHINE}/>`,
  },
  {
    id: 'radio',
    name: 'Old radio',
    category: 'home',
    bg: BG.sage,
    ground: 100,
    body: `
      <path d="M38 34 70 16" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>
      <circle cx="71" cy="15" r="3" fill="${INK}"/>
      <rect x="16" y="34" width="88" height="62" rx="14" fill="${C.wood}" ${S}/>
      <path d="M92 38c10 6 10 50 0 56h-8c6-10 6-46 0-56z" ${SHADE}/>
      <rect x="24" y="44" width="44" height="44" rx="8" fill="${C.sand}" ${S}/>
      <g stroke="${C.brown}" stroke-width="2.5" stroke-linecap="round"><path d="M30 54h32M30 62h32M30 70h32M30 78h32"/></g>
      <rect x="74" y="44" width="22" height="14" rx="3" fill="${C.paper}" ${S} stroke-width="2.5"/>
      <path d="M85 46v10" stroke="${C.red}" stroke-width="2"/>
      <g fill="${C.mustard}" ${S} stroke-width="2.5"><circle cx="79" cy="74" r="6"/><circle cx="93" cy="74" r="4"/></g>
      <path d="M26 98l-2 6M94 98l2 6" ${S}/>`,
  },
  {
    id: 'books',
    name: 'Pile of books',
    category: 'home',
    bg: BG.sky,
    ground: 104,
    body: `
      <rect x="18" y="84" width="84" height="18" rx="3" fill="${C.blue}" ${S}/>
      <path d="M94 86v14" stroke="${C.paper}" stroke-width="4"/>
      <rect x="26" y="66" width="70" height="18" rx="3" fill="${C.red}" ${S} transform="rotate(-4 60 75)"/>
      <path d="M36 70l40-3" stroke="${C.mustard}" stroke-width="3" stroke-linecap="round" transform="rotate(-4 60 75)"/>
      <rect x="22" y="48" width="76" height="18" rx="3" fill="${C.green}" ${S}/>
      <path d="M90 50v14" stroke="${C.paper}" stroke-width="4"/>
      <rect x="34" y="34" width="54" height="14" rx="3" fill="${C.mustard}" ${S}/>
      <path d="M80 36v10" stroke="${C.paper}" stroke-width="4"/>
      <path d="M48 48v14l4-4 4 4V48" fill="${C.red}" ${S} stroke-width="2"/>
      <path d="M26 88h48" ${SHINE} stroke-width="2.5"/>`,
  },
  {
    id: 'candle',
    name: 'Candle',
    category: 'home',
    bg: BG.night,
    body: `
      <circle cx="60" cy="34" r="26" fill="${C.yellow}" fill-opacity=".18"/>
      <path d="M60 14c8 10 10 18 10 22a10 10 0 0 1-20 0c0-4 2-12 10-22z" fill="${C.yellow}" stroke="${C.paper}" stroke-width="3" stroke-linejoin="round"/>
      <path d="M60 28c3 4 4 7 4 9a4 4 0 0 1-8 0c0-2 1-5 4-9z" fill="${C.orange}"/>
      <path d="M60 46v6" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>
      <rect x="46" y="52" width="28" height="44" rx="3" fill="${C.paper}" stroke="${INK}" stroke-width="3"/>
      <path d="M66 54v40h6V54z" ${SHADE}/>
      <path d="M46 58c4 4 4 10 2 14" fill="none" stroke="${C.sand}" stroke-width="3" stroke-linecap="round"/>
      <path d="M26 98h68l-6 8H32z" fill="${C.mustard}" stroke="${INK}" stroke-width="3" stroke-linejoin="round"/>
      <path d="M94 100c10 0 12 8 4 8" fill="none" stroke="${C.mustard}" stroke-width="4" stroke-linecap="round"/>`,
  },
  {
    id: 'glasses',
    name: 'Reading glasses',
    category: 'home',
    bg: BG.cream,
    body: `
      <path d="M20 54 8 44M100 54l12-10" stroke="${C.brown}" stroke-width="4" stroke-linecap="round"/>
      <path d="M50 58c4-6 16-6 20 0" fill="none" stroke="${C.brown}" stroke-width="4" stroke-linecap="round"/>
      <g fill="${C.sky}" fill-opacity=".45" stroke="${C.brown}" stroke-width="5"><circle cx="34" cy="64" r="18"/><circle cx="86" cy="64" r="18"/></g>
      <g ${SHINE} stroke-width="3"><path d="M24 58c2-4 5-7 9-8"/><path d="M76 58c2-4 5-7 9-8"/></g>
      <path d="M22 96h76" stroke="${C.brown}" stroke-opacity=".25" stroke-width="5" stroke-linecap="round"/>`,
  },
  {
    id: 'telephone',
    name: 'Telephone',
    category: 'home',
    bg: BG.blush,
    ground: 102,
    body: `
      <path d="M28 64c-2 18 10 36 32 36s34-18 32-36z" fill="${C.red}" ${S}/>
      <path d="M86 66c0 16-8 28-22 32 18 0 28-14 28-32z" ${SHADE}/>
      <path d="M16 40c0-12 20-20 44-20s44 8 44 20v6c0 4-4 6-8 6H84c-4 0-6-2-6-6v-4c-12-4-24-4-36 0v4c0 4-2 6-6 6H24c-4 0-8-2-8-6z" fill="${C.red}" ${S}/>
      <circle cx="60" cy="76" r="16" fill="${C.paper}" ${S}/>
      <g fill="${INK}"><circle cx="60" cy="65" r="2.5"/><circle cx="69" cy="68" r="2.5"/><circle cx="71" cy="77" r="2.5"/><circle cx="66" cy="85" r="2.5"/><circle cx="54" cy="85" r="2.5"/><circle cx="49" cy="77" r="2.5"/><circle cx="51" cy="68" r="2.5"/></g>
      <circle cx="60" cy="76" r="4" fill="${C.red}" ${S} stroke-width="2"/>
      <path d="M26 34c6-4 14-6 22-6" ${SHINE}/>`,
  },
  {
    id: 'ball-of-wool',
    name: 'Ball of wool',
    category: 'home',
    bg: BG.sage,
    ground: 102,
    body: `
      <path d="M26 30l50 60M94 30 44 90" stroke="${C.tan}" stroke-width="5" stroke-linecap="round"/>
      <g fill="${C.mustard}"><circle cx="25" cy="29" r="4"/><circle cx="95" cy="29" r="4"/></g>
      <path d="M86 92c10 6 20 4 24-2" fill="none" stroke="${C.blue}" stroke-width="4" stroke-linecap="round"/>
      <circle cx="60" cy="68" r="30" fill="${C.blue}" ${S}/>
      <g fill="none" stroke="${C.paper}" stroke-opacity=".55" stroke-width="2.5" stroke-linecap="round">
        <path d="M34 56c16 4 34 18 42 36M38 46c18 6 36 22 44 42M48 40c14 8 30 24 36 40"/>
        <path d="M32 74c14-14 30-24 50-26M36 86c14-14 32-26 52-26"/>
      </g>
      <path d="M80 48c12 16 8 38-12 48 18-4 28-30 12-48z" ${SHADE}/>`,
  },
  {
    id: 'straw-hat',
    name: 'Sun hat',
    category: 'home',
    bg: BG.sky,
    body: `
      <ellipse cx="60" cy="76" rx="50" ry="16" fill="${C.sand}" ${S}/>
      <path d="M34 74c0-26 12-40 26-40s26 14 26 40c-8 6-44 6-52 0z" fill="${C.sand}" ${S}/>
      <path d="M35 64c10 6 40 6 50 0l1 10c-8 6-44 6-52 0z" fill="${C.red}" ${S}/>
      <path d="M84 70c6 4 14 16 10 22-4-4-10-12-10-22z" fill="${C.red}" ${S}/>
      <path d="M74 40c8 8 12 20 12 34H76c0-14-2-24-2-34z" ${SHADE}/>
      <circle cx="40" cy="64" r="6" fill="${C.paper}" ${S} stroke-width="2"/>
      <circle cx="40" cy="64" r="2" fill="${C.mustard}"/>
      <path d="M42 50c2-6 6-10 10-12" ${SHINE}/>`,
  },
];
