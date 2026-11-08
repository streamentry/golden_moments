import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';
import { sounds } from './sound';
import { settingsStore } from './settings';

describe('sounds multisensory feedback module', () => {
  beforeEach(() => {
    settingsStore.setState(() => ({ sound: false }));
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it('safely handles tap, match, and done when sound is disabled', () => {
    expect(() => sounds.tap()).not.toThrow();
    expect(() => sounds.match()).not.toThrow();
    expect(() => sounds.done()).not.toThrow();
  });

  it('handles tone synthesis when sound is enabled with mocked window AudioContext', () => {
    settingsStore.setState(() => ({ sound: true }));

    const mockStart = vi.fn();
    const mockStop = vi.fn();
    const mockConnect = vi.fn().mockReturnThis();
    const mockSetValueAtTime = vi.fn();
    const mockLinearRamp = vi.fn();
    const mockExponentialRamp = vi.fn();

    const mockOscillator = {
      type: 'sine',
      frequency: { value: 0 },
      connect: mockConnect,
      start: mockStart,
      stop: mockStop,
    };

    const mockGain = {
      gain: {
        setValueAtTime: mockSetValueAtTime,
        linearRampToValueAtTime: mockLinearRamp,
        exponentialRampToValueAtTime: mockExponentialRamp,
      },
      connect: mockConnect,
    };

    class MockAudioContext {
      currentTime = 10;
      destination = {};
      createOscillator = vi.fn(() => mockOscillator);
      createGain = vi.fn(() => mockGain);
    }

    vi.stubGlobal('AudioContext', MockAudioContext);
    vi.stubGlobal('window', {
      AudioContext: MockAudioContext,
    });

    expect(() => sounds.tap()).not.toThrow();
    expect(mockStart).toHaveBeenCalled();
    expect(mockStop).toHaveBeenCalled();

    expect(() => sounds.match()).not.toThrow();
    expect(() => sounds.done()).not.toThrow();
  });
});
