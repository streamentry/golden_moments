/**
 * The answers on /today/ ("What is hardest today?"). Each one condenses an
 * existing, sourced guide on this site; change the guide first, then this.
 * Wording rules: plain adult language, enjoyment and comfort in the moment
 * only, no claims about memory, behavior or the course of dementia.
 */
export const SITUATION_IDS = [
  'go-home',
  'same-question',
  'says-no',
  'late-day',
  'nothing-to-do',
  'hard-to-talk',
  'visit',
  'worn-out',
] as const;

export type SituationId = (typeof SITUATION_IDS)[number];

export interface Situation {
  id: SituationId;
  /** In the caregiver's own words. */
  label: string;
  /** Three things to try now, most useful first. */
  tries: readonly [string, string, string];
  /** When to get help; always shown with the answer. */
  help: string;
  /** One gentle activity on this site. */
  activity: { href: string; label: string };
  /** The full guide this answer comes from. */
  guide: { href: string; label: string };
}

const DOCTOR =
  'Call their doctor the same day if this starts suddenly or gets much worse over hours or days, or comes with a fever, pain or a new medicine. In an emergency, call 911.';

export const SITUATIONS: readonly Situation[] = [
  {
    id: 'go-home',
    label: 'They keep asking to go home',
    tries: [
      'Answer the feeling, not the address: “You’re safe here, and I’m staying with you.”',
      'Say “Tell me about your home,” then share a photo, a song or a cup of tea.',
      'Check the simple things: hungry, thirsty, the toilet, pain, too hot or too cold.',
    ],
    help: DOCTOR,
    activity: { href: '/games/conversation-cards/', label: 'Look at conversation cards together' },
    guide: { href: '/caregiving/asking-to-go-home/', label: 'When they keep asking to go home' },
  },
  {
    id: 'same-question',
    label: 'They ask the same question again and again',
    tries: [
      'Answer briefly and kindly, as if for the first time. Skip “You already asked.”',
      'Listen for the feeling underneath, such as worry about a visit, and answer that.',
      'Put the answer where they can see it: a note, a whiteboard or a clock.',
    ],
    help: DOCTOR,
    activity: { href: '/games/picture-pairs/', label: 'Play picture pairs side by side' },
    guide: { href: '/caregiving/repeated-questions/', label: 'Answering repeated questions' },
  },
  {
    id: 'says-no',
    label: 'They say no to everything',
    tries: [
      'Take the no as an answer. Stop, wait, and try again later or another day.',
      'Make it smaller or simpler, or ask for their help instead: “Could you help me fold these?”',
      'Check for tired, unwell, uncomfortable or rushed, including on your side.',
    ],
    help: DOCTOR,
    activity: { href: '/games/sort-together/', label: 'Try sorting together, as a helping task' },
    guide: { href: '/caregiving/when-they-say-no/', label: 'When they say no to an activity' },
  },
  {
    id: 'late-day',
    label: 'Late afternoons are restless',
    tries: [
      'Turn the lights on before dusk and lower the noise: TV, radio, visitors.',
      'Switch to something calm and familiar: music they love, photos, folding towels.',
      'Move outings, bathing and busy tasks to the morning tomorrow.',
    ],
    help: DOCTOR,
    activity: { href: '/games/calm-breathing/', label: 'Breathe slowly together for a minute' },
    guide: { href: '/caregiving/late-day-restlessness/', label: 'Calm late-afternoon activities' },
  },
  {
    id: 'nothing-to-do',
    label: 'There’s nothing they want to do',
    tries: [
      'Start from their own life: their work, hobbies, faith or favorite music.',
      'Offer two choices, not a list, and do the hard part yourself.',
      'Watching, holding something or sitting close all count. Stopping early is fine.',
    ],
    help: DOCTOR,
    activity: { href: '/games/picture-pairs/', label: 'Play picture pairs side by side' },
    guide: { href: '/activities/ideas/', label: '101 activity ideas' },
  },
  {
    id: 'hard-to-talk',
    label: 'Talking together is hard',
    tries: [
      'Turn off background noise and get eye contact before you start.',
      'Use short sentences and offer a choice of two: “Tea or coffee?”',
      'Wait for the answer. Respond to the feeling behind the words, and share a picture.',
    ],
    help: DOCTOR,
    activity: { href: '/games/finish-the-saying/', label: 'Finish a few familiar sayings together' },
    guide: { href: '/caregiving/communication-tips/', label: 'Communication tips' },
  },
  {
    id: 'visit',
    label: 'A visit or call is coming up',
    tries: [
      'Greet them by name and say who you are: “Hi Mom, it’s Susan, your daughter.”',
      'Bring one or two things to share: a photo album, a favorite song, a soft blanket.',
      'Keep it short, use the same goodbye each time, and leave without lingering.',
    ],
    help: 'If you notice a sudden change during a visit, tell the staff or their doctor the same day. In an emergency, call 911.',
    activity: { href: '/games/photo-pairs/', label: 'Make a pairs game from family photos' },
    guide: { href: '/activities/visiting/', label: 'Visiting someone with dementia' },
  },
  {
    id: 'worn-out',
    label: 'I’m worn out',
    tries: [
      'Ask one person for one specific thing this week: a meal, an afternoon, a phone call.',
      'Call the Alzheimer’s Association 24/7 Helpline, 1-800-272-3900. It is free and confidential.',
      'Ask the Eldercare Locator, 1-800-677-1116, about respite care near you.',
    ],
    help: 'If you feel in crisis, call or text 988. In an emergency, call 911.',
    activity: { href: '/games/calm-breathing/', label: 'Take one slow minute for yourself' },
    guide: { href: '/caregiving/caregiver-self-care/', label: 'Looking after yourself' },
  },
];

export const SITUATION_BY_ID: ReadonlyMap<SituationId, Situation> = new Map(SITUATIONS.map((s) => [s.id, s]));
