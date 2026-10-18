import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('release_metadata', ROOT / 'scripts/release_metadata.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class MetadataTests(unittest.TestCase):
    def setUp(self):
        self.data = json.loads((ROOT / 'metadata/app-store.en-US.json').read_text())
        self.status = json.loads((ROOT / 'docs/specs/release-status.json').read_text())

    def test_current_copy_fits(self):
        self.assertEqual(module.validate(self.data, self.status), [])
        self.assertEqual(len(self.data['name']), 30)
        self.assertEqual(len(self.data['subtitle']), 28)

    def test_title_limit(self):
        self.data['name'] += '!'
        self.assertTrue(module.validate(self.data, self.status))

    def test_keyword_limit_is_bytes_not_characters(self):
        self.data['keywords'] = '\u00e9' * 51
        self.assertTrue(any('bytes' in e for e in module.validate(self.data, self.status)))

    def test_keywords_cannot_repeat_visible_terms(self):
        self.data['keywords'] = 'dementia,photo'
        self.assertTrue(any('repeats' in e for e in module.validate(self.data, self.status)))

    def test_unsupported_claim_rejected(self):
        self.data['promotional_text'] = 'Clinically proven. Improves memory.'
        self.assertTrue(any('claim' in e for e in module.validate(self.data, self.status)))

    def test_screenshot_claim_rejected(self):
        self.data['screenshots'][0]['headline'] = 'Improves memory'
        self.assertTrue(any('claim' in e for e in module.validate(self.data, self.status)))

    def test_screenshots_require_known_features(self):
        self.data['screenshots'][0]['requires'] = ['automatic_family_sync']
        self.assertTrue(any('unknown feature' in e for e in module.validate(self.data, self.status)))

    def test_release_cannot_pass_pending_evidence(self):
        errors = module.validate(self.data, self.status, release=True)
        self.assertTrue(any('not verified' in e for e in errors))
        self.assertTrue(any('not evidenced' in e for e in errors))
        self.assertTrue(any('missing iphone' in e for e in errors))

    def test_deleting_gates_does_not_bypass_release(self):
        self.status['gates'] = {}
        errors = module.validate(self.data, self.status, release=True)
        self.assertTrue(any('ios_archive' in e for e in errors))

    def test_exported_copy_matches_source(self):
        for field, filename in module.EXPORTS.items():
            self.assertEqual((ROOT / 'metadata/en-US' / filename).read_text(), self.data[field] + '\n')

    def test_google_play_copy_fits_and_matches_exports(self):
        data = json.loads(module.GOOGLE_SOURCE.read_text())
        for field, limit in {'name': 30, 'short_description': 80,
                             'full_description': 4000, 'release_notes': 500}.items():
            self.assertTrue(data[field].strip())
            self.assertLessEqual(len(data[field]), limit)
            self.assertEqual((ROOT / 'metadata/google-play/en-US' /
                              (field + '.txt')).read_text(), data[field] + '\n')
        self.assertEqual(data['name'], self.data['name'])
        self.assertEqual(data['full_description'], self.data['description'])


if __name__ == '__main__':
    unittest.main()
