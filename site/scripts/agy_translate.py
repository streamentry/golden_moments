#!/usr/bin/env python3
"""Translate the website into many languages with the Antigravity CLI (`agy`).

    python3 scripts/agy_translate.py status
    python3 scripts/agy_translate.py run  --kinds ui,games,play,guides [--langs is,ka] [--jobs 8]

Kinds: ui, games, play (JSON dictionaries) and guides (markdown). A language
whose file is missing, or still an English copy, is (re)translated; finished
files are skipped, so the script can be stopped and started again. Output is
validated (keys, {placeholders}, HTML tags, plural forms, guide frontmatter)
and a failed chunk is retried and then split. Everything it writes is machine
translated and unreviewed, like the other languages.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import subprocess
import sys
import tempfile
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

SITE = Path(__file__).resolve().parent.parent
I18N = SITE / 'src/i18n'
GUIDES = SITE / 'src/content/guides'
GUIDES_I18N = SITE / 'src/content/guides-i18n'
CSV = SITE.parent / 'docs/languages.csv'
MODEL = 'gemini-3.8-flash-medium'
PLURALS = ('zero', 'one', 'two', 'few', 'many', 'other')
NO_LETTER_GRID = {'zh-Hans', 'zh-Hant', 'ja', 'ko', 'th', 'my', 'yo', 'lo', 'ii', 'bo', 'dz', 'km', 'zh'}
lock = threading.Lock()

RULES = """You are a professional localizer for a website of simple, free picture activities that families play with an adult living with dementia.
Rules:
- Warm, plain, respectful adult language, grade 6-8 reading level. Say what a native speaker naturally says; never word for word.
- Say the local equivalent of "people living with dementia" / "the person you care for". Never "patients", "sufferers", "demented", or baby talk. Use the polite-but-warm adult form of address.
- Never claim or imply any activity treats, slows, prevents, cures or "trains" anything. Keep every hedge ("may", "linked with").
- Keep EXACTLY: {placeholders} such as {name}, HTML tags and every href/URL, markdown link targets, the brand "Golden Moments", and the store name "Dementia Games: Golden Moments". Keep numbers.
- Use the language's own punctuation and quotation marks. No emoji, no exclamation-mark praise, no ALL CAPS.
- Localize US-only details (for example "911" becomes your local emergency number); keep titles, publishers and URLs of cited sources.
"""


def languages() -> list[dict]:
    out = []
    with open(CSV, newline='') as f:
        for row in csv.reader(f):
            if row and row[0].strip() and row[0].strip() != '639-1':
                out.append({'code': row[0].strip(), 'english': row[3].strip(), 'native': row[4].split(',')[0].strip()})
    return out


def locale_codes() -> dict[str, dict]:
    """code -> {english, native, bcp47} from the site's own locales.ts."""
    src = (I18N / 'locales.ts').read_text()
    res = {}
    for m in re.finditer(r"\{ code: '([^']+)', prefix: '[^']*', bcp47: '([^']+)'.*?name: '((?:[^'\\]|\\.)*)', englishName: '((?:[^'\\]|\\.)*)'", src):
        res[m.group(1)] = {'bcp47': m.group(2), 'native': m.group(3), 'english': m.group(4)}
    return res


def plural_cats(bcp47: str) -> list[str]:
    try:
        out = subprocess.run(['node', '-e', f"console.log(JSON.stringify(new Intl.PluralRules('{bcp47}').resolvedOptions().pluralCategories))"],
                             capture_output=True, text=True, timeout=20).stdout
        cats = json.loads(out)
        return [c for c in PLURALS if c in cats] or ['other']
    except Exception:
        return ['other']


MAX_JOBS = 5  # never more than 5 agy processes at once
slots = threading.BoundedSemaphore(MAX_JOBS)


def agy(prompt: str, timeout: int = 900) -> str:
    """One agy call. Quota/rate errors (429) wait and retry with backoff instead of failing."""
    wait = 60
    while True:
        with slots, tempfile.TemporaryDirectory() as cwd:
            r = subprocess.run(['agy', '--model', MODEL, f'-p={prompt}'], capture_output=True, text=True, cwd=cwd, timeout=timeout)
        out = r.stdout + r.stderr
        if 'RESOURCE_EXHAUSTED' in out or 'code 429' in out:
            print(f'quota hit, waiting {wait}s', flush=True)
            time.sleep(wait)
            wait = min(wait * 2, 900)
            continue
        if r.returncode != 0 and not r.stdout.strip():
            raise RuntimeError(r.stderr[-300:])
        return r.stdout


