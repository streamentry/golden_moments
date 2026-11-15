"""Tests for the changed website UI/game dictionary coverage gate."""

import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path, PurePosixPath
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "site/scripts/check-ui-copy-coverage.py"
SPEC = importlib.util.spec_from_file_location("site_ui_copy_coverage", MODULE_PATH)
coverage = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(coverage)


class SiteUiCopyCoverageTests(unittest.TestCase):
    def test_routes_include_english_registry_codes_and_active_variants(self) -> None:
        routes = coverage.required_routes(ROOT)
        self.assertEqual(len(routes), 190)
        self.assertEqual(len(routes), len(set(routes)))
        self.assertIn("en", routes)
        self.assertIn("azb", routes)
        self.assertIn("pt-BR", routes)
        self.assertIn("pt-PT", routes)
        self.assertIn("zh-Hans", routes)
        self.assertIn("zh-Hant", routes)

    def test_flatten_keeps_interface_copy_and_excludes_noncopy_fields(self) -> None:
        data = {
            "_note": "internal",
            "button": {
                "label": "Open",
                "href": "/games/",
                "icon": "door",
                "id": "open",
            },
            "count": {"one": "One item", "other": "{n} items"},
        }
        messages = coverage.fixed_messages(data, "ui")
        self.assertEqual(set(messages), {("button", "label"), ("count",)})

    def test_flatten_skips_native_play_content(self) -> None:
        data = {
            "ui": {"readAloud": "Read aloud"},
            "content": {"sayings": ["A native saying"]},
        }
        self.assertEqual(
            coverage.fixed_messages(data, "play"),
            {("ui", "readAloud"): "Read aloud"},
        )

    def test_changed_strings_preserve_placeholders_html_and_link_targets(self) -> None:
        self.assertEqual(
            coverage.message_shape_errors(
                'Open <a href="/games/">{name}</a>',
                'View <a href="/games/">{name}</a>',
            ),
            [],
        )
        errors = coverage.message_shape_errors(
            'Open <a href="/games/">{name}</a>',
            'View <b href="/activities/">{person}</b>',
        )
        self.assertEqual(len(errors), 3)
        self.assertIn("placeholders differ", errors)
        self.assertIn("HTML tags differ", errors)
        self.assertIn("link targets differ", errors)

    def test_translation_can_reorder_placeholders_and_links(self) -> None:
        self.assertEqual(
            coverage.message_shape_errors(
                '{name} can open <a href="/games/a/">A</a> or <a href="/games/b/">B</a>.',
                '<a href="/games/b/">B</a> ou <a href="/games/a/">A</a> : {name}.',
            ),
            [],
        )

    def test_plural_message_accepts_locale_specific_forms(self) -> None:
        source = {"one": "{n} item", "other": "{n} items"}
        target = {"few": "{n} items", "many": "{n} items", "other": "{n} items"}
        self.assertEqual(coverage.message_shape_errors(source, target), [])

    def test_missing_locale_file_is_reported_for_a_changed_string(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "site/src/i18n/ui/en.json"
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps({"button": "Open"}), encoding="utf-8")
            errors = coverage.missing_copy_errors(
                root,
                "ui",
                ["en", "fr"],
                {("button",)},
                {("button",): "Open"},
            )

        self.assertEqual(len(errors), 1)
        self.assertIn("ui/fr: missing", errors[0])

    def test_changed_paths_use_the_supplied_base_and_head(self) -> None:
        completed = subprocess.CompletedProcess(
            args=["git", "diff"],
            returncode=0,
            stdout=(
                "site/src/i18n/ui/en.json\n"
                "site/src/i18n/games/fr.json\n"
                "site/src/content/guides/caregiving/example.md\n"
            ),
            stderr="",
        )
        with patch.object(coverage.subprocess, "run", return_value=completed) as run:
            files = coverage.changed_i18n_files(ROOT, "base-sha", "head-sha")

        self.assertEqual(
            files,
            [
                PurePosixPath("site/src/i18n/games/fr.json"),
                PurePosixPath("site/src/i18n/ui/en.json"),
            ],
        )
        self.assertEqual(run.call_args.args[0][4], "base-sha...head-sha")

    def test_changed_copy_requires_each_active_route_to_have_the_key(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            subprocess.run(["git", "-C", str(root), "config", "user.name", "Coverage Test"], check=True)
            subprocess.run(
                ["git", "-C", str(root), "config", "user.email", "coverage@example.invalid"],
                check=True,
            )
            english = root / "site/src/i18n/ui/en.json"
            french = root / "site/src/i18n/ui/fr.json"
            english.parent.mkdir(parents=True)
            english.write_text(json.dumps({"button": "Open"}), encoding="utf-8")
            french.write_text(json.dumps({"other": "Autre"}), encoding="utf-8")
            subprocess.run(["git", "-C", str(root), "add", "."], check=True)
            subprocess.run(["git", "-C", str(root), "commit", "-qm", "base"], check=True)
            base = subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()

            english.write_text(json.dumps({"button": "Open now"}), encoding="utf-8")
            subprocess.run(["git", "-C", str(root), "add", "."], check=True)
            subprocess.run(["git", "-C", str(root), "commit", "-qm", "change copy"], check=True)
            head = subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()

            with patch.object(coverage, "required_routes", return_value=["en", "fr"]):
                changed_count, errors = coverage.check_changed_copy(root, base, head)

        self.assertEqual(changed_count, 1)
        self.assertTrue(any("ui/fr" in error and "button" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
