import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { ActivityChoiceBoard } from './ActivityChoiceBoard';

describe('ActivityChoiceBoard', () => {
  it('renders two large picture links with a calm, nonverbal choice cue', () => {
    const html = renderToStaticMarkup(
      createElement(ActivityChoiceBoard, { choices: ['picture-pairs', 'conversation-cards'] }),
    );

    expect(html).toContain('Choose one together');
    expect(html).toContain('They can point; you can tap.');
    expect(html).toContain('href="/games/picture-pairs/"');
    expect(html).toContain('href="/games/conversation-cards/"');
    expect(html.match(/class="today__activity-choice"/g)).toHaveLength(2);
    expect(html.match(/alt=""/g)).toHaveLength(2);
  });
});
