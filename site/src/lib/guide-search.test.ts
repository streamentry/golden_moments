import { describe, expect, it } from 'vitest';
import { matchesGuideSearch } from './guide-search';

describe('matchesGuideSearch', () => {
  it('shows all guides for an empty query', () => {
    expect(matchesGuideSearch('Calm mealtimes and familiar food', '')).toBe(true);
    expect(matchesGuideSearch('Calm mealtimes and familiar food', '   ')).toBe(true);
  });

  it('matches every word regardless of order and case', () => {
    expect(matchesGuideSearch('Calm mealtimes with dementia', 'DEMENTIA calm')).toBe(true);
    expect(matchesGuideSearch('Calm mealtimes with dementia', 'calm travel')).toBe(false);
  });

  it('matches a common -ing form when the final e is dropped', () => {
    expect(matchesGuideSearch('Driving and dementia', 'drive')).toBe(true);
  });

  it('matches common accented letters without accents', () => {
    expect(matchesGuideSearch('Activities for café visits', 'cafe')).toBe(true);
  });
});
