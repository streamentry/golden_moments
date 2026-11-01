import importlib.util
import json
import plistlib
import re
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('register_language', ROOT / 'scripts/register_language.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

SAMPLE = ['bn', 'fa', 'ha', 'my']  # a plain, a right-to-left, a no-store/no-sayings and a no-letter-grid language


def temp_repo() -> Path:
    """A throwaway copy of every file the script edits."""
    root = Path(tempfile.mkdtemp())
    for rel, _ in module.EDITORS:
        target = root / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(ROOT / rel, target)
    return root


class RegisterLanguageTests(unittest.TestCase):
    def setUp(self):
        self.root = temp_repo()
        self.addCleanup(shutil.rmtree, self.root, ignore_errors=True)

    def read(self, rel):
        return (self.root / rel).read_text(encoding='utf-8')

    def test_table_has_unique_codes_and_prefixes(self):
        codes = list(module.LANGUAGES)
        self.assertEqual(len(codes), len(set(codes)))
        self.assertEqual(len({l.prefix for l in module.LANGUAGES.values()}), len(codes))

    def test_pbx_ids_are_stable_unique_24_hex(self):
        ids = {code: module.pbx_id(code) for code in module.LANGUAGES}
        self.assertEqual(len(set(ids.values())), len(ids))
        for value in ids.values():
            self.assertRegex(value, r'^[0-9A-F]{24}$')
        self.assertEqual(module.pbx_id('bn'), module.pbx_id('bn'))

    def test_registering_twice_changes_nothing_the_second_time(self):
        module.register(SAMPLE, self.root)
        snapshot = {rel: self.read(rel) for rel, _ in module.EDITORS}
        again = module.register(SAMPLE, self.root)
        self.assertEqual(again, {code: 0 for code in SAMPLE})
        self.assertEqual(snapshot, {rel: self.read(rel) for rel, _ in module.EDITORS})

    def test_ios_and_android_lists_include_the_new_languages(self):
        module.register(SAMPLE, self.root)
        info = plistlib.loads(self.read('ios/Runner/Info.plist').encode())
        for code in SAMPLE:
            self.assertIn(code, info['CFBundleLocalizations'])
            self.assertIn(f'android:name="{code}"', self.read('android/app/src/main/res/xml/locales_config.xml'))
        project = self.read('ios/Runner.xcodeproj/project.pbxproj')
        for code in SAMPLE:
            self.assertIn(f'path = {code}.lproj/InfoPlist.strings', project)
            self.assertIn(f'{module.pbx_id(code)} /* {code} */,', project)
        regions = re.search(r'knownRegions = \((.*?)\);', project, re.S).group(1)
        for code in SAMPLE:
            self.assertIn(code, regions)

    def test_python_and_dart_lists_use_arb_names(self):
        module.register(['bn'], self.root)
        self.assertIn("'bn'", self.read('scripts/pack_text.py'))
        self.assertIn("'bn',", self.read('test/l10n/arb_files_test.dart'))
        module.register(['zh-Hans'] if 'zh-Hans' in module.LANGUAGES else [], self.root)

    def test_store_entries_match_the_stores(self):
        module.register(SAMPLE, self.root)
        store = self.read('scripts/store_locales.py')
        self.assertIn("'bn': (('bn-BD',), ('bn-BD',)),", store)
        self.assertIn("'fa': ((), ('fa',)),", store)
        self.assertIn("'ha': ((), ()),", store)

    def test_site_registry_gets_prefix_dir_font_and_review_status(self):
        module.register(SAMPLE, self.root)
        locales = self.read('site/src/i18n/locales.ts')
        self.assertIn("code: 'fa', prefix: 'fa'", locales)
        self.assertRegex(locales, r"code: 'fa'[^\n]*dir: 'rtl'")
        self.assertRegex(locales, r"code: 'bn'[^\n]*dir: 'ltr'")
        css = self.read('site/src/styles/base.css')
        self.assertIn(':root:lang(bn)', css)
        self.assertIn(':root:lang(fa)', css)
        self.assertNotIn(':root:lang(ha)', css)  # Latin script: the bundled font covers it
        held = re.search(r"HELD_FROM_INDEX: ReadonlySet<string> = new Set\(\[(.*?)\]\)", locales, re.S).group(1)
        self.assertIn("'ha'", held)  # too weak to index unread
        self.assertNotIn("'bn'", held)
        play = self.read('site/src/i18n/play.ts')
        self.assertRegex(play, r"NO_LETTER_GRID: readonly string\[\] = \[[^\]]*'my'")
        self.assertRegex(play, r"NO_SAYINGS_GAME: readonly string\[\] = \[[^\]]*'ha'")
        self.assertNotRegex(play, r"NO_SAYINGS_GAME: readonly string\[\] = \[[^\]]*'bn'")
        status = json.loads(self.read('docs/specs/release-status.json'))['localization']['languages']
        for code in SAMPLE:
            self.assertEqual(status[code]['status'], 'unreviewed')
        checker = self.read('site/scripts/check-site.mjs')
        self.assertIn("'bn'", checker)
        rtl = re.search(r"const RTL_PREFIXES = new Set\(\[(.*?)\]\)", checker, re.S).group(1)
        self.assertIn("'fa'", rtl)  # right to left
        self.assertNotIn("'bn'", rtl)  # left to right


if __name__ == '__main__':
    unittest.main()
