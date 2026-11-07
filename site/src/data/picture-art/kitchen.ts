import { BG, C, INK, S, SHADE, SHINE, type Picture } from './kit.ts';

/** Kitchen and table pictures, drawn after the first set. */
export const KITCHEN: readonly Picture[] = [
  {
    id: 'teapot',
    name: 'Teapot',
    category: 'kitchen',
    bg: BG.sage,
    ground: 98,
    body: `
      <path d="M86 62c16-4 18 22 2 26" fill="none" ${S} stroke-width="6"/>
      <path d="M34 70C24 66 18 56 14 46l7-3c4 9 9 15 16 17z" fill="${C.blue}" ${S}/>
      <path d="M28 96c-8-30 8-44 32-44s40 14 32 44z" fill="${C.blue}" ${S}/>
      <path d="M78 58c10 8 14 22 10 38H70c8-12 10-26 8-38z" ${SHADE}/>
      <path d="M38 52c4-12 40-12 44 0z" fill="${C.blue}" ${S}/>
      <circle cx="60" cy="40" r="5" fill="${C.mustard}" ${S}/>
      <g fill="${C.paper}"><circle cx="44" cy="76" r="4"/><circle cx="60" cy="78" r="4"/><circle cx="76" cy="76" r="4"/></g>
      <path d="M38 66c2-5 5-8 9-10" ${SHINE}/>`,
  },
  {
    id: 'apple-pie',
    name: 'Apple pie',
    category: 'kitchen',
    bg: BG.blush,
    ground: 96,
    body: `
      <path d="M50 34c-5-6 5-9 0-16M68 34c-5-6 5-9 0-16" fill="none" stroke="${C.grey}" stroke-width="3" stroke-linecap="round"/>
      <path d="M14 70h92l-8 22H22z" fill="${C.silver}" ${S}/>
      <path d="M14 70c0-18 22-28 46-28s46 10 46 28z" fill="${C.tan}" ${S}/>
      <path d="M30 52l14 18M48 45l14 25M68 44l12 26M86 50l8 20M24 62l64-16" fill="none" stroke="${C.brown}" stroke-width="3" stroke-linecap="round"/>
      <path d="M14 70c4 6 88 6 92 0" fill="none" ${S}/>
      <path d="M30 80h60l-4 10H34z" ${SHADE}/>`,
  },
  {
    id: 'honey-jar',
    name: 'Jar of honey',
    category: 'kitchen',
    bg: BG.cream,
    ground: 102,
    body: `
      <path d="M36 44h48c8 0 10 6 10 12v34c0 6-4 10-10 10H36c-6 0-10-4-10-10V56c0-6 2-12 10-12z" fill="${C.mustard}" ${S}/>
      <path d="M80 50c6 2 8 8 8 14v26c0 4-2 6-6 6h-6c4-10 6-30 4-46z" ${SHADE}/>
      <path d="M30 32h60l-6 14H36z" fill="${C.red}" ${S}/>
      <path d="M40 32v14M50 32v14M60 32v14M70 32v14M80 32v14" stroke="${C.paper}" stroke-width="2.5" stroke-opacity=".8"/>
      <path d="M32 44h56" ${S}/>
      <rect x="38" y="62" width="44" height="24" rx="5" fill="${C.paper}" ${S}/>
      <g fill="${C.mustard}" stroke="${C.brown}" stroke-width="2" stroke-linejoin="round"><path d="M54 68l4-2.5 4 2.5v5l-4 2.5-4-2.5z"/><path d="M62 68l4-2.5 4 2.5v5l-4 2.5-4-2.5z"/><path d="M58 75l4-2.5 4 2.5v5l-4 2.5-4-2.5z"/></g>
      <path d="M34 56v20" ${SHINE}/>`,
  },
  {
    id: 'boiled-egg',
    name: 'Egg in an egg cup',
    category: 'kitchen',
    bg: BG.sky,
    ground: 102,
    body: `
      <path d="M40 98h40l-4-8H44z" fill="${C.red}" ${S}/>
      <path d="M48 90c0-8-12-12-12-26h48c0 14-12 18-12 26z" fill="${C.red}" ${S}/>
      <path d="M38 50c0-20 10-34 22-34s22 14 22 34c0 10-10 16-22 16S38 60 38 50z" fill="${C.paper}" ${S}/>
      <path d="M38 44l6-5 6 5 6-5 6 5 6-5 6 5 6-5 2 2" fill="none" ${S}/>
      <path d="M72 30c6 8 10 20 8 30" fill="none" stroke="${INK}" stroke-opacity=".16" stroke-width="6" stroke-linecap="round"/>
      <path d="M44 72c4 2 8 3 12 3" ${SHINE}/>`,
  },
  {
    id: 'toaster',
    name: 'Toaster',
    category: 'kitchen',
    bg: BG.cream,
    ground: 100,
    body: `
      <path d="M36 30h20v24H36zM62 26h20v28H62z" fill="${C.tan}" ${S}/>
      <path d="M38 30c0-6 16-6 16 0M64 26c0-6 16-6 16 0" fill="${C.tan}" ${S}/>
      <rect x="20" y="46" width="80" height="50" rx="16" fill="${C.silver}" ${S}/>
      <path d="M84 50c10 6 12 30 0 42h-8c8-12 8-30 0-42z" ${SHADE}/>
      <path d="M34 50h22M62 50h22" stroke="${INK}" stroke-width="5" stroke-linecap="round"/>
      <rect x="96" y="62" width="10" height="6" rx="3" fill="${INK}"/>
      <path d="M28 92l-2 6M92 92l2 6" ${S}/>
      <path d="M30 60c0 8 0 16 2 22" ${SHINE}/>`,
  },
  {
    id: 'cheese',
    name: 'Wedge of cheese',
    category: 'kitchen',
    bg: BG.sage,
    ground: 96,
    body: `
      <rect x="10" y="88" width="100" height="10" rx="4" fill="${C.brown}" ${S}/>
      <path d="M18 88V60l76-26v54z" fill="${C.yellow}" ${S}/>
      <path d="M18 60l76-26 10 10-76 28z" fill="#F7E07A" ${S}/>
      <path d="M94 34l10 10v44H94z" fill="${C.mustard}" ${S}/>
      <g fill="${C.mustard}" ${S} stroke-width="2.5"><circle cx="36" cy="76" r="6"/><circle cx="58" cy="66" r="4"/><circle cx="70" cy="80" r="5"/><circle cx="84" cy="58" r="3.5"/></g>`,
  },
  {
    id: 'milk-jug',
    name: 'Milk jug',
    category: 'kitchen',
    bg: BG.sky,
    ground: 100,
    body: `
      <path d="M80 48c18 2 18 34 0 36" fill="none" ${S} stroke-width="6"/>
      <path d="M38 36h44c-4 10 0 22 4 34 4 14 0 26-6 28H40c-6-2-10-14-6-28 4-12 8-24 4-34z" fill="${C.paper}" ${S}/>
      <path d="M38 36l-10-6 6 12z" fill="${C.paper}" ${S}/>
      <path d="M34 66c10 4 40 4 52 0" fill="none" stroke="${C.blue}" stroke-width="5"/>
      <path d="M34 76c10 4 40 4 52 0" fill="none" stroke="${C.blue}" stroke-width="3"/>
      <path d="M76 42c6 18 10 36 4 54h-6c6-18 4-36 2-54z" ${SHADE}/>
      <ellipse cx="60" cy="37" rx="22" ry="3" fill="${C.white}" ${S} stroke-width="2"/>`,
  },
  {
    id: 'cupcake',
    name: 'Cupcake',
    category: 'kitchen',
    bg: BG.blush,
    ground: 100,
    body: `
      <path d="M32 64h56l-8 34H40z" fill="${C.pink}" ${S}/>
      <path d="M42 64l4 34M54 64l1 34M66 64l-1 34M78 64l-4 34" stroke="${C.paper}" stroke-width="3" stroke-opacity=".8"/>
      <path d="M28 66c-6-12 6-18 12-16-2-12 12-18 20-10 8-8 22-2 20 10 6-2 18 4 12 16z" fill="${C.paper}" ${S}/>
      <path d="M40 56c8 4 32 4 40 0" fill="none" stroke="${INK}" stroke-width="2.5" stroke-linecap="round" stroke-opacity=".5"/>
      <circle cx="60" cy="30" r="8" fill="${C.deepRed}" ${S}/>
      <path d="M62 22c2-6 6-8 10-8" fill="none" ${S} stroke-width="2.5"/>
      <g fill="${C.blue}"><rect x="44" y="44" width="5" height="2.5" rx="1" transform="rotate(-30 46 45)"/><rect x="72" y="48" width="5" height="2.5" rx="1" transform="rotate(25 74 49)"/></g>
      <g fill="${C.mustard}"><rect x="58" y="46" width="5" height="2.5" rx="1" transform="rotate(10 60 47)"/><rect x="36" y="58" width="5" height="2.5" rx="1"/></g>
      <path d="M57 27a3 3 0 0 1 3-2" ${SHINE} stroke-width="2"/>`,
  },
];
