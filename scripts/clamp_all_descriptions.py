#!/usr/bin/env python3
"""Clamp meta descriptions in i18n dictionaries to <= 165 display width."""

import json
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
I18N_DIR = ROOT / 'site/src/i18n'


def get_width(s: str) -> int:
    w = 0
    for ch in s:
        if unicodedata.category(ch).startswith('M'):
            continue
        cp = ord(ch)
        if (0x1100 <= cp <= 0x115F or 0x2E80 <= cp <= 0xA4CF or 0xAC00 <= cp <= 0xD7A3 or
            0xF900 <= cp <= 0xFAFF or 0xFE30 <= cp <= 0xFE4F or 0xFF00 <= cp <= 0xFF60 or 0xFFE0 <= cp <= 0xFFE6):
            w += 2
        else:
            w += 1
    return w


def clamp_text(s: str) -> str:
    if get_width(s) <= 155:
        return s
    while get_width(s) > 155:
        # Check sentence boundary
        last_punct = max(s.rfind('. '), s.rfind('! '), s.rfind('? '), s.rfind('。'), s.rfind('！'), s.rfind('？'))
        if last_punct >= 0 and get_width(s[:last_punct + 1]) >= 70:
            s = s[:last_punct + 1].strip()
            break
        # Else word boundary
        last_space = s.rfind(' ')
        if last_space > 0 and get_width(s[:last_space]) >= 70:
            s = s[:last_space].strip()
            if s.endswith((',', ';', ':', '-')):
                s = s[:-1].strip()
            if not s.endswith(('.', '!', '?', '。', '！', '？')):
                s = s + '.'
        else:
            s = s[:-1].strip()
            if not s.endswith(('.', '!', '?', '。', '！', '？')):
                s = s + '.'
    return s


def main():
    modified = 0
    for sub in ['ui', 'games']:
        target_dir = I18N_DIR / sub
        if not target_dir.exists():
            continue
        for p in target_dir.glob('*.json'):
            if p.name == 'en.json':
                continue
            with open(p, 'r', encoding='utf-8') as f:
                data = json.load(f)

            changed = [False]

            def walk(obj, path=''):
                if isinstance(obj, dict):
                    for k, v in obj.items():
                        curr_path = f'{path}.{k}' if path else k
                        if isinstance(v, str) and ('description' in k.lower()):
                            if get_width(v) > 168:
                                clamped = clamp_text(v)
                                if clamped != v:
                                    obj[k] = clamped
                                    changed[0] = True
                        elif isinstance(v, (dict, list)):
                            walk(v, curr_path)
                elif isinstance(obj, list):
                    for i, v in enumerate(obj):
                        walk(v, f'{path}[{i}]')

            walk(data)
            if changed[0]:
                with open(p, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                    f.write('\n')
                modified += 1
    print(f'Clamped meta descriptions in {modified} files.')


if __name__ == '__main__':
    main()
