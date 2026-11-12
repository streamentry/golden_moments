import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { playProps } from '../i18n/play';
import PhotoPairs from './PhotoPairs';

describe('PhotoPairs', () => {
  it('shows the setup reminder before photo selection', () => {
    const props = playProps('en', 'photo-pairs');
    const html = renderToStaticMarkup(createElement(PhotoPairs, props));

    expect(html).toContain(props.ui.photoPairs.setupHint);
    expect(html).toContain(props.ui.photoPairs.photoComfort);
    expect(html.indexOf(props.ui.photoPairs.setupHint)).toBeLessThan(html.indexOf(props.ui.photoPairs.photoComfort));
  });

  it('uses the English setup reminder where no reviewed translation exists', () => {
    const english = playProps('en', 'photo-pairs');
    const vietnamese = playProps('vi', 'photo-pairs');

    expect(vietnamese.ui.photoPairs.setupHint).toBe(english.ui.photoPairs.setupHint);
  });

  it('uses Japanese copy for one-photo viewing and its controls', () => {
    const english = playProps('en', 'photo-pairs').ui.photoPairs;
    const japanese = playProps('ja', 'photo-pairs').ui.photoPairs;

    expect(japanese.intro).toContain('写真を1〜6枚');
    expect(japanese.intro).toContain('1枚ずつ');
    expect(japanese.lookOnly).toBe('写真を1枚ずつ見る');
    expect(japanese.lookOnly).not.toBe(english.lookOnly);
    expect(japanese.atLeastTwo).toContain('もう1枚');
    expect(japanese.previousPhoto).toBe('前の写真');
    expect(japanese.nextPhoto).toBe('次の写真');
    expect(japanese.captionLabel).toContain('{n}');
  });
});
