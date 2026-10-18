"""Source-level guard for the no-backend / no-upload boundary (GM-028).

This reads source and manifests. It is NOT a runtime traffic capture and does
not prove what a native binary transmits: Android library manifests and
FirebaseInitProvider are only visible in a built app. A failure here means a
network-capable path changed and needs a conscious privacy decision plus an
update to docs/release/network-privacy-audit.md.
"""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'

NETWORK_IMPORT = re.compile(
    r"import\s+'package:(http|cached_network_image|dio|firebase_[a-z_]+)/")
NETWORK_IO = re.compile(
    r'InternetAddress\.lookup|HttpClient\(|Socket\.connect|WebSocket\.connect|RawSocket')
EXPECTED_URLS = {
    # Explicit user-initiated share text, opened through the OS share sheet.
    'https://play.google.com/store/apps/details',
    # Shown as copyable text on the Help page; the app never opens them
    # (lib/shared/utils/support_info.dart, test/support_info_test.dart).
    'https://streamentry.github.io/golden-moments-web/help/',
    'https://streamentry.github.io/golden-moments-web/app-privacy/',
    'https://streamentry.github.io/golden-moments-web/terms/',
}


def dart_files():
    for path in sorted(LIB.rglob('*.dart')):
        rel = path.relative_to(ROOT).as_posix()
        if '/l10n/gen/' not in rel:
            yield rel, path.read_text(encoding='utf-8')


def code_lines(text):
    return [line for line in text.splitlines()
            if not line.lstrip().startswith('//')]


class NetworkBoundaryTests(unittest.TestCase):
    def test_no_dart_code_imports_a_network_or_firebase_package(self):
        importers = {rel for rel, text in dart_files()
                     if NETWORK_IMPORT.search(text)}
        self.assertEqual(importers, set())

    def test_no_dart_code_opens_a_connection(self):
        users = {rel for rel, text in dart_files()
                 if NETWORK_IO.search('\n'.join(code_lines(text)))}
        self.assertEqual(users, set())

    def test_the_remote_pack_downloader_stays_removed(self):
        names = [p.relative_to(ROOT).as_posix() for p in LIB.rglob('*.dart')]
        banned = ('download_manager', 'http_client_service',
                  'long_term_image_cache', 'connectivity_service',
                  'json_cache_service')
        self.assertEqual(
            [n for n in names if any(b in n for b in banned)], [])
        for rel, text in dart_files():
            with self.subTest(file=rel):
                body = '\n'.join(code_lines(text))
                self.assertNotIn('downloadPack(', body)
                self.assertNotIn('raw.githubusercontent.com', body)

    def test_firebase_is_never_initialized_by_the_app(self):
        for rel, text in dart_files():
            with self.subTest(file=rel):
                self.assertNotIn('initializeApp(', '\n'.join(code_lines(text)))

    def test_local_photo_features_and_startup_have_no_firebase_references(self):
        guarded = [
            rel for rel, _ in dart_files()
            if rel.startswith('lib/features/gentle_activities/')
            or rel in ('lib/bootstrap.dart', 'lib/main.dart',
                       'lib/app/view/platform_home_native.dart')
        ]
        self.assertTrue(guarded)
        texts = dict(dart_files())
        for rel in guarded:
            with self.subTest(file=rel):
                self.assertNotIn('Firebase', '\n'.join(code_lines(texts[rel])))

    def test_hard_coded_urls_are_known_user_initiated_links(self):
        found = set()
        for _, text in dart_files():
            for line in code_lines(text):
                found.update(re.findall(r"https?://[^'\"\s)]+", line))
        self.assertEqual(found, EXPECTED_URLS)

    def test_android_manifest_disables_collection_and_requests_no_sensitive_access(self):
        manifest = (ROOT / 'android/app/src/main/AndroidManifest.xml').read_text()
        self.assertRegex(
            manifest,
            r'firebase_analytics_collection_deactivated"\s+android:value="true"')
        self.assertRegex(
            manifest,
            r'firebase_crashlytics_collection_enabled"\s+android:value="false"')
        permissions = set(re.findall(r'uses-permission[^>]*android:name="([^"]+)"', manifest))
        forbidden = {
            'android.permission.CAMERA', 'android.permission.RECORD_AUDIO',
            'android.permission.ACCESS_FINE_LOCATION',
            'android.permission.ACCESS_COARSE_LOCATION',
            'android.permission.READ_CONTACTS',
            'android.permission.READ_EXTERNAL_STORAGE',
            'android.permission.READ_MEDIA_IMAGES',
            'android.permission.POST_NOTIFICATIONS',
        }
        self.assertEqual(permissions & forbidden, set())

    def test_ios_plist_disables_collection_and_asks_only_for_the_picker(self):
        plist = (ROOT / 'ios/Runner/Info.plist').read_text()
        self.assertRegex(
            plist, r'FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED</key>\s*<true/>')
        self.assertRegex(
            plist, r'FirebaseCrashlyticsCollectionEnabled</key>\s*<false/>')
        usage_keys = set(re.findall(r'<key>(NS\w+UsageDescription)</key>', plist))
        self.assertEqual(usage_keys, {'NSPhotoLibraryUsageDescription'})
        self.assertNotIn('NSUserTrackingUsageDescription', plist)
        self.assertNotIn('NSPhotoLibraryAddUsageDescription', plist)


if __name__ == '__main__':
    unittest.main()
