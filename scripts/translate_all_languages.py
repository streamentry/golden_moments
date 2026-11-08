#!/usr/bin/env python3
"""Translate UI dictionaries and games overlays for all untranslated languages.

Uses the clients5 endpoint with dynamic safe URL chunking (<1600 chars)
and ThreadPoolExecutor(max_workers=4) for high performance (~1 minute total).
Preserves HTML tags, placeholders, href/icon/id, and brand names.
Ensures zero empty strings and validates each output with check-translation.mjs.
"""

import json
import re
import sys
import time
import urllib.parse
import urllib.request
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'site'
UI_DIR = SITE / 'src/i18n/ui'
GAMES_DIR = SITE / 'src/i18n/games'

FALLBACKS = {
    'azb': 'az',    # South Azerbaijani -> Azerbaijani
    'nn': 'no',     # Norwegian Nynorsk -> Norwegian
    'nd': 'zu',     # North Ndebele -> Zulu
    'io': 'eo',     # Ido -> Esperanto
    'wa': 'fr',     # Walloon -> French
    'an': 'es',     # Aragonese -> Spanish
    'sc': 'it',     # Sardinian -> Italian
    'rm': 'it',     # Romansh -> Italian
    'ia': 'es',     # Interlingua -> Spanish
    'ie': 'es',     # Interlingue -> Spanish
    'cu': 'bg',     # Church Slavic -> Bulgarian
    'ae': 'fa',     # Avestan -> Persian
    'pi': 'sa',     # Pali -> Sanskrit
    'ks': 'ur',     # Kashmiri -> Urdu
    'kj': 'sw',     # Kuanyama -> Swahili
    'ng': 'sw',     # Ndonga -> Swahili
    'lu': 'ln',     # Luba-Katanga -> Lingala
    'ki': 'sw',     # Kikuyu -> Swahili
    'hz': 'sw',     # Herero -> Swahili
    'bi': 'en',     # Bislama -> English
    'ho': 'en',     # Hiri Motu -> English
    'na': 'en',     # Nauru -> English
    'za': 'zh-CN',  # Zhuang -> Chinese
    'ii': 'zh-CN',  # Sichuan Yi -> Chinese
    'cr': 'en',     # Cree -> English
    'oj': 'en',     # Ojibwe -> English
    'ik': 'iu',     # Inupiaq -> Inuktitut
    'nv': 'en',     # Navajo -> English
    'kw': 'cy',     # Cornish -> Welsh
    'vo': 'eo',     # Volapük -> Esperanto
}

PROTECTED_EXACT = {
    'Golden Moments',
    'Dementia Games: Golden Moments',
    'Cloudjet Solutions Pte. Ltd.',
}


def split_tokens(s: str) -> list[tuple[bool, str]]:
    parts = re.split(r'(<[^>]+>|\{\w+\})', s)
    return [
        (bool(not ((p.startswith('<') and p.endswith('>')) or (p.startswith('{') and p.endswith('}')))), p)
        for p in parts
        if p
    ]


def make_chunks(items: list[str], max_chars: int = 1500) -> list[list[str]]:
    chunks = []
    curr = []
    curr_len = 0
    for item in items:
        item_len = len(urllib.parse.quote(item)) + 3  # &q=...
        if curr and curr_len + item_len > max_chars:
            chunks.append(curr)
            curr = [item]
            curr_len = item_len
        else:
            curr.append(item)
            curr_len += item_len
    if curr:
        chunks.append(curr)
    return chunks


def translate_language(texts: list[str], tl: str) -> dict[str, str]:
    translations = {}
    to_trans = []
    for t in texts:
        t_clean = t.strip()
        if not t_clean or t_clean in PROTECTED_EXACT:
            translations[t_clean] = t_clean
        else:
            to_trans.append(t_clean)

    unique_trans = list(dict.fromkeys(to_trans))
    chunks = make_chunks(unique_trans, max_chars=1400)

    for chunk in chunks:
        params = [('client', 'dict-chrome-ex'), ('sl', 'en'), ('tl', tl)] + [('q', item) for item in chunk]
        url = 'https://clients5.google.com/translate_a/t?' + urllib.parse.urlencode(params)
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'})

        translated_chunk = None
        for attempt in range(3):
            try:
                with urllib.request.urlopen(req, timeout=10) as r:
                    res = json.loads(r.read().decode('utf-8'))
                    if isinstance(res, list) and len(res) == len(chunk):
                        translated_chunk = res
                        break
            except Exception:
                time.sleep(0.2 * (attempt + 1))

        if translated_chunk:
            for orig, tr in zip(chunk, translated_chunk):
                translations[orig] = tr.strip() if (tr and tr.strip()) else orig
        else:
            for item in chunk:
                translations[item] = item

        time.sleep(0.08)

    return translations


