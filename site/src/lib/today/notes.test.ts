import { describe, expect, it } from 'vitest';
import { MAX_NOTES, MAX_TEXT, addNote, byDay, loadNotes, parseNotes, removeNote, saveNotes, type Note } from './notes';

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
  };
}

describe('notes', () => {
  it('adds a note at the front without changing the old list', () => {
    const before = [note({ id: 'old' })];
    const after = addNote(before, note({ id: 'new' }));
    expect(after.map((n) => n.id)).toEqual(['new', 'old']);
    expect(before.map((n) => n.id)).toEqual(['old']);
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
    expect(saveNotes(ok, [note()])).toBe(true);
    expect(loadNotes(ok)).toEqual([note()]);
  });
});
