"""Every shipped asset is covered by the rights register (GM-025)."""
import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTER = json.loads(
    (ROOT / 'docs/specs/asset-provenance.json').read_text(encoding='utf-8'))
GROUPS = REGISTER['groups']
STATUSES = {'unreviewed', 'reviewed', 'license_text_bundled', 'not_shipped'}


def shipped_paths() -> set[str]:
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    paths = set(re.findall(r'^\s+- (assets/\S+)\s*$', pubspec, re.M))
    paths |= set(re.findall(r'asset:\s*(assets/\S+)', pubspec))
    paths |= set(re.findall(r'image_path:\s*"(assets/[^"]+)"', pubspec))
    paths |= set(re.findall(r'^\s+image:\s*(assets/\S+)', pubspec, re.M))
    return paths


def covered(path: str) -> bool:
    for group in GROUPS:
        for entry in group['paths']:
            if path == entry or (entry.endswith('/') and path.startswith(entry)):
                return True
    return False


class AssetProvenanceTests(unittest.TestCase):
    def test_every_declared_asset_is_in_the_register(self):
        paths = shipped_paths()
        self.assertTrue(paths)
        uncovered = []
        for path in sorted(paths):
            target = ROOT / path
            members = ([p.relative_to(ROOT).as_posix()
                        for p in target.rglob('*') if p.is_file()]
                       if target.is_dir() else [path])
            self.assertTrue(members, f'{path} declares no files')
            uncovered += [m for m in members if not covered(m)]
        self.assertEqual(uncovered, [])

    def test_every_file_on_disk_is_covered(self):
        files = [p.relative_to(ROOT).as_posix()
                 for p in (ROOT / 'assets').rglob('*') if p.is_file()]
        self.assertEqual([p for p in files if not covered(p)], [])

    def test_registered_paths_exist(self):
        for group in GROUPS:
            for entry in group['paths']:
                with self.subTest(group=group['id'], path=entry):
                    self.assertTrue((ROOT / entry).exists())

    def test_statuses_are_known_and_gaps_are_named(self):
        for group in GROUPS:
            with self.subTest(group=group['id']):
                self.assertIn(group['rights_status'], STATUSES)
                if group['rights_status'] == 'unreviewed':
                    self.assertTrue(group['missing'])
                if group['rights_status'] == 'license_text_bundled':
                    self.assertTrue((ROOT / group['license_file']).is_file())

    def test_image_count_matches_files_and_source_register(self):
        group = next(g for g in GROUPS if g['id'] == 'catalog-images')
        files = list((ROOT / 'assets/images/catalog').glob('*'))
        sources = json.loads(
            (ROOT / group['register']).read_text(encoding='utf-8'))['images']
        self.assertEqual(group['count'], len(files))
        self.assertEqual(group['count'], len(sources))

    def test_release_check_refuses_unreviewed_rights(self):
        import importlib.util
        spec = importlib.util.spec_from_file_location(
            'release_metadata', ROOT / 'scripts/release_metadata.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        data = json.loads(
            (ROOT / 'metadata/app-store.en-US.json').read_text(encoding='utf-8'))
        status = json.loads(
            (ROOT / 'docs/specs/release-status.json').read_text(encoding='utf-8'))
        errors = module.validate(data, status, release=True)
        self.assertTrue(any('asset rights unreviewed: catalog-images' in e
                            for e in errors))
        self.assertFalse(any('font-roboto' in e for e in errors))


if __name__ == '__main__':
    unittest.main()
