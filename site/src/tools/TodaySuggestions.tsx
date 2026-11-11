import { renderWithPhoneLinks } from '../lib/today/text';

interface TodaySuggestionsProps {
  suggestions: readonly string[];
}

/** Show the most useful first step; keep other options available on request. */
export function TodaySuggestions({ suggestions }: TodaySuggestionsProps) {
  const [first, ...more] = suggestions;
  if (!first) return null;

  return (
    <div className="today__suggestions">
      <h3>Try this first</h3>
      <p>{renderWithPhoneLinks(first)}</p>
      {more.length > 0 ? (
        <details className="today__more-ideas">
          <summary className="btn btn--quiet">See two more ideas</summary>
          <ul className="today__tries">
            {more.map((suggestion, index) => (
              <li key={`${index}-${suggestion}`}>{renderWithPhoneLinks(suggestion)}</li>
            ))}
          </ul>
        </details>
      ) : null}
    </div>
  );
}
