"""Regression tests for translation backend failures in site/scripts/agy_translate.py."""

import importlib.util
import io
import tempfile
from pathlib import Path
import unittest
from unittest.mock import patch


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
            self.assertEqual(agy_translate.BACKENDS, ['iceman', 'dsfree', 'glmfree'])
            self.assertEqual(agy_translate.FALLBACKS, [])
            self.assertEqual(agy_translate.ALL_BACKENDS, ['iceman', 'dsfree', 'glmfree'])
        finally:
            (
                agy_translate.BACKENDS,
                agy_translate.FALLBACKS,
                agy_translate.ALL_BACKENDS,
            ) = original

    def test_guide_validation_rejects_emergency_numbers_absent_from_source(self) -> None:
        source = '''---
section: caregiving
order: 1
updated: 2026-11-12
sources: []
relatedGames: []
related: []
health: true
keyPoints: []
faq: []
---
Contact local urgent medical services on 2021.
'''
        translated = '''---
section: caregiving
order: 1
updated: 2026-11-12
translatedFrom: 2026-11-12
sources: []
relatedGames: []
related: []
health: true
keyPoints: []
faq: []
---
Contact local urgent medical services on 2021 at 112.
'''
        problems = agy_translate.guide_problems(source, translated)
        self.assertIn('numbers added that are absent from the English source', problems)

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
