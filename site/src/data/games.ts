import type { FaqItem } from '../lib/schema';

export type GameSlug =
  | 'picture-pairs'
  | 'find-the-same'
  | 'sort-together'
  | 'picture-puzzle'
  | 'finish-the-saying'
  | 'word-search'
  | 'coloring'
  | 'conversation-cards'
  | 'photo-pairs'
  | 'picture-bingo'
  | 'calm-breathing';

export type Stage = 'early' | 'middle' | 'late';

export interface GameInfo {
  slug: GameSlug;
  name: string;
  /** <title> without the brand suffix, <= 60 chars with suffix. */
  seoTitle: string;
  h1: string;
  description: string;
  /** One line for cards. */
  short: string;
  /** Two or three pictures shown on the card. */
  cardPictures: string[];
  stages: Stage[];
  players: string;
  printable: boolean;
  intro: string;
  howTo: string[];
  tips: string[];
  faq: FaqItem[];
  relatedGuides: string[];
  featured: boolean;
}

export const STAGE_LABEL: Record<Stage, string> = {
  early: 'Early stage',
  middle: 'Middle stage',
  late: 'Later stage',
};

/**
 * A suitability hint, never a promise: "Often suits early and middle stages".
 * People differ more than stages do.
 */
export function stageHint(stages: readonly Stage[]): string {
  const words = stages.map((s) => ({ early: 'early', middle: 'middle', late: 'later' })[s]);
  const list = words.length > 1 ? `${words.slice(0, -1).join(', ')} and ${words[words.length - 1]}` : words[0];
  return `Often suits ${list} stage${words.length > 1 ? 's' : ''}`;
}

const NO_PRESSURE_FAQ: FaqItem = {
  q: 'Is there a timer or a score?',
  a: 'No. There is no clock, score, move counter or losing. You can stop at any moment, and stopping halfway is a perfectly good way to finish.',
};

const FREE_FAQ: FaqItem = {
  q: 'Is it free, and do I need to sign up?',
  a: 'Yes, it is free, and there is no account, sign-up or download. It works in the web browser on a phone, tablet or computer.',
};

