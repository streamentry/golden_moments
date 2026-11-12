import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { TodayClearAllConfirmation } from './TodayClearAllConfirmation';

describe('TodayClearAllConfirmation', () => {
  it('states the scope and requires a clear choice', () => {
    const hiddenHtml = renderToStaticMarkup(
      createElement(TodayClearAllConfirmation, { hidden: true, onConfirm: () => {}, onCancel: () => {} }),
    );
    const html = renderToStaticMarkup(
      createElement(TodayClearAllConfirmation, { hidden: false, onConfirm: () => {}, onCancel: () => {} }),
    );

    expect(hiddenHtml).toContain('hidden=""');
    expect(html).toContain('Remove all notes saved in this browser? This cannot be undone.');
    expect(html).toContain('Remove all notes');
    expect(html).toContain('Keep notes');
    expect(html).toContain('role="group"');
  });
});
