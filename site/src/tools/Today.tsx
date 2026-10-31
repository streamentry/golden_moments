import { useEffect, useRef, useState } from 'react';
import { SITUATIONS, SITUATION_BY_ID, type SituationId } from '../lib/today/situations';
import { addNote, byDay, loadNotes, localDay, removeNote, saveNotes, type Note, type Outcome } from '../lib/today/notes';

const OUTCOME_LABEL: Record<Outcome, string> = {
  helped: 'That helped',
  not_really: 'Not really',
  not_tried: 'Didn’t try it',
};

const OUTCOME_IN_NOTES: Record<Outcome, string> = {
  helped: 'Helped',
  not_really: 'Did not help',
  not_tried: 'Not tried',
};

function browserStorage(): Storage | undefined {
  try {
    return window.localStorage;
  } catch {
    return undefined;
  }
}

function dayLabel(date: string): string {
  return new Date(`${date}T12:00:00Z`).toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric',
    timeZone: 'UTC',
  });
}

const newId = () => `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;

/** "What is hardest today?": one answer, one tap to note how it went, notes to print. */
export function Today() {
  const [chosen, setChosen] = useState<SituationId | null>(null);
  const [notes, setNotes] = useState<Note[]>([]);
  const [text, setText] = useState('');
  const [status, setStatus] = useState('');
  const [canSave, setCanSave] = useState(true);
  const answerHeading = useRef<HTMLHeadingElement>(null);

  // Read saved notes after hydration so the server HTML and first render match.
  useEffect(() => setNotes(loadNotes(browserStorage())), []);
  useEffect(() => {
    if (chosen) answerHeading.current?.focus();
  }, [chosen]);

  const situation = chosen ? SITUATION_BY_ID.get(chosen) : undefined;

  const commit = (next: Note[], message: string) => {
    const saved = saveNotes(browserStorage(), next);
    setCanSave(saved);
    setNotes(next);
    setStatus(saved ? message : 'This browser is not saving notes, so they will be gone when you close the page. You can still print them now.');
  };

  const record = (outcome: Outcome) => {
    if (!chosen) return;
    commit(addNote(notes, { id: newId(), date: localDay(), situation: chosen, outcome, text }), 'Saved in your notes below.');
    setText('');
  };

  const days = byDay(notes);

  return (
    <div className="today">
      <section className="today__ask no-print" aria-labelledby="today-ask">
        <h2 id="today-ask">Choose one</h2>
        <p>You get three things to try, when to get help, and one gentle activity.</p>
        <ul className="today__choices">
          {SITUATIONS.map((s) => (
            <li key={s.id}>
              <button
                type="button"
                className="btn btn--block today__choice"
                aria-pressed={chosen === s.id}
                onClick={() => {
                  setChosen(s.id);
                  setStatus('');
                }}
              >
                {s.label}
              </button>
            </li>
          ))}
        </ul>
      </section>

      {situation ? (
        <section className="today__answer no-print" aria-labelledby="today-answer">
          <h2 id="today-answer" ref={answerHeading} tabIndex={-1}>
            {situation.label}
          </h2>
          <h3>Try one of these</h3>
          <ol className="today__tries">
            {situation.tries.map((t) => (
              <li key={t}>{t}</li>
            ))}
          </ol>
          <p className="today__help">
            <strong>Get help: </strong>
            {situation.help}
          </p>
          <div className="btn-row">
            <a className="btn btn--primary" href={situation.activity.href}>
              {situation.activity.label}
            </a>
            <a className="btn btn--quiet" href={situation.guide.href}>
              Read more: {situation.guide.label}
            </a>
          </div>

          <h3 id="today-how">Later: how did it go?</h3>
          <label className="today__label" htmlFor="today-text">
            A few words for yourself (optional)
          </label>
          <textarea
            id="today-text"
            className="today__text"
            rows={2}
            maxLength={280}
            value={text}
            onChange={(e) => setText(e.target.value)}
          />
          <div className="btn-row" role="group" aria-labelledby="today-how">
            {(Object.keys(OUTCOME_LABEL) as Outcome[]).map((o) => (
              <button key={o} type="button" className="btn" onClick={() => record(o)}>
                {OUTCOME_LABEL[o]}
              </button>
            ))}
          </div>
        </section>
      ) : null}

      <p className="today__status no-print" role="status" aria-live="polite">
        {status}
      </p>

      <section className="today__notes" aria-labelledby="today-notes">
        <div className="print-only">
          <p className="today__print-title">Notes to bring to an appointment</p>
          <p>Written by a family member. These are personal notes, not a medical record.</p>
        </div>
        <h2 id="today-notes" className="no-print">
          Your notes
        </h2>
        {days.length === 0 ? (
          <p className="no-print">Nothing yet. After you try something, tap how it went and it appears here, by day.</p>
        ) : (
          <>
            {days.map((d) => (
              <div key={d.date} className="today__day">
                <h3>{dayLabel(d.date)}</h3>
                <ul>
                  {d.notes.map((n) => (
                    <li key={n.id}>
                      <span>
                        <strong>{SITUATION_BY_ID.get(n.situation)?.label}.</strong> {OUTCOME_IN_NOTES[n.outcome]}.
                        {n.text ? ` “${n.text}”` : ''}
                      </span>
                      <button
                        type="button"
                        className="btn btn--quiet"
                        onClick={() => commit(removeNote(notes, n.id), 'Note removed.')}
                      >
                        Remove
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
            <div className="btn-row">
              <button type="button" className="btn" onClick={() => window.print()}>
                Print notes for an appointment
              </button>
            </div>
          </>
        )}
        <p className="small-print no-print">
          {canSave
            ? 'Your notes stay in this browser on this device. Nothing is sent to us. Clearing your browser’s site data deletes them.'
            : 'This browser is not saving notes (private browsing or blocked site data). Nothing is sent to us.'}
        </p>
      </section>
    </div>
  );
}
