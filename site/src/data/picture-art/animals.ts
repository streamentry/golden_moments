import { BG, C, INK, S, SHADE, SHINE, type Picture } from './kit.ts';

/** Animal pictures, drawn after the first set. Friendly faces, no teeth. */
export const ANIMALS: readonly Picture[] = [
  {
    id: 'rabbit',
    name: 'Rabbit',
    category: 'animals',
    bg: BG.sage,
    ground: 104,
    body: `
      <path d="M44 46c-8-20-6-36 2-38s12 16 10 36zM76 46c8-20 6-36-2-38s-12 16-10 36z" fill="${C.silver}" ${S}/>
      <path d="M48 40c-4-12-4-22 0-26M72 40c4-12 4-22 0-26" stroke="${C.pink}" stroke-width="5" stroke-linecap="round"/>
      <path d="M30 104c-6-28 10-46 30-46s36 18 30 46z" fill="${C.silver}" ${S}/>
      <circle cx="60" cy="56" r="20" fill="${C.silver}" ${S}/>
      <path d="M76 62c6 14 12 26 12 42h-8c2-14-2-28-4-42z" ${SHADE}/>
      <g fill="${INK}"><circle cx="52" cy="54" r="3"/><circle cx="68" cy="54" r="3"/></g>
      <path d="M57 62h6l-3 3z" fill="${C.pink}" ${S} stroke-width="2"/>
      <path d="M60 65v3M54 70c3 2 9 2 12 0" fill="none" ${S} stroke-width="2"/>
      <path d="M44 52c0-6 3-10 7-12" ${SHINE} stroke-width="2.5"/>`,
  },
  {
    id: 'duck',
    name: 'Duck',
    category: 'animals',
    bg: BG.sky,
    body: `
      <path d="M8 96c10-4 20 4 30 0s20-4 30 0 20 4 30 0 14-2 14-2v24H8z" fill="${C.blue}" ${S}/>
      <path d="M24 72c0-14 14-20 32-18 4-14 14-22 26-20 12 2 18 14 14 26-2 10-8 14-8 14 6 0 12-2 14-6 2 18-12 34-40 34-20 0-38-10-38-30z" fill="${C.yellow}" ${S}/>
      <path d="M96 48l14 4-14 6z" fill="${C.orange}" ${S}/>
      <circle cx="84" cy="44" r="3.5" fill="${INK}"/>
      <path d="M38 74c10 10 26 10 34 2" fill="none" ${S}/>
      <path d="M26 82c4 12 20 18 38 18 14 0 24-4 30-12-6 14-20 20-36 20-16 0-30-10-32-26z" ${SHADE}/>
      <path d="M78 38c2-3 5-4 8-4" ${SHINE} stroke-width="2.5"/>`,
  },
  {
    id: 'hen',
    name: 'Hen',
    category: 'animals',
    bg: BG.cream,
    ground: 104,
    body: `
      <path d="M52 92v12M66 92v12M47 104h10M61 104h10" stroke="${C.orange}" stroke-width="4" stroke-linecap="round"/>
      <path d="M34 66 14 34l16 8-2-18 14 18 4-14 6 22z" fill="${C.paper}" ${S}/>
      <path d="M76 28c-3-8 6-11 8-4 1-8 10-7 9 1 5-4 11 1 6 7z" fill="${C.red}" ${S}/>
      <circle cx="86" cy="42" r="15" fill="${C.paper}" ${S}/>
      <path d="M100 38l11 5-11 5z" fill="${C.mustard}" ${S}/>
      <path d="M97 50c3 7-3 11-6 5z" fill="${C.red}" ${S}/>
      <circle cx="89" cy="39" r="3" fill="${INK}"/>
      <ellipse cx="58" cy="72" rx="34" ry="24" fill="${C.paper}" ${S}/>
      <path d="M80 60c10 18 2 34-18 36 20-8 22-24 18-36z" ${SHADE}/>
      <path d="M40 66c8 14 26 16 36 4" fill="none" ${S}/>
      <path d="M36 60c3-6 8-10 14-11" fill="none" stroke="${C.sand}" stroke-linecap="round"/>`,
  },
  {
    id: 'sheep',
    name: 'Sheep',
    category: 'animals',
    bg: BG.sage,
    ground: 104,
    body: `
      <path d="M40 84v18M54 86v18M70 86v18M84 84v18" stroke="${INK}" stroke-width="6" stroke-linecap="round"/>
      <path d="M30 70c-10-4-8-20 4-20 0-12 14-16 22-10 6-8 20-8 26 0 8-6 22-2 22 10 12 0 14 16 4 20 6 10-4 20-14 16-6 8-20 8-26 2-6 6-20 6-26-2-10 4-20-6-12-16z" fill="${C.paper}" ${S}/>
      <path d="M90 72c6 10-2 18-12 16-4 6-14 8-20 4 10-2 18-6 22-12 4-2 8-6 10-8z" ${SHADE}/>
      <ellipse cx="26" cy="62" rx="14" ry="12" fill="${INK}"/>
      <path d="M14 56c-6-2-8-8-4-10M36 54c4-4 10-4 12 0" fill="none" stroke="${INK}" stroke-width="6" stroke-linecap="round"/>
      <circle cx="22" cy="60" r="2.5" fill="${C.paper}"/>`,
  },
  {
    id: 'owl',
    name: 'Owl',
    category: 'animals',
    bg: BG.night,
    body: `
      <path d="M14 100h92" stroke="${C.brown}" stroke-width="8" stroke-linecap="round"/>
      <path d="M32 98c-8-30 0-62 6-70l10 10c8-4 16-4 24 0l10-10c6 8 14 40 6 70z" fill="${C.tan}" stroke="${C.paper}" stroke-width="3" stroke-linejoin="round"/>
      <path d="M44 70c6-2 26-2 32 0-2 18-6 26-16 28-10-2-14-10-16-28z" fill="${C.sand}"/>
      <path d="M50 80l4 3 4-3 4 3 4-3 4 3" fill="none" stroke="${C.brown}" stroke-width="2" stroke-linecap="round"/>
      <g fill="${C.paper}" stroke="${C.brown}" stroke-width="3"><circle cx="48" cy="54" r="11"/><circle cx="72" cy="54" r="11"/></g>
      <g fill="${INK}"><circle cx="48" cy="54" r="5"/><circle cx="72" cy="54" r="5"/></g>
      <path d="M56 62h8l-4 8z" fill="${C.mustard}"/>
      <path d="M50 98v6M56 98v6M66 98v6M72 98v6" stroke="${C.mustard}" stroke-width="3" stroke-linecap="round"/>
      <g fill="${C.paper}"><path d="M98 18l2 5 5 2-5 2-2 5-2-5-5-2 5-2z"/><path d="M20 30l1.5 4 4 1.5-4 1.5-1.5 4-1.5-4-4-1.5 4-1.5z"/></g>`,
  },
  {
    id: 'ladybird',
    name: 'Ladybird',
    category: 'animals',
    bg: BG.sage,
    body: `
      <path d="M22 98c20-8 30-22 34-40M98 98c-20-8-30-22-34-40" fill="none" stroke="${C.deepGreen}" stroke-width="5" stroke-linecap="round"/>
      <path d="M36 40l-10-8M30 60H18M36 80l-10 8M84 40l10-8M90 60h12M84 80l10 8" stroke="${INK}" stroke-width="4" stroke-linecap="round"/>
      <circle cx="60" cy="34" r="12" fill="${INK}"/>
      <path d="M54 24l-6-10M66 24l6-10" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>
      <circle cx="47" cy="13" r="3" fill="${INK}"/><circle cx="73" cy="13" r="3" fill="${INK}"/>
      <circle cx="60" cy="62" r="28" fill="${C.red}" ${S}/>
      <path d="M60 34v56" ${S}/>
      <g fill="${INK}"><circle cx="46" cy="52" r="5"/><circle cx="74" cy="52" r="5"/><circle cx="44" cy="72" r="4"/><circle cx="76" cy="72" r="4"/><circle cx="52" cy="84" r="3"/><circle cx="68" cy="84" r="3"/></g>
      <path d="M38 50c2-6 6-10 12-12" ${SHINE}/>`,
  },
  {
    id: 'snail',
    name: 'Snail',
    category: 'animals',
    bg: BG.blush,
    ground: 98,
    body: `
      <path d="M12 96h70c10 0 12-6 14-14l4-34" fill="${C.sand}" ${S}/>
      <path d="M96 52l-4-16M104 52l4-16" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>
      <circle cx="91" cy="34" r="3.5" fill="${INK}"/><circle cx="109" cy="34" r="3.5" fill="${INK}"/>
      <path d="M90 64c4 0 10-2 10-8" fill="none" ${S} stroke-width="2"/>
      <circle cx="50" cy="64" r="30" fill="${C.mustard}" ${S}/>
      <path d="M50 64c0-4 6-4 6 0 0 8-12 8-12 0 0-12 18-12 18 0 0 16-24 16-24 0 0-20 30-20 30 0" fill="none" stroke="${C.brown}" stroke-width="3.5" stroke-linecap="round"/>
      <path d="M72 46c10 16 6 36-12 46 16-4 26-24 12-46z" ${SHADE}/>
      <path d="M28 52c4-8 10-14 18-16" ${SHINE}/>`,
  },
  {
    id: 'frog',
    name: 'Frog',
    category: 'animals',
    bg: BG.sky,
    body: `
      <ellipse cx="60" cy="98" rx="50" ry="12" fill="${C.green}" fill-opacity=".45" ${S}/>
      <path d="M34 96c-14 0-16-10-6-12M86 96c14 0 16-10 6-12" fill="${C.leaf}" ${S}/>
      <path d="M26 74c0-20 14-30 34-30s34 10 34 30c0 14-14 22-34 22S26 88 26 74z" fill="${C.leaf}" ${S}/>
      <path d="M80 54c12 10 16 34-4 40 12-10 12-28 4-40z" ${SHADE}/>
      <g fill="${C.leaf}" ${S}><circle cx="42" cy="46" r="11"/><circle cx="78" cy="46" r="11"/></g>
      <g fill="${C.paper}" ${S} stroke-width="2"><circle cx="42" cy="45" r="6"/><circle cx="78" cy="45" r="6"/></g>
      <g fill="${INK}"><circle cx="43" cy="46" r="3"/><circle cx="79" cy="46" r="3"/></g>
      <path d="M42 70c10 8 26 8 36 0" fill="none" ${S}/>`,
  },
  {
    id: 'bee',
    name: 'Bee',
    category: 'animals',
    bg: BG.cream,
    body: `
      <path d="M14 98c10-10 22-6 28-14" fill="none" stroke="${INK}" stroke-width="2.5" stroke-dasharray="1 7" stroke-linecap="round"/>
      <g fill="${C.white}" fill-opacity=".85" ${S}><ellipse cx="48" cy="38" rx="14" ry="22" transform="rotate(-25 48 38)"/><ellipse cx="72" cy="38" rx="14" ry="22" transform="rotate(25 72 38)"/></g>
      <ellipse cx="60" cy="68" rx="32" ry="24" fill="${C.yellow}" ${S}/>
      <clipPath id="bee-body"><ellipse cx="60" cy="68" rx="32" ry="24"/></clipPath>
      <g clip-path="url(#bee-body)" fill="${INK}"><rect x="44" y="40" width="10" height="60"/><rect x="64" y="40" width="10" height="60"/><rect x="84" y="40" width="10" height="60"/></g>
      <ellipse cx="60" cy="68" rx="32" ry="24" fill="none" ${S}/>
      <circle cx="36" cy="66" r="3" fill="${INK}"/>
      <path d="M30 52l-8-12M38 48l-2-14" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>
      <path d="M92 70l8 2-8 4" fill="${INK}"/>
      <path d="M40 56c4-4 8-6 12-6" ${SHINE}/>`,
  },
];
