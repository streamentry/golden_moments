function normalizeSearchText(value: string): string {
  return value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
}

function matchesTerm(text: string, term: string): boolean {
  if (text.includes(term)) return true;
  return term.length > 3 && term.endsWith('e') && text.includes(`${term.slice(0, -1)}ing`);
}

/** Match every query word against a guide's indexed title and summary text. */
export function matchesGuideSearch(indexedText: string, query: string): boolean {
  const terms = normalizeSearchText(query).trim().split(/\s+/).filter(Boolean);
  if (terms.length === 0) return true;

  const text = normalizeSearchText(indexedText);
  return terms.every((term) => matchesTerm(text, term));
}
