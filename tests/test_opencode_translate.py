import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import opencode_translate as translator  # noqa: E402


class GuideGapReportTests(unittest.TestCase):
    def test_absent_directory_and_english_copy_are_reported(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            site = root / 'site'
            locales = site / 'src/i18n/locales.ts'
            locales.parent.mkdir(parents=True)
            locales.write_text(
                "export const LOCALES = [\n"
                "  { code: 'en', prefix: '', bcp47: 'en', htmlLang: 'en-US', og: 'en_US', name: 'English', englishName: 'English', dir: 'ltr' },\n"
                "  { code: 'an', prefix: 'an', bcp47: 'an', htmlLang: 'an', og: 'an_ES', name: 'Aragonés', englishName: 'Aragonese', dir: 'ltr' },\n"
                "  { code: 'ba', prefix: 'ba', bcp47: 'ba', htmlLang: 'ba', og: 'ba_RU', name: 'Башҡорт теле', englishName: 'Bashkir', dir: 'ltr' },\n"
                "];\n"
                "// Example in documentation, not a registry entry: code: 'an'\n",
                encoding='utf-8',
            )
            guides = site / 'src/content/guides'
            source = guides / 'activities/alzheimers.md'
            source.parent.mkdir(parents=True)
            body = 'This source sentence is long enough to compare against a copy.'
            source.write_text(f'---\ntitle: English\n---\n{body}\n', encoding='utf-8')
            guides_i18n = site / 'src/content/guides-i18n'
            english_copy = guides_i18n / 'an/activities/alzheimers.md'
            english_copy.parent.mkdir(parents=True)
            english_copy.write_text(f'---\ntitle: Aragonese\n---\n{body}\n', encoding='utf-8')

            with (
                patch.object(translator, 'SITE', site),
                patch.object(translator, 'GUIDES', guides),
                patch.object(translator, 'GUIDES_I18N', guides_i18n),
            ):
                self.assertEqual(
                    translator.guide_gap_rows(),
                    [('an', 1), ('ba', 1)],
                )


if __name__ == '__main__':
    unittest.main()
