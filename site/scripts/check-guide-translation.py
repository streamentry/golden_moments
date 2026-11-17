#!/usr/bin/env python3
"""Compares translated guides with their English source.

    python3 scripts/check-guide-translation.py <code> [<section>/<slug> ...]

Checks every `src/content/guides-i18n/<code>/**.md` (or only the named
guides) against `src/content/guides/<section>/<slug>.md`. Errors: fixed
frontmatter that changed (section, order, dates, sources, related lists,
health), a missing or wrong `translatedFrom`, a different number of key
points or FAQ entries, different heading levels, different link targets, or
numbers added without an emergency number in English. Warnings: other
number differences, exclamation marks, and long titles or descriptions. It
runs without a site build, so several translators can check their own files
at once; `pnpm exec astro build` still validates the schema.
"""

from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path

import yaml

SITE = Path(__file__).resolve().parent.parent
SOURCE = SITE / 'src/content/guides'
TRANSLATED = SITE / 'src/content/guides-i18n'

# Words that must not label people living with dementia ("patients"); the same
# list check-site.mjs fails on for these languages.
PATIENT_WORDS = {
    'ar': r'مرضى',
    'vi': r'người bệnh|bệnh nhân',
    'th': r'ผู้ป่วย',
    'zh-Hans': r'患者|病人',
}

FIXED = ('section', 'order', 'updated', 'published', 'sources',
         'relatedGames', 'related', 'health')
HEADING = re.compile(r'^(#{2,6})\s', re.M)
LINK = re.compile(r'\]\(([^)\s]+)[^)]*\)|href="([^"]+)"')
NUMBER = re.compile(r'\d{1,3}(?:[   ]\d{3})+|\d+(?:[,.]\d+)*')
CLOCK_12 = re.compile(r'(?<!\d)(0?[1-9]|1[0-2])(?::([0-5]\d))?\s*(a\.m\.|p\.m\.|am|pm)(?![a-z])', re.I)
CLOCK_24 = re.compile(r'(?<!\d)([01]?\d|2[0-3]):([0-5]\d)(?!\d)')

# Recognized emergency and crisis lines that may replace an explicit source number.
EMERGENCY_NUMBERS = {'000', '101', '102', '108', '110', '111', '112', '119', '190', '191', '192', '193', '911', '988', '995', '999', '116123'}


class UniqueKeyLoader(yaml.SafeLoader):
    """PyYAML keeps the last of two equal keys; the site's parser rejects them."""


def _no_duplicate_keys(loader: UniqueKeyLoader, node: yaml.MappingNode, deep: bool = False) -> dict:
    seen = set()
    for key_node, _ in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in seen:
            raise yaml.YAMLError(f'duplicate key `{key}`')
        seen.add(key)
    return yaml.SafeLoader.construct_mapping(loader, node, deep=deep)


UniqueKeyLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, _no_duplicate_keys)


def split(path: Path) -> tuple[dict, str]:
    text = path.read_text(encoding='utf-8')
    _, front, body = text.split('---', 2)
    return yaml.load(front, Loader=UniqueKeyLoader), body


def width(text: str) -> int:
    """Display width: wide (CJK) characters count twice, marks not at all."""
    total = 0
    for ch in text:
        if unicodedata.category(ch).startswith('M'):
            continue
        total += 2 if unicodedata.east_asian_width(ch) in 'WF' else 1
    return total


def numbers(text: str) -> list[str]:
    found = []
    for token in NUMBER.findall(text):
        value = ''.join(str(unicodedata.decimal(ch)) for ch in token if ch.isdecimal())
        if value:
            found.append(value)
    return sorted(found)


def visible_numbers(text: str) -> list[str]:
    visible = re.sub(r'\]\([^)]*\)', ']', text)
    visible = re.sub(r'https?://\S+', '', visible)
    times: list[str] = []

    def clock_12(match: re.Match[str]) -> str:
        hour_12 = int(match.group(1))
        hour_24 = hour_12
        minute = int(match.group(2) or '0')
        period = match.group(3).lower().replace('.', '')
        if period == 'pm' and hour_12 != 12:
            hour_24 += 12
        elif period == 'am' and hour_12 == 12:
            hour_24 = 0
        hour_12 = hour_24 % 12 or 12
        times.extend(sorted({f'clock:{hour_24:02d}{minute:02d}', str(hour_12), str(hour_24)}))
        return ' '

    def clock_24(match: re.Match[str]) -> str:
        hour_24 = int(match.group(1))
        hour_12 = hour_24 % 12 or 12
        times.extend(sorted({f'clock:{hour_24:02d}{match.group(2)}', str(hour_12), str(hour_24)}))
        return ' '

    visible = CLOCK_12.sub(clock_12, visible)
    visible = CLOCK_24.sub(clock_24, visible)
    return sorted(numbers(visible) + times)


def _clock_value(value: str) -> tuple[int, int, bool] | None:
    twelve = CLOCK_12.search(value)
    if twelve:
        hour = int(twelve.group(1))
        minute = int(twelve.group(2) or '0')
        period = twelve.group(3).lower().replace('.', '')
        if period == 'pm' and hour != 12:
            hour += 12
        elif period == 'am' and hour == 12:
            hour = 0
        return hour, minute, True
    twenty_four = CLOCK_24.search(value)
    if twenty_four:
        return int(twenty_four.group(1)), int(twenty_four.group(2)), False
    plain = re.search(r'(?<!\d)(\d{1,2})(?::([0-5]\d))?(?!\d)', value)
    if plain:
        return int(plain.group(1)), int(plain.group(2) or '0'), False
    return None


