import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { playProps } from '../../i18n/play';
import { GameFrame } from './GameFrame';

describe('GameFrame exit action', () => {
  it('shows the existing Done for now link before game options and play', () => {
    const ui = playProps('en', 'picture-pairs').ui;
    const markup = renderToStaticMarkup(
      createElement(
        GameFrame,
        {
          ui,
          lang: 'en',
          guidance: 'Read the instructions together.',
          options: createElement('div', null, 'OPTIONS'),
          children: createElement('div', null, 'BOARD'),
        },
      ),
    );

    const doneIndex = markup.indexOf(ui.frame.done);
    expect(doneIndex).toBeGreaterThanOrEqual(0);
    expect(doneIndex).toBeLessThan(markup.indexOf('OPTIONS'));
    expect(doneIndex).toBeLessThan(markup.indexOf('Read the instructions together.'));
    expect(doneIndex).toBeLessThan(markup.indexOf('BOARD'));
    expect(markup.split(ui.frame.done)).toHaveLength(2);
    expect(markup).toContain('class="btn btn--quiet" href="/games/"');
  });
});
