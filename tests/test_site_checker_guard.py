"""Keep claim and translated-description checks active on the generated site."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class SiteCheckerGuardTests(unittest.TestCase):
    def test_native_review_pending_pages_are_scanned_as_warnings(self):
        checker = (ROOT / "site/scripts/check-site.mjs").read_text(encoding="utf-8")

        self.assertIn("for (const re of BANNED)", checker)
        self.assertIn("CLAIMS_REVIEW_PENDING.has(rel) ? warn : err", checker)
        self.assertNotIn("CLAIMS_REVIEW_PENDING.has(rel) ? [] : BANNED", checker)

    def test_translated_meta_descriptions_have_hard_outer_bounds(self):
        checker = (ROOT / "site/scripts/check-site.mjs").read_text(encoding="utf-8")

        self.assertIn("if (!desc.trim()) err(rel, 'missing meta description')", checker)
        self.assertIn("descriptionWidth < 50 || descriptionWidth > 360", checker)
        self.assertIn("descriptionWidth < 70 || descriptionWidth > 170", checker)


if __name__ == "__main__":
    unittest.main()
