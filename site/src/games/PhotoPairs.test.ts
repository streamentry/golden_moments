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
});
