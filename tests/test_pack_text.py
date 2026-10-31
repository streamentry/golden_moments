"""Picture-pack text overlays stay in step with the index (GM-036)."""
import json
from pathlib import Path
import unittest

from scripts import pack_text

ROOT = Path(__file__).resolve().parents[1]
INDEX = json.loads((ROOT / 'assets/data/packs_index.json').read_text(
    encoding='utf-8'))


class PackTextTests(unittest.TestCase):
    def test_repository_overlays_pass_the_check(self):
        self.assertEqual(pack_text.check(), [])

    def test_english_source_matches_the_index_exactly(self):
        source = json.loads(pack_text.overlay_path('en').read_text(
            encoding='utf-8'))
        self.assertEqual(
            list(source['categories']), [c['id'] for c in INDEX['categories']])
        for category in INDEX['categories']:
            entry = source['categories'][category['id']]
            self.assertEqual(entry['name'], category['name'])
            self.assertEqual(entry['description'], category['description'])
        self.assertEqual(list(source['packs']), [p['id'] for p in INDEX['packs']])
        for pack in INDEX['packs']:
            entry = source['packs'][pack['id']]
            for field in ('title', 'description', 'theme'):
                self.assertEqual(entry[field], pack[field], pack['id'])
            self.assertEqual(
                entry['images'],
                {image['id']: image['caption'] for image in pack['images']})

    def test_every_app_language_has_an_overlay_registered_as_an_asset(self):
        pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
        self.assertIn('- assets/data/i18n/', pubspec)
        for locale in pack_text.LOCALES:
            self.assertTrue(pack_text.overlay_path(locale).is_file(), locale)

    def test_valid_partial_translation_has_no_errors(self):
        overlay = {
            'categories': {'animals': {'name': 'Animales'}},
            'packs': {'animals_farm': {'images': {'cow_1': 'Vaca'}}},
        }
        self.assertEqual(pack_text.overlay_errors(overlay, INDEX), [])

    def test_unknown_ids_and_wrong_types_are_reported(self):
        overlay = {
            'categories': {'nope': {'name': 3}},
            'packs': {
                'animals_farm': {'title': ['x'], 'colour': 'red',
                                 'images': {'zebra_9': 'Zebra'}},
                'ghost': {},
            },
            'extra': {},
        }
        errors = pack_text.overlay_errors(overlay, INDEX)
        for fragment in ("unknown top-level keys: ['extra']",
                         'categories.nope: no such category',
                         'categories.nope.name must be text',
                         'packs.animals_farm.title must be text',
                         "packs.animals_farm: unknown field 'colour'",
                         'packs.animals_farm.images.zebra_9: no such picture',
                         'packs.ghost: no such pack'):
            self.assertTrue(any(fragment in e for e in errors), fragment)
        self.assertEqual(pack_text.overlay_errors([], INDEX),
                         ['top level must be an object'])


if __name__ == '__main__':
    unittest.main()
