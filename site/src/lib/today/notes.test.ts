import { describe, expect, it } from 'vitest';
import { MAX_NOTES, MAX_TEXT, STORAGE_KEY, addNote, byDay, clearNotes, loadNotes, parseNotes, removeNote, removeNoteAriaLabel, saveNotes, toggleSituation, type Note } from './notes';

const note = (over: Partial<Note> = {}): Note => ({
  id: 'a',
  date: '2026-11-01',
  situation: 'go-home',
  outcome: 'helped',
  text: '',
  ...over,
});

function memoryStorage(initial: Record<string, string> = {}) {
  const data = { ...initial };
  return {
    data,
    getItem: (k: string) => (k in data ? data[k] : null),
    setItem: (k: string, v: string) => void (data[k] = v),
    removeItem: (k: string) => void delete data[k],
  };
}

describe('notes', () => {
  it('adds a note at the front without changing the old list', () => {
    const before = [note({ id: 'old' })];
    const after = addNote(before, note({ id: 'new' }));
    expect(after.map((n) => n.id)).toEqual(['new', 'old']);
    expect(before.map((n) => n.id)).toEqual(['old']);
  });

  it('does not attach a time band to an activity that was not tried', () => {
    const saved = addNote([], note({ outcome: 'not_tried', timeOfDay: 'morning' }));
    expect(saved[0]).toEqual(note({ outcome: 'not_tried' }));
  });

  it('keeps at most MAX_NOTES and trims long text', () => {
    let list: Note[] = [];
    for (let i = 0; i < MAX_NOTES + 5; i++) list = addNote(list, note({ id: String(i) }));
    expect(list).toHaveLength(MAX_NOTES);
    expect(list[0].id).toBe(String(MAX_NOTES + 4));
    expect(addNote([], note({ text: 'x'.repeat(MAX_TEXT + 50) }))[0].text).toHaveLength(MAX_TEXT);
  });

  it('removes one note by id', () => {
    expect(removeNote([note({ id: 'a' }), note({ id: 'b' })], 'a').map((n) => n.id)).toEqual(['b']);
  });

  it('drops anything malformed when reading saved data', () => {
    expect(parseNotes(null)).toEqual([]);
    expect(parseNotes('not json')).toEqual([]);
    expect(parseNotes('{"a":1}')).toEqual([]);
    const raw = JSON.stringify([
      note(),
      { ...note(), outcome: 'great' },
      { ...note(), situation: 'unknown' },
      { ...note(), date: 'yesterday' },
      { ...note(), text: 5 },
    ]);
    expect(parseNotes(raw)).toEqual([note()]);
  });

  it('keeps legacy notes and normalizes an optional time-of-day field', () => {
    const oldNote = note({ id: 'old' });
    const timedNote = note({ id: 'timed', timeOfDay: 'morning' });
    const unknownTime = { ...note({ id: 'unknown' }), futureFlag: true, timeOfDay: 'night' };

    expect(parseNotes(JSON.stringify([oldNote, timedNote, unknownTime]))).toEqual([
      oldNote,
      timedNote,
      { ...note({ id: 'unknown' }), futureFlag: true },
    ]);
  });

  it('groups notes by day, newest day first', () => {
    const days = byDay([note({ id: '1', date: '2026-10-30' }), note({ id: '2', date: '2026-11-01' }), note({ id: '3', date: '2026-10-30' })]);
    expect(days.map((d) => [d.date, d.notes.map((n) => n.id)])).toEqual([
      ['2026-11-01', ['2']],
      ['2026-10-30', ['1', '3']],
    ]);
  });

  it('survives storage that is missing or throws', () => {
    const broken = {
      getItem: () => {
        throw new Error('blocked');
      },
      setItem: () => {
        throw new Error('full');
      },
    };
    expect(loadNotes(broken)).toEqual([]);
    expect(saveNotes(broken, [note()])).toBe(false);
    expect(loadNotes(undefined)).toEqual([]);
    const ok = memoryStorage();
    const timedNote = note({ timeOfDay: 'afternoon' });
    expect(saveNotes(ok, [timedNote])).toBe(true);
    expect(loadNotes(ok)).toEqual([timedNote]);
  });

  it('clears only Today notes and reports when storage blocks deletion', () => {
    const storage = memoryStorage({ [STORAGE_KEY]: JSON.stringify([note()]), otherPreference: 'large' });

    expect(clearNotes(storage)).toBe(true);
    expect(storage.data).toEqual({ otherPreference: 'large' });
    expect(loadNotes(storage)).toEqual([]);
    expect(clearNotes(undefined)).toBe(false);
    expect(clearNotes({ removeItem: () => { throw new Error('blocked'); } })).toBe(false);
  });

  it('formats an accessible remove button label', () => {
    expect(removeNoteAriaLabel('Asking to go home')).toBe('Remove note for Asking to go home');
    expect(removeNoteAriaLabel(undefined)).toBe('Remove note');
    expect(removeNoteAriaLabel('')).toBe('Remove note');
  });

  it('toggles situation selection', () => {
    expect(toggleSituation(null, 'go-home')).toBe('go-home');
    expect(toggleSituation('go-home', 'go-home')).toBe(null);
    expect(toggleSituation('go-home', 'visit')).toBe('visit');
  });
});