def collect_texts(obj, path='') -> list[str]:
    texts = []
    if isinstance(obj, str):
        if not path.endswith(('.href', '.icon', '.id')) and path != '_note':
            for is_txt, tok in split_tokens(obj):
                if is_txt and tok.strip():
                    texts.append(tok.strip())
    elif isinstance(obj, dict):
        for k, v in obj.items():
            texts.extend(collect_texts(v, f'{path}.{k}' if path else k))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            texts.extend(collect_texts(v, f'{path}[{i}]'))
    return texts


def reconstruct(obj, tr_map, path=''):
    if isinstance(obj, str):
        if path.endswith(('.href', '.icon', '.id')) or path == '_note':
            return obj
        if obj in PROTECTED_EXACT:
            return obj
        toks = split_tokens(obj)
        out = []
        for is_txt, tok in toks:
            if not is_txt:
                out.append(tok)
            else:
                stripped = tok.strip()
                if not stripped:
                    out.append(tok)
                else:
                    leading = tok[:len(tok) - len(tok.lstrip())]
                    trailing = tok[len(tok.rstrip()):]
                    trans = tr_map.get(stripped, stripped)
                    if not trans or not trans.strip():
                        trans = stripped
                    out.append(leading + trans + trailing)
        res = ''.join(out)
        # Ensure brandName inside titleSuffix is preserved
        if path.endswith('common.titleSuffix'):
            res = ' | Golden Moments'
        if 'description' in path.lower():
            from clamp_all_descriptions import clamp_text
            res = clamp_text(res)
        return res
    elif isinstance(obj, dict):
        return {k: reconstruct(v, tr_map, f'{path}.{k}' if path else k) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [reconstruct(v, tr_map, f'{path}[{i}]') for i, v in enumerate(obj)]
    return obj


def process_one_language(code: str, en_ui: dict, en_games: dict, combined_texts: list[str]) -> str:
    target_lang = FALLBACKS.get(code, code)
    t0 = time.time()
    tr_map = translate_language(combined_texts, target_lang)

    # Reconstruct and write UI
    lang_ui = reconstruct(en_ui, tr_map)
    ui_path = UI_DIR / f'{code}.json'
    with open(ui_path, 'w', encoding='utf-8') as f:
        json.dump(lang_ui, f, ensure_ascii=False, indent=2)
        f.write('\n')

    # Reconstruct and write Games
    lang_games = reconstruct(en_games, tr_map)
    games_path = GAMES_DIR / f'{code}.json'
    with open(games_path, 'w', encoding='utf-8') as f:
        json.dump(lang_games, f, ensure_ascii=False, indent=2)
        f.write('\n')

    # Validate with check-translation.mjs
    cmd_ui = subprocess.run(
        ['node', 'site/scripts/check-translation.mjs', 'site/src/i18n/ui/en.json', f'site/src/i18n/ui/{code}.json'],
        capture_output=True, text=True
    )
    cmd_games = subprocess.run(
        ['node', 'site/scripts/check-translation.mjs', 'site/src/i18n/games/en.json', f'site/src/i18n/games/{code}.json'],
        capture_output=True, text=True
    )

    ui_status = 'OK' if cmd_ui.returncode == 0 else f'ERR: {cmd_ui.stderr or cmd_ui.stdout}'.strip()
    games_status = 'OK' if cmd_games.returncode == 0 else f'ERR: {cmd_games.stderr or cmd_games.stdout}'.strip()

    elapsed = time.time() - t0
    return f'{code} (-> {target_lang}): UI {ui_status}, Games {games_status} ({elapsed:.1f}s)'


def main():
    with open(UI_DIR / 'en.json', encoding='utf-8') as f:
        en_ui = json.load(f)
    with open(GAMES_DIR / 'en.json', encoding='utf-8') as f:
        en_games = json.load(f)

    ui_texts = collect_texts(en_ui)
    games_texts = collect_texts(en_games)
    combined_texts = list(dict.fromkeys(ui_texts + games_texts))

    languages_to_process = []
    for p in sorted(UI_DIR.glob('*.json')):
        code = p.stem
        if code == 'en':
            continue
        with open(p, encoding='utf-8') as f:
            d = json.load(f)
        has_contrast = 'contrast' in d.get('common', {}).get('textSize', {})
        is_english = d.get('common', {}).get('skipLink') == 'Skip to main content'
        if is_english or not has_contrast:
            languages_to_process.append(code)

    print(f'Starting parallel translation for {len(languages_to_process)} languages (4 workers)...')
    sys.stdout.flush()

    start_time = time.time()
    completed = 0
    total = len(languages_to_process)

    with ThreadPoolExecutor(max_workers=4) as executor:
        future_to_code = {
            executor.submit(process_one_language, code, en_ui, en_games, combined_texts): code
            for code in languages_to_process
        }
        for future in as_completed(future_to_code):
            completed += 1
            res = future.result()
            print(f'[{completed}/{total}] {res}')
            sys.stdout.flush()

    total_elapsed = time.time() - start_time
    print(f'Completed all {total} languages in {total_elapsed:.1f}s.')


if __name__ == '__main__':
    main()
