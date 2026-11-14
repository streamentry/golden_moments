import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { playProps } from '../i18n/play';
import Coloring from './Coloring';

describe('Coloring touch targets', () => {
  it('widens narrow tap targets while keeping the visible outline unchanged', () => {
    const markup = renderToStaticMarkup(
      createElement(Coloring, playProps('en', 'coloring')),
    );
    const stemTarget = markup.match(/<path[^>]*data-region="stem"[^>]*>/)?.[0] ?? '';
    const stemArt = markup.match(/<path[^>]*data-region-art="stem"[^>]*>/)?.[0] ?? '';

    expect(stemTarget).toContain('stroke-width="36"');
    expect(stemTarget).toContain('vector-effect="non-scaling-stroke"');
    expect(stemTarget).toContain('role="button"');
    expect(markup.match(/<path[^>]*data-region="leaf-left"[^>]*>/)?.[0]).toContain('stroke-width="4"');
    expect(stemArt).toContain('stroke-width="4"');
    expect(stemArt).toContain('aria-hidden="true"');
  });
});
