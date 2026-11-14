#!/usr/bin/env python3
"""Machine-translate app and guide text with OpenCode, writing only what passes the repo's checks.

This drives the `opencode` CLI (`opencode run -m <model>`) as a translation
sub-agent. It never registers a language and never commits: it writes the
per-language files that docs/engineering/localization.md lists, and only after
the matching checker passes. Everything it writes is machine-made and must stay
marked unreviewed (AGENTS.md).

    python3 scripts/opencode_translate.py gaps                       # what is missing
    python3 scripts/opencode_translate.py app ti "Tigrinya" -m MODEL  # ARB, pack overlay, iOS strings, store draft
    python3 scripts/opencode_translate.py guides ti "Tigrinya" -m MODEL [--limit 10]

`app` writes lib/l10n/arb/app_<code>.arb, assets/data/i18n/packs_<code>.json,
ios/Runner/<code>.lproj/InfoPlist.strings and metadata/i18n/<code>.json. Run
`python3 scripts/register_language.py <code>` only after a quality review
passes (see docs/engineering/opencode-translation.md).

`guides` translates English guides that are missing for <code> or are still
English copies, one file per OpenCode call, and keeps a file only when
site/scripts/check-guide-translation.py reports no ERROR for it.
"""

from __future__ import annotations

import argparse
import datetime
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'site'
ARB_DIR = ROOT / 'lib/l10n/arb'
GUIDES = SITE / 'src/content/guides'
GUIDES_I18N = SITE / 'src/content/guides-i18n'
ANSI = re.compile(r'\x1b\[[0-9;]*m')

VOICE = (
    'Golden Moments is a calm shared photo activity for a family caregiver and an '
    'adult living with dementia. Write plain, warm, respectful adult language, never '
    'childish. No medical claims (never say it treats, prevents, diagnoses or '
    'measures anything) and keep every hedge. Never call anyone a patient. No '
    'exclamation marks of any kind. No emoji. Use the target language in its normal '
    'script only; leave no English except brand names (Golden Moments, Apple, Google, '
    'iPhone, Android, App Store, iCloud). If you do not know a word, use a short plain '
    'phrase you are sure of; never invent words. Check that every negation keeps its '
    'meaning.'
)


def run_opencode(prompt: str, model: str, timeout: int = 900) -> str:
    """One OpenCode call in an empty scratch directory; returns its text output."""
    with tempfile.TemporaryDirectory(prefix='oc-translate-') as work:
        result = subprocess.run(
            ['opencode', 'run', '-m', model, prompt],
            capture_output=True, text=True, cwd=work, timeout=timeout,
        )
    if result.returncode != 0:
        raise RuntimeError(f'opencode failed ({result.returncode}): {result.stderr[-500:]}')
    return ANSI.sub('', result.stdout)


def extract_json(text: str):
    match = re.search(r'\{.*\}', text, re.S)
    if not match:
        raise ValueError('no JSON object in OpenCode output')
    return json.loads(match.group(0))


def extract_block(text: str) -> str:
    """The contents of the last fenced block, or the whole text from the first '---'."""
    fences = re.findall(r'```[a-zA-Z]*\n(.*?)```', text, re.S)
    if fences:
        return fences[-1].strip() + '\n'
    start = text.find('---\n')
    if start < 0:
        raise ValueError('no markdown in OpenCode output')
    return text[start:].strip() + '\n'


def run_check(args: list[str], cwd: Path = ROOT) -> tuple[bool, str]:
    result = subprocess.run(args, capture_output=True, text=True, cwd=cwd)
    return result.returncode == 0, (result.stdout + result.stderr).strip()


# ---------------------------------------------------------------- app text


