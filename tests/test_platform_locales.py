"""iOS and Android declare the same app languages as the ARB files (GM-036)."""
import plistlib
import re
import unittest
from pathlib import Path

from scripts import pack_text

ROOT = Path(__file__).resolve().parents[1]
# ARB names (pt_BR, zh_Hans) as BCP 47 / Apple folder names (pt-BR, zh-Hans).
LANGUAGES = [locale.replace('_', '-') for locale in pack_text.LOCALES]
STRINGS_LINE = re.compile(r'^"(\w+)" = "((?:[^"\\]|\\.)*)";$', re.M)


class PlatformLocaleTests(unittest.TestCase):
    def test_ios_declares_every_language(self):
        with (ROOT / 'ios/Runner/Info.plist').open('rb') as handle:
            info = plistlib.load(handle)
        self.assertEqual(info['CFBundleLocalizations'], LANGUAGES)

    def test_ios_infoplist_strings_exist_with_required_keys(self):
        with (ROOT / 'ios/Runner/Info.plist').open('rb') as handle:
            info = plistlib.load(handle)
        for language in LANGUAGES:
            path = ROOT / f'ios/Runner/{language}.lproj/InfoPlist.strings'
            with self.subTest(language=language):
                self.assertTrue(path.is_file())
                values = dict(STRINGS_LINE.findall(
                    path.read_text(encoding='utf-8')))
                self.assertEqual(
                    set(values),
                    {'CFBundleDisplayName', 'NSPhotoLibraryUsageDescription'})
                self.assertTrue(values['NSPhotoLibraryUsageDescription'])
                if language == 'en':
                    self.assertEqual(
                        values['NSPhotoLibraryUsageDescription'],
                        info['NSPhotoLibraryUsageDescription'])

    def test_xcode_project_bundles_every_infoplist_strings(self):
        project = (ROOT / 'ios/Runner.xcodeproj/project.pbxproj').read_text(
            encoding='utf-8')
        regions = re.search(r'knownRegions = \((.*?)\);', project, re.S)
        self.assertIsNotNone(regions)
        known = {r.strip().strip('"') for r in regions.group(1).split(',')
                 if r.strip()}
        self.assertLessEqual(set(LANGUAGES), known)
        self.assertIn('/* InfoPlist.strings in Resources */', project)
        for language in LANGUAGES:
            path = f'{language}.lproj/InfoPlist.strings'
            self.assertTrue(
                f'path = {path};' in project or f'path = "{path}";' in project,
                path)

    def test_android_locale_config_lists_every_language(self):
        config = (ROOT / 'android/app/src/main/res/xml/locales_config.xml'
                  ).read_text(encoding='utf-8')
        self.assertEqual(
            re.findall(r'<locale android:name="([^"]+)"', config), LANGUAGES)
        manifest = (ROOT / 'android/app/src/main/AndroidManifest.xml'
                    ).read_text(encoding='utf-8')
        self.assertRegex(
            manifest,
            r'<application[^>]*android:localeConfig="@xml/locales_config"')


if __name__ == '__main__':
    unittest.main()
