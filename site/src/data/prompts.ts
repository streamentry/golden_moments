/**
 * Conversation cards. Open invitations only: nothing to get right, no
 * "Do you remember…?" and no "Who is this?".
 */
export interface TalkCard {
  theme: TalkTheme;
  picture: string;
  prompt: string;
}

export type TalkTheme = 'food' | 'home' | 'outdoors' | 'animals' | 'travel' | 'work' | 'music' | 'seasons';

export const TALK_THEMES: readonly { value: TalkTheme | 'all'; label: string }[] = [
  { value: 'all', label: 'All cards' },
  { value: 'food', label: 'Food' },
  { value: 'home', label: 'Home' },
  { value: 'outdoors', label: 'Outdoors' },
  { value: 'animals', label: 'Animals' },
  { value: 'travel', label: 'Going places' },
  { value: 'work', label: 'Work and hobbies' },
  { value: 'music', label: 'Music and fun' },
  { value: 'seasons', label: 'Seasons' },
];

export const TALK_CARDS: readonly TalkCard[] = [
  { theme: 'food', picture: 'bread', prompt: 'What is your favorite smell from a kitchen?' },
  { theme: 'food', picture: 'cake', prompt: 'What kind of cake would you choose for a celebration?' },
  { theme: 'food', picture: 'apple', prompt: 'Tell me about a favorite fruit pie or dessert.' },
  { theme: 'food', picture: 'teacup', prompt: 'How do you like your tea or coffee?' },
  { theme: 'food', picture: 'frying-pan', prompt: 'What makes a really good breakfast?' },
  { theme: 'food', picture: 'strawberry', prompt: 'Have you ever picked fruit straight from the plant?' },
  { theme: 'food', picture: 'lemon', prompt: 'Sweet or sour: which do you like better?' },
  { theme: 'food', picture: 'cherries', prompt: 'What is a food that tastes like summer to you?' },
  { theme: 'home', picture: 'house', prompt: 'Tell me about a house you liked living in.' },
  { theme: 'home', picture: 'armchair', prompt: 'Where is your favorite place to sit and relax?' },
  { theme: 'home', picture: 'lamp', prompt: 'What do you like to do on a quiet evening?' },
  { theme: 'home', picture: 'key', prompt: 'What is a treasure you would keep in a special box?' },
  { theme: 'home', picture: 'kettle', prompt: 'Who would you invite over for a cup of tea?' },
  { theme: 'home', picture: 'umbrella', prompt: 'What do you like to do on a rainy day?' },
  { theme: 'outdoors', picture: 'sunflower', prompt: 'What flowers would you plant in a garden?' },
  { theme: 'outdoors', picture: 'tree', prompt: 'Tell me about a tree or park you like.' },
  { theme: 'outdoors', picture: 'watering-can', prompt: 'What is the best part of being in a garden?' },
  { theme: 'outdoors', picture: 'tulip', prompt: 'What color flowers do you like best?' },
  { theme: 'outdoors', picture: 'potted-plant', prompt: 'Do you like having plants in the house?' },
  { theme: 'outdoors', picture: 'sun', prompt: 'What is your idea of a perfect sunny day?' },
  { theme: 'animals', picture: 'dog', prompt: 'Tell me about a dog you have known.' },
  { theme: 'animals', picture: 'cat', prompt: 'Cats or dogs, or neither? What do you like about them?' },
  { theme: 'animals', picture: 'bird', prompt: 'What birds do you see or hear outside?' },
  { theme: 'animals', picture: 'fish', prompt: 'Have you ever been fishing, or kept a fish tank?' },
  { theme: 'animals', picture: 'butterfly', prompt: 'What is the most beautiful animal you have seen?' },
  { theme: 'travel', picture: 'car', prompt: 'Tell me about a car you liked.' },
  { theme: 'travel', picture: 'sailboat', prompt: 'Would you rather spend a day at the beach or in the mountains?' },
  { theme: 'travel', picture: 'bicycle', prompt: 'Where would you like to go for a ride?' },
  { theme: 'travel', picture: 'balloon', prompt: 'If you could fly over any place, where would it be?' },
  { theme: 'travel', picture: 'lighthouse', prompt: 'What is a trip you enjoyed?' },
  { theme: 'work', picture: 'key', prompt: 'What kind of work have you enjoyed doing?' },
  { theme: 'work', picture: 'watering-can', prompt: 'What is a hobby that you could spend hours on?' },
  { theme: 'work', picture: 'bread', prompt: 'What is something you were known for making or fixing?' },
  { theme: 'work', picture: 'house', prompt: 'What advice would you give a young person starting work?' },
  { theme: 'music', picture: 'balloon', prompt: 'What kind of music makes you want to tap your feet?' },
  { theme: 'music', picture: 'cake', prompt: 'What makes a really good party?' },
  { theme: 'music', picture: 'lamp', prompt: 'Who is a singer you like to listen to?' },
  { theme: 'music', picture: 'armchair', prompt: 'What is a favorite movie or TV show to watch again?' },
  { theme: 'seasons', picture: 'sun', prompt: 'What do you like most about summer?' },
  { theme: 'seasons', picture: 'tree', prompt: 'What do you enjoy about the fall?' },
  { theme: 'seasons', picture: 'moon', prompt: 'What is a cozy thing to do on a winter evening?' },
  { theme: 'seasons', picture: 'tulip', prompt: 'What are the first signs of spring for you?' },
  { theme: 'seasons', picture: 'umbrella', prompt: 'Snow, rain or sunshine: which do you prefer?' },
];
