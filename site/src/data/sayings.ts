/**
 * Traditional sayings and proverbs (public domain). `start` is shown with a
 * blank, `end` is the usual ending, `others` are two friendly alternatives.
 */
export interface Saying {
  start: string;
  end: string;
  others: [string, string];
  prompt: string;
}

export const SAYINGS: readonly Saying[] = [
  { start: 'A penny saved is a penny', end: 'earned', others: ['spent', 'found'], prompt: 'What is something you were glad you saved up for?' },
  { start: 'An apple a day keeps the doctor', end: 'away', others: ['busy', 'happy'], prompt: 'What kind of apples do you like best?' },
  { start: 'The early bird catches the', end: 'worm', others: ['bus', 'train'], prompt: 'Are you a morning person or a night owl?' },
  { start: 'Every cloud has a silver', end: 'lining', others: ['button', 'spoon'], prompt: 'What is a small thing that cheers you up on a gray day?' },
  { start: 'Home is where the heart', end: 'is', others: ['was', 'sings'], prompt: 'What makes a place feel like home to you?' },
  { start: 'Two heads are better than', end: 'one', others: ['none', 'three'], prompt: 'Who do you like to work on a problem with?' },
  { start: 'Actions speak louder than', end: 'words', others: ['music', 'bells'], prompt: 'Who is someone whose kindness you could always count on?' },
  { start: "Don't count your chickens before they", end: 'hatch', others: ['sing', 'sleep'], prompt: 'Have you ever kept chickens, or seen a farm up close?' },
  { start: 'Where there is a will, there is a', end: 'way', others: ['day', 'path'], prompt: 'What is something you worked hard to do?' },
  { start: 'Better late than', end: 'never', others: ['early', 'sorry'], prompt: 'What is something you started later in life and enjoyed?' },
  { start: 'A watched pot never', end: 'boils', others: ['spills', 'cools'], prompt: 'What was a favorite dish cooked in your home?' },
  { start: 'Birds of a feather flock', end: 'together', others: ['south', 'home'], prompt: 'What did you and your closest friends enjoy doing together?' },
  { start: 'Laughter is the best', end: 'medicine', others: ['music', 'present'], prompt: 'Who always makes you laugh?' },
  { start: 'Practice makes', end: 'perfect', others: ['pictures', 'progress'], prompt: 'Is there a skill you practiced a lot, like an instrument or a sport?' },
  { start: 'Rome was not built in a', end: 'day', others: ['week', 'hurry'], prompt: 'What is a place you would love to visit, or loved visiting?' },
  { start: 'The grass is always greener on the other side of the', end: 'fence', others: ['road', 'hill'], prompt: 'What did your yard or garden look like when you were young?' },
  { start: 'You can lead a horse to water, but you cannot make it', end: 'drink', others: ['dance', 'swim'], prompt: 'Have you ever ridden a horse, or would you like to?' },
  { start: 'Look before you', end: 'leap', others: ['sleep', 'speak'], prompt: 'What is the most adventurous thing you have done?' },
  { start: 'Many hands make light', end: 'work', others: ['lunch', 'music'], prompt: 'What jobs did your family do together around the house?' },
  { start: 'A picture is worth a thousand', end: 'words', others: ['dollars', 'smiles'], prompt: 'What is a picture or painting you love to look at?' },
  { start: 'Beauty is in the eye of the', end: 'beholder', others: ['storm', 'painter'], prompt: 'What do you think is the most beautiful season?' },
  { start: 'Great minds think', end: 'alike', others: ['aloud', 'twice'], prompt: 'Who is someone you often agree with?' },
  { start: 'Easy come, easy', end: 'go', others: ['does it', 'now'], prompt: 'What is something small you once won or found?' },
  { start: 'Out of sight, out of', end: 'mind', others: ['town', 'time'], prompt: 'What is a favorite place to keep things safe at home?' },
  { start: 'When it rains, it', end: 'pours', others: ['shines', 'stops'], prompt: 'Do you like the sound of rain?' },
  { start: 'The best things in life are', end: 'free', others: ['sweet', 'small'], prompt: 'What is one of the best free things in life, for you?' },
  { start: 'All good things must come to an', end: 'end', others: ['hour', 'inn'], prompt: 'What is a happy day you like to think about?' },
  { start: 'Absence makes the heart grow', end: 'fonder', others: ['younger', 'warmer'], prompt: 'Who is someone you love to hear from?' },
  { start: 'Slow and steady wins the', end: 'race', others: ['prize', 'day'], prompt: 'What is something you enjoy doing slowly?' },
  { start: 'Strike while the iron is', end: 'hot', others: ['ready', 'here'], prompt: 'Did you ever iron clothes, or learn a trade with tools?' },
  { start: 'There is no place like', end: 'home', others: ['here', 'Rome'], prompt: 'What is your favorite room in a house, and why?' },
  { start: 'Too many cooks spoil the', end: 'broth', others: ['bread', 'party'], prompt: 'Who was the best cook you have known?' },
  { start: 'Variety is the spice of', end: 'life', others: ['soup', 'Sunday'], prompt: 'What is your favorite spice or flavor?' },
  { start: 'Old habits die', end: 'hard', others: ['young', 'quietly'], prompt: 'What is a favorite part of your daily routine?' },
  { start: 'Kill two birds with one', end: 'stone', others: ['trip', 'call'], prompt: 'What errands do you like to do together?' },
  { start: 'Curiosity killed the', end: 'cat', others: ['clock', 'radio'], prompt: 'Have you had a pet cat or dog? What was it like?' },
  { start: 'If the shoe fits, wear', end: 'it', others: ['two', 'blue'], prompt: 'What is the most comfortable pair of shoes you have owned?' },
  { start: 'It takes two to', end: 'tango', others: ['talk', 'travel'], prompt: 'Do you like to dance? What kind of music?' },
  { start: 'Money does not grow on', end: 'trees', others: ['Tuesdays', 'farms'], prompt: 'What was your first job?' },
  { start: 'One good turn deserves', end: 'another', others: ['a cake', 'a song'], prompt: 'What is a kind thing someone did for you?' },
  { start: 'Patience is a', end: 'virtue', others: ['garden', 'river'], prompt: 'What helps you feel calm and patient?' },
  { start: 'The squeaky wheel gets the', end: 'grease', others: ['oil change', 'ride'], prompt: 'Have you ever fixed something with your own hands?' },
  { start: 'Time flies when you are having', end: 'fun', others: ['tea', 'lunch'], prompt: 'What is an activity that makes time fly for you?' },
  { start: 'You are never too old to', end: 'learn', others: ['laugh', 'dance'], prompt: 'What would you like to learn about, or teach someone?' },
  { start: 'A friend in need is a friend', end: 'indeed', others: ['in town', 'at noon'], prompt: 'What makes someone a good friend?' },
  { start: 'Honesty is the best', end: 'policy', others: ['present', 'medicine'], prompt: 'What is a good piece of advice you were given?' },
  { start: 'Make hay while the sun', end: 'shines', others: ['sets', 'rises'], prompt: 'What is your favorite thing to do on a sunny day?' },
  { start: 'Necessity is the mother of', end: 'invention', others: ['patience', 'gardens'], prompt: 'What is a clever invention you are glad we have?' },
  { start: 'Still waters run', end: 'deep', others: ['fast', 'cold'], prompt: 'Do you like being near a lake, a river or the ocean?' },
  { start: 'The apple does not fall far from the', end: 'tree', others: ['table', 'basket'], prompt: 'Who in your family are you most alike?' },
];
