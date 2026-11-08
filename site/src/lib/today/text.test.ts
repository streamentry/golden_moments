import { describe, expect, it } from 'vitest';
import { parsePhoneSegments, renderWithPhoneLinks, telHref } from './text';

describe('today/text', () => {
  it('converts phone strings to clean tel: URIs', () => {
    expect(telHref('1-800-272-3900')).toBe('tel:18002723900');
    expect(telHref('911')).toBe('tel:911');
    expect(telHref('988')).toBe('tel:988');
    expect(telHref('1-800-677-1116')).toBe('tel:18006771116');
  });

  it('parses plain text without phone numbers into a single text part', () => {
    const parts = parsePhoneSegments('Take a short walk together.');
    expect(parts).toEqual([{ type: 'text', value: 'Take a short walk together.' }]);
  });

  it('parses text with emergency and helpline numbers', () => {
    const parts = parsePhoneSegments('In an emergency, call 911.');
    expect(parts).toEqual([
      { type: 'text', value: 'In an emergency, call ' },
      { type: 'phone', value: '911', href: 'tel:911' },
      { type: 'text', value: '.' },
    ]);
  });

  it('parses multiple phone numbers in one sentence', () => {
    const parts = parsePhoneSegments('If you feel in crisis, call or text 988. In an emergency, call 911.');
    expect(parts).toEqual([
      { type: 'text', value: 'If you feel in crisis, call or text ' },
      { type: 'phone', value: '988', href: 'tel:988' },
      { type: 'text', value: '. In an emergency, call ' },
      { type: 'phone', value: '911', href: 'tel:911' },
      { type: 'text', value: '.' },
    ]);
  });

  it('renders phone segments with React elements', () => {
    const nodes = renderWithPhoneLinks('Call the Alzheimer’s Association 24/7 Helpline, 1-800-272-3900. It is free.');
    expect(nodes).toHaveLength(3);
    expect(nodes[0]).toBe('Call the Alzheimer’s Association 24/7 Helpline, ');
    expect(typeof nodes[1]).toBe('object');
    expect(nodes[2]).toBe('. It is free.');
  });
});
