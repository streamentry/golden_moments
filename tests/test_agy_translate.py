"""Regression tests for translation backend failures in site/scripts/agy_translate.py."""

import importlib.util
import io
import tempfile
from pathlib import Path
import unittest
from unittest.mock import patch

import yaml


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "site/scripts/agy_translate.py"
SPEC = importlib.util.spec_from_file_location("agy_translate", MODULE_PATH)
agy_translate = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(agy_translate)


class FakeProcess:
    def __init__(self, events: list[dict[str, object]]) -> None:
        self.stdout = io.StringIO("\n".join(agy_translate.json.dumps(event) for event in events))
        self.returncode: int | None = 0

    def kill(self) -> None:
        self.returncode = -9

    def wait(self) -> int:
        return self.returncode or 0

    def poll(self) -> int | None:
        return self.returncode


class AgyTranslateTests(unittest.TestCase):
    def test_free_only_backend_pool_excludes_paid_models(self) -> None:
        original = (
            agy_translate.BACKENDS,
            agy_translate.FALLBACKS,
            agy_translate.ALL_BACKENDS,
        )
        try:
            agy_translate.configure_free_only()
            expected = [
                'iceman', 'dsfree', 'glmfree', 'beamfree', 'flintfree', 'hy4free',
                'icemanfree', 'inklingfree', 'longcatfree', 'mimofree',
                'nemotronfree', 'nemotronvlfree', 'beamgofree', 'hy4gofree', 'longcatgofree',
            ]
            self.assertEqual(agy_translate.BACKENDS, expected)
            self.assertEqual(agy_translate.FALLBACKS, [])
            self.assertEqual(agy_translate.ALL_BACKENDS, expected)
            self.assertTrue(all('free' in agy_translate.MODEL_FOR[backend] for backend in expected))
        finally:
            (
                agy_translate.BACKENDS,
                agy_translate.FALLBACKS,
                agy_translate.ALL_BACKENDS,
            ) = original

    def test_number_validation_rejects_added_values_even_if_source_has_a_year(self) -> None:
        source = 'The guide was published in 2021; contact local urgent services.'
        translated = 'The guide was published in 2021; call local urgent services at 112.'
        self.assertTrue(agy_translate.unsafe_number_additions(source, translated))

    def test_number_feedback_detects_an_invented_day(self) -> None:
        self.assertEqual(
            agy_translate.added_number_values('Since October 2022.', 'Since October 17, 2022.'),
            ['17'],
        )

    def test_site_checker_keeps_locale_date_components_separate(self) -> None:
        self.assertEqual(agy_translate.GUIDE_CHECKER.numbers('October 17, 2022'), ['17', '2022'])
        self.assertEqual(agy_translate.GUIDE_CHECKER.numbers('October 17. 2022'), ['17', '2022'])
        self.assertEqual(agy_translate.GUIDE_CHECKER.numbers('1,000'), ['1000'])
        self.assertEqual(agy_translate.GUIDE_CHECKER.numbers('1 000'), ['1000'])

    def test_site_checker_normalizes_equivalent_clock_formats(self) -> None:
        checker = agy_translate.GUIDE_CHECKER
        self.assertEqual(checker.visible_numbers('Start at 8 a.m.'), ['8', 'clock:0800'])
        self.assertEqual(checker.visible_numbers('Start at 08:00'), ['8', 'clock:0800'])
        self.assertEqual(checker.visible_numbers('Start at 1:00 p.m.'), ['1', '13', 'clock:1300'])
        self.assertEqual(checker.visible_numbers('Start at 13:00'), ['1', '13', 'clock:1300'])
        self.assertFalse(agy_translate.unsafe_number_additions('Start at 1 p.m.', 'Start at 13:00'))
        self.assertFalse(agy_translate.unsafe_number_additions('Start at 4 p.m.', 'Start at 4 nm.'))
        self.assertTrue(agy_translate.unsafe_number_additions('Start at 8 a.m.', 'Start at 8:15'))

    def test_site_checker_matches_daily_routine_times_by_value(self) -> None:
        checker = agy_translate.GUIDE_CHECKER
        source = '| 1:00 p.m. | Lunch |\n| 2:00 p.m. | Walk |'
        translated_24_hour = '| 13:00 | Nahar |\n| 14:00 | Gəzinti |'
        translated_12_hour = '| 1:00 | Nahar |\n| 2:00 | Gəzinti |'
        wrong_time = '| 15:00 | Nahar |\n| 14:00 | Gəzinti |'
        self.assertTrue(checker.daily_routine_times_match(source, translated_24_hour))
        self.assertTrue(checker.daily_routine_times_match(source, translated_12_hour))
        self.assertFalse(checker.daily_routine_times_match(source, wrong_time))

    def test_number_validation_allows_localizing_an_explicit_emergency_number(self) -> None:
        source = 'Call 911 if there is immediate danger.'
        translated = 'Call 112 if there is immediate danger.'
        self.assertFalse(agy_translate.unsafe_number_additions(source, translated))

    def test_number_validation_allows_localizing_an_explicit_crisis_line(self) -> None:
        source = 'Call or text 988 for crisis support.'
        translated = 'Call 116123 for crisis support.'
        self.assertFalse(agy_translate.unsafe_number_additions(source, translated))

    def test_guide_done_uses_site_checker_for_visible_frontmatter_numbers(self) -> None:
        rel = 'activities/alzheimers'
        source_path = agy_translate.GUIDES / f'{rel}.md'
        source_front, body = agy_translate.GUIDE_CHECKER.split(source_path)
        source_front['translatedFrom'] = source_front['updated']
        source_front['description'] = f"{source_front['description']} 987654."
        candidate = (
            '---\n'
            + yaml.safe_dump(source_front, allow_unicode=True, sort_keys=False)
            + '---'
            + body
        )
        with tempfile.TemporaryDirectory() as tmp:
            translated_root = Path(tmp) / 'guides-i18n'
            candidate_path = translated_root / 'ln' / f'{rel}.md'
            candidate_path.parent.mkdir(parents=True)
            candidate += '\n\nTranslated body.\n'
            candidate_path.write_text(candidate, encoding='utf-8')
            with patch.object(agy_translate, 'GUIDES_I18N', translated_root):
                self.assertFalse(agy_translate.guide_done('ln', f'{rel}.md'))

    def test_translation_rules_preserve_source_number_format(self) -> None:
        self.assertIn('Preserve all numeric values from the visible English source.', agy_translate.RULES)
        self.assertIn('Clock notation may be localized between 12-hour and 24-hour formats', agy_translate.RULES)
        self.assertIn('`1:00 p.m.` becomes `13:00`, not `1:00`', agy_translate.RULES)
        self.assertIn('If English writes a number as a word', agy_translate.RULES)
        self.assertIn('Keep the quantity; never turn it into the digit 4', agy_translate.RULES)

    def test_quota_retry_discards_partial_opencode_translation(self) -> None:
        process = FakeProcess(
            [
                {"type": "text", "part": {"text": "partial translation"}},
                {
                    "type": "retry",
                    "error": {"message": "rate limit exceeded"},
                    "timestamp": 0,
                    "nextRetryAt": 5000,
                },
            ]
        )

        with (
            patch.object(agy_translate.subprocess, "Popen", return_value=process),
            patch.object(agy_translate.threading, "Timer"),
        ):
            with self.assertRaises(agy_translate.BackendError) as error:
                agy_translate._run_opencode(["opencode"], str(ROOT), 10)

        self.assertEqual(error.exception.kind, "quota")
        self.assertIn("retry in 5s", str(error.exception))


    def test_language_catalog_has_185_unique_codes_including_south_azerbaijani(self) -> None:
        codes = [language['code'] for language in agy_translate.languages()]
        self.assertEqual(len(codes), 185)
        self.assertEqual(len(set(codes)), 185)
        self.assertIn('en', codes)
        self.assertIn('azb', codes)
        self.assertEqual(codes.count('az'), 1)

    def test_language_catalog_rejects_duplicate_codes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            csv_path = Path(tmp) / 'languages.csv'
            csv_path.write_text(
                'Locale code,639-2/T,639-2/B,Language name,Native name\n'
                'aa,aar,aar,Afar,Afaraf\n'
                'aa,aa,aa,Duplicate,Duplicate\n',
                encoding='utf-8',
            )
            with patch.object(agy_translate, 'CSV', csv_path):
                with self.assertRaisesRegex(ValueError, 'duplicate language code.*aa'):
                    agy_translate.languages()

    def test_pending_can_select_one_guide_by_slug(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            guides = Path(tmp) / 'guides'
            (guides / 'caregiving').mkdir(parents=True)
            (guides / 'caregiving/one.md').write_text('one', encoding='utf-8')
            (guides / 'caregiving/two.md').write_text('two', encoding='utf-8')
            with (
                patch.object(agy_translate, 'GUIDES', guides),
                patch.object(agy_translate, 'guide_done', return_value=False),
            ):
                tasks = agy_translate.pending(['guides'], ['es'], ['caregiving/one'])
            self.assertEqual(tasks, [('guides', 'es', 'caregiving/one.md')])

    def test_pending_skips_finish_the_saying_for_excluded_locales(self) -> None:
        self.assertIn('azb', agy_translate.no_sayings_game_codes())
        with patch.object(agy_translate, 'json_done') as json_done:
            self.assertEqual(agy_translate.pending(['play'], ['azb']), [])
        json_done.assert_not_called()

    def test_guide_selection_rejects_unknown_or_parent_paths(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            guides = Path(tmp) / 'guides'
            (guides / 'caregiving').mkdir(parents=True)
            (guides / 'caregiving/one.md').write_text('one', encoding='utf-8')
            with patch.object(agy_translate, 'GUIDES', guides):
                with self.assertRaisesRegex(ValueError, 'unknown guide path'):
                    agy_translate.guide_paths(['caregiving/missing'])
                with self.assertRaisesRegex(ValueError, 'invalid guide path'):
                    agy_translate.guide_paths(['../secret'])


if __name__ == "__main__":
    unittest.main()
