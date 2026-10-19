import plistlib
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'ios/Runner/PrivacyInfo.xcprivacy'
PROJECT = ROOT / 'ios/Runner.xcodeproj/project.pbxproj'


class PrivacyManifestTests(unittest.TestCase):
    """The app's own privacy manifest matches what the app does: no tracking,
    no collected data (the App Store label is "Data Not Collected"), and a
    stated reason for each required-reason API its own code relies on."""

    def setUp(self):
        self.manifest = plistlib.loads(MANIFEST.read_bytes())

    def test_no_tracking_and_no_collected_data(self):
        self.assertIs(self.manifest['NSPrivacyTracking'], False)
        self.assertEqual(self.manifest['NSPrivacyTrackingDomains'], [])
        self.assertEqual(self.manifest['NSPrivacyCollectedDataTypes'], [])

    def test_only_app_container_reasons_are_declared(self):
        reasons = {
            entry['NSPrivacyAccessedAPIType']:
                entry['NSPrivacyAccessedAPITypeReasons']
            for entry in self.manifest['NSPrivacyAccessedAPITypes']
        }
        self.assertEqual(reasons, {
            # Photo copies inside the app's own folder are ordered by date.
            'NSPrivacyAccessedAPICategoryFileTimestamp': ['C617.1'],
            # Comfort, sound and pack choices are the app's own preferences.
            'NSPrivacyAccessedAPICategoryUserDefaults': ['CA92.1'],
        })

    def test_the_manifest_ships_in_the_app(self):
        project = PROJECT.read_text()
        build_file = re.search(
            r'(\w{24}) /\* PrivacyInfo\.xcprivacy in Resources \*/ = '
            r'\{isa = PBXBuildFile; fileRef = (\w{24})', project)
        self.assertIsNotNone(build_file)
        resources = re.search(
            r'97C146EC1CF9000F007C117D /\* Resources \*/ = \{.*?files = \((.*?)\);',
            project, re.S)
        self.assertIn(build_file.group(1), resources.group(1))


if __name__ == '__main__':
    unittest.main()
