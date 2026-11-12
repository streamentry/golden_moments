import { TIME_OF_DAY_LABELS, TIME_OF_DAY_OPTIONS, type TimeOfDay } from '../lib/today/notes';

interface TodayTimePickerProps {
  value: TimeOfDay | '';
  onChange: (value: TimeOfDay | '') => void;
}

/** Optional broad time band for a caregiver's local Today note. */
export function TodayTimePicker({ value, onChange }: TodayTimePickerProps) {
  return (
    <>
      <label className="today__label" htmlFor="today-time">
        When did you try it? (optional)
      </label>
      <select
        id="today-time"
        className="today__time"
        value={value}
        onChange={(event) => onChange(event.currentTarget.value as TimeOfDay | '')}
      >
        <option value="">Not recorded</option>
        {TIME_OF_DAY_OPTIONS.map((timeOfDay) => (
          <option key={timeOfDay} value={timeOfDay}>
            {TIME_OF_DAY_LABELS[timeOfDay]}
          </option>
        ))}
      </select>
    </>
  );
}
