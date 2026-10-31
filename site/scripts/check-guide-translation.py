#!/usr/bin/env python3
"""Compares translated guides with their English source.

    python3 scripts/check-guide-translation.py <code> [<section>/<slug> ...]

Checks every `src/content/guides-i18n/<code>/**.md` (or only the named
guides) against `src/content/guides/<section>/<slug>.md`. Errors: fixed
frontmatter that changed (section, order, dates, sources, related lists,
health), a missing or wrong `translatedFrom`, a different number of key
points or FAQ entries, different heading levels, or different link targets.
Warnings: numbers that differ, exclamation marks, and long titles or
descriptions. It runs without a site build, so several translators can check
their own files at once; `pnpm exec astro build` still validates the schema.
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

FIXED = ('section', 'order', 'updated', 'published', 'sources',
         'relatedGames', 'related', 'health')
HEADING = re.compile(r'^(#{2,6})\s', re.M)
LINK = re.compile(r'\]\(([^)\s]+)[^)]*\)|href="([^"]+)"')
NUMBER = re.compile(r'\d[\d,.   ]*\d|\d')


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
    found = (re.sub(r'[,.   ]', '', n) for n in NUMBER.findall(text))
    return sorted(n for n in found if n)


def links(body: str) -> list[str]:
    return [a or b for a, b in LINK.findall(body)]


def check(code: str, rel: str) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    src_front, src_body = split(SOURCE / f'{rel}.md')
    path = TRANSLATED / code / f'{rel}.md'
    if not path.exists():
        return [f'missing {path.relative_to(SITE)}'], []
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

    if numbers(src_body) != numbers(body):
        warnings.append('numbers in the body differ from English')
    shown = ' '.join(str(front.get(k, '')) for k in ('title', 'seoTitle', 'description', 'summary')) + body
    if '!' in shown or '！' in shown:
        warnings.append('exclamation mark')
    title = front.get('seoTitle') or front.get('title', '')
    if width(title) > 64:
        warnings.append(f'search title is long ({width(title)})')
    if width(front.get('description', '')) > 170:
        errors.append(f'description is too long for the site check ({width(front.get("description", ""))}, maximum 170)')
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