def extract_json(text: str):
    text = text.strip()
    m = re.search(r'```(?:json)?\s*\n(.*?)\n```', text, re.S)
    if m:
        text = m.group(1)
    a, b = text.find('{'), text.rfind('}')
    return json.loads(text[a:b + 1])


# ---------------------------------------------------------------- JSON units

def is_plural(v) -> bool:
    return isinstance(v, dict) and v and all(k in PLURALS for k in v)


def units(node, path=()):
    """Yield (path, value) translatable units; plural objects and string lists stay whole."""
    if isinstance(node, str):
        if node.strip():
            yield path, node
    elif is_plural(node):
        yield path, node
    elif isinstance(node, list):
        if node and all(isinstance(x, str) for x in node):
            yield path, node
        else:
            for i, x in enumerate(node):
                yield from units(x, path + (i,))
    elif isinstance(node, dict):
        for k, v in node.items():
            if k.startswith('_') or k in ('id', 'value', 'href', 'icon', 'available'):
                continue
            yield from units(v, path + (k,))


def set_path(root, path, val):
    for p in path[:-1]:
        root = root[p]
    root[path[-1]] = val


def get_path(root, path):
    for p in path:
        root = root[p]
    return root


PH = re.compile(r'\{[^{}]+\}')
TAG = re.compile(r'</?[a-zA-Z][^>]*>')


def sig(v) -> list:
    s = json.dumps(v, ensure_ascii=False)
    return sorted(PH.findall(s)), sorted(TAG.findall(s.replace('\\"', '"')))


def valid_unit(src, out, cats) -> str | None:
    if is_plural(src):
        if not isinstance(out, dict) or set(out) != set(cats) or not all(isinstance(x, str) and x for x in out.values()):
            return f'plural forms must be exactly {cats}'
        sp = sorted(set(PH.findall(json.dumps(src))))
        for x in out.values():
            if sorted(set(PH.findall(x))) != sp and not (set(PH.findall(x)) <= set(sp)):
                return 'placeholder mismatch'
        return None
    if isinstance(src, list):
        if not isinstance(out, list) or len(out) != len(src) or not all(isinstance(x, str) for x in out):
            return 'list length changed'
    elif not isinstance(out, str) or not out.strip():
        return 'empty'
    if isinstance(src, list) or isinstance(out, list):
        ok = sig(src)[1] == sig(out)[1] and set(sig(out)[0]) <= set(sig(src)[0])
    else:
        ok = sig(src)[1] == sig(out)[1] and sorted(set(PH.findall(src))) == sorted(set(PH.findall(out)))
    return None if ok else 'placeholders or HTML tags changed'


def translate_chunk(lang: dict, chunk: dict, cats: list[str], extra: str, depth=0) -> dict:
    keys = list(chunk)
    note = ''
    if any(is_plural(v) for v in chunk.values()):
        note = f'\nKeys whose value is an object of plural forms must be answered with exactly these forms: {cats} (Intl.PluralRules for this language), each a complete natural sentence with the same placeholders.'
    prompt = (f'{RULES}\nTranslate the JSON values from English into {lang["english"]} ({lang["native"]}, code {lang["code"]}). '
              f'Keep every key exactly. Return ONLY one JSON object, no commentary.{note}\n{extra}\n\n'
              + json.dumps(chunk, ensure_ascii=False, indent=1))
    last = ''
    for attempt in range(3):
        try:
            out = extract_json(agy(prompt if not last else prompt + f'\n\nYour previous answer was rejected: {last}. Fix it.'))
            bad = [k for k in keys if k not in out]
            if not bad:
                err = {k: valid_unit(chunk[k], out[k], cats) for k in keys}
                err = {k: e for k, e in err.items() if e}
                if not err:
                    return {k: out[k] for k in keys}
                last = '; '.join(f'{k}: {e}' for k, e in list(err.items())[:5])
            else:
                last = f'missing keys {bad[:5]}'
        except Exception as e:  # noqa: BLE001
            last = f'{type(e).__name__}: {str(e)[:120]}'
    if len(keys) > 1:
        h = len(keys) // 2
        a = translate_chunk(lang, {k: chunk[k] for k in keys[:h]}, cats, extra, depth + 1)
        b = translate_chunk(lang, {k: chunk[k] for k in keys[h:]}, cats, extra, depth + 1)
        return {**a, **b}
    raise RuntimeError(f'{lang["code"]}: {keys[0]} failed: {last}')


