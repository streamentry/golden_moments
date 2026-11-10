#!/usr/bin/env python3
"""Translate the mobile-only illustration labels for app locales.

Only locales that already have all 83 drawing names are eligible. This keeps
the existing English fallback for low-confidence languages whose object names
were intentionally left untranslated. The script uses the repository's
translation endpoint and writes only the top-level ``illustrations`` map.

    python3 site/scripts/translate_illustration_names.py --status
    python3 site/scripts/translate_illustration_names.py --langs es,vi,de
    python3 site/scripts/translate_illustration_names.py
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAY = ROOT / 'site/src/i18n/play'
APP_PACKS = ROOT / 'assets/data/i18n'
MANIFEST = ROOT / 'assets/images/illustrations/manifest.json'
sys.path.insert(0, str(ROOT / 'scripts'))
from translate_all_languages import FALLBACKS, translate_language  # noqa: E402

GOOGLE_CODES = {'nb': 'no', 'zh-Hans': 'zh-CN', 'zh-Hant': 'zh-TW'}
UNTRANSLATED_CUTOFF = 0.5
ILLUSTRATIONS_BLOCK = re.compile(r'(?ms)^  "illustrations": \{\n.*?^  \},\n')
SENTINEL = 'The painted window is open.'


def app_locale_codes() -> list[str]:
    codes = {'en'}
    for path in APP_PACKS.glob('packs_*.json'):
        codes.add(path.stem.removeprefix('packs_').replace('_', '-'))
    return sorted(codes)


def illustration_source() -> dict[str, str]:
    manifest = json.loads(MANIFEST.read_text())
    return {item['id']: item['name'] for item in manifest['illustrations']}


def eligible_app_locales() -> tuple[list[str], list[str]]:
    english = json.loads((PLAY / 'en.json').read_text())
    drawing_ids = set(english['pictures'])
    eligible, skipped = [], []
    for code in app_locale_codes():
        if code == 'en':
            eligible.append(code)
            continue
        path = PLAY / f'{code}.json'
        if not path.exists():
            skipped.append(code)
            continue
        pictures = json.loads(path.read_text()).get('pictures', {})
        (eligible if drawing_ids.issubset(pictures) else skipped).append(code)
    return eligible, skipped


def illustration_block(names: dict[str, str]) -> str:
    entries = ',\n'.join(
        f'    {json.dumps(key, ensure_ascii=False)}: {json.dumps(value, ensure_ascii=False)}'
        for key, value in names.items()
    )
    return f'  "illustrations": {{\n{entries}\n  }},\n'


def write_names(path: Path, names: dict[str, str]) -> None:
    text = path.read_text()
    block = illustration_block(names)
    if '  "illustrations": {' in text:
        if not ILLUSTRATIONS_BLOCK.search(text):
            raise ValueError(f'{path}: could not locate the illustration map')
        text = ILLUSTRATIONS_BLOCK.sub(block, text, count=1)
    else:
        marker = '  "content": {\n'
        if text.count(marker) != 1:
            raise ValueError(f'{path}: expected one content object')
        text = text.replace(marker, block + marker, 1)
    json.loads(text)
    temporary = path.with_suffix('.tmp')
    temporary.write_text(text)
    temporary.replace(path)


def translate_locale(code: str, source: dict[str, str]) -> tuple[str, int]:
    path = PLAY / f'{code}.json'
    data = json.loads(path.read_text())
    current = data.get('illustrations')
    current = current if isinstance(current, dict) else {}
    missing = {key: value for key, value in source.items() if not isinstance(current.get(key), str) or not current[key].strip()}
    if not missing:
        return code, 0

    target = GOOGLE_CODES.get(code, FALLBACKS.get(code, code))
    sentinel = translate_language([SENTINEL], target).get(SENTINEL, SENTINEL)
    if not sentinel.strip() or sentinel == SENTINEL:
        raise RuntimeError(f'{code}: translation service did not translate its check phrase')

    items = list(dict.fromkeys(missing.values()))
    translations: dict[str, str] = {}
    for start in range(0, len(items), 20):
        group = items[start:start + 20]
        result = translate_language(group, target)
        unchanged = sum(result.get(value, value) == value for value in group)
        if unchanged / len(group) >= UNTRANSLATED_CUTOFF:
            raise RuntimeError(f'{code}: {unchanged} of {len(group)} names came back unchanged')
        translations.update(result)

    labels = {key: translations.get(english, english) for key, english in missing.items()}
    if any(not value.strip() or '\n' in value or '\r' in value for value in labels.values()):
        raise RuntimeError(f'{code}: translation returned an empty or multi-line label')
    write_names(path, {**current, **labels})
    return code, len(labels)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--status', action='store_true', help='show eligible and intentionally skipped app locales')
    parser.add_argument('--langs', default='', help='comma-separated site locale codes; defaults to every eligible app locale')
    parser.add_argument('--jobs', type=int, default=2, help='parallel locale translations, from 1 to 4')
    args = parser.parse_args()
    if not 1 <= args.jobs <= 4:
        parser.error('--jobs must be between 1 and 4')

    eligible, skipped = eligible_app_locales()
    print(f'Eligible locales ({len(eligible)}): {", ".join(eligible)}')
    print(f'Kept on the existing English fallback ({len(skipped)}): {", ".join(skipped)}')
    if args.status:
        return 0

    requested = [code for code in args.langs.split(',') if code] if args.langs else eligible
    invalid = sorted(set(requested) - set(eligible))
    if invalid:
        parser.error(f'these locales keep the existing fallback because drawing names are incomplete: {", ".join(invalid)}')
    requested = [code for code in requested if code != 'en']
    source = illustration_source()
    failures = []
    with ThreadPoolExecutor(max_workers=args.jobs) as executor:
        futures = {executor.submit(translate_locale, code, source): code for code in requested}
        for future in as_completed(futures):
            code = futures[future]
            try:
                locale, count = future.result()
                print(f'OK {locale}: added {count} illustration labels', flush=True)
            except Exception as error:  # noqa: BLE001
                failures.append(code)
                print(f'FAIL {code}: {error}', flush=True)
    print(f'Completed {len(requested) - len(failures)} locales; failed {len(failures)}')
    return 1 if failures else 0


if __name__ == '__main__':
    raise SystemExit(main())
