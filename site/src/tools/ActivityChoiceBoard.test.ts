import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { SITUATION_BY_ID } from '../lib/today/situations';
import { ActivityChoiceBoard } from './ActivityChoiceBoard';

describe('ActivityChoiceBoard', () => {
  it('renders the configured game and music choices with a calm, nonverbal cue', () => {
    const choices = SITUATION_BY_ID.get('nothing-to-do')?.choices;
    if (!choices) throw new Error('The no-activity situation needs two choices.');

    const html = renderToStaticMarkup(createElement(ActivityChoiceBoard, { choices }));

    expect(html).toContain('Choose one together');
    expect(html).toContain('They can point; you can tap.');
    expect(html).toContain('href="/games/picture-pairs/"');
    expect(html).toContain('href="/activities/music/"');
    expect(html).toContain('Listen to a familiar song');
    expect(html).toContain('Choose music they enjoy. Listening together is enough.');
    expect(html).toContain('radio.svg');
    expect(html.match(/class="today__activity-choice"/g)).toHaveLength(2);
    expect(html.match(/alt=""/g)).toHaveLength(2);
  });
});