def translate_json(kind: str, lang: dict, cats: list[str]) -> Path:
    code = lang['code']
    en = json.loads((I18N / kind / 'en.json').read_text())
    work = json.loads(json.dumps(en))
    extra = ''
    if kind == 'play':
        content = work.get('content', {})
        content.pop('sayings', None)
        if code in NO_LETTER_GRID:
            content.pop('wordSearch', None)
        else:
            extra = ('wordSearch: use common nouns of 3-6 letters as a reader counts them, no spaces or hyphens, in capitals where the script has them; '
                     '"fill" is at least 10 easy-to-tell-apart letters of that alphabet. Picture names: short concrete nouns, the noun first. '
                     'Conversation prompts are open invitations, never quiz questions. Coloring paints: 12 common color names.')
        if code in NO_LETTER_GRID:
            extra = 'Picture names: short concrete nouns, the noun first. Conversation prompts are open invitations, never quiz questions.'
        work['content'] = content
    items = list(units(work))
    chunk, size, chunks = {}, 0, []
    for path, v in items:
        k = '/'.join(map(str, path))
        s = len(json.dumps(v, ensure_ascii=False))
        if size + s > 5000 and chunk:
            chunks.append(chunk)
            chunk, size = {}, 0
        chunk[k] = v
        size += s
    if chunk:
        chunks.append(chunk)
    paths = {'/'.join(map(str, p)): p for p, _ in items}
    for ch in chunks:
        res = translate_chunk(lang, ch, cats, extra)
        for k, v in res.items():
            set_path(work, paths[k], v)
    target = I18N / kind / f'{code}.json'
    tmp = target.with_suffix('.tmp')
    tmp.write_text(json.dumps(work, ensure_ascii=False, indent=2) + '\n')
    tmp.replace(target)
    return target


# ---------------------------------------------------------------- guides

def guide_done(code: str, rel: str) -> bool:
    t = GUIDES_I18N / code / rel
    if not t.exists():
        return False
    en = (GUIDES / rel).read_text().split('---', 2)[-1].strip()
    txt = t.read_text()
    return txt.split('---', 2)[-1].strip() != en and not guide_problems((GUIDES / rel).read_text(), txt)


def translate_guide(lang: dict, rel: str) -> str:
    code = lang['code']
    src = (GUIDES / rel).read_text()
    upd = re.search(r'^updated:\s*(\S+)', src, re.M).group(1)
    base = (f'{RULES}\nTranslate this markdown guide from English into {lang["english"]} ({lang["native"]}). '
            'Translate the frontmatter values of title, seoTitle, description, summary, keyPoints, faq (q and a), and the whole body. Keep the `sources` list completely unchanged, character for character. '
            'Keep every other frontmatter key and value exactly (section, order, updated, relatedGames, related, health, sources url/publisher), the same YAML structure, the same number of keyPoints and FAQ entries, the same heading levels and the same link targets in the same order. '
            f'Add the line `translatedFrom: {upd}` after the `updated:` line. Keep title/seoTitle under about 60 characters and description under about 160. '
            'Return ONLY the full translated file starting with ---, no code fence, no commentary.\n\n')
    last = ''
    for attempt in range(3):
        out = agy(base + src + (f'\n\nYour previous answer failed these checks, fix them:\n{last}' if last else ''), timeout=1500).strip()
        out = re.sub(r'^```\w*\n|\n```$', '', out)
        if not out.startswith('---'):
            last = 'file must start with ---'
            continue
        target = GUIDES_I18N / code / rel
        tmp = target.with_name('.tmp-' + target.name)
        tmp.parent.mkdir(parents=True, exist_ok=True)
        tmp.write_text(out + '\n')
        rel_slug = rel[:-3]
        r = subprocess.run([sys.executable, str(SITE / 'scripts/check-guide-translation.py'), code, rel_slug, '--file', str(tmp)],
                           capture_output=True, text=True) if False else None
        problems = guide_problems(src, out)
        if not problems:
            tmp.replace(target)
            return str(target)
        tmp.unlink(missing_ok=True)
        last = problems
    raise RuntimeError(f'{code}/{rel}: {last}')