def _schedule_time_cells(body: str) -> list[tuple[int, int, bool] | None]:
    values = []
    for line in body.splitlines():
        if not line.lstrip().startswith('|'):
            continue
        cells = line.strip().strip('|').split('|')
        if not cells or not re.search(r'\d', cells[0]):
            continue
        values.append(_clock_value(cells[0].strip()))
    return values


def daily_routine_times_match(source_body: str, translated_body: str) -> bool:
    source_times = _schedule_time_cells(source_body)
    translated_times = _schedule_time_cells(translated_body)
    if not source_times or len(source_times) != len(translated_times):
        return False
    for source, translated in zip(source_times, translated_times):
        if source is None or translated is None:
            return False
        source_hour, source_minute, _ = source
        target_hour, target_minute, target_explicit = translated
        if source_minute != target_minute:
            return False
        if target_explicit:
            if source_hour != target_hour:
                return False
            continue
        source_12_hour = source_hour % 12 or 12
        if target_hour not in {source_hour, source_12_hour}:
            return False
    return True


def _without_first_table_column(body: str) -> str:
    lines = []
    for line in body.splitlines():
        if line.lstrip().startswith('|'):
            cells = line.split('|')
            if len(cells) > 2:
                cells[1] = ' '
                line = '|'.join(cells)
        lines.append(line)
    return '\n'.join(lines)


def unsafe_number_additions(source: str, translated: str) -> bool:
    source_numbers, translated_numbers = visible_numbers(source), visible_numbers(translated)
    remaining = source_numbers.copy()
    added = []
    for number in translated_numbers:
        if number in remaining:
            remaining.remove(number)
        else:
            added.append(number)
    if not added:
        return False
    if any(number not in EMERGENCY_NUMBERS for number in added):
        return True
    source_emergency = [number for number in visible_numbers(source) if number in EMERGENCY_NUMBERS]
    translated_emergency = [number for number in visible_numbers(translated) if number in EMERGENCY_NUMBERS]
    return not source_emergency or len(translated_emergency) > len(source_emergency)


def visible_copy(front: dict, body: str) -> str:
    parts = []
    for key in ('title', 'seoTitle', 'description', 'summary'):
        value = front.get(key)
        if value is not None:
            parts.append(str(value))
    parts.extend(str(value) for value in front.get('keyPoints') or [])
    for item in front.get('faq') or []:
        if isinstance(item, dict):
            parts.extend(str(item.get(key, '')) for key in ('q', 'a'))
        else:
            parts.append(str(item))
    parts.append(body)
    return '\n'.join(parts)


def links(body: str) -> list[str]:
    return [a or b for a, b in LINK.findall(body)]


def check(code: str, rel: str, translated_path: Path | None = None) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    src_front, src_body = split(SOURCE / f'{rel}.md')
    path = translated_path or TRANSLATED / code / f'{rel}.md'
    if not path.exists():
        try:
            shown_path = path.relative_to(SITE)
        except ValueError:
            shown_path = path
        return [f'missing {shown_path}'], []
    try:
        front, body = split(path)
    except (ValueError, yaml.YAMLError) as error:
        return [f'unreadable frontmatter: {error}'], []

    for key in FIXED:
        if src_front.get(key) != front.get(key):
            errors.append(f'`{key}` differs from English')
    if front.get('translatedFrom') != src_front.get('updated'):
        errors.append('`translatedFrom` must equal the English `updated`')
    for key in ('keyPoints', 'faq'):
        if len(src_front.get(key) or []) != len(front.get(key) or []):
            errors.append(f'`{key}` has a different number of entries')
    if HEADING.findall(src_body) != HEADING.findall(body):
        errors.append('heading levels differ from English')
    if links(src_body) != links(body):
        errors.append('link targets differ from English (same links, same order)')

    source_copy = visible_copy(src_front, src_body)
    translated_copy = visible_copy(front, body)
    if rel == 'activities/daily-routine':
        if not daily_routine_times_match(src_body, body):
            errors.append('sample schedule times differ from English')
        source_copy = visible_copy(src_front, _without_first_table_column(src_body))
        translated_copy = visible_copy(front, _without_first_table_column(body))
    if unsafe_number_additions(source_copy, translated_copy):
        errors.append('numbers added without an explicit emergency number in English')
    elif visible_numbers(source_copy) != visible_numbers(translated_copy):
        warnings.append('numbers in visible text differ from English')
    shown = ' '.join(str(front.get(k, '')) for k in ('title', 'seoTitle', 'description', 'summary')) + body
    if '!' in shown or '！' in shown:
        warnings.append('exclamation mark')
    banned = PATIENT_WORDS.get(code)
    if banned and re.search(banned, shown):
        errors.append('uses "patients" wording for people living with dementia')
    title = front.get('seoTitle') or front.get('title', '')
    if width(title) > 64:
        warnings.append(f'search title is long ({width(title)})')
    description_width = width(front.get('description', ''))
    if description_width < 50 or description_width > 360:
        errors.append(f'description is outside the site check limits ({description_width}, expected 50–360)')
    elif description_width < 70 or description_width > 170:
        warnings.append(f'description is outside the preferred range ({description_width}, preferred 70–170)')
    return errors, warnings


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 2
    code, wanted = argv[0], argv[1:]
    if not wanted:
        base = TRANSLATED / code
        wanted = sorted(str(p.relative_to(base).with_suffix('')) for p in base.rglob('*.md'))
    failed = 0
    for rel in wanted:
        errors, warnings = check(code, rel)
        for message in errors:
            print(f'ERROR {code}/{rel}: {message}')
        for message in warnings:
            print(f'warn  {code}/{rel}: {message}')
        failed += bool(errors)
    print(f'{code}: {len(wanted)} guides, {failed} with errors')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