export const GAMES: readonly GameInfo[] = [
  {
    slug: 'picture-pairs',
    name: 'Picture pairs',
    seoTitle: 'Matching Game for Dementia: Picture Pairs',
    h1: 'Picture Pairs: a Gentle Matching Game',
    description:
      'A free, gentle matching game for people living with dementia. Large pictures stay visible, there is no timer or score, and you choose 4 to 12 tiles.',
    short: 'Find the two pictures that are the same. Pictures can stay showing.',
    cardPictures: ['teacup', 'sunflower', 'teacup'],
    stages: ['early', 'middle', 'late'],
    players: '1 or 2 people, side by side',
    printable: false,
    intro:
      'Tap a picture, then tap the one that matches it. Pictures stay showing by default, so nothing has to be remembered. When two pictures go together they get a gold border and a check mark.',
    howTo: [
      'Choose how many tiles to use. Four tiles is a calm place to start.',
      'Tap any picture. It gets a gold border.',
      'Tap the picture that looks the same. The pair stays together with a check mark.',
      'If the two pictures are different, nothing bad happens. Tap again whenever you are ready.',
      'Turn on "Hidden pictures" only if you both enjoy the classic face-down version.',
    ],
    tips: [
      'Name the pictures out loud together and chat about them: "A red teacup. Do you take milk in your tea?"',
      'Let the person you care for do the tapping, even if it takes a while. Point rather than tap for them.',
      'Stay with four tiles for as long as it feels good. More tiles are a choice, never a level to reach.',
      'Finish while it is still enjoyable. One game is a complete activity.',
    ],
    faq: [
      NO_PRESSURE_FAQ,
      {
        q: 'Why do the pictures stay face up?',
        a: 'Keeping pictures visible turns the game into looking and matching rather than remembering. Many people find this calmer. You can switch to hidden pictures in one tap if you prefer.',
      },
      FREE_FAQ,
      {
        q: 'Can we use our own family photos?',
        a: 'Yes. Try Photo pairs, which lets you choose photos from your device. The photos stay in your browser and are not uploaded.',
      },
    ],
    relatedGuides: ['caregiving/how-to-play-together', 'activities/middle-stage'],
    featured: true,
  },
  {
    slug: 'find-the-same',
    name: 'Find the same',
    seoTitle: 'Find the Same Picture: Simple Dementia Game',
    h1: 'Find the Same Picture',
    description:
      'One picture at the top, two to four below. Tap the one that is the same. A calm, free picture game for people living with dementia, with no timer.',
    short: 'Look at the picture at the top and tap the same one below.',
    cardPictures: ['apple', 'pear', 'apple'],
    stages: ['middle', 'late'],
    players: '1 or 2 people',
    printable: false,
    intro:
      'A single picture sits at the top of the screen. Below it are two, three or four pictures. Tap the one that is the same. It is one simple choice at a time, with plenty of room to talk.',
    howTo: [
      'Choose two, three or four pictures to pick from. Two is the simplest.',
      'Look at the picture at the top together.',
      'Tap the same picture below. It is marked with a check and a few warm words.',
      'If a different picture is tapped, the game simply names it and waits. Take your time.',
      'Tap "Next picture" when you are ready for another.',
    ],
    tips: [
      'Talk about each picture before choosing: colors, shapes, where you might see it.',
      'Two choices are not "too easy". The goal is a pleasant moment, not a challenge.',
      'If tapping is hard, the person can point and you can tap for them.',
    ],
    faq: [
      NO_PRESSURE_FAQ,
      {
        q: 'What happens if the wrong picture is tapped?',
        a: 'Nothing unpleasant. There is no buzzer, red cross or shaking. The game names the picture that was tapped and waits for the next tap.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['activities/late-stage', 'caregiving/communication-tips'],
    featured: true,
  },
  {
    slug: 'sort-together',
    name: 'Sort together',
    seoTitle: 'Sorting Game for Dementia: Sort Together',
    h1: 'Sort Together: a Picture Sorting Activity',
    description:
      'Tap a picture, then tap the basket it belongs in: kitchen or garden, fruit or animals. A calm, free sorting activity for people living with dementia.',
    short: 'Put each picture in its basket: kitchen or garden, and more.',
    cardPictures: ['kettle', 'watering-can', 'bread'],
    stages: ['early', 'middle'],
    players: '1 or 2 people',
    printable: false,
    intro:
      'Sorting is a familiar, satisfying everyday task, like putting away groceries or pairing socks. Tap a picture, then tap the basket where it belongs. There is no rush and no wrong turn.',
    howTo: [
      'Pick a theme: kitchen and garden, fruit and animals, or home and travel.',
      'Tap a picture. It gets a gold border.',
      'Tap the basket it belongs in. The picture moves into that basket.',
      'If it belongs in the other basket, the game says so gently and waits.',
      'When every picture is sorted, look through the baskets together.',
    ],
    tips: [
      'There are often no wrong answers in real life. If someone says a watering can belongs in the kitchen, ask why. You may get a good story.',
      'Use the pictures as a prompt: "What did you grow in your garden?"',
      'Sorting real objects, like spoons and forks or buttons by color, is a great follow-up away from the screen.',
    ],
    faq: [
      NO_PRESSURE_FAQ,
      {
        q: 'Why sorting?',
        a: 'Many people enjoy sorting because it feels like useful, familiar work. It is also easy to talk about the pictures as you go.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['activities/household-tasks', 'activities/early-stage'],
    featured: false,
  },
  {
    slug: 'picture-puzzle',
    name: 'Picture puzzle',
    seoTitle: 'Easy Jigsaw Puzzle for Dementia: 4 or 9 Pieces',
    h1: 'Picture Puzzle: an Easy Jigsaw',
    description:
      'An easy online jigsaw for people living with dementia: 4 or 9 large pieces, the whole picture stays visible, and you tap two pieces to swap them.',
    short: 'Tap two pieces to swap them until the picture is whole.',
    cardPictures: ['sailboat', 'house', 'balloon'],
    stages: ['early', 'middle'],
    players: '1 or 2 people',
    printable: false,
    intro:
      'A friendly picture is cut into four or nine large pieces and mixed up. The whole picture stays visible as a guide. Tap one piece, then another, and they swap places. No dragging is needed.',
    howTo: [
      'Choose a picture and 4 or 9 pieces. Four is a gentle start.',
      'Look at the whole picture at the top.',
      'Tap a piece, then tap the place where it should go. The two pieces swap.',
      'Pieces in the right place get a small check mark.',
      'When the picture is whole, enjoy it together, then choose another.',
    ],
    tips: [
      'Tapping two pieces to swap them is much easier than dragging for many people.',
      'Talk about the picture as it comes together: "There is the red roof."',
      'A real wooden jigsaw with 12 to 24 large pieces is a lovely table activity too.',
    ],
    faq: [
      NO_PRESSURE_FAQ,
      {
        q: 'Do I need to drag the pieces?',
        a: 'No. Tap one piece, then tap another, and they swap places. This is easier with a shaky hand or on a small screen.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['activities/early-stage', 'caregiving/tablets-and-screens'],
    featured: true,
  },
  {
    slug: 'finish-the-saying',
    name: 'Finish the saying',
    seoTitle: 'Finish the Saying: Proverbs Game for Seniors',
    h1: 'Finish the Saying',
    description:
      'Familiar American sayings with the last word missing, like "A penny saved is a penny ___". Tap a choice or show the ending, then talk about it.',
    short: 'Complete familiar sayings together, then talk about them.',
    cardPictures: ['key', 'umbrella', 'lamp'],
    stages: ['early', 'middle'],
    players: '1, 2 or a group',
    printable: false,
    intro:
      'Old sayings are often well known for a lifetime. Each card shows a familiar saying with the last word missing, three choices, and a "Show the ending" button. After the ending, a gentle question invites conversation.',
    howTo: [
      'Read the saying out loud together.',
      'Tap the word that finishes it, or tap "Show the ending".',
      'Read the whole saying again and talk about it using the prompt.',
      'Tap "Next saying" when you are ready.',
    ],
    tips: [
      'Read slowly and leave a pause before the last word. Often people say it before you finish.',
      'If someone gives a different ending, enjoy it. Some versions of sayings vary by family or region.',
      'In a group, one person reads and everyone joins in on the ending.',
    ],
    faq: [
      NO_PRESSURE_FAQ,
      {
        q: 'What if we choose a different word?',
        a: 'The game shows the usual ending and moves on to conversation. There is no score, and a different answer is fine.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['activities/care-home-groups', 'activities/reminiscence'],
    featured: true,
  },
  {
    slug: 'word-search',
    name: 'Large-print word search',
    seoTitle: 'Large Print Word Search for Dementia, Printable',
    h1: 'Large-Print Word Search',
    description:
      'A free large-print word search for seniors and people living with dementia. Few words, big letters, words across and down only. Play online or print.',
    short: 'Big letters, a few words, across and down only. Print it too.',
    cardPictures: ['strawberry', 'cherries', 'lemon'],
    stages: ['early'],
    players: '1 or 2 people',
    printable: true,
    intro:
      'A small grid with large letters and just a handful of words, all reading across or down. Tap the first letter of a word, then its last letter. Prefer paper? Print a fresh puzzle in one tap.',
    howTo: [
      'Choose a theme and a grid size.',
      'Look at the word list. Words read across (left to right) or down (top to bottom).',
      'Tap the first letter of a word, then tap its last letter.',
      'A found word is highlighted and crossed off the list.',
      'Tap "Print this puzzle" to play on paper with a pencil or marker.',
    ],
    tips: [
      'Point to a word in the list and look for its first letter together.',
      'On paper, a highlighter is easier to hold than a pencil.',
      'Talk about the theme words. Fruit words are a natural way into memories of picking, baking or markets.',
    ],
    faq: [
      NO_PRESSURE_FAQ,
      {
        q: 'Can I print the word search?',
        a: 'Yes. Tap "Print this puzzle" to print the current grid in large type, with the word list underneath. Every new puzzle is different.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['activities/printable', 'activities/early-stage'],
    featured: false,
  },
  {
    slug: 'coloring',
    name: 'Coloring pages',
    seoTitle: 'Coloring Pages for Adults with Dementia (Free)',
    h1: 'Coloring Pages',
    description:
      'Simple, adult coloring pages with big areas: tap a color, then tap the picture. No mess, no wrong colors, and every page can be printed for free.',
    short: 'Tap a color, then a part of the picture. Print pages too.',
    cardPictures: ['tulip', 'butterfly', 'house'],
    stages: ['early', 'middle', 'late'],
    players: '1 or 2 people',
    printable: true,
    intro:
      'Pages with large, simple shapes: a flower in a pot, a house, a teacup, a butterfly and a sailboat. Tap a color, then tap a part of the picture to fill it. There are no wrong colors.',
    howTo: [
      'Choose a page.',
      'Tap a color. Each color has its name written on it.',
      'Tap a part of the picture to fill it with that color.',
      'Change your mind any time by filling it again.',
      'Tap "Print this page" for a blank page to color with pencils or markers.',
    ],
    tips: [
      'Offer two colors to choose from rather than the whole set if choosing feels like too much.',
      'Purple trees and blue suns are welcome. This is about enjoying color, not accuracy.',
      'Printed pages work well with thick markers or crayons, which are easier to grip.',
    ],
    faq: [
      NO_PRESSURE_FAQ,
      {
        q: 'Are these pages too childish?',
        a: 'We drew calm, simple objects rather than cartoons, so the pages suit adults. Large shapes keep coloring easy without making it babyish.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['activities/arts-and-crafts', 'activities/printable'],
    featured: true,
  },
  {
    slug: 'conversation-cards',
    name: 'Conversation cards',
    seoTitle: 'Conversation Starters for Dementia: Picture Cards',
    h1: 'Conversation Cards',
    description:
      'Picture cards with gentle conversation starters for people living with dementia: no quizzing, no right answers. Use on screen or print the full set.',
    short: 'Picture cards with open, gentle questions. No quizzing.',
    cardPictures: ['dog', 'bread', 'car'],
    stages: ['early', 'middle', 'late'],
    players: '2 people or a group',
    printable: true,
    intro:
      'Each card pairs a familiar picture with an open invitation to talk, like "What is your favorite kind of weather?" There are no right answers and nothing to remember. Choose a theme or shuffle them all.',
    howTo: [
      'Choose a theme, or keep "All cards".',
      'Read the question out loud and look at the picture together.',
      'Listen, share your own answer, and let the talk wander.',
      'Tap "Next card" when you are ready, or stay with one card as long as you like.',
      'Tap "Print all cards" to cut out a paper set.',
    ],
    tips: [
      'Answer the question yourself too. It feels like a conversation, not an interview.',
      'Follow the story, not the facts. If details change, that is fine.',
      'If a card touches something sad, acknowledge the feeling and gently move to another card.',
    ],
    faq: [
      {
        q: 'Why are there no "Do you remember…?" questions?',
        a: 'Questions that test memory can feel like an exam and cause embarrassment. Open invitations such as "Tell me about…" let anyone join in, whatever they recall.',
      },
      {
        q: 'Can I print the cards?',
        a: 'Yes. "Print all cards" prints the full set in large type, several cards per page, ready to cut out.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['activities/reminiscence', 'caregiving/communication-tips'],
    featured: true,
  },
  {
    slug: 'photo-pairs',
    name: 'Photo pairs',
    seoTitle: 'Make a Matching Game from Family Photos',
    h1: 'Photo Pairs: Match Your Own Photos',
    description:
      'Turn your own family photos into a gentle matching game. Choose 2 to 6 photos on your device; they stay in your browser and are never uploaded.',
    short: 'Choose your own photos and match them. Nothing is uploaded.',
    cardPictures: ['house', 'dog', 'car'],
    stages: ['early', 'middle', 'late'],
    players: '2 people, side by side',
    printable: false,
    intro:
      'Choose two to six photos from your phone, tablet or computer, and they become a matching game with large, visible pictures. The photos are shown only inside this page. They are not uploaded, saved or shared, and they disappear when you close the page.',
    howTo: [
      'Tap "Choose photos" and pick two to six photos.',
      'Each photo appears twice. Tap one, then tap its pair.',
      'Talk about each photo as you find it.',
      'When you are done, close the page or tap "Clear photos". Nothing is kept.',
    ],
    tips: [
      'Choose clear photos of happy, familiar things: a pet, a garden, a favorite place, a wedding day.',
      'Pictures of places and objects can be easier than faces, and they avoid any pressure to name people.',
      'Leave out photos of people who have died if they might bring sudden grief, unless you know they bring comfort.',
    ],
    faq: [
      {
        q: 'Are my photos uploaded anywhere?',
        a: 'No. The page reads the photos you choose directly in your browser and shows them on your screen. They are not sent to us or to anyone else, and they are gone when you close or reload the page.',
      },
      NO_PRESSURE_FAQ,
      {
        q: 'Can I save the game for next time?',
        a: 'Not in the browser, by design, so nothing private is stored. The free Golden Moments app for iPhone and iPad can keep selected photo copies on your device.',
      },
    ],
    relatedGuides: ['activities/reminiscence', 'activities/phone-and-video-calls'],
    featured: true,
  },
  {
    slug: 'picture-bingo',
    name: 'Picture bingo',
    seoTitle: 'Picture Bingo for Seniors with Dementia: Printable',
    h1: 'Picture Bingo for Groups',
    description:
      'Free printable picture bingo for memory care and senior groups, with a large on-screen caller. Big pictures with words, 9 or 16 squares, no reading needed.',
    short: 'Printable picture bingo cards and a big-screen caller for groups.',
    cardPictures: ['sun', 'fish', 'cake'],
    stages: ['early', 'middle'],
    players: 'A group of 2 to 30',
    printable: true,
    intro:
      'Classic bingo with pictures instead of numbers, so no one needs to read small print. Print a set of unique cards, then use the on-screen caller to show each picture large on a TV, laptop or tablet.',
    howTo: [
      'Choose 9 or 16 squares per card and how many players.',
      'Tap "Print cards". Each card is different.',
      'Open the caller on a large screen. Tap "Next picture" to show each picture with its name.',
      'Players cover the matching picture on their card with a coin, button or marker.',
      'Everyone who fills a row, or the whole card, gets a cheer. There are no losers in this version: keep playing until everyone has a line.',
    ],
    tips: [
      'Use large tokens such as checkers or bottle caps. Small buttons can be hard to pick up.',
      'Name the picture and say something about it: "A sailboat. Who has been out on a boat?"',
      'Sit people with difficulty seeing closest to the screen, and pair helpers with players who need them.',
      'Nine squares is plenty for most groups. Keep the session around 20 to 30 minutes.',
    ],
    faq: [
      {
        q: 'How do I run picture bingo in a care home?',
        a: 'Print one card per player, put the caller on the biggest screen you have, and call pictures slowly, naming each one. Play until everyone has a line, so no one is left out.',
      },
      {
        q: 'Is it free to print?',
        a: 'Yes. Print as many cards as you need, as often as you like, for personal or group use.',
      },
      {
        q: 'Can people play without reading?',
        a: 'Yes. Every square is a large picture, with its name underneath for those who like words.',
      },
    ],
    relatedGuides: ['activities/care-home-groups', 'activities/printable'],
    featured: true,
  },
  {
    slug: 'calm-breathing',
    name: 'Calm breathing',
    seoTitle: 'A Calm Breathing Pause for Seniors and Caregivers',
    h1: 'A Calm Breathing Pause',
    description:
      'A slow, quiet breathing pause to share: a gentle circle grows and shrinks for six breaths. You start it, and you can stop any time.',
    short: 'A slow circle to breathe along with. Start and stop when you like.',
    cardPictures: ['moon', 'sun', 'potted-plant'],
    stages: ['early', 'middle', 'late'],
    players: '1 or 2 people',
    printable: false,
    intro:
      'Sometimes the best activity is a quiet pause. Tap "Start", then breathe in as the circle grows and out as it shrinks. Choose a slower or faster pace. It is not a treatment, just a peaceful moment to share.',
    howTo: [
      'Sit comfortably side by side.',
      'Choose a pace: slow or gentle.',
      'Tap "Start". Breathe in while the circle grows, and out while it shrinks.',
      'It stops by itself after six breaths, or tap "Stop" whenever you like.',
    ],
    tips: [
      'Hold hands or rest a hand on the person\'s arm if that is welcome.',
      'Never insist. If they would rather watch, that is fine.',
      'If someone has breathing problems, breathe normally and simply watch the circle. Ask a doctor about any breathing concerns.',
    ],
    faq: [
      {
        q: 'Is this a medical breathing exercise?',
        a: 'No. It is a simple, optional pause for calm and company. It is not a treatment for anxiety or any condition. Talk with a doctor about health concerns.',
      },
      {
        q: 'Does the circle move without me starting it?',
        a: 'No. Nothing moves until you tap Start, and it stops after six breaths or when you tap Stop. If your device is set to reduce motion, the words change without the circle growing.',
      },
      FREE_FAQ,
    ],
    relatedGuides: ['caregiving/late-day-restlessness', 'caregiving/caregiver-self-care'],
    featured: false,
  },
];

export const GAME_BY_SLUG: ReadonlyMap<GameSlug, GameInfo> = new Map(GAMES.map((g) => [g.slug, g]));
