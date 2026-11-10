export interface ConversationPromptPresentation {
  /** The card question, or null when the helper chooses to look without it. */
  visiblePrompt: string | null;
  /** Text used by Read aloud; a hidden prompt must not be spoken. */
  spokenText: string;
}

/** Keep the visual card and its spoken version in the same prompt mode. */
export function conversationPromptPresentation(
  showPrompt: boolean,
  prompt: string,
  guidance: string,
): ConversationPromptPresentation {
  return showPrompt
    ? { visiblePrompt: prompt, spokenText: prompt }
    : { visiblePrompt: null, spokenText: guidance };
}
