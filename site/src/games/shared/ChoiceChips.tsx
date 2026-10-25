import { useId } from 'react';

export interface Choice<T extends string | number> {
  value: T;
  label: string;
}

interface ChoiceChipsProps<T extends string | number> {
  legend: string;
  choices: readonly Choice<T>[];
  value: T;
  onChange: (value: T) => void;
}

/** A row of equal-width chips. More is a choice, never a level-up. */
export function ChoiceChips<T extends string | number>({ legend, choices, value, onChange }: ChoiceChipsProps<T>) {
  const name = useId();
  return (
    <fieldset className="chips">
      <legend className="chips__legend">{legend}</legend>
      <div className="chips__row">
        {choices.map((c) => (
          <label key={String(c.value)} className="chip">
            <input
              type="radio"
              name={name}
              value={String(c.value)}
              checked={c.value === value}
              onChange={() => onChange(c.value)}
            />
            <span>{c.label}</span>
          </label>
        ))}
      </div>
    </fieldset>
  );
}
