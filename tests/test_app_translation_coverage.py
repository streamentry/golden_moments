"""Tests for the changed-app-copy translation coverage gate."""

import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "scripts/check_app_translation_coverage.py"
SPEC = importlib.util.spec_from_file_location("app_translation_coverage", MODULE_PATH)
coverage = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(coverage)


class AppTranslationCoverageTests(unittest.TestCase):
    def test_registry_has_185_unique_codes_including_english(self) -> None:
        codes = coverage.language_codes(ROOT / "docs/languages.csv")
        self.assertEqual(len(codes), 185)
        self.assertEqual(len(set(codes)), 185)
        self.assertIn("en", codes)

    def test_registry_code_maps_to_arb_filename(self) -> None:
        self.assertEqual(
            coverage.arb_path("pt-PT"),
            Path("lib/l10n/arb/app_pt_PT.arb"),
        )

    def test_changed_message_keys_ignore_arb_metadata(self) -> None:
        before = {"@@locale": "en", "@title": {"description": "title"}, "title": "Title"}
        after = {"@@locale": "en", "@title": {"description": "new note"}, "title": "A title"}
        self.assertEqual(coverage.changed_message_keys(before, after), {"title"})

    def test_translation_only_change_to_unknown_key_is_not_silently_ignored(self) -> None:
        self.assertEqual(
            coverage.orphaned_translation_keys({"unregistered"}, {"title"}, {"title"}),
            {"unregistered"},
        )

    def test_removed_english_key_does_not_require_translation_coverage(self) -> None:
        self.assertEqual(
            coverage.orphaned_translation_keys({"oldLabel"}, {"oldLabel"}, set()),
            set(),
        )

    def test_changed_english_copy_requires_all_185_arb_files(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            docs = root / "docs"
            docs.mkdir()
            codes = ["en", *[f"l{i:03}" for i in range(1, 185)]]
            (docs / "languages.csv").write_text(
                "Locale code,Language name\n"
                + "".join(f"{code},Language {code}\n" for code in codes),
                encoding="utf-8",
            )
            for code in codes:
                path = root / coverage.arb_path(code)
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(
                    json.dumps({"@@locale": code, "newLabel": "Translated"}),
                    encoding="utf-8",
                )

            def fake_load(_root: Path, revision: str, _path: Path):
                value = "Old label" if revision == "base" else "New label"
                return {"@@locale": "en", "newLabel": value}

            with (
                patch.object(coverage, "changed_arb_paths", return_value=[coverage.arb_path("en")]),
                patch.object(coverage, "load_arb_at", side_effect=fake_load),
            ):
                changed, errors = coverage.check_changed_copy(root, "base", "head")

            self.assertEqual(changed, {"newLabel"})
            self.assertEqual(errors, [])
            (root / coverage.arb_path("l001")).unlink()
            with (
                patch.object(coverage, "changed_arb_paths", return_value=[coverage.arb_path("en")]),
                patch.object(coverage, "load_arb_at", side_effect=fake_load),
            ):
                _, errors = coverage.check_changed_copy(root, "base", "head")

        self.assertEqual(len(errors), 1)
        self.assertIn("l001: missing", errors[0])

    def test_missing_english_source_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            docs = root / "docs"
            docs.mkdir()
            codes = ["en", *[f"l{i:03}" for i in range(1, 185)]]
            (docs / "languages.csv").write_text(
                "Locale code,Language name\n"
                + "".join(f"{code},Language {code}\n" for code in codes),
                encoding="utf-8",
            )
            with (
                patch.object(coverage, "changed_arb_paths", return_value=[coverage.arb_path("en")]),
                patch.object(coverage, "load_arb_at", return_value=None),
            ):
                changed, errors = coverage.check_changed_copy(root, "base", "head")

        self.assertEqual(changed, set())
        self.assertEqual(len(errors), 2)
        self.assertIn("English source is missing", errors[1])

    def test_missing_locale_file_is_reported_for_changed_copy(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / coverage.arb_path("en")
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps({"@@locale": "en", "newLabel": "New label"}), encoding="utf-8")

            errors = coverage.missing_copies(root, ["en", "fr"], {"newLabel"})

        self.assertEqual(len(errors), 1)
        self.assertIn("fr: missing lib/l10n/arb/app_fr.arb", errors[0])

    def test_empty_copy_is_reported(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for code, value in (("en", "New label"), ("fr", " ")):
                path = root / coverage.arb_path(code)
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(
                    json.dumps({"@@locale": code, "newLabel": value}),
                    encoding="utf-8",
                )

            errors = coverage.missing_copies(root, ["en", "fr"], {"newLabel"})

        self.assertEqual(len(errors), 1)
        self.assertIn("fr: 1 changed keys missing or empty: newLabel", errors[0])

    def test_changed_paths_use_the_supplied_base_and_head(self) -> None:
        completed = subprocess.CompletedProcess(
            args=["git", "diff"],
            returncode=0,
            stdout="lib/l10n/arb/app_en.arb\nlib/l10n/arb/app_fr.arb\nsite/src/i18n/ui/fr.json\n",
            stderr="",
        )
        with patch.object(coverage.subprocess, "run", return_value=completed) as run:
            paths = coverage.changed_arb_paths(ROOT, "base-sha", "head-sha")

        self.assertEqual(
            paths,
            [Path("lib/l10n/arb/app_en.arb"), Path("lib/l10n/arb/app_fr.arb")],
        )
        self.assertEqual(run.call_args.args[0][4], "base-sha...head-sha")


if __name__ == "__main__":
    unittest.main()
