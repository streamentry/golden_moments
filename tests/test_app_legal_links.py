"""Static contract checks; cannot replace real iOS/Android link and privacy audit."""

import json
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class LegalLinksSourceTests(unittest.TestCase):
    def test_offline_privacy_summary_is_discoverable_in_mobile_and_legacy(self):
        page = (ROOT / "lib/features/legal/presentation/legal_info_page.dart").read_text()
        gentle = (ROOT / "lib/features/gentle_activities/presentation/gentle_home_page.dart").read_text()
        legacy = (ROOT / "lib/features/home/presentation/widgets/setting_modal.dart").read_text()
        for x in ("app-privacy/", "privacy-choices/", "terms/", "safety/", "support/"):
            self.assertIn(x, page)
        # The visible words live in the English ARB; the pages use the keys.
        english = json.loads(
            (ROOT / "lib/l10n/arb/app_en.arb").read_text(encoding="utf-8"))
        self.assertEqual(english["commonPrivacyTermsSupport"],
                         "Privacy, terms and support")
        for src in (gentle, legacy):
            self.assertIn("LegalInfoPage", src)
            self.assertIn("l10n.commonPrivacyTermsSupport", src)
        self.assertIn("https://dementiaactivities.games/", page)
        self.assertIn("Clipboard.setData", page)
        self.assertIn("LaunchMode.externalApplication", page)
        self.assertIn("l10n.legalBuiltInPictures", page)
        self.assertTrue(english["legalBuiltInPictures"].endswith(
            "choosing any personal photographs."))

    def test_external_browsing_only_after_explicit_tap(self):
        page = (ROOT / "lib/features/legal/presentation/legal_info_page.dart").read_text()
        self.assertIn("onPressed: () => unawaited(_openExternal(context, url))", page)
        self.assertNotIn("initState()", page)
        self.assertNotIn("Firebase", page)

    def test_link_dependency_present_and_candidate_not_marked_approved(self):
        pubspec = (ROOT / "pubspec.yaml").read_text()
        release = (ROOT / "docs/release/1.3.0.md").read_text()
        self.assertIn("url_launcher:", pubspec)
        self.assertIn("Data Not Collected", release)
        self.assertIn("Firebase", release)
        self.assertIn("not", release.lower())
        self.assertIn("legal review", release.lower())


if __name__ == "__main__":
    unittest.main()
