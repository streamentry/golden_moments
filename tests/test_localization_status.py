"""Per-language native-review status is recorded and consistent (GM-036)."""
import json
from pathlib import Path
import unittest

from scripts import store_locales

ROOT = Path(__file__).resolve().parents[1]
STATUS = json.loads((ROOT / 'docs/specs/release-status.json').read_text(
    encoding='utf-8'))
LOCALIZATION = STATUS.get('localization', {})
LANGUAGES = LOCALIZATION.get('languages', {})


class LocalizationStatusTests(unittest.TestCase):
    def test_every_translated_language_has_an_entry(self):
        self.assertEqual(sorted(LANGUAGES), sorted(store_locales.LANGUAGES))

    def test_status_is_unreviewed_or_reviewed(self):
        for code, entry in LANGUAGES.items():
            with self.subTest(language=code):
                self.assertIn(entry.get('status'), ('unreviewed', 'reviewed'))

    def test_reviewed_needs_a_reviewer_and_evidence(self):
        for code, entry in LANGUAGES.items():
            with self.subTest(language=code):
                if entry.get('status') == 'reviewed':
                    self.assertTrue(entry.get('reviewer'), 'name the reviewer')
                    self.assertTrue(entry.get('evidence'), 'link the evidence')
                    self.assertTrue(entry.get('date'), 'record the date')
                else:
                    self.assertIsNone(entry.get('reviewer'))

    def test_store_listing_review_field_matches(self):
        for code, entry in LANGUAGES.items():
            listing = store_locales.path_for(code)
            if not listing.exists():
                continue
            with self.subTest(language=code):
                data = json.loads(listing.read_text(encoding='utf-8'))
                self.assertEqual(data.get('review'), entry.get('status'))

    def test_a_meaning_is_written_down(self):
        self.assertTrue(LOCALIZATION.get('meaning'))
        self.assertTrue(LOCALIZATION.get('decision'))


if __name__ == '__main__':
    unittest.main()
