import hashlib
import json
from pathlib import Path
import unittest
from unittest import mock

from scripts import validate_packs

ROOT = Path(__file__).resolve().parents[1]


def strings(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from strings(child)
    elif isinstance(value, str):
        yield value


class BundledCatalogTests(unittest.TestCase):
    def test_catalog_has_only_local_images_and_complete_provenance(self):
        catalog = json.loads((ROOT / 'assets/data/packs_index.json').read_text())
        sources = json.loads((ROOT / 'docs/catalog-image-sources.json').read_text())['images']
        references = {value for value in strings(catalog) if value.startswith(('assets/', 'http'))}
        self.assertEqual(len(references), 121)
        self.assertEqual(references, {entry['asset'] for entry in sources})
        for entry in sources:
            with self.subTest(asset=entry['asset']):
                self.assertTrue(entry['asset'].startswith('assets/images/catalog/'))
                data = (ROOT / entry['asset']).read_bytes()
                self.assertEqual(len(data), entry['bytes'])
                self.assertEqual(hashlib.sha256(data).hexdigest(), entry['sha256'])
                self.assertTrue(entry['source'].startswith('https://images.unsplash.com/'))


    def test_local_validation_needs_no_http_library(self):
        catalog = json.loads((ROOT / 'assets/data/packs_index.json').read_text())
        with mock.patch.object(validate_packs, 'HAS_REQUESTS', False):
            self.assertEqual(validate_packs.check_image_urls(catalog, True), [])
            catalog['packs'][0]['thumbnailUrl'] = 'assets/images/catalog/missing.jpg'
            self.assertTrue(validate_packs.check_image_urls(catalog, True))


if __name__ == '__main__':
    unittest.main()
