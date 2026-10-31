"""Source-level guard for the no-backend / no-upload boundary (GM-028).

This reads source and manifests. It is NOT a runtime traffic capture and does
not prove what a native binary transmits: merged Android manifests and linked
iOS pods are only visible in a built app. A failure here means a
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
    # The Play link is also where "Rate Golden Moments" goes on Android.
    'https://play.google.com/store/apps/details',
    'https://apps.apple.com/app/id$appStoreId',
    # Opened only after "Rate Golden Moments" is tapped on the Help page.
    'https://apps.apple.com/app/id$appStoreId?action=write-review',
    # Shown as copyable text on the Help page; the app never opens them
    # (lib/shared/utils/support_info.dart, test/support_info_test.dart).
    'https://dementiaactivities.games/help/',
    'https://dementiaactivities.games/app-privacy/',
    'https://dementiaactivities.games/terms/',
    # Base of the pages LegalInfoPage opens in the browser, only after a tap.
    'https://dementiaactivities.games/',
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
    def test_no_dart_code_imports_a_network_package(self):
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

    def test_firebase_stays_removed_everywhere_it_could_collect(self):
        # Removed by maintainer decision; bringing any analytics or crash SDK
        # back needs a privacy decision first (see WORKBOARD.md).
        for rel in ('pubspec.yaml', 'pubspec.lock',
                    'android/build.gradle', 'android/app/build.gradle',
                    'android/app/src/main/AndroidManifest.xml',
                    'ios/Runner/Info.plist',
                    'ios/Runner.xcodeproj/project.pbxproj'):
            with self.subTest(file=rel):
                text = (ROOT / rel).read_text().lower()
                for needle in ('firebase', 'crashlytics', 'google-services',
                               'googleservice-info', 'com.google.gms'):
                    self.assertNotIn(needle, text)
        for rel in ('android/app/google-services.json',
                    'ios/Runner/GoogleService-Info.plist'):
            self.assertFalse((ROOT / rel).exists(), rel)
        # Native lock files decide what an iOS build links. Regenerated on a
        # Mac after the removal; any SwiftPM pin that returns must not be an
        # analytics or crash SDK.
        locks = [ROOT / 'ios/Podfile.lock',
                 *ROOT.glob('ios/**/swiftpm/Package.resolved')]
        for path in locks:
            with self.subTest(file=path.relative_to(ROOT).as_posix()):
                text = path.read_text().lower()
                for needle in ('firebase', 'crashlytics', 'googleappmeasurement',
                               'google-app-measurement', 'nanopb',
                               'googleutilities', 'googledatatransport'):
                    self.assertNotIn(needle, text)
        for rel, text in dart_files():
            with self.subTest(file=rel):
                body = '\n'.join(code_lines(text)).lower()
                self.assertNotIn('firebase', body)
                self.assertNotIn('initializeapp(', body)

    def test_hard_coded_urls_are_known_user_initiated_links(self):
        found = set()
        for _, text in dart_files():
            for line in code_lines(text):
                found.update(re.findall(r"https?://[^'\"\s)]+", line))
        self.assertEqual(found, EXPECTED_URLS)

    def test_android_manifest_requests_no_sensitive_access(self):
        manifest = (ROOT / 'android/app/src/main/AndroidManifest.xml').read_text()
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

    def test_ios_plist_asks_only_for_the_picker(self):
        plist = (ROOT / 'ios/Runner/Info.plist').read_text()
        usage_keys = set(re.findall(r'<key>(NS\w+UsageDescription)</key>', plist))
        self.assertEqual(usage_keys, {'NSPhotoLibraryUsageDescription'})
        self.assertNotIn('NSUserTrackingUsageDescription', plist)
        self.assertNotIn('NSPhotoLibraryAddUsageDescription', plist)


if __name__ == '__main__':
    unittest.main()
