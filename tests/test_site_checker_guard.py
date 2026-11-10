"""Keep unreviewed translated claims visible to the site checker."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class SiteCheckerGuardTests(unittest.TestCase):
    def test_native_review_pending_pages_are_scanned_as_warnings(self):
        checker = (ROOT / "site/scripts/check-site.mjs").read_text(encoding="utf-8")

        self.assertIn("for (const re of BANNED)", checker)
        self.assertIn("CLAIMS_REVIEW_PENDING.has(rel) ? warn : err", checker)
        self.assertNotIn("CLAIMS_REVIEW_PENDING.has(rel) ? [] : BANNED", checker)


if __name__ == "__main__":
    unittest.main()
