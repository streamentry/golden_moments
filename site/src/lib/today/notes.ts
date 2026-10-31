import { SITUATION_IDS, type SituationId } from './situations';

/**
 * The one-tap care notes on /today/. They live only in this browser's
 * localStorage: nothing is sent anywhere, and clearing site data removes them.
 */
export type Outcome = 'helped' | 'not_really' | 'not_tried';

export interface Note {
  id: string;
  /** Local calendar day, YYYY-MM-DD. */
  date: string;
  situation: SituationId;
  outcome: Outcome;
  /** Optional words of the caregiver's own, at most MAX_TEXT characters. */
  text: string;
}

export interface Day {
  date: string;
  notes: Note[];
}

export const STORAGE_KEY = 'gm-today-notes-v1';
export const MAX_NOTES = 200;
export const MAX_TEXT = 280;
export const OUTCOMES: readonly Outcome[] = ['helped', 'not_really', 'not_tried'];

type ReadStorage = Pick<Storage, 'getItem'>;
type WriteStorage = Pick<Storage, 'setItem'>;

const DATE = /^\d{4}-\d{2}-\d{2}$/;

function isNote(value: unknown): value is Note {
  if (typeof value !== 'object' || value === null) return false;
  const n = value as Record<string, unknown>;
  return (
    typeof n.id === 'string' &&
    typeof n.date === 'string' &&
    DATE.test(n.date) &&
    typeof n.situation === 'string' &&
    (SITUATION_IDS as readonly string[]).includes(n.situation) &&
    typeof n.outcome === 'string' &&
    (OUTCOMES as readonly string[]).includes(n.outcome) &&
    typeof n.text === 'string'
  );
}

/** Saved notes, keeping only well-formed entries; anything else reads as none. */
export function parseNotes(raw: string | null): Note[] {
  if (!raw) return [];
  try {
    const data: unknown = JSON.parse(raw);
    return Array.isArray(data) ? data.filter(isNote).slice(0, MAX_NOTES) : [];
  } catch {
    return [];
  }
}

/** A new list with `note` first, its text trimmed and the oldest notes dropped past MAX_NOTES. */
export function addNote(notes: readonly Note[], note: Note): Note[] {
  return [{ ...note, text: note.text.trim().slice(0, MAX_TEXT) }, ...notes].slice(0, MAX_NOTES);
}

export function removeNote(notes: readonly Note[], id: string): Note[] {
  return notes.filter((n) => n.id !== id);
}

/** Notes grouped by day, newest day first, keeping the order within each day. */
export function byDay(notes: readonly Note[]): Day[] {
  const days = new Map<string, Note[]>();
  for (const n of notes) days.set(n.date, [...(days.get(n.date) ?? []), n]);
  return [...days.entries()].sort(([a], [b]) => b.localeCompare(a)).map(([date, list]) => ({ date, notes: list }));
}

/** Private windows and blocked site data throw on access; treat both as empty. */
export function loadNotes(storage: ReadStorage | undefined): Note[] {
  try {
    return parseNotes(storage?.getItem(STORAGE_KEY) ?? null);
  } catch {
    return [];
  }
}

/** Whether the notes were saved; false means the browser refused. */
export function saveNotes(storage: WriteStorage | undefined, notes: readonly Note[]): boolean {
  if (!storage) return false;
  try {
    storage.setItem(STORAGE_KEY, JSON.stringify(notes));
    return true;
  } catch {
    return false;
  }
}

/** Today's local date as YYYY-MM-DD. */
export function localDay(now: Date = new Date()): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
}
