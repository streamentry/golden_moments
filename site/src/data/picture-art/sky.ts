import { BG, C, INK, S, SHADE, SHINE, type Picture } from './kit.ts';

/** Weather and sky, drawn after the first set. */
export const SKY: readonly Picture[] = [
  {
    id: 'rainbow',
    name: 'Rainbow',
    category: 'sky',
    bg: BG.sky,
    body: `
      <g fill="none" stroke-width="9">
        <path d="M14 88a46 46 0 0 1 92 0" stroke="${C.red}"/>
        <path d="M23 88a37 37 0 0 1 74 0" stroke="${C.orange}"/>
        <path d="M32 88a28 28 0 0 1 56 0" stroke="${C.yellow}"/>
        <path d="M41 88a19 19 0 0 1 38 0" stroke="${C.green}"/>
      </g>
      <path d="M9.5 88a50.5 50.5 0 0 1 101 0M45.5 88a14.5 14.5 0 0 1 29 0" fill="none" ${S}/>
      <g fill="${C.paper}" ${S}><path d="M6 96c0-8 8-12 14-8 2-8 14-10 18-2 8-2 14 4 12 10z"/><path d="M70 96c0-8 8-12 14-8 2-8 14-10 18-2 8-2 14 4 12 10z"/></g>`,
  },
  {
    id: 'rain-cloud',
    name: 'Rain cloud',
    category: 'sky',
    bg: BG.sage,
    body: `
      <g stroke="${C.blue}" stroke-width="4" stroke-linecap="round"><path d="M38 76l-6 12M58 76l-6 12M78 76l-6 12M48 94l-6 12M68 94l-6 12"/></g>
      <path d="M26 70c-12 0-16-16-4-20-2-16 16-26 28-16 6-14 28-14 32 2 14-2 22 14 14 24 8 4 4 10-2 10z" fill="${C.paper}" ${S}/>
      <path d="M82 44c10 0 16 12 12 20 6 2 4 6 0 6H70c10-4 16-14 12-26z" ${SHADE}/>
      <path d="M30 48c0-6 4-10 10-12" fill="none" stroke="${C.sky}" stroke-width="3" stroke-linecap="round"/>`,
  },
  {
    id: 'snowflake',
    name: 'Snowflake',
    category: 'sky',
    bg: BG.night,
    body: `
      <g stroke="${C.paper}" stroke-width="5" stroke-linecap="round" fill="none">
        <g id="snow-arm"><path d="M60 60V18M60 30l-9-9M60 30l9-9M60 44l-12-10M60 44l12-10"/></g>
        <use href="#snow-arm" transform="rotate(60 60 60)"/>
        <use href="#snow-arm" transform="rotate(120 60 60)"/>
        <use href="#snow-arm" transform="rotate(180 60 60)"/>
        <use href="#snow-arm" transform="rotate(240 60 60)"/>
        <use href="#snow-arm" transform="rotate(300 60 60)"/>
      </g>
      <circle cx="60" cy="60" r="7" fill="${C.sky}" stroke="${C.paper}" stroke-width="3"/>
      <g fill="${C.paper}" fill-opacity=".7"><circle cx="18" cy="22" r="2.5"/><circle cx="102" cy="96" r="2.5"/><circle cx="100" cy="20" r="2"/><circle cx="20" cy="98" r="2"/></g>`,
  },
  {
    id: 'kite',
    name: 'Kite',
    category: 'sky',
    bg: BG.sky,
    body: `
      <path d="M60 86c-6 10 8 14 2 24" fill="none" stroke="${INK}" stroke-width="2.5" stroke-linecap="round"/>
      <g fill="${C.red}" ${S} stroke-width="2"><path d="M56 96l-6-3 2 7zM66 104l6-3-2 7z"/></g>
      <path d="M60 10 92 46 60 86 28 46z" fill="${C.yellow}" ${S}/>
      <path d="M60 10v76L28 46z" fill="${C.red}"/>
      <path d="M60 46 92 46 60 86z" fill="${C.blue}"/>
      <path d="M60 10 92 46 60 86 28 46zM60 10v76M28 46h64" fill="none" ${S}/>
      <path d="M60 46 92 46 60 86z" ${SHADE}/>
      <path d="M86 46c10 18 14 40 22 62" fill="none" stroke="${INK}" stroke-opacity=".5" stroke-width="2" stroke-linecap="round"/>`,
  },
  {
    id: 'sunrise',
    name: 'Sunrise over the hills',
    category: 'sky',
    bg: BG.blush,
    body: `
      <g stroke="${C.mustard}" stroke-width="4" stroke-linecap="round"><path d="M60 14v10M28 28l7 7M92 28l-7 7M14 58h10M96 58h10"/></g>
      <circle cx="60" cy="66" r="28" fill="${C.yellow}" ${S}/>
      <path d="M0 74c22-10 40-8 60 4 20-12 40-14 60-4v46H0z" fill="${C.leaf}" ${S}/>
      <path d="M0 92c26-12 52-10 76 0 16-6 32-6 44 0v28H0z" fill="${C.green}" ${S}/>
      <path d="M76 92c16-6 32-6 44 0v28H96c-4-14-10-22-20-28z" ${SHADE}/>
      <path d="M44 48c4-6 10-8 16-8" ${SHINE}/>`,
  },
];
