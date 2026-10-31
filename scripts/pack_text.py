#!/usr/bin/env python3
"""Picture-pack text per language: the English source and translator overlays.

``assets/data/packs_index.json`` holds the English names, descriptions, themes
and picture captions. Each app language has an overlay at
``assets/data/i18n/packs_<locale>.json`` with the same ids and translated text:

    {"categories": {"<id>": {"name": "...", "description": "..."}},
     "packs": {"<id>": {"title": "...", "description": "...", "theme": "...",
                        "images": {"<imageId>": "<caption>"}}}}

Anything left out shows in English. ``packs_en.json`` is generated from the
index and is the file translators copy.

    python3 scripts/pack_text.py           # regenerate packs_en.json and add
                                           # empty overlays for new languages
    python3 scripts/pack_text.py --check   # fail on drift or a bad overlay
"""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / 'assets/data/packs_index.json'
OVERLAYS = ROOT / 'assets/data/i18n'
ARB = ROOT / 'lib/l10n/arb'

# App languages, named as the ARB files name them. The base ``pt`` and ``zh``
# ARBs exist only because the generator needs them; the app never selects them.
LOCALES = (
    'en', 'es', 'pt_BR', 'fr', 'de', 'it', 'nl', 'pl', 'ru', 'uk', 'tr', 'ar',
    'hi', 'ja', 'ko', 'zh_Hans', 'zh_Hant', 'vi', 'id', 'th',
)
GENERATOR_ONLY_ARBS = ('pt', 'zh')
CATEGORY_FIELDS = ('name', 'description')
PACK_FIELDS = ('title', 'description', 'theme')


def overlay_path(locale, root=ROOT):
    return root / 'assets/data/i18n' / f'packs_{locale}.json'


def english_source(index):
    """The overlay that reproduces the index's English text exactly."""
    categories = {}
    for category in index['categories']:
        categories[category['id']] = {
            field: category[field] for field in CATEGORY_FIELDS
            if isinstance(category.get(field), str)
        }
    packs = {}
    for pack in index['packs']:
        entry = {
            field: pack[field] for field in PACK_FIELDS
            if isinstance(pack.get(field), str)
        }
        entry['images'] = {
            image['id']: image['caption'] for image in pack.get('images', [])
            if isinstance(image.get('caption'), str)
        }
        packs[pack['id']] = entry
    return {'categories': categories, 'packs': packs}


def dumps(value):
    return json.dumps(value, ensure_ascii=False, indent=2) + '\n'


def overlay_errors(overlay, index):
    """Problems a translator must fix; the app ignores them but shows English."""
    errors = []
    if not isinstance(overlay, dict):
        return ['top level must be an object']
    unknown = set(overlay) - {'categories', 'packs'}
    if unknown:
        errors.append(f'unknown top-level keys: {sorted(unknown)}')
    known_categories = {c['id'] for c in index['categories']}
    packs_by_id = {p['id']: p for p in index['packs']}

    categories = overlay.get('categories', {})
    if not isinstance(categories, dict):
        errors.append('categories must be an object')
        categories = {}
    for category_id, entry in categories.items():
        where = f'categories.{category_id}'
        if category_id not in known_categories:
            errors.append(f'{where}: no such category in the index')
        errors += _field_errors(where, entry, CATEGORY_FIELDS)

    packs = overlay.get('packs', {})
    if not isinstance(packs, dict):
        errors.append('packs must be an object')
        packs = {}
    for pack_id, entry in packs.items():
        where = f'packs.{pack_id}'
        pack = packs_by_id.get(pack_id)
        if pack is None:
            errors.append(f'{where}: no such pack in the index')
        errors += _field_errors(where, entry, PACK_FIELDS + ('images',))
        images = entry.get('images', {}) if isinstance(entry, dict) else {}
        if not isinstance(images, dict):
            errors.append(f'{where}.images must be an object')
            continue
        image_ids = {i['id'] for i in pack.get('images', [])} if pack else set()
        for image_id, caption in images.items():
            if pack is not None and image_id not in image_ids:
                errors.append(f'{where}.images.{image_id}: no such picture')
            if not isinstance(caption, str):
                errors.append(f'{where}.images.{image_id} must be text')
    return errors


def _field_errors(where, entry, allowed):
    if not isinstance(entry, dict):
        return [f'{where} must be an object']
    errors = [f'{where}: unknown field {key!r}' for key in entry
              if key not in allowed]
    errors += [f'{where}.{key} must be text' for key, value in entry.items()
               if key in allowed and key != 'images'
               and not isinstance(value, str)]
    return errors


def check(root=ROOT):
    index = json.loads((root / 'assets/data/packs_index.json').read_text(
        encoding='utf-8'))
    errors = []
    arbs = {p.stem.removeprefix('app_')
            for p in (root / 'lib/l10n/arb').glob('app_*.arb')}
    if arbs != set(LOCALES) | set(GENERATOR_ONLY_ARBS):
        errors.append(f'ARB languages {sorted(arbs)} differ from LOCALES')
    english = overlay_path('en', root)
    if not english.is_file() or english.read_text(encoding='utf-8') != dumps(
            english_source(index)):
        errors.append('packs_en.json is out of date: run scripts/pack_text.py')
    for locale in LOCALES:
        path = overlay_path(locale, root)
        if not path.is_file():
            errors.append(f'{path.name} is missing')
            continue
        try:
            overlay = json.loads(path.read_text(encoding='utf-8'))
        except ValueError as error:
            errors.append(f'{path.name}: not valid JSON ({error})')
            continue
        errors += [f'{path.name}: {e}' for e in overlay_errors(overlay, index)]
    return errors


def generate(root=ROOT):
    index = json.loads((root / 'assets/data/packs_index.json').read_text(
        encoding='utf-8'))
    (root / 'assets/data/i18n').mkdir(parents=True, exist_ok=True)
    overlay_path('en', root).write_text(dumps(english_source(index)),
                                        encoding='utf-8')
    for locale in LOCALES:
        path = overlay_path(locale, root)
        if not path.exists():  # Never overwrite a translation.
            path.write_text(dumps({'categories': {}, 'packs': {}}),
                            encoding='utf-8')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('--check', action='store_true',
                        help='report drift or invalid overlays; change nothing')
    args = parser.parse_args(argv)
    if not args.check:
        generate()
    errors = check()
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
