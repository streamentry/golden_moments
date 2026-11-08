import type { ReactNode } from 'react';
import React from 'react';

const PHONE_REGEX = /\b(1-800-272-3900|1-800-677-1116|911|988|711)\b/g;

/** Strips non-digits to create a valid tel: URI. */
export function telHref(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  return `tel:${digits}`;
}

export interface TextPart {
  type: 'text' | 'phone';
  value: string;
  href?: string;
}

/** Parses plain text into segments of text and phone numbers. */
export function parsePhoneSegments(text: string): TextPart[] {
  const parts: TextPart[] = [];
  let lastIndex = 0;
  PHONE_REGEX.lastIndex = 0;
  let match: RegExpExecArray | null;

  while ((match = PHONE_REGEX.exec(text)) !== null) {
    if (match.index > lastIndex) {
      parts.push({ type: 'text', value: text.slice(lastIndex, match.index) });
    }
    parts.push({
      type: 'phone',
      value: match[0],
      href: telHref(match[0]),
    });
    lastIndex = match.index + match[0].length;
  }

  if (lastIndex < text.length) {
    parts.push({ type: 'text', value: text.slice(lastIndex) });
  }

  return parts;
}

/** Renders string text with phone numbers as interactive, accessible tel: links. */
export function renderWithPhoneLinks(text: string): ReactNode[] {
  const segments = parsePhoneSegments(text);
  return segments.map((seg, i) => {
    if (seg.type === 'phone' && seg.href) {
      return React.createElement(
        'a',
        {
          key: `${seg.value}-${i}`,
          href: seg.href,
          className: 'today__phone',
        },
        seg.value,
      );
    }
    return seg.value;
  });
}
