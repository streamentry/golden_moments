export interface WordTheme {
  value: string;
  label: string;
  words: string[];
}

/** Short, familiar words. The generator uses the ones that fit the grid. */
export const WORD_THEMES: readonly WordTheme[] = [
  { value: 'fruit', label: 'Fruit', words: ['APPLE', 'PEAR', 'PLUM', 'LEMON', 'GRAPE', 'PEACH', 'MELON', 'LIME', 'FIG'] },
  { value: 'garden', label: 'Garden', words: ['ROSE', 'TULIP', 'SEED', 'SOIL', 'LEAF', 'TREE', 'DAISY', 'POND', 'BEE'] },
  { value: 'kitchen', label: 'Kitchen', words: ['CUP', 'SPOON', 'BREAD', 'PAN', 'BOWL', 'PLATE', 'TEA', 'OVEN', 'FORK'] },
  { value: 'weather', label: 'Weather', words: ['SUN', 'RAIN', 'SNOW', 'WIND', 'CLOUD', 'STORM', 'FOG', 'MILD', 'WARM'] },
  { value: 'animals', label: 'Animals', words: ['DOG', 'CAT', 'BIRD', 'FISH', 'HORSE', 'COW', 'DUCK', 'GOAT', 'HEN'] },
  { value: 'home', label: 'Home', words: ['DOOR', 'CHAIR', 'LAMP', 'BED', 'RUG', 'SOFA', 'CLOCK', 'DESK', 'KEY'] },
];
