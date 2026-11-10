import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { playProps } from '../i18n/play';
import ConversationCards from './ConversationCards';

describe('ConversationCards', () => {
  it('starts with the conversation prompt available and checked', () => {
    const html = renderToStaticMarkup(createElement(ConversationCards, playProps('en', 'conversation-cards')));

    expect(html).toContain('Show a conversation prompt');
    expect(html).toMatch(/type="checkbox" checked=""/);
    expect(html).toContain('class="talk-card__prompt"');
  });

  it('uses the English source label until a locale has a reviewed translation', () => {
    const english = playProps('en', 'conversation-cards');
    const spanish = playProps('es', 'conversation-cards');

    expect(spanish.ui.conversationCards.showPrompt).toBe(english.ui.conversationCards.showPrompt);
  });
});