def guide_problems(src: str, out: str) -> str:
    import yaml
    try:
        fa = yaml.safe_load(src.split('---', 2)[1])
        fb = yaml.safe_load(out.split('---', 2)[1])
    except Exception as e:  # noqa: BLE001
        return f'frontmatter YAML invalid: {e}'
    errs = []
    for k in ('section', 'order', 'updated', 'sources', 'relatedGames', 'related', 'health'):
        if fa.get(k) != fb.get(k):
            errs.append(f'{k} changed')
    if str(fb.get('translatedFrom')) != str(fa['updated']):
        errs.append('translatedFrom wrong')
    for k in ('keyPoints', 'faq'):
        if len(fa.get(k, [])) != len(fb.get(k, [])):
            errs.append(f'{k} count differs')
    link = re.compile(r'\]\(([^)\s]+)[^)]*\)|href="([^"]+)"')
    ba, bb = src.split('---', 2)[2], out.split('---', 2)[2]
    if [a or b for a, b in link.findall(ba)] != [a or b for a, b in link.findall(bb)]:
        errs.append('link targets differ or reordered')
    h = re.compile(r'^(#{2,6})\s', re.M)
    if h.findall(ba) != h.findall(bb):
        errs.append('heading levels differ')
    return '; '.join(errs)


# ---------------------------------------------------------------- orchestration

def json_done(kind: str, code: str) -> bool:
    p = I18N / kind / f'{code}.json'
    if not p.exists():
        return False
    if kind == 'play':
        return True
    en = json.loads((I18N / kind / 'en.json').read_text())
    try:
        t = json.loads(p.read_text())
    except Exception:  # noqa: BLE001
        return False
    es, ts = [v for _, v in units(en) if isinstance(v, str) and len(v) > 3], []
    for path, v in units(en):
        if isinstance(v, str) and len(v) > 3:
            try:
                ts.append(get_path(t, path) == v)
            except Exception:  # noqa: BLE001
                ts.append(True)
    return sum(ts) / max(1, len(ts)) < 0.3


def pending(kinds, codes):
    todo = []
    rels = [str(p.relative_to(GUIDES)) for p in sorted(GUIDES.glob('**/*.md'))]
    for code in codes:
        for k in kinds:
            if k == 'guides':
                todo += [('guides', code, r) for r in rels if not guide_done(code, r)]
            elif not json_done(k, code):
                todo.append((k, code, None))
    return todo


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('cmd', choices=['status', 'run'])
    ap.add_argument('--kinds', default='ui,games,play,guides')
    ap.add_argument('--langs', default='')
    ap.add_argument('--jobs', type=int, default=5, help='parallel tasks, capped at 5')
    ap.add_argument('--limit', type=int, default=0)
    a = ap.parse_args()
    meta = locale_codes()
    codes = [c for c in (a.langs.split(',') if a.langs else [l['code'] for l in languages() if l['code'] in meta]) if c != 'en' and c in meta]
    kinds = a.kinds.split(',')
    todo = pending(kinds, codes)
    by = {}
    for k, c, r in todo:
        by.setdefault(k, set()).add(c)
    print({k: (len(v), sum(1 for t in todo if t[0] == k)) for k, v in by.items()}, 'languages/tasks; total tasks', len(todo))
    if a.cmd == 'status':
        return
    if a.limit:
        todo = todo[:a.limit]
    cats = {}

    def work(t):
        k, c, r = t
        lang = {'code': c, 'english': meta[c]['english'], 'native': meta[c]['native']}
        if k == 'guides':
            return t, translate_guide(lang, r)
        with lock:
            if c not in cats:
                cats[c] = plural_cats(meta[c]['bcp47'])
        return t, str(translate_json(k, lang, cats[c]))

    done = 0
    with ThreadPoolExecutor(min(a.jobs, MAX_JOBS)) as ex:
        futs = [ex.submit(work, t) for t in todo]
        for f in as_completed(futs):
            try:
                t, p = f.result()
                done += 1
                print(f'[{done}/{len(todo)}] ok {t[0]} {t[1]} {t[2] or ""}', flush=True)
            except Exception as e:  # noqa: BLE001
                print('FAIL', str(e)[:200], flush=True)


if __name__ == '__main__':
    main()
