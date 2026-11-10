import { describe, expect, it } from 'vitest';
import { conversationPromptPresentation } from './conversation-prompt';

describe('conversation prompt presentation', () => {
  const prompt = 'What do you notice in this picture?';
  const guidance = 'Read the card out loud. There are no right answers.';

  it('keeps the question out of sight and speech when prompts are off', () => {
    expect(conversationPromptPresentation(false, prompt, guidance)).toEqual({
      visiblePrompt: null,
      spokenText: guidance,
    });
  });

  it('shows and reads the question when prompts are on', () => {
    expect(conversationPromptPresentation(true, prompt, guidance)).toEqual({
      visiblePrompt: prompt,
      spokenText: prompt,
    });
  });
});
