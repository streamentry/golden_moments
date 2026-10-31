"""Keep Android releases on the Google Play API 36 submission baseline."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GRADLE = ROOT / 'android/app/build.gradle'


class AndroidTargetApiTests(unittest.TestCase):
    def test_compile_and_target_sdk_are_api_36(self):
        config = GRADLE.read_text(encoding='utf-8')
        self.assertRegex(config, r'(?m)^\s*compileSdkVersion\s+36\s*$')
        self.assertRegex(config, r'(?m)^\s*targetSdkVersion\s+36\s*$')


if __name__ == '__main__':
    unittest.main()
