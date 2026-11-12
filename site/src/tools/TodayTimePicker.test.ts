import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { TodayTimePicker } from './TodayTimePicker';

describe('TodayTimePicker', () => {
  it('labels the optional time band and offers broad, plain choices', () => {
    const html = renderToStaticMarkup(createElement(TodayTimePicker, { value: '', onChange: () => {} }));

    expect(html).toContain('When did you try it? (optional)');
    expect(html).toContain('<option value="" selected="">Not recorded</option>');
    expect(html).toContain('<option value="morning">Morning</option>');
    expect(html).toContain('<option value="afternoon">Afternoon</option>');
    expect(html).toContain('<option value="evening">Evening</option>');
  });
});
