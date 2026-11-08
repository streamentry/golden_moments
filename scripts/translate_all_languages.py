#!/usr/bin/env python3
"""Batch translate UI dictionaries and games overlays for all untranslated languages.

Uses Google Translate with token-safe chunking to preserve HTML tags,
placeholders, and non-translatable keys (href, icon, id).
Validates each language against check-translation.mjs.
"""

import json
import re
import sys
import time
import urllib.parse
import urllib.request
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'site'
UI_DIR = SITE / 'src/i18n/ui'
GAMES_DIR = SITE / 'src/i18n/games'

FALLBACKS = {
    'azb': 'az',
    'nn': 'no',
    'nd': 'zu',
    'io': 'eo',
    'wa': 'fr',
    'an': 'es',
    'sc': 'it',
    'rm': 'it',
    'ia': 'es',
    'ie': 'es',
    'cu': 'bg',
    'ae': 'fa',
    'pi': 'sa',
    'ks': 'ur',
    'kj': 'sw',
    'ng': 'sw',
    'lu': 'ln',
    'ki': 'sw',
    'hz': 'sw',
    'bi': 'en',
    'ho': 'en',
    'na': 'en',
    'za': 'zh-CN',
    'ii': 'zh-CN',
    'cr': 'en',
    'oj': 'en',
    'ik': 'iu',
    'nv': 'en',
    'kw': 'cy',
    'vo': 'eo',
}

DELIM = ' ||| '


def split_tokens(s: str) -> list[tuple[bool, str]]:
    parts = re.split(r'(<[^>]+>|\{\w+\})', s)
    return [(bool(not ((p.startswith('<') and p.endswith('>')) or (p.startswith('{') and p.endswith('}')))), p) for p in parts if p]


def batch_translate(texts: list[str], tl: str) -> dict[str, str]:
    translations = {}
    to_trans = []
    for t in texts:
        t_clean = t.strip()
        if not t_clean or t_clean in ('Golden Moments', 'Dementia Games: Golden Moments'):
            translations[t_clean] = t_clean
        else:
            to_trans.append(t_clean)

    unique_trans = list(dict.fromkeys(to_trans))
    chunk_size = 35

    for i in range(0, len(unique_trans), chunk_size):
        chunk = unique_trans[i:i + chunk_size]
        query = DELIM.join(chunk)
        url = f'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={tl}&dt=t&q=' + urllib.parse.quote(query)
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        success = False
        for attempt in range(3):
            try:
                with urllib.request.urlopen(req, timeout=12) as resp:
                    data = json.loads(resp.read().decode('utf-8'))
                    res_str = ''.join(part[0] for part in data[0] if part[0])
                    parts = res_str.split('|||')
                    if len(parts) == len(chunk):
                        for orig, tr in zip(chunk, parts):
                            translations[orig] = tr.strip()
                        success = True
                        break
                    else:
                        break  # Fall back to single-item requests
            except Exception as e:
                time.sleep(0.5 * (attempt + 1))

        if not success:
            for item in chunk:
                u = f'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={tl}&dt=t&q=' + urllib.parse.quote(item)
                r = urllib.request.Request(u, headers={'User-Agent': 'Mozilla/5.0'})
                try:
                    with urllib.request.urlopen(r, timeout=10) as rp:
                        d = json.loads(rp.read().decode('utf-8'))
                        translations[item] = ''.join(p[0] for p in d[0] if p[0]).strip()
                except Exception:
                    translations[item] = item

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


def clamp_meta_desc(text: str, orig_en: str) -> str:
    if len(text) <= 170:
        return text
    m = re.match(r'^(.{70,167}[.!?])\s', text)
    if m:
        return m.group(1)
    m = re.match(r'^(.{70,165})\s', text)
    if m:
        return m.group(1).rstrip('.,;:') + '.'
    return orig_en if len(orig_en) <= 170 else orig_en[:165].rstrip() + '.'


def reconstruct(obj, tr_map, en_obj=None, path=''):
    if isinstance(obj, str):
        if path.endswith(('.href', '.icon', '.id')) or path == '_note':
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
                    out.append(leading + trans + trailing)
        res = ''.join(out)
        if path.endswith(('description', 'lede')) and isinstance(en_obj, str):
            res = clamp_meta_desc(res, en_obj)
        return res
    elif isinstance(obj, dict):
        return {k: reconstruct(v, tr_map, en_obj.get(k) if isinstance(en_obj, dict) else None, f'{path}.{k}' if path else k) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [reconstruct(v, tr_map, en_obj[i] if isinstance(en_obj, list) and i < len(en_obj) else None, f'{path}[{i}]') for i, v in enumerate(obj)]
    return obj


def main():
    with open(UI_DIR / 'en.json', encoding='utf-8') as f:
        en_ui = json.load(f)
    with open(GAMES_DIR / 'en.json', encoding='utf-8') as f:
        en_games = json.load(f)

    ui_texts = collect_texts(en_ui)
    games_texts = collect_texts(en_games)
    combined_texts = list(dict.fromkeys(ui_texts + games_texts))

    untranslated = []
    for p in sorted(UI_DIR.glob('*.json')):
        code = p.stem
        if code == 'en':
            continue
        with open(p, encoding='utf-8') as f:
            d = json.load(f)
        if d.get('common', {}).get('skipLink') == 'Skip to main content':
            untranslated.append(code)

    print(f'Found {len(untranslated)} untranslated languages to process.')

    total = len(untranslated)
    for idx, code in enumerate(untranslated, 1):
        target_lang = FALLBACKS.get(code, code)
        t0 = time.time()
        tr_map = batch_translate(combined_texts, target_lang)

        # Reconstruct and write UI
        lang_ui = reconstruct(en_ui, tr_map, en_ui)
        ui_path = UI_DIR / f'{code}.json'
        with open(ui_path, 'w', encoding='utf-8') as f:
            json.dump(lang_ui, f, ensure_ascii=False, indent=2)
            f.write('\n')

        # Reconstruct and write Games
        lang_games = reconstruct(en_games, tr_map, en_games)
        games_path = GAMES_DIR / f'{code}.json'
        with open(games_path, 'w', encoding='utf-8') as f:
            json.dump(lang_games, f, ensure_ascii=False, indent=2)
            f.write('\n')

        # Validate with check-translation.mjs
        cmd_ui = subprocess.run(['node', 'site/scripts/check-translation.mjs', 'site/src/i18n/ui/en.json', f'site/src/i18n/ui/{code}.json'], capture_output=True, text=True)
        cmd_games = subprocess.run(['node', 'site/scripts/check-translation.mjs', 'site/src/i18n/games/en.json', f'site/src/i18n/games/{code}.json'], capture_output=True, text=True)

        ui_status = 'OK' if cmd_ui.returncode == 0 else f'ERR: {cmd_ui.stderr or cmd_ui.stdout}'
        games_status = 'OK' if cmd_games.returncode == 0 else f'ERR: {cmd_games.stderr or cmd_games.stdout}'

        elapsed = time.time() - t0
        print(f'[{idx}/{total}] {code} (-> {target_lang}): UI {ui_status}, Games {games_status} ({elapsed:.1f}s)')
        sys.stdout.flush()

    print('All languages processed.')


if __name__ == '__main__':
    main()
