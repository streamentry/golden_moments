import { settingsStore } from './settings';

let ctx: AudioContext | null = null;

function audio(): AudioContext | null {
  if (typeof window === 'undefined' || !('AudioContext' in window)) return null;
  ctx ??= new AudioContext();
  return ctx;
}

function tone(freq: number, start: number, duration: number, volume: number): void {
  const ac = audio();
  if (!ac) return;
  const osc = ac.createOscillator();
  const gain = ac.createGain();
  osc.type = 'sine';
  osc.frequency.value = freq;
  const t = ac.currentTime + start;
  gain.gain.setValueAtTime(0, t);
  gain.gain.linearRampToValueAtTime(volume, t + 0.02);
  gain.gain.exponentialRampToValueAtTime(0.0001, t + duration);
  osc.connect(gain).connect(ac.destination);
  osc.start(t);
  osc.stop(t + duration + 0.05);
}

/** Soft, optional sounds. There is never a failure sound. */
export const sounds = {
  tap(): void {
    if (settingsStore.state.sound) tone(660, 0, 0.12, 0.05);
  },
  match(): void {
    if (!settingsStore.state.sound) return;
    tone(523.25, 0, 0.35, 0.07);
    tone(659.25, 0.12, 0.4, 0.06);
  },
  done(): void {
    if (!settingsStore.state.sound) return;
    tone(523.25, 0, 0.5, 0.06);
    tone(659.25, 0.15, 0.5, 0.05);
    tone(783.99, 0.3, 0.7, 0.05);
  },
};
