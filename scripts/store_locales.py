#!/usr/bin/env python3
"""Checks the translated store listings in `metadata/i18n/<language>.json`.

    python3 scripts/store_locales.py --check    # validate every language file
    python3 scripts/store_locales.py --list     # store locale codes per file

One file per app language holds its App Store and Google Play listing text, the
"What's New" release notes (identical on both stores, at most 500 characters)
and the store locale codes it fills (Spanish fills Mexico and Spain, for example).
English stays in `metadata/app-store.en-US.json` and
`metadata/google-play.en-US.json`. The check enforces the store limits, the
brand name, keyword rules and our tone rules; it cannot judge translation
quality. Like `release_metadata.py`, this never publishes anything.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / 'metadata/i18n'
BRAND = 'Golden Moments'

# App language -> (App Store locales, Google Play locales). English is the
# source and lives elsewhere.
LANGUAGES: dict[str, tuple[tuple[str, ...], tuple[str, ...]]] = {
    'es': (('es-MX', 'es-ES'), ('es-419', 'es-US', 'es-ES')),
    'pt-BR': (('pt-BR',), ('pt-BR',)),
    'fr': (('fr-FR', 'fr-CA'), ('fr-FR', 'fr-CA')),
    'de': (('de-DE',), ('de-DE',)),
    'it': (('it',), ('it-IT',)),
    'nl': (('nl-NL',), ('nl-NL',)),
    'pl': (('pl',), ('pl-PL',)),
    'ru': (('ru',), ('ru-RU',)),
    'uk': (('uk',), ('uk',)),
    'tr': (('tr',), ('tr-TR',)),
    'ar': (('ar-SA',), ('ar',)),
    'hi': (('hi',), ('hi-IN',)),
    'ja': (('ja',), ('ja-JP',)),
    'ko': (('ko',), ('ko-KR',)),
    'zh-Hans': (('zh-Hans',), ('zh-CN',)),
    'zh-Hant': (('zh-Hant',), ('zh-TW', 'zh-HK')),
    'vi': (('vi',), ('vi',)),
    'id': (('id',), ('id',)),
    'th': (('th',), ('th',)),
    'bn': (('bn-BD',), ('bn-BD',)),
    'fa': ((), ('fa',)),
    'ha': ((), ()),
    'ur': (('ur-PK',), ('ur',)),
    'mr': (('mr-IN',), ('mr-IN',)),
    'te': (('te-IN',), ('te-IN',)),
    'ta': (('ta-IN',), ('ta-IN',)),
    'gu': (('gu-IN',), ('gu',)),
}

APP_STORE_LIMITS = {'name': 30, 'subtitle': 30, 'promotional_text': 170,
                    'description': 4000, 'release_notes': 4000}
PLAY_LIMITS = {'name': 30, 'short_description': 80, 'full_description': 4000,
               'release_notes': 500}
KEYWORD_BYTES = 100
# Pressure, praise and claim marks the tone rules exclude in every language.
FORBIDDEN_MARKS = ('!', '！', '¡')


def path_for(language: str) -> Path:
    return FOLDER / f'{language}.json'


def _text_errors(section: str, data: dict, limits: dict[str, int]) -> list[str]:
    errors = []
    for key, limit in limits.items():
        value = data.get(key)
        if not isinstance(value, str) or not value.strip():
            errors.append(f'{section}.{key}: required text')
        elif len(value) > limit:
            errors.append(f'{section}.{key}: {len(value)} characters, maximum {limit}')
        elif any(mark in value for mark in FORBIDDEN_MARKS):
            errors.append(f'{section}.{key}: no exclamation marks')
    if BRAND not in str(data.get('name', '')):
        errors.append(f'{section}.name: must contain "{BRAND}"')
    return errors


def _keyword_errors(store: dict) -> list[str]:
    keywords = store.get('keywords')
    if not isinstance(keywords, str) or not keywords:
        return ['app_store.keywords: required text']
    errors = []
    if len(keywords.encode('utf-8')) > KEYWORD_BYTES:
        errors.append(f'app_store.keywords: {len(keywords.encode("utf-8"))} '
                      f'UTF-8 bytes, maximum {KEYWORD_BYTES}')
    words = keywords.split(',')
    if any(not word or word != word.strip() for word in words):
        errors.append('app_store.keywords: empty term or space around a comma')
    if len({word.casefold() for word in words}) != len(words):
        errors.append('app_store.keywords: duplicate terms')
    visible = f'{store.get("name", "")} {store.get("subtitle", "")}'.casefold()
    repeated = [w for w in words if w and w.casefold() in visible]
    if repeated:
        errors.append('app_store.keywords: already in the name or subtitle: '
                      + ', '.join(repeated))
    return errors


def validate(language: str, data: dict) -> list[str]:
    """Problems with one language file; an empty list means it passes."""
    if language not in LANGUAGES:
        return [f'{language}: not an app language']
    errors = []
    app_locales, play_locales = LANGUAGES[language]
    if data.get('language') != language:
        errors.append(f'language: must be "{language}"')
    if tuple(data.get('app_store_locales', ())) != app_locales:
        errors.append(f'app_store_locales: must be {list(app_locales)}')
    if tuple(data.get('google_play_locales', ())) != play_locales:
        errors.append(f'google_play_locales: must be {list(play_locales)}')
    if data.get('review') not in ('unreviewed', 'reviewed'):
        errors.append('review: "unreviewed" or "reviewed"')
    store = data.get('app_store') or {}
    play = data.get('google_play') or {}
    errors += _text_errors('app_store', store, APP_STORE_LIMITS)
    errors += _keyword_errors(store)
    errors += _text_errors('google_play', play, PLAY_LIMITS)
    if store.get('release_notes') != play.get('release_notes'):
        errors.append('release_notes: the App Store and Google Play texts differ')
    return errors


def check(folder: Path = FOLDER) -> list[str]:
    problems = []
    for file in sorted(folder.glob('*.json')):
        language = file.stem
        try:
            data = json.loads(file.read_text(encoding='utf-8'))
        except ValueError as error:
            problems.append(f'{file.name}: not valid JSON ({error})')
            continue
        problems += [f'{file.name}: {e}' for e in validate(language, data)]
    return problems


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--list', action='store_true')
    args = parser.parse_args(argv)
    if args.list:
        for language, (app, play) in LANGUAGES.items():
            state = 'ready' if path_for(language).exists() else 'missing'
            print(f'{language:8} {state:8} App Store {",".join(app):14} Play {",".join(play)}')
        return 0
    problems = check()
    for problem in problems:
        print(problem)
    done = len(list(FOLDER.glob('*.json')))
    print(f'{done} of {len(LANGUAGES)} languages, {len(problems)} problems')
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
