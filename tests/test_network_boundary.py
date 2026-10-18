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

# The legacy remote-catalog downloader. Since the bundled catalog it has no
# route from any screen; keep that true or decide deliberately.
ISLAND_PREFIXES = (
    'lib/data/services/download_manager',
    'lib/features/download_manager/',
)
ISLAND_FILES = {
    'lib/data/services/http_client_service.dart',
    'lib/data/services/long_term_image_cache.dart',
    'lib/data/services/connectivity_service.dart',
    'lib/shared/widgets/offline_indicator.dart',
    'lib/shared/widgets/cached_image_widget.dart',
}
ISLAND_NAMES = (
    'DownloadManagerPage', 'DownloadedPacksCubit', 'ConnectivityService',
    'OfflineIndicator', 'CachedImageWidget', 'LongTermImageCache',
    'HttpClientService', 'ImageDownloader',
)
NETWORK_IMPORT = re.compile(
    r"import\s+'package:(http|cached_network_image|dio|firebase_[a-z_]+)/")
NETWORK_IO = re.compile(
    r'InternetAddress\.lookup|HttpClient\(|Socket\.connect|WebSocket\.connect|RawSocket')
EXPECTED_URLS = {
    # Legacy catalog location; unreachable from screens (see island test).
    'https://raw.githubusercontent.com/user/golden-moments-packs/main/',
    # Explicit user-initiated share text, opened through the OS share sheet.
    'https://play.google.com/store/apps/details',
}


def dart_files():
    for path in sorted(LIB.rglob('*.dart')):
        rel = path.relative_to(ROOT).as_posix()
        if '/l10n/gen/' not in rel:
            yield rel, path.read_text(encoding='utf-8')


def in_island(rel):
    return rel in ISLAND_FILES or rel.startswith(ISLAND_PREFIXES)


def code_lines(text):
    return [line for line in text.splitlines()
            if not line.lstrip().startswith('//')]


class NetworkBoundaryTests(unittest.TestCase):
    def test_network_packages_are_imported_only_by_the_legacy_island(self):
        importers = {rel for rel, text in dart_files() if NETWORK_IMPORT.search(text)}
        self.assertEqual(
            importers,
            {
                'lib/data/services/http_client_service.dart',
                'lib/data/services/long_term_image_cache.dart',
                'lib/features/download_manager/cubit/downloaded_packs_cubit.dart',
            },
        )
        self.assertTrue(all(in_island(rel) for rel in importers))

    def test_raw_network_io_is_confined_to_the_legacy_island(self):
        users = {rel for rel, text in dart_files()
                 if NETWORK_IO.search('\n'.join(code_lines(text)))}
        self.assertEqual(
            users,
            {
                'lib/data/services/connectivity_service.dart',
                'lib/data/services/http_client_service.dart',
            },
        )
        self.assertTrue(all(in_island(rel) for rel in users))

    def test_no_screen_references_the_legacy_network_classes(self):
        pattern = re.compile(r'\b(' + '|'.join(ISLAND_NAMES) + r')\b')
        leaks = {
            rel: sorted(set(pattern.findall('\n'.join(code_lines(text)))))
            for rel, text in dart_files()
            if not in_island(rel) and pattern.search('\n'.join(code_lines(text)))
        }
        self.assertEqual(leaks, {})

    def test_only_the_navigation_cubit_touches_the_download_manager_singleton(self):
        users = {rel for rel, text in dart_files()
                 if not in_island(rel)
                 and re.search(r'\bDownloadManager\b', '\n'.join(code_lines(text)))}
        self.assertEqual(users, {'lib/app/cubit/navigation_cubit.dart'})

    def test_downloads_are_only_started_inside_the_legacy_island(self):
        starters = {rel for rel, text in dart_files()
                    if re.search(r'\.downloadPack\(|downloadInitialPacks\(',
                                 '\n'.join(code_lines(text)))
                    and not in_island(rel)}
        self.assertEqual(starters, set())

    def test_firebase_is_never_initialized_by_the_app(self):
        for rel, text in dart_files():
            with self.subTest(file=rel):
                self.assertNotIn('initializeApp(', '\n'.join(code_lines(text)))

    def test_local_photo_features_and_startup_have_no_network_code(self):
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
                body = '\n'.join(code_lines(texts[rel]))
                self.assertIsNone(NETWORK_IMPORT.search(body))
                self.assertIsNone(NETWORK_IO.search(body))
                self.assertNotIn('Firebase', body)

    def test_hard_coded_urls_are_the_two_known_ones(self):
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
