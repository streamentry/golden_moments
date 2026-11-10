import { describe, expect, it } from 'vitest';
import { photoTileName } from './photo-label';

describe('photo tile names', () => {
  it('uses a caption as the spoken name when one is provided', () => {
    expect(photoTileName('Photo 2', '  Mum by the sea  ')).toBe('Mum by the sea');
  });

  it('keeps the numbered name when the caption is empty', () => {
    expect(photoTileName('Photo 2', '   ')).toBe('Photo 2');
    expect(photoTileName('Photo 2')).toBe('Photo 2');
  });
});
