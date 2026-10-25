import { createStore, useSelector } from '@tanstack/react-store';

export interface PlaySettings {
  sound: boolean;
}

const KEY = 'gm-play-settings';
const DEFAULTS: PlaySettings = { sound: false };

function load(): PlaySettings {
  try {
    const raw = globalThis.localStorage?.getItem(KEY);
    if (!raw) return DEFAULTS;
    const parsed: unknown = JSON.parse(raw);
    if (parsed && typeof parsed === 'object' && 'sound' in parsed) {
      return { sound: (parsed as { sound: unknown }).sound === true };
    }
  } catch {
    // Private windows and blocked storage fall back to defaults.
  }
  return DEFAULTS;
}

/** Shared, per-viewer play preferences. Stored only in this browser. */
export const settingsStore = createStore<PlaySettings, { toggleSound: () => void }>(DEFAULTS, ({ setState, get }) => ({
  toggleSound: () => {
    setState((prev) => ({ ...prev, sound: !prev.sound }));
    try {
      globalThis.localStorage?.setItem(KEY, JSON.stringify(get()));
    } catch {
      // Not saved; the choice still applies for this visit.
    }
  },
}));

let hydrated = false;
export function hydrateSettings(): void {
  if (hydrated) return;
  hydrated = true;
  const stored = load();
  settingsStore.setState(() => stored);
}

export function useSound(): boolean {
  return useSelector(settingsStore, (s) => s.sound);
}
