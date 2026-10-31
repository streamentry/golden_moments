/**
 * Picture library. Every picture is drawn for this site (no third-party
 * artwork), on a 120 x 120 canvas with a full-bleed soft background so it
 * reads like a mounted print and can be cut into puzzle pieces.
 * Files are emitted at /pictures/<id>.svg by src/pages/pictures/[id].svg.ts.
 */

export type PictureCategory =
  | 'kitchen'
  | 'garden'
  | 'animals'
  | 'fruit'
  | 'home'
  | 'travel'
  | 'sky';

export interface Picture {
  id: string;
  name: string;
  category: PictureCategory;
  bg: string;
  body: string;
}

const INK = '#2b2b2b';
// Stroke width defaults to 3 through the wrapping <g> in pictureSvg, so a
// shape can override it without a duplicate attribute.
const S = `stroke="${INK}" stroke-linejoin="round" stroke-linecap="round"`;

const BG = {
  cream: '#F9E7C3',
  sky: '#DCEBF2',
  sage: '#E3EDD5',
  blush: '#F6DCD3',
  night: '#34506F',
} as const;

export const PICTURES: readonly Picture[] = [
  {
    id: 'teacup',
    name: 'Teacup',
    category: 'kitchen',
    bg: BG.cream,
    body: `
      <path d="M50 38c-6-6 6-10 0-18M66 38c-6-6 6-10 0-18" fill="none" stroke="#8C8C8C" stroke-width="3" stroke-linecap="round"/>
      <ellipse cx="58" cy="90" rx="44" ry="9" fill="#FFFDF7" ${S}/>
      <path d="M84 56c14 0 14 20 0 20" fill="none" ${S} stroke-width="6"/>
      <path d="M28 48h60v6c0 22-13 34-30 34S28 76 28 54z" fill="#C8473A" ${S}/>
      <path d="M31 62h54" stroke="#FFFDF7" stroke-width="4"/>
      <ellipse cx="58" cy="48" rx="30" ry="6" fill="#8A5A2B" ${S}/>`,
  },
  {
    id: 'kettle',
    name: 'Kettle',
    category: 'kitchen',
    bg: BG.sage,
    body: `
      <path d="M42 50Q60 22 78 50" fill="none" ${S} stroke-width="6"/>
      <path d="M36 66 14 50l5-5 19 12z" fill="#2F6F9E" ${S}/>
      <path d="M32 94 38 56q22-14 44 0l6 38z" fill="#2F6F9E" ${S}/>
      <circle cx="60" cy="47" r="5" fill="${INK}"/>
      <rect x="26" y="92" width="68" height="8" rx="4" fill="${INK}"/>
      <path d="M44 70h32" stroke="#FFFDF7" stroke-width="4" stroke-linecap="round"/>`,
  },
  {
    id: 'bread',
    name: 'Loaf of bread',
    category: 'kitchen',
    bg: BG.blush,
    body: `
      <rect x="12" y="84" width="96" height="12" rx="5" fill="#8A5A2B" ${S}/>
      <path d="M20 84V62c0-18 14-22 24-18 6-10 26-10 32 0 10-4 24 0 24 18v22z" fill="#D9A15B" ${S}/>
      <path d="M40 54l8 16M58 51l8 16M76 54l8 16" stroke="#8A5A2B" stroke-width="4" stroke-linecap="round"/>`,
  },
  {
    id: 'frying-pan',
    name: 'Frying pan with an egg',
    category: 'kitchen',
    bg: BG.cream,
    body: `
      <path d="M80 56 112 46l3 9-32 12z" fill="#8A5A2B" ${S}/>
      <circle cx="50" cy="62" r="34" fill="${INK}"/>
      <circle cx="50" cy="62" r="27" fill="#555"/>
      <path d="M32 60c-2-12 10-18 18-12 8-8 22 0 18 12 6 8-4 18-14 14-10 6-26-2-22-14z" fill="#FFFDF7" ${S}/>
      <circle cx="51" cy="62" r="8" fill="#E0A526" ${S}/>`,
  },
  {
    id: 'cake',
    name: 'Birthday cake',
    category: 'kitchen',
    bg: BG.sky,
    body: `
      <ellipse cx="60" cy="96" rx="46" ry="8" fill="#FFFDF7" ${S}/>
      <rect x="24" y="58" width="72" height="36" rx="4" fill="#E58FA0" ${S}/>
      <path d="M24 64q6 10 12 0t12 0 12 0 12 0 12 0 12 0v-6H24z" fill="#FFFDF7" ${S}/>
      <path d="M24 80h72" stroke="#FFFDF7" stroke-width="4"/>
      <rect x="40" y="38" width="6" height="20" fill="#2F6F9E" ${S}/>
      <rect x="57" y="38" width="6" height="20" fill="#2F6F9E" ${S}/>
      <rect x="74" y="38" width="6" height="20" fill="#2F6F9E" ${S}/>
      <path d="M43 26q5 6 0 10-5-4 0-10zM60 26q5 6 0 10-5-4 0-10zM77 26q5 6 0 10-5-4 0-10z" fill="#E0A526" ${S} stroke-width="2"/>`,
  },
  {
    id: 'sunflower',
    name: 'Sunflower',
    category: 'garden',
    bg: BG.sky,
    body: `
      <path d="M60 60v54" stroke="#3E7A30" stroke-width="7" stroke-linecap="round"/>
      <path d="M60 92c-14-12-28-6-30 0 10 6 22 6 30 0zM60 82c14-12 28-6 30 0-10 6-22 6-30 0z" fill="#4E8A3E" ${S}/>
      <g fill="#E0A526" ${S}>
        ${Array.from({ length: 12 }, (_, i) => `<ellipse cx="60" cy="22" rx="8" ry="16" transform="rotate(${i * 30} 60 44)"/>`).join('')}
      </g>
      <circle cx="60" cy="44" r="15" fill="#8A5A2B" ${S}/>
      <g fill="${INK}"><circle cx="55" cy="40" r="2"/><circle cx="64" cy="41" r="2"/><circle cx="58" cy="49" r="2"/><circle cx="66" cy="48" r="2"/></g>`,
  },
  {
    id: 'tulip',
    name: 'Red tulip',
    category: 'garden',
    bg: BG.cream,
    body: `
      <path d="M60 64v50" stroke="#3E7A30" stroke-width="7" stroke-linecap="round"/>
      <path d="M58 110C40 104 30 86 32 70c14 6 24 20 26 40zM62 110c18-6 28-24 26-40-14 6-24 20-26 40z" fill="#4E8A3E" ${S}/>
      <path d="M40 30v26q20 22 40 0V30l-10 12-10-18-10 18z" fill="#C8473A" ${S}/>`,
  },
  {
    id: 'watering-can',
    name: 'Watering can',
    category: 'garden',
    bg: BG.cream,
    body: `
      <path d="M44 52Q54 28 72 52" fill="none" ${S} stroke-width="6"/>
      <path d="M78 74 102 48" ${S} stroke-width="7"/>
      <path d="M98 40l12 12-6 4-12-12z" fill="#4E8A3E" ${S}/>
      <rect x="26" y="50" width="56" height="44" rx="8" fill="#4E8A3E" ${S}/>
      <path d="M34 62h40" stroke="#FFFDF7" stroke-width="4" stroke-linecap="round"/>
      <g fill="#2F6F9E"><circle cx="110" cy="66" r="3"/><circle cx="104" cy="74" r="3"/><circle cx="112" cy="80" r="3"/></g>`,
  },
  {
    id: 'potted-plant',
    name: 'Potted plant',
    category: 'garden',
    bg: BG.sky,
    body: `
      <path d="M60 70V38" stroke="#3E7A30" stroke-width="5" stroke-linecap="round"/>
      <path d="M60 50C46 30 26 34 22 40c10 12 28 16 38 10zM60 44c14-22 34-20 38-14-8 12-26 18-38 14zM60 64C48 52 34 56 30 62c8 8 22 8 30 2zM60 62c12-12 26-8 30-2-8 8-22 8-30 2z" fill="#4E8A3E" ${S}/>
      <path d="M34 70h52l-7 38H41z" fill="#C9673A" ${S}/>
      <rect x="30" y="66" width="60" height="12" rx="3" fill="#B0552B" ${S}/>`,
  },
  {
    id: 'tree',
    name: 'Tree',
    category: 'garden',
    bg: BG.sky,
    body: `
      <rect x="0" y="98" width="120" height="22" fill="#9BBF6A"/>
      <path d="M52 104V66h16v38z" fill="#8A5A2B" ${S}/>
      <g fill="#4E8A3E" ${S}><circle cx="42" cy="56" r="20"/><circle cx="78" cy="56" r="20"/><circle cx="60" cy="36" r="24"/></g>
      <g fill="#C8473A"><circle cx="48" cy="40" r="4"/><circle cx="72" cy="30" r="4"/><circle cx="82" cy="58" r="4"/><circle cx="40" cy="62" r="4"/></g>`,
  },
  {
    id: 'bird',
    name: 'Robin on a branch',
    category: 'animals',
    bg: BG.cream,
    body: `
      <path d="M8 92h104" stroke="#8A5A2B" stroke-width="7" stroke-linecap="round"/>
      <path d="M50 92l-3-10M64 92l3-10" ${S}/>
      <path d="M86 58l24-10-18 22z" fill="#8A5A2B" ${S}/>
      <ellipse cx="60" cy="62" rx="32" ry="22" fill="#8A5A2B" ${S}/>
      <path d="M36 70c4-14 18-18 28-12 0 12-10 24-28 12z" fill="#E07B28" ${S}/>
      <circle cx="40" cy="42" r="16" fill="#8A5A2B" ${S}/>
      <path d="M26 42 14 46l12 4z" fill="#E0A526" ${S}/>
      <circle cx="36" cy="38" r="3" fill="${INK}"/>`,
  },
  {
    id: 'butterfly',
    name: 'Butterfly',
    category: 'animals',
    bg: BG.sage,
    body: `
      <path d="M56 30q-8-12-14-14M64 30q8-12 14-14" fill="none" ${S}/>
      <g fill="#E07B28" ${S}>
        <path d="M58 56C46 24 14 22 14 40s20 26 44 16zM62 56c12-32 44-34 44-16s-20 26-44 16z"/>
        <path d="M58 62C40 64 26 78 30 92s24 6 28-30zM62 62c18 2 32 16 28 30s-24 6-28-30z"/>
      </g>
      <g fill="#FFFDF7"><circle cx="30" cy="38" r="5"/><circle cx="90" cy="38" r="5"/><circle cx="40" cy="82" r="4"/><circle cx="80" cy="82" r="4"/></g>
      <ellipse cx="60" cy="60" rx="5" ry="26" fill="${INK}"/>`,
  },
  {
    id: 'dog',
    name: 'Dog',
    category: 'animals',
    bg: BG.blush,
    body: `
      <path d="M30 82q30 18 60 0v26H30z" fill="#C9935A" ${S}/>
      <path d="M38 86q22 10 44 0" stroke="#C8473A" stroke-width="7" stroke-linecap="round" fill="none"/>
      <circle cx="60" cy="56" r="30" fill="#C9935A" ${S}/>
      <path d="M34 36c-12 2-16 26-8 40 8-4 12-20 12-34zM86 36c12 2 16 26 8 40-8-4-12-20-12-34z" fill="#8A5A2B" ${S}/>
      <ellipse cx="60" cy="68" rx="14" ry="10" fill="#E8C9A0"/>
      <circle cx="49" cy="52" r="4" fill="${INK}"/><circle cx="71" cy="52" r="4" fill="${INK}"/>
      <ellipse cx="60" cy="64" rx="6" ry="4.5" fill="${INK}"/>
      <path d="M60 68v5m-7 2q7 5 14 0" fill="none" ${S}/>`,
  },
  {
    id: 'cat',
    name: 'Cat',
    category: 'animals',
    bg: BG.sky,
    body: `
      <path d="M30 50 34 16l24 18zM90 50 86 16 62 34z" fill="#E07B28" ${S}/>
      <path d="M36 24l3 16 10-6zM84 24l-3 16-10-6z" fill="#F6DCD3"/>
      <ellipse cx="60" cy="64" rx="36" ry="32" fill="#E07B28" ${S}/>
      <path d="M52 36l3 10M60 34v11M68 36l-3 10" stroke="#B0552B" stroke-width="3" stroke-linecap="round"/>
      <ellipse cx="46" cy="60" rx="6" ry="7" fill="#9BBF3E" ${S}/><ellipse cx="74" cy="60" rx="6" ry="7" fill="#9BBF3E" ${S}/>
      <ellipse cx="46" cy="60" rx="2" ry="5" fill="${INK}"/><ellipse cx="74" cy="60" rx="2" ry="5" fill="${INK}"/>
      <path d="M56 72h8l-4 5z" fill="#E58FA0" ${S} stroke-width="2"/>
      <path d="M60 77q-4 6-9 4m9-4q4 6 9 4M20 70l22 2M20 80l22-4M100 70l-22 2M100 80l-22-4" fill="none" ${S} stroke-width="2"/>`,
  },
  {
    id: 'fish',
    name: 'Goldfish',
    category: 'animals',
    bg: BG.sky,
    body: `
      <g fill="none" stroke="#2F6F9E" stroke-width="3"><circle cx="96" cy="34" r="5"/><circle cx="104" cy="20" r="3.5"/><circle cx="92" cy="14" r="2.5"/></g>
      <path d="M26 60 6 40v40z" fill="#E07B28" ${S}/>
      <path d="M56 40 66 24l12 20z" fill="#E0A526" ${S}/>
      <ellipse cx="60" cy="60" rx="36" ry="24" fill="#E07B28" ${S}/>
      <path d="M50 46q8 14 0 28" fill="none" stroke="#B0552B" stroke-width="3"/>
      <circle cx="80" cy="54" r="5" fill="#FFFDF7" ${S} stroke-width="2"/><circle cx="81" cy="54" r="2.5" fill="${INK}"/>
      <path d="M90 66q4 2 6-2" fill="none" ${S} stroke-width="2"/>`,
  },
  {
    id: 'apple',
    name: 'Red apple',
    category: 'fruit',
    bg: BG.sage,
    body: `
      <path d="M60 36c-6-12-40-14-40 24 0 30 22 50 40 40 18 10 40-10 40-40 0-38-34-36-40-24z" fill="#C8473A" ${S}/>
      <path d="M60 36c0-8 2-16 8-22" fill="none" stroke="#8A5A2B" stroke-width="5" stroke-linecap="round"/>
      <path d="M64 28c6-12 22-14 28-8-6 10-18 12-28 8z" fill="#4E8A3E" ${S}/>
      <path d="M36 52q2-10 10-12" fill="none" stroke="#FFFDF7" stroke-width="4" stroke-linecap="round"/>`,
  },
  {
    id: 'pear',
    name: 'Pear',
    category: 'fruit',
    bg: BG.blush,
    body: `
      <path d="M60 22c-12 0-14 16-16 26-4 14-22 18-22 38 0 18 16 26 38 26s38-8 38-26c0-20-18-24-22-38-2-10-4-26-16-26z" fill="#B5C944" ${S}/>
      <path d="M60 22V8" stroke="#8A5A2B" stroke-width="5" stroke-linecap="round"/>
      <path d="M62 16c8-10 20-8 24-2-8 8-16 6-24 2z" fill="#4E8A3E" ${S}/>
      <path d="M38 80q0-10 8-14" fill="none" stroke="#FFFDF7" stroke-width="4" stroke-linecap="round"/>`,
  },
  {
    id: 'strawberry',
    name: 'Strawberry',
    category: 'fruit',
    bg: BG.cream,
    body: `
      <path d="M22 44c0-8 18-12 38-12s38 4 38 12c0 30-22 62-38 62S22 74 22 44z" fill="#D2363A" ${S}/>
      <path d="M60 36 46 22l4 14-18-4 12 10-12 6h56l-12-6 12-10-18 4 4-14z" fill="#4E8A3E" ${S}/>
      <path d="M60 30V14" stroke="#3E7A30" stroke-width="5" stroke-linecap="round"/>
      <g fill="#F2D03B">
        <ellipse cx="40" cy="56" rx="2" ry="3"/><ellipse cx="56" cy="54" rx="2" ry="3"/><ellipse cx="72" cy="56" rx="2" ry="3"/><ellipse cx="86" cy="54" rx="2" ry="3"/>
        <ellipse cx="46" cy="70" rx="2" ry="3"/><ellipse cx="62" cy="70" rx="2" ry="3"/><ellipse cx="78" cy="70" rx="2" ry="3"/>
        <ellipse cx="54" cy="86" rx="2" ry="3"/><ellipse cx="68" cy="86" rx="2" ry="3"/>
      </g>`,
  },
  {
    id: 'banana',
    name: 'Banana',
    category: 'fruit',
    bg: BG.sky,
    body: `
      <path d="M22 34c-6 34 18 66 62 62 10-1 16-6 14-10-40 4-60-20-62-52z" fill="#F2CC3D" ${S}/>
      <path d="M30 38c4 24 22 44 56 46" fill="none" stroke="#C99200" stroke-width="3"/>
      <path d="M22 34l-4-12 10 2 8 10z" fill="#8A5A2B" ${S}/>
      <path d="M98 86l4 4" stroke="${INK}" stroke-width="6" stroke-linecap="round"/>`,
  },
  {
    id: 'lemon',
    name: 'Lemon',
    category: 'fruit',
    bg: BG.sage,
    body: `
      <path d="M14 66c4-2 6-4 8-8 8-20 30-30 52-24 14 4 22 14 26 24 2 4 4 6 8 8-4 2-6 4-8 8-8 18-30 28-52 22-14-4-22-14-26-22-2-4-4-6-8-8z" fill="#F2D03B" ${S}/>
      <path d="M40 54q8-10 22-10" fill="none" stroke="#FFFDF7" stroke-width="4" stroke-linecap="round"/>
      <path d="M78 34c4-14 20-20 28-16-4 12-16 18-28 16z" fill="#4E8A3E" ${S}/>`,
  },
  {
    id: 'cherries',
    name: 'Cherries',
    category: 'fruit',
    bg: BG.cream,
    body: `
      <path d="M40 76c4-24 14-46 34-60M80 80c-2-24-2-44-6-64" fill="none" stroke="#3E7A30" stroke-width="4" stroke-linecap="round"/>
      <path d="M74 16c10-8 26-6 30 2-10 8-22 8-30-2z" fill="#4E8A3E" ${S}/>
      <circle cx="40" cy="86" r="20" fill="#B3262E" ${S}/>
      <circle cx="82" cy="88" r="20" fill="#B3262E" ${S}/>
      <path d="M30 80q2-6 8-8M72 82q2-6 8-8" fill="none" stroke="#FFFDF7" stroke-width="4" stroke-linecap="round"/>`,
  },
  {
    id: 'house',
    name: 'House',
    category: 'home',
    bg: BG.sky,
    body: `
      <rect x="0" y="102" width="120" height="18" fill="#9BBF6A"/>
      <rect x="74" y="22" width="12" height="24" fill="#8A5A2B" ${S}/>
      <rect x="24" y="56" width="72" height="48" fill="#E8C9A0" ${S}/>
      <path d="M14 60 60 22l46 38z" fill="#C8473A" ${S}/>
      <rect x="52" y="76" width="18" height="28" rx="2" fill="#2F6F9E" ${S}/>
      <rect x="30" y="66" width="16" height="16" fill="#FFFDF7" ${S}/><path d="M38 66v16M30 74h16" stroke="${INK}" stroke-width="2"/>
      <rect x="76" y="66" width="14" height="16" fill="#FFFDF7" ${S}/><path d="M83 66v16M76 74h14" stroke="${INK}" stroke-width="2"/>`,
  },
  {
    id: 'lamp',
    name: 'Table lamp',
    category: 'home',
    bg: BG.blush,
    body: `
      <path d="M14 34l-8-4M106 34l8-4M60 10V2" stroke="#C99200" stroke-width="3" stroke-linecap="round"/>
      <path d="M38 18h44l14 40H24z" fill="#E0A526" ${S}/>
      <path d="M60 58v34" stroke="${INK}" stroke-width="6"/>
      <path d="M36 104q0-14 24-14t24 14z" fill="#8A5A2B" ${S}/>`,
  },
  {
    id: 'armchair',
    name: 'Armchair',
    category: 'home',
    bg: BG.sage,
    body: `
      <path d="M30 96v12M90 96v12" stroke="#8A5A2B" stroke-width="6" stroke-linecap="round"/>
      <path d="M30 70V34q0-14 14-14h32q14 0 14 14v36z" fill="#C8473A" ${S}/>
      <rect x="30" y="68" width="60" height="16" rx="5" fill="#E58FA0" ${S}/>
      <path d="M14 62q0-8 8-8h8v44H18q-4 0-4-4zM106 62q0-8-8-8h-8v44h12q4 0 4-4z" fill="#C8473A" ${S}/>
      <rect x="30" y="84" width="60" height="14" fill="#B03127" ${S}/>`,
  },
  {
    id: 'key',
    name: 'Old key',
    category: 'home',
    bg: BG.cream,
    body: `
      <circle cx="34" cy="60" r="22" fill="#C99200" ${S}/>
      <circle cx="34" cy="60" r="10" fill="${BG.cream}" ${S}/>
      <path d="M56 54h50v12H56z" fill="#C99200" ${S}/>
      <path d="M84 66v14h8V66M98 66v10h8V66" fill="#C99200" ${S}/>`,
  },
  {
    id: 'umbrella',
    name: 'Umbrella',
    category: 'home',
    bg: BG.blush,
    body: `
      <path d="M60 22v70q0 12-10 12t-10-10" fill="none" ${S} stroke-width="5"/>
      <path d="M12 62C12 34 34 18 60 18s48 16 48 44q-8-8-16 0-8-8-16 0-8-8-16 0-8-8-16 0-8-8-16 0-8-8-16 0z" fill="#2F6F9E" ${S}/>
      <path d="M60 18q-14 18-14 44M60 18q14 18 14 44" fill="none" stroke="#FFFDF7" stroke-width="3"/>
      <circle cx="60" cy="16" r="4" fill="${INK}"/>`,
  },
  {
    id: 'sailboat',
    name: 'Sailboat',
    category: 'travel',
    bg: BG.sky,
    body: `
      <path d="M0 100q10-6 20 0t20 0 20 0 20 0 20 0 20 0v20H0z" fill="#2F6F9E"/>
      <path d="M62 14v68" stroke="${INK}" stroke-width="4"/>
      <path d="M58 20 24 76h34z" fill="#FFFDF7" ${S}/>
      <path d="M66 26l30 50H66z" fill="#C8473A" ${S}/>
      <path d="M16 82h90l-14 18H30z" fill="#8A5A2B" ${S}/>`,
  },
  {
    id: 'car',
    name: 'Classic car',
    category: 'travel',
    bg: BG.cream,
    body: `
      <path d="M8 98h104" stroke="#8C8C8C" stroke-width="4" stroke-linecap="round"/>
      <path d="M12 82V70q0-8 10-10l14-2 12-16q4-4 12-4h18q8 0 12 6l10 14 10 2q8 2 8 10v12z" fill="#2F6F9E" ${S}/>
      <path d="M50 46h14v14H40zM70 46h12l8 14H70z" fill="#DCEBF2" ${S}/>
      <circle cx="34" cy="84" r="12" fill="${INK}"/><circle cx="34" cy="84" r="5" fill="#C8C8C8"/>
      <circle cx="88" cy="84" r="12" fill="${INK}"/><circle cx="88" cy="84" r="5" fill="#C8C8C8"/>
      <rect x="100" y="68" width="8" height="6" rx="2" fill="#F2D03B"/>`,
  },
  {
    id: 'bicycle',
    name: 'Bicycle',
    category: 'travel',
    bg: BG.sage,
    body: `
      <circle cx="30" cy="78" r="20" fill="none" ${S} stroke-width="5"/>
      <circle cx="90" cy="78" r="20" fill="none" ${S} stroke-width="5"/>
      <path d="M30 78l20-30h30l10 30M50 48l14 30h-34M64 78l16-30" fill="none" stroke="#C8473A" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>
      <path d="M50 48l-4-10M40 38h14M80 48l-4-16h10" fill="none" ${S} stroke-width="4"/>
      <circle cx="64" cy="78" r="4" fill="${INK}"/>`,
  },
  {
    id: 'balloon',
    name: 'Hot air balloon',
    category: 'travel',
    bg: BG.sky,
    body: `
      <path d="M44 74l6 18M76 74l-6 18" stroke="${INK}" stroke-width="2"/>
      <path d="M60 8C34 8 20 26 20 44c0 20 18 30 24 32h32c6-2 24-12 24-32 0-18-14-36-40-36z" fill="#E0A526" ${S}/>
      <path d="M60 8C48 18 44 34 46 50s4 24 4 26h20c0-2 2-10 4-26S72 18 60 8z" fill="#C8473A" ${S}/>
      <path d="M22 40h76" stroke="#FFFDF7" stroke-width="3"/>
      <rect x="48" y="92" width="24" height="18" rx="2" fill="#8A5A2B" ${S}/>`,
  },
  {
    id: 'lighthouse',
    name: 'Lighthouse',
    category: 'travel',
    bg: BG.sky,
    body: `
      <path d="M68 26 112 12v28zM52 26 8 12v28z" fill="#F2D03B" opacity=".8"/>
      <path d="M0 104q16-10 30-4 10-12 26-8h8q16-4 26 8 14-6 30 4v16H0z" fill="#8C8C8C" ${S}/>
      <path d="M44 96l6-60h20l6 60z" fill="#FFFDF7" ${S}/>
      <path d="M48 58l26-1 1.5 14-29 1zM45.5 84l29-1 1.2 12H44.4z" fill="#C8473A"/>
      <rect x="48" y="20" width="24" height="16" fill="#F2D03B" ${S}/>
      <path d="M44 20h32L60 6z" fill="#C8473A" ${S}/>
      <path d="M44 36h32" ${S}/>`,
  },
  {
    id: 'sun',
    name: 'Sun',
    category: 'sky',
    bg: BG.sky,
    body: `
      <g stroke="#C99200" stroke-width="6" stroke-linecap="round">
        ${Array.from({ length: 12 }, (_, i) => `<path d="M60 10v12" transform="rotate(${i * 30} 60 60)"/>`).join('')}
      </g>
      <circle cx="60" cy="60" r="28" fill="#F2CC3D" ${S}/>`,
  },
  {
    id: 'moon',
    name: 'Moon and stars',
    category: 'sky',
    bg: BG.night,
    body: `
      <path d="M70 18a40 40 0 1 0 30 58A34 34 0 1 1 70 18z" fill="#F2D03B" stroke="#FFFDF7" stroke-width="3" stroke-linejoin="round"/>
      <g fill="#FFFDF7">
        <path d="M92 22l3 7 7 3-7 3-3 7-3-7-7-3 7-3z"/>
        <path d="M100 52l2 5 5 2-5 2-2 5-2-5-5-2 5-2z"/>
        <path d="M20 26l2 5 5 2-5 2-2 5-2-5-5-2 5-2z"/>
      </g>`,
  },
];

export const PICTURE_BY_ID: ReadonlyMap<string, Picture> = new Map(PICTURES.map((p) => [p.id, p]));

export function pictureSvg(picture: Picture): string {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" width="240" height="240" role="img" aria-label="${picture.name}"><title>${picture.name}</title><rect width="120" height="120" fill="${picture.bg}"/><g stroke-width="3">${picture.body.replace(/\s*\n\s*/g, '')}</g></svg>`;
}

export function pictureUrl(id: string): string {
  return `/pictures/${id}.svg`;
}

/**
 * The picture without its background, for Shadow match. The game darkens it
 * with a CSS filter, which keeps open strokes as lines instead of filling
 * them in.
 */
export function pictureShadowSvg(picture: Picture): string {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" width="240" height="240" aria-hidden="true"><g stroke-width="3">${picture.body.replace(/\s*\n\s*/g, '')}</g></svg>`;
}

export function pictureShadowUrl(id: string): string {
  return `/pictures/shadow/${id}.svg`;
}

export function picturesIn(category: PictureCategory): Picture[] {
  return PICTURES.filter((p) => p.category === category);
}
