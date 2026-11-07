import { BG, C, INK, S, SHADE, SHINE, type Picture } from './kit.ts';

/** Getting about, drawn after the first set. */
export const TRAVEL: readonly Picture[] = [
  {
    id: 'train',
    name: 'Steam train',
    category: 'travel',
    bg: BG.sky,
    body: `
      <g fill="${C.paper}" fill-opacity=".95" ${S} stroke-width="2.5"><circle cx="34" cy="20" r="8"/><circle cx="22" cy="12" r="6"/></g>
      <path d="M6 100h108" stroke="${C.brown}" stroke-width="4" stroke-linecap="round"/>
      <path d="M12 104h4M28 104h4M44 104h4M60 104h4M76 104h4M92 104h4" stroke="${C.brown}" stroke-width="3" stroke-linecap="round"/>
      <rect x="28" y="30" width="12" height="20" rx="2" fill="${INK}"/>
      <path d="M14 50h58v34H14z" fill="${C.green}" ${S}/>
      <path d="M72 30h30v54H72z" fill="${C.green}" ${S}/>
      <path d="M68 26h38v8H68z" fill="${C.red}" ${S}/>
      <rect x="80" y="40" width="14" height="14" rx="2" fill="${C.paper}" ${S} stroke-width="2.5"/>
      <path d="M6 84 14 70v14z" fill="${C.red}" ${S}/>
      <path d="M14 76h92" stroke="${C.mustard}" stroke-width="4"/>
      <g fill="${C.red}" ${S}><circle cx="30" cy="90" r="10"/><circle cx="56" cy="90" r="10"/><circle cx="88" cy="88" r="12"/></g>
      <g fill="${INK}"><circle cx="30" cy="90" r="3"/><circle cx="56" cy="90" r="3"/><circle cx="88" cy="88" r="3"/></g>
      <path d="M30 90h58" stroke="${INK}" stroke-width="3"/>
      <path d="M20 56h40" ${SHINE}/>`,
  },
  {
    id: 'bus',
    name: 'Bus',
    category: 'travel',
    bg: BG.cream,
    ground: 102,
    body: `
      <rect x="12" y="30" width="96" height="62" rx="12" fill="${C.red}" ${S}/>
      <path d="M100 34c6 4 8 10 8 18v28c0 6-2 10-8 12z" ${SHADE}/>
      <g fill="${C.sky}" ${S} stroke-width="2.5"><rect x="20" y="40" width="18" height="20" rx="3"/><rect x="44" y="40" width="18" height="20" rx="3"/><rect x="68" y="40" width="18" height="20" rx="3"/><rect x="90" y="40" width="12" height="34" rx="3"/></g>
      <path d="M12 68h76" stroke="${C.paper}" stroke-width="4"/>
      <g fill="${INK}"><circle cx="34" cy="92" r="10"/><circle cx="86" cy="92" r="10"/></g>
      <g fill="${C.silver}"><circle cx="34" cy="92" r="4"/><circle cx="86" cy="92" r="4"/></g>
      <circle cx="104" cy="84" r="3" fill="${C.yellow}" ${S} stroke-width="1.5"/>
      <g ${SHINE} stroke-width="2.5"><path d="M24 46l6-4"/><path d="M48 46l6-4"/></g>`,
  },
  {
    id: 'airplane',
    name: 'Aeroplane',
    category: 'travel',
    bg: BG.sky,
    body: `
      <path d="M10 96c14-4 22-10 30-18" fill="none" stroke="${C.paper}" stroke-width="5" stroke-linecap="round" stroke-dasharray="2 9"/>
      <path d="M52 66 26 92l12 2 32-20z" fill="${C.blue}" ${S}/>
      <path d="M58 46 44 22l10-2 24 22z" fill="${C.blue}" ${S}/>
      <path d="M24 70c4-8 52-38 74-46 8-3 14 2 10 8-8 12-60 40-76 44-6 2-10-2-8-6z" fill="${C.paper}" ${S}/>
      <path d="M28 64 16 52l6-2 14 10z" fill="${C.red}" ${S}/>
      <g fill="${C.sky}"><circle cx="70" cy="44" r="3"/><circle cx="60" cy="50" r="3"/><circle cx="50" cy="56" r="3"/></g>
      <path d="M98 26c2 2 4 4 4 6" fill="none" stroke="${INK}" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M36 72c20-8 52-28 66-36" fill="none" stroke="${INK}" stroke-opacity=".16" stroke-width="5" stroke-linecap="round"/>`,
  },
  {
    id: 'suitcase',
    name: 'Suitcase',
    category: 'travel',
    bg: BG.blush,
    ground: 102,
    body: `
      <path d="M46 40V28c0-4 2-6 6-6h16c4 0 6 2 6 6v12" fill="none" ${S} stroke-width="5"/>
      <rect x="14" y="38" width="92" height="60" rx="8" fill="${C.wood}" ${S}/>
      <path d="M96 40c6 2 10 6 10 12v36c0 6-4 10-10 10z" ${SHADE}/>
      <path d="M14 56h92" stroke="${C.brown}" stroke-width="3"/>
      <g fill="${C.mustard}" ${S} stroke-width="2"><rect x="30" y="52" width="10" height="9" rx="2"/><rect x="80" y="52" width="10" height="9" rx="2"/></g>
      <path d="M34 38v60M86 38v60" stroke="${C.sand}" stroke-width="5"/>
      <path d="M62 40c4 8 6 16 6 24" fill="none" stroke="${INK}" stroke-width="2" stroke-linecap="round"/>
      <path d="M58 64h20l4 6v16H58z" fill="${C.paper}" ${S} stroke-width="2.5"/>
      <circle cx="64" cy="70" r="2" fill="${INK}"/>
      <path d="M64 78h12M64 82h8" stroke="${C.blue}" stroke-width="2" stroke-linecap="round"/>
      <path d="M20 46h30" ${SHINE}/>`,
  },
  {
    id: 'tractor',
    name: 'Tractor',
    category: 'travel',
    bg: BG.sage,
    ground: 104,
    body: `
      <path d="M44 22v20" stroke="${INK}" stroke-width="6" stroke-linecap="round"/>
      <path d="M56 26h28l6 30H56z" fill="${C.sky}" fill-opacity=".6" ${S}/>
      <path d="M52 22h36" stroke="${C.red}" stroke-width="6" stroke-linecap="round"/>
      <path d="M18 56h80c6 0 8 4 8 8v18H18z" fill="${C.red}" ${S}/>
      <path d="M18 56h34v26H18z" fill="${C.red}" ${S}/>
      <path d="M24 62h22" stroke="${INK}" stroke-opacity=".3" stroke-width="3" stroke-linecap="round"/>
      <circle cx="82" cy="84" r="20" fill="${INK}"/>
      <circle cx="82" cy="84" r="9" fill="${C.mustard}" ${S}/>
      <circle cx="28" cy="92" r="12" fill="${INK}"/>
      <circle cx="28" cy="92" r="5" fill="${C.mustard}" ${S} stroke-width="2"/>
      <path d="M58 62h28" ${SHINE}/>`,
  },
  {
    id: 'rowing-boat',
    name: 'Rowing boat',
    category: 'travel',
    bg: BG.sky,
    body: `
      <path d="M0 92c10-4 20 4 30 0s20-4 30 0 20 4 30 0 20-4 30 0v28H0z" fill="${C.blue}"/>
      <path d="M0 92c10-4 20 4 30 0s20-4 30 0 20 4 30 0 20-4 30 0" fill="none" ${S}/>
      <path d="M22 54 8 98M98 54l14 44" stroke="${C.brown}" stroke-width="4" stroke-linecap="round"/>
      <path d="M12 62h96c-4 18-18 28-48 28S16 80 12 62z" fill="${C.wood}" ${S}/>
      <path d="M16 70h88" stroke="${C.paper}" stroke-width="4"/>
      <path d="M86 70c-4 10-12 16-26 18 18 0 32-6 38-18z" ${SHADE}/>
      <path d="M14 62h92" ${S}/>`,
  },
];
