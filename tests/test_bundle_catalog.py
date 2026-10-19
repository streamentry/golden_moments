import hashlib
from pathlib import Path
import tempfile
import unittest

from scripts.bundle_catalog import reusable


def entry(root, name, data, **extra):
    path = Path(root) / name
    path.write_bytes(data)
    return {'asset': name, 'source': 'https://images.unsplash.com/x',
            'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data),
            **extra}


class ReusableTests(unittest.TestCase):
    def test_a_verified_file_is_kept_unless_refreshing(self):
        with tempfile.TemporaryDirectory() as root:
            old = entry(root, 'a.jpg', b'picture')
            self.assertIs(reusable(old, False, Path(root)), old)
            self.assertIsNone(reusable(old, True, Path(root)))

    def test_a_changed_or_missing_file_is_fetched_again(self):
        with tempfile.TemporaryDirectory() as root:
            old = entry(root, 'a.jpg', b'picture')
            (Path(root) / 'a.jpg').write_bytes(b'changed')
            self.assertIsNone(reusable(old, False, Path(root)))
            (Path(root) / 'a.jpg').unlink()
            self.assertIsNone(reusable(old, False, Path(root)))

    def test_a_locally_derived_image_is_never_fetched(self):
        with tempfile.TemporaryDirectory() as root:
            old = entry(root, 'a.jpg', b'crop', derivedFrom='b.jpg resized')
            self.assertIs(reusable(old, True, Path(root)), old)
            self.assertIs(reusable(old, False, Path(root)), old)

    def test_an_unknown_source_is_fetched(self):
        self.assertIsNone(reusable(None, False))


if __name__ == '__main__':
    unittest.main()
