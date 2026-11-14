import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { playProps } from '../i18n/play';
import { SayingActions } from './FinishTheSaying';

describe('FinishTheSaying answer choices', () => {
  it('shows the answer-free reveal action before the guess choices', () => {
    const ui = playProps('en', 'finish-the-saying').ui.finishTheSaying;
    const markup = renderToStaticMarkup(
      createElement(SayingActions, {
        choices: ['choice one', 'choice two', 'choice three'],
        choicesLabel: ui.choicesLabel,
        showLabel: ui.show,
        onChoose: () => undefined,
        onReveal: () => undefined,
      }),
    );

    expect(markup.indexOf(ui.show)).toBeLessThan(markup.indexOf('role="group"'));
    expect(markup).toContain('class="btn say-card__reveal"');
  });
});
