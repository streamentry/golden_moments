import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { TodaySuggestions } from './TodaySuggestions';

describe('TodaySuggestions', () => {
  it('shows the first suggestion and keeps alternatives collapsed until requested', () => {
    const html = renderToStaticMarkup(
      createElement(TodaySuggestions, { suggestions: ['Try a familiar photo.', 'Offer tea.', 'Take a short walk.'] }),
    );

    expect(html).toContain('<h3>Try this first</h3>');
    expect(html).toContain('<p>Try a familiar photo.</p>');
    expect(html).toContain('<details class="today__more-ideas">');
    expect(html).toContain('<summary class="btn btn--quiet">See two more ideas</summary>');
    expect(html).not.toMatch(/<details[^>]*\bopen(?:=""|(?=\s|>))/);
    expect(html).toContain('Offer tea.');
    expect(html).toContain('Take a short walk.');
  });

  it('does not invent advice when the list is empty', () => {
    expect(renderToStaticMarkup(createElement(TodaySuggestions, { suggestions: [] }))).toBe('');
  });
});
