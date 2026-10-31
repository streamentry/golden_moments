/**
 * Coloring pages drawn on a 400 x 400 canvas. Every region is one large,
 * closed shape with a plain name, so it can be tapped and announced.
 * Regions are listed back to front.
 *
 * Page and region names are text, so they live in `src/i18n/play/en.json`
 * (`content.coloring.pages.<page id>`) and its translations, keyed by these ids.
 */
export interface ColorRegion {
  id: string;
  d: string;
}

export interface ColoringPage {
  id: string;
  regions: ColorRegion[];
  /** Thin decorative lines drawn on top, not fillable. */
  details?: string;
}

const circle = (cx: number, cy: number, r: number): string =>
  `M${cx - r} ${cy}a${r} ${r} 0 1 0 ${r * 2} 0a${r} ${r} 0 1 0 ${-r * 2} 0z`;

const ellipse = (cx: number, cy: number, rx: number, ry: number): string =>
  `M${cx - rx} ${cy}a${rx} ${ry} 0 1 0 ${rx * 2} 0a${rx} ${ry} 0 1 0 ${-rx * 2} 0z`;

export const COLORING_PAGES: readonly ColoringPage[] = [
  {
    id: 'flower',
    regions: [
      { id: 'sky', d: 'M0 0h400v300H0z' },
      { id: 'table', d: 'M0 300h400v100H0z' },
      { id: 'stem', d: 'M192 160h16v130h-16z' },
      { id: 'leaf-left', d: 'M192 250c-40-40-90-30-104-10 30 30 74 34 104 10z' },
      { id: 'leaf-right', d: 'M208 220c40-40 90-30 104-10-30 30-74 34-104 10z' },
      ...Array.from({ length: 8 }, (_, i) => {
        const a = (i * Math.PI) / 4;
        const cx = Math.round(200 + Math.cos(a) * 52);
        const cy = Math.round(120 + Math.sin(a) * 52);
        return { id: `petal-${i + 1}`, d: circle(cx, cy, 34) };
      }),
      { id: 'center', d: circle(200, 120, 34) },
      { id: 'pot', d: 'M130 290h140l-20 96H150z' },
      { id: 'pot-rim', d: 'M118 270h164v28H118z' },
    ],
  },
  {
    id: 'house',
    regions: [
      { id: 'sky', d: 'M0 0h400v320H0z' },
      { id: 'sun', d: circle(330, 70, 40) },
      { id: 'grass', d: 'M0 320h400v80H0z' },
      { id: 'chimney', d: 'M262 90h34v80h-34z' },
      { id: 'walls', d: 'M90 190h220v140H90z' },
      { id: 'roof', d: 'M60 196 200 80l140 116z' },
      { id: 'door', d: 'M176 250h48v80h-48z' },
      { id: 'window-left', d: 'M108 216h50v50h-50z' },
      { id: 'window-right', d: 'M242 216h50v50h-50z' },
      { id: 'path', d: 'M176 330h48l30 70h-108z' },
    ],
    details: 'M133 216v50M108 241h50M267 216v50M242 241h50',
  },
  {
    id: 'teacup',
    regions: [
      { id: 'background', d: 'M0 0h400v400H0z' },
      { id: 'saucer', d: ellipse(200, 320, 160, 34) },
      { id: 'handle', d: 'M290 180c70-10 80 90 0 96v-26c40-4 36-50 0-44z' },
      { id: 'cup', d: 'M90 160h220v40c0 80-50 110-110 110S90 280 90 200z' },
      { id: 'band', d: 'M93 214h214l-4 26H97z' },
      { id: 'tea', d: ellipse(200, 160, 110, 22) },
    ],
  },
  {
    id: 'butterfly',
    regions: [
      { id: 'background', d: 'M0 0h400v400H0z' },
      { id: 'wing-top-left', d: 'M196 180C150 60 30 50 40 130s90 90 156 50z' },
      { id: 'wing-top-right', d: 'M204 180c46-120 166-130 156-50s-90 90-156 50z' },
      { id: 'wing-bottom-left', d: 'M196 200c-70 0-120 50-104 100s90 20 104-100z' },
      { id: 'wing-bottom-right', d: 'M204 200c70 0 120 50 104 100s-90 20-104-100z' },
      { id: 'spot-left', d: circle(110, 130, 26) },
      { id: 'spot-right', d: circle(290, 130, 26) },
      { id: 'body', d: ellipse(200, 200, 14, 90) },
    ],
    details: 'M194 116c-10-30-30-46-46-50M206 116c10-30 30-46 46-50',
  },
  {
    id: 'sailboat',
    regions: [
      { id: 'sky', d: 'M0 0h400v290H0z' },
      { id: 'sea', d: 'M0 290q50-20 100 0t100 0 100 0 100 0v110H0z' },
      { id: 'sail-big', d: 'M190 60 80 250h110z' },
      { id: 'sail-small', d: 'M214 90l96 160h-96z' },
      { id: 'mast', d: 'M196 50h14v210h-14z' },
      { id: 'hull', d: 'M60 262h290l-44 56H104z' },
      { id: 'flag', d: 'M210 50l40 14-40 14z' },
    ],
  },
];

export interface Paint {
  /** Key for the color's name in `ui.coloring.paints` and for `data-paint` in games.css. */
  id: string;
  value: string;
}

/** Every color has a name (`ui.coloring.paints`), so color is never the only signal. */
export const PAINTS: readonly Paint[] = [
  { id: 'red', value: '#C8473A' },
  { id: 'orange', value: '#E07B28' },
  { id: 'yellow', value: '#F2CC3D' },
  { id: 'green', value: '#4E8A3E' },
  { id: 'blue', value: '#2F6F9E' },
  { id: 'purple', value: '#8A5A9E' },
  { id: 'pink', value: '#E58FA0' },
  { id: 'brown', value: '#8A5A2B' },
  { id: 'sky-blue', value: '#BFD9E6' },
  { id: 'cream', value: '#F9E7C3' },
  { id: 'gray', value: '#8C8C8C' },
  { id: 'white', value: '#FFFFFF' },
];
