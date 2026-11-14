"""Safety tests for translated-guide structure and numeric facts."""

import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).with_name("check-guide-translation.py")
SPEC = importlib.util.spec_from_file_location("guide_translation", SCRIPT)
guide_translation = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(guide_translation)


class GuideTranslationNumberTests(unittest.TestCase):
    def test_rejects_an_emergency_number_absent_from_english(self) -> None:
        self.assertTrue(
            guide_translation.unsafe_number_additions(
                "Contact local urgent services.",
                "Contact local urgent services at 112.",
            )
        )

    def test_allows_localizing_an_explicit_emergency_number(self) -> None:
        self.assertFalse(
            guide_translation.unsafe_number_additions(
                "Call 911 if there is immediate danger.",
                "Call 112 if there is immediate danger.",
            )
        )

    def test_rejects_adding_a_number_even_when_english_has_a_year(self) -> None:
        self.assertTrue(
            guide_translation.unsafe_number_additions(
                "This guide was updated in 2021; contact local urgent services.",
                "This guide was updated in 2021; call local urgent services at 112.",
            )
        )

    def test_ignores_numbers_hidden_in_markdown_link_targets(self) -> None:
        self.assertFalse(
            guide_translation.unsafe_number_additions(
                "See [local contacts](https://example.org/112).",
                "See [local contacts](https://example.org/911).",
            )
        )

    def test_normalizes_localized_decimal_digits(self) -> None:
        self.assertFalse(
            guide_translation.unsafe_number_additions(
                "Call 112.",
                "اتصل ١١٢.",
            )
        )

    def test_frontmatter_copy_is_part_of_the_visible_text(self) -> None:
        source = {"description": "Ask local services for urgent help."}
        translated = {"description": "Call local urgent services at 112."}
        source_copy = guide_translation.visible_copy(source, "")
        translated_copy = guide_translation.visible_copy(translated, "")
        self.assertTrue(
            guide_translation.unsafe_number_additions(source_copy, translated_copy)
        )

    def test_missing_translation_is_a_hard_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / "site/src/content/guides/caregiving/example.md"
            source.parent.mkdir(parents=True)
            source.write_text("---\ntitle: Example\n---\nBody\n", encoding="utf-8")

            with (
                patch.object(guide_translation, "SITE", root / "site"),
                patch.object(guide_translation, "SOURCE", root / "site/src/content/guides"),
                patch.object(guide_translation, "TRANSLATED", root / "site/src/content/guides-i18n"),
            ):
                errors, warnings = guide_translation.check("fr", "caregiving/example")

        self.assertFalse(warnings)
        self.assertEqual(len(errors), 1)
        self.assertIn("missing src/content/guides-i18n/fr/caregiving/example.md", errors[0])

    def test_check_rejects_number_added_to_translated_description(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / "guides/caregiving/example.md"
            translated = root / "guides-i18n/fr/caregiving/example.md"
            source.parent.mkdir(parents=True)
            translated.parent.mkdir(parents=True)
            english = """---
title: "Shared activity"
seoTitle: "Shared activity"
description: "A calm guide to choosing a comfortable activity together."
section: caregiving
order: 1
updated: 2026-11-12
published: 2026-11-12
sources: []
relatedGames: []
related: []
health: false
summary: "A practical guide to choosing one comfortable shared activity."
keyPoints:
  - "Start with one familiar activity."
faq: []
---
## Getting started
Ask which activity feels comfortable.
"""
            french = english.replace(
                'description: "A calm guide to choosing a comfortable activity together."',
                'description: "Call local urgent services at 112 for help with an activity."',
            ).replace(
                "updated: 2026-11-12\n",
                "updated: 2026-11-12\ntranslatedFrom: 2026-11-12\n",
            )
            source.write_text(english, encoding="utf-8")
            translated.write_text(french, encoding="utf-8")

            with (
                patch.object(guide_translation, "SOURCE", root / "guides"),
                patch.object(guide_translation, "TRANSLATED", root / "guides-i18n"),
            ):
                errors, _ = guide_translation.check("fr", "caregiving/example")

        self.assertIn(
            "numbers added without an explicit emergency number in English",
            errors,
        )


if __name__ == "__main__":
    unittest.main()