def translate_arb(code: str, language: str, model: str, chunk: int = 40) -> dict:
    english = json.loads((ARB_DIR / 'app_en.arb').read_text(encoding='utf-8'))
    keys = [k for k in english if not k.startswith('@')]
    rules = (
        f'Translate user-interface text into {language}. {VOICE} Keep every '
        '{placeholder} name exactly as written. Keep ICU plural/select syntax and its '
        'keywords exactly (for example {count, plural, one{...} other{...}}); translate '
        'only the text inside branches and use only the keywords the English uses. Keep '
        'the numbers 911 and 988 and the U.S.-only wording around them. In '
        'todayWornOutTry2 and todayWornOutTry3 write no phone numbers and no U.S. '
        "organization names: say to call a dementia helpline in the reader's country, and "
        'to ask a local older-adult or social service about respite care. Follow each '
        "item's note for context and length. Return ONLY one JSON object mapping each key "
        'to its translated string.'
    )
    done: dict[str, str] = {}
    for start in range(0, len(keys), chunk):
        part = keys[start:start + chunk]
        items = {k: {'text': english[k], 'note': (english.get('@' + k) or {}).get('description', '')} for k in part}
        for attempt in range(3):
            try:
                got = extract_json(run_opencode(rules + '\n\nItems:\n' + json.dumps(items, ensure_ascii=False), model))
            except (ValueError, RuntimeError) as error:
                print(f'  chunk {start}: {error}', file=sys.stderr)
                continue
            done.update({k: v for k, v in got.items() if k in items and isinstance(v, str) and v.strip()})
            if all(k in done for k in part):
                break
        print(f'  ARB {sum(k in done for k in keys)}/{len(keys)}', flush=True)
    arb = {'@@locale': code}
    arb.update({k: done[k] for k in keys if k in done})
    return arb


