#!/usr/bin/env python3
"""Check a translated ARB file against app_en.arb without running Flutter.

Same message keys, the same {placeholders}, and the same ICU plural/select
structure (keywords and branch names). `flutter gen-l10n` remains the final
check; this one is fast and safe to run while others build.

    python3 scripts/check_arb.py lib/l10n/arb/app_vi.arb
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EN = json.loads((ROOT / 'lib/l10n/arb/app_en.arb').read_text(encoding='utf-8'))
ICU = re.compile(r'\{\s*(\w+)\s*,\s*(plural|select)\s*,')
BRANCH = re.compile(r'(?:^|[\s}])(=\d+|zero|one|two|few|many|other|\w+)\s*\{')
# Names start with a Latin letter, so branch text such as {1枚} is not mistaken for one.
PLACEHOLDER = re.compile(r'\{\s*([A-Za-z_]\w*)\s*[,}]')


def shape(text):
    names = set(PLACEHOLDER.findall(text))
    icu = sorted(ICU.findall(text))
    return names, icu


def main(path):
    data = json.loads(Path(path).read_text(encoding='utf-8'))
    errors = []
    locale = data.get('@@locale')
    expected = Path(path).stem.removeprefix('app_')
    if locale != expected:
        errors.append(f'@@locale is {locale!r}, expected {expected!r}')
    messages = {k: v for k, v in EN.items() if not k.startswith('@')}
    for key, english in messages.items():
        if key not in data:
            errors.append(f'{key}: missing')
            continue
        value = data[key]
        if not isinstance(value, str) or not value.strip():
            errors.append(f'{key}: empty')
            continue
        en_names, en_icu = shape(english)
        names, icu = shape(value)
        if names != en_names:
            errors.append(f'{key}: placeholders {sorted(names)} vs English {sorted(en_names)}')
        if [k for k, _ in icu] != [k for k, _ in en_icu] or [t for _, t in icu] != [t for _, t in en_icu]:
            errors.append(f'{key}: plural/select structure differs from English')
        if any(t == 'plural' for _, t in icu) and 'other' not in value:
            errors.append(f'{key}: plural needs an "other" branch')
        if value.count('{') != value.count('}'):
            errors.append(f'{key}: unbalanced braces')
    for key in data:
        if not key.startswith('@') and key not in messages:
            errors.append(f'{key}: not in English')
    if errors:
        print('\n'.join(errors))
        print(f'{len(errors)} problems in {path}')
        return 1
    print(f'{path}: OK ({len(messages)} messages)')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
