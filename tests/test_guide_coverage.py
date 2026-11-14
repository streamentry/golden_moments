"""Tests for the changed-English-guide localization gate."""

import importlib.util
import subprocess
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "site/scripts/check-guide-coverage.py"
SPEC = importlib.util.spec_from_file_location("guide_coverage", MODULE_PATH)
guide_coverage = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(guide_coverage)


class FakeChecker:
    def check(self, code: str, slug: str):
        if code == "vi":
            return ["numbers added without an explicit emergency number in English"], []
        return [], ["description outside preferred width"]


class GuideCoverageTests(unittest.TestCase):
    def test_only_english_markdown_guides_are_selected(self) -> None:
        paths = [
            "site/src/content/guides/caregiving/new-guide.md",
            "site/src/content/guides/activities/another-guide.md",
            "site/src/content/guides-i18n/vi/caregiving/new-guide.md",
            "site/src/i18n/games/en.json",
            "site/src/content/guides/caregiving/ignored.mdx",
        ]
        self.assertEqual(
            guide_coverage.guide_slugs(paths),
            ["activities/another-guide", "caregiving/new-guide"],
        )

    def test_required_locales_cover_registry_and_active_route_variants(self) -> None:
        locales = guide_coverage.required_locales(ROOT)
        self.assertEqual(len(locales), 189)
        self.assertNotIn("en", locales)
        self.assertIn("azb", locales)
        self.assertIn("fil", locales)
        self.assertIn("pt-BR", locales)
        self.assertIn("pt-PT", locales)
        self.assertIn("zh-Hans", locales)
        self.assertIn("zh-Hant", locales)

    def test_validator_checks_each_changed_guide_in_each_locale(self) -> None:
        errors, warnings = guide_coverage.validate_translations(
            ROOT,
            ["caregiving/one", "caregiving/two"],
            ["fr", "vi"],
            FakeChecker(),
        )
        self.assertEqual(
            errors,
            [
                "vi/caregiving/one: numbers added without an explicit emergency number in English",
                "vi/caregiving/two: numbers added without an explicit emergency number in English",
            ],
        )
        self.assertEqual(warnings, 2)

    def test_git_diff_uses_the_supplied_base_and_head(self) -> None:
        completed = subprocess.CompletedProcess(
            args=["git", "diff"],
            returncode=0,
            stdout="site/src/content/guides/caregiving/new-guide.md\n",
            stderr="",
        )
        with patch.object(guide_coverage.subprocess, "run", return_value=completed) as run:
            paths = guide_coverage.changed_paths(ROOT, "base-sha", "head-sha")

        self.assertEqual(paths, ["site/src/content/guides/caregiving/new-guide.md"])
        self.assertEqual(run.call_args.args[0][-2:], ["base-sha", "head-sha"])


if __name__ == "__main__":
    unittest.main()