def write_arb(code: str, language: str, model: str) -> bool:
    arb = translate_arb(code, language, model)
    path = ARB_DIR / f'app_{code}.arb'
    path.write_text(json.dumps(arb, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    for _ in range(2):
        ok, report = run_check([sys.executable, 'scripts/check_arb.py', str(path)])
        if ok:
            print(f'  {report.splitlines()[-1]}')
            return True
        bad = sorted({line.split(':')[0] for line in report.splitlines() if ':' in line and not line.startswith(str(path))})
        print(f'  check_arb: {len(bad)} keys to redo', flush=True)
        english = json.loads((ARB_DIR / 'app_en.arb').read_text(encoding='utf-8'))
        redo = {k: v for k, v in translate_arb_subset(english, bad, language, model, report).items()}
        arb.update(redo)
        path.write_text(json.dumps(arb, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    ok, report = run_check([sys.executable, 'scripts/check_arb.py', str(path)])
    if not ok:
        path.unlink()
        print(f'  ARB rejected, file removed:\n{report[-1500:]}')
    return ok


def translate_arb_subset(english: dict, keys: list[str], language: str, model: str, report: str) -> dict:
    keys = [k for k in keys if k in english and not k.startswith('@')]
    if not keys:
        return {}
    items = {k: {'text': english[k], 'note': (english.get('@' + k) or {}).get('description', '')} for k in keys}
    prompt = (
        f'These {language} UI strings failed a check. Translate them again into {language}. {VOICE} '
        'Keep every {placeholder} and the exact ICU plural/select structure of the English. '
        f'Checker output:\n{report[-2000:]}\n\nItems:\n{json.dumps(items, ensure_ascii=False)}\n'
        'Return ONLY one JSON object mapping each key to its string.'
    )
    try:
        got = extract_json(run_opencode(prompt, model))
    except (ValueError, RuntimeError):
        return {}
    return {k: v for k, v in got.items() if k in items and isinstance(v, str) and v.strip()}


def write_pack_overlay(code: str, language: str, model: str) -> bool:
    english = json.loads((ROOT / 'assets/data/i18n/packs_en.json').read_text(encoding='utf-8'))
    prompt = (
        f'Translate the picture-pack names, descriptions, themes and picture captions into {language}. '
        f'{VOICE} Captions describe the picture simply. Keep every key and id exactly; check each '
        'adjective agrees with its noun. Return ONLY the JSON object with the same structure.\n\n'
        + json.dumps(english, ensure_ascii=False)
    )
    path = ROOT / f'assets/data/i18n/packs_{code}.json'
    for _ in range(3):
        try:
            got = extract_json(run_opencode(prompt, model))
        except (ValueError, RuntimeError) as error:
            print(f'  pack: {error}', file=sys.stderr)
            continue
        if _same_shape(english, got):
            path.write_text(json.dumps(got, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
            print('  pack overlay written')
            return True
    print('  pack overlay rejected (shape differs from packs_en.json)')
    return False


def _same_shape(a, b) -> bool:
    if isinstance(a, dict):
        return isinstance(b, dict) and set(a) == set(b) and all(_same_shape(a[k], b[k]) for k in a)
    return isinstance(b, str) and bool(b.strip())


def write_infoplist(code: str, language: str, model: str) -> bool:
    english = (ROOT / 'ios/Runner/en.lproj/InfoPlist.strings').read_text(encoding='utf-8')
    source = re.search(r'"NSPhotoLibraryUsageDescription" = "((?:[^"\\]|\\.)*)";', english).group(1)
    prompt = (
        f'Translate this iOS photo-permission sentence into {language}. {VOICE} Say plainly that only '
        'chosen photos are copied, on this device. Return ONLY JSON {"text": "..."}.\n\n' + source
    )
    for _ in range(3):
        try:
            text = extract_json(run_opencode(prompt, model)).get('text', '').strip()
        except (ValueError, RuntimeError):
            continue
        if text and '!' not in text:
            text = text.replace('\\', '\\\\').replace('"', '\\"')
            out = re.sub(r'("NSPhotoLibraryUsageDescription" = ")((?:[^"\\]|\\.)*)(";)',
                         lambda m: m.group(1) + text + m.group(3), english)
            folder = ROOT / f'ios/Runner/{code}.lproj'
            folder.mkdir(exist_ok=True)
            (folder / 'InfoPlist.strings').write_text(out, encoding='utf-8')
            print('  InfoPlist.strings written')
            return True
    return False


def write_store_draft(code: str, language: str, model: str) -> bool:
    sys.path.insert(0, str(ROOT))
    from scripts import store_locales  # noqa: E402

    if code not in store_locales.LANGUAGES:
        print(f'  store draft skipped: register {code} first (scripts/register_language.py)')
        return False
    app_locales, play_locales = store_locales.LANGUAGES[code]
    app = json.loads((ROOT / 'metadata/app-store.en-US.json').read_text(encoding='utf-8'))
    play_dir = ROOT / 'metadata/google-play/en-US'
    play = {p.stem: p.read_text(encoding='utf-8').strip() for p in play_dir.glob('*.txt')}
    english = {'app_store': {k: app.get(k, '') for k in ('name', 'subtitle', 'keywords', 'promotional_text', 'description', 'release_notes')},
               'google_play': {k: play.get(k, '') for k in ('name', 'short_description', 'full_description', 'release_notes')}}
    limits = ('Limits in characters: app_store name 30 (must contain "Golden Moments"; use plain '
              '"Golden Moments" if a local prefix does not fit), subtitle 30, promotional_text 170, '
              'description 4000, release_notes 500; google_play name 30 (must contain "Golden Moments"), '
              'short_description 80, full_description 4000, release_notes 500. release_notes must be '
              'identical in both stores. keywords: comma-separated, no spaces around commas, no '
              'duplicates, none repeating a word of the name or subtitle, at most 100 UTF-8 bytes.')
    prompt = (f'Translate this app-store listing into {language}. {VOICE} Keep the product claims exactly '
              f'as in English; no new claims. {limits} Return ONLY JSON with keys "app_store" and '
              f'"google_play" holding the same fields.\n\n' + json.dumps(english, ensure_ascii=False))
    feedback = ''
    for _ in range(4):
        try:
            got = extract_json(run_opencode(prompt + feedback, model))
        except (ValueError, RuntimeError):
            continue
        data = {'language': code, 'app_store_locales': list(app_locales), 'google_play_locales': list(play_locales),
                'review': 'unreviewed', 'translated_from': datetime.date.today().isoformat(),
                'app_store': got.get('app_store', {}), 'google_play': got.get('google_play', {})}
        errors = store_locales.validate(code, data)
        if not errors:
            store_locales.path_for(code).write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
            print('  store draft written')
            return True
        feedback = '\n\nYour previous answer failed these checks; fix them:\n' + '\n'.join(errors)
    print('  store draft rejected:\n' + '\n'.join(errors))
    return False


# ---------------------------------------------------------------- guides


def _body_lines(path: Path) -> list[str]:
    text = path.read_text(encoding='utf-8')
    body = text.split('\n---\n', 1)[-1]
    return [line.strip() for line in body.splitlines() if len(line.strip()) > 25]


def guide_gaps(code: str) -> list[str]:
    """Guides (section/slug.md) missing for `code`, or still an English copy."""
    todo = []
    for english in sorted(GUIDES.glob('*/*.md')):
        rel = english.relative_to(GUIDES).as_posix()
        target = GUIDES_I18N / code / rel
        if not target.exists():
            todo.append(rel)
            continue
        lines = _body_lines(target)
        source = set(_body_lines(english))
        if lines and sum(line in source for line in lines) / len(lines) > 0.5:
            todo.append(rel)
    return todo


GUIDE_RULES = (
    'Translate this guide into {language}. ' + VOICE + ' Rules: translate title, seoTitle, '
    'description, summary, keyPoints, faq q/a and the body. Keep every other frontmatter field '
    'byte-identical (section, order, updated, published, sources, relatedGames, related, health). '
    'Add `translatedFrom: <the English updated date>` right after `updated`. Keep the same number of '
    'keyPoints, FAQ entries and headings at the same levels; keep the same link targets in the same '
    'order and well-formed [text](url) links; keep numbers and dates in the same shape as English. '
    'Never write 911: where English says call 911, write the local wording for "call your local '
    'emergency number" with no digits. Keep every double-quoted YAML value free of ASCII double '
    'quotes and quote YAML list items that contain a colon. description at most 150 characters. '
    'Translate the whole file, never shorten. Return ONLY the complete markdown file in one '
    'fenced block.'
)


def translate_guides(code: str, language: str, model: str, limit: int | None) -> tuple[int, int]:
    todo = guide_gaps(code)[:limit]
    kept = rejected = 0
    for rel in todo:
        english = (GUIDES / rel).read_text(encoding='utf-8')
        target = GUIDES_I18N / code / rel
        previous = target.read_text(encoding='utf-8') if target.exists() else None
        prompt = GUIDE_RULES.format(language=language) + '\n\n' + english
        feedback = ''
        ok = False
        for _ in range(2):
            try:
                text = extract_block(run_opencode(prompt + feedback, model))
            except (ValueError, RuntimeError) as error:
                print(f'  {rel}: {error}', file=sys.stderr)
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(text, encoding='utf-8')
            slug = rel[:-3]
            passed, report = run_check([sys.executable, 'scripts/check-guide-translation.py', code, slug], cwd=SITE)
            problems = [line for line in report.splitlines() if line.startswith('ERROR')]
            if '911' in text:
                problems.append('ERROR contains 911')
            if '!' in text.split('\n---\n', 1)[-1]:
                problems.append('ERROR contains an exclamation mark')
            lines = _body_lines(target)
            source = set(_body_lines(GUIDES / rel))
            if lines and sum(line in source for line in lines) / len(lines) > 0.2:
                problems.append('ERROR body is still largely English')
            if not problems:
                ok = True
                break
            feedback = '\n\nYour previous answer failed these checks; fix them and return the whole file:\n' + '\n'.join(problems)
        if ok:
            kept += 1
            print(f'  kept {rel}')
        else:
            rejected += 1
            if previous is None:
                target.unlink(missing_ok=True)
            else:
                target.write_text(previous, encoding='utf-8')
            print(f'  rejected {rel}')
    return kept, rejected


# ---------------------------------------------------------------- CLI


def show_gaps() -> None:
    codes = [line.split(',')[0].strip() for line in (ROOT / 'docs/languages.csv').read_text(encoding='utf-8').splitlines()[1:] if line.strip()]
    arbs = {p.stem.removeprefix('app_').replace('_', '-') for p in ARB_DIR.glob('app_*.arb')}
    missing_app = [c for c in codes if c not in arbs and c != 'en']
    total = 0
    rows = []
    for directory in sorted(GUIDES_I18N.iterdir()):
        if directory.is_dir():
            n = len(guide_gaps(directory.name))
            total += n
            if n:
                rows.append(f'{directory.name}:{n}')
    print(f'app languages without app text ({len(missing_app)}): {" ".join(missing_app)}')
    print(f'guide files missing or English copies: {total} across {len(rows)} languages')
    print(' '.join(rows))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('mode', choices=['gaps', 'app', 'guides'])
    parser.add_argument('code', nargs='?')
    parser.add_argument('language', nargs='?', help='language name for the prompt, e.g. "Tigrinya (Ge\'ez script)"')
    parser.add_argument('-m', '--model', help='OpenCode model id, e.g. provider/model')
    parser.add_argument('--limit', type=int, help='guides: at most this many files')
    args = parser.parse_args()
    if args.mode == 'gaps':
        show_gaps()
        return 0
    if not (args.code and args.language and args.model):
        parser.error('app and guides need: code, language and --model')
    if args.mode == 'app':
        results = {
            'arb': write_arb(args.code, args.language, args.model),
            'pack': write_pack_overlay(args.code, args.language, args.model),
            'infoplist': write_infoplist(args.code, args.language, args.model),
            'store': write_store_draft(args.code, args.language, args.model),
        }
        print(json.dumps(results))
        return 0 if all(results.values()) else 1
    kept, rejected = translate_guides(args.code, args.language, args.model, args.limit)
    print(f'{args.code}: {kept} kept, {rejected} rejected')
    return 0 if rejected == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
