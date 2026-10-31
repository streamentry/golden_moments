import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('store_downloads', ROOT / 'scripts/store_downloads.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

HEADER = 'Date\tApp Name\tDownload Type\tTerritory\tCounts\n'


class StoreDownloadsTests(unittest.TestCase):
    def test_counts_only_first_time_downloads_per_day(self):
        tsv = HEADER + (
            '2026-11-01\tGolden Moments\tFirst-time download\tUS\t7\n'
            '2026-11-01\tGolden Moments\tFirst-time download\tGB\t2\n'
            '2026-11-01\tGolden Moments\tRedownload\tUS\t5\n'
            '2026-11-02\tGolden Moments\tFirst-time download\tUS\t11\n')
        self.assertEqual(module.first_time_downloads(tsv),
                         {'2026-11-01': 9, '2026-11-02': 11})

    def test_bad_counts_are_skipped_not_fatal(self):
        tsv = HEADER + '2026-11-01\tGolden Moments\tFirst-time download\tUS\t\n'
        tsv += '2026-11-01\tGolden Moments\tFirst-time download\tUS\tn/a\n'
        self.assertEqual(module.first_time_downloads(tsv), {'2026-11-01': 0})

    def test_segments_from_several_instances_add_up(self):
        self.assertEqual(module.merge({'2026-11-01': 3}, {'2026-11-01': 4, '2026-11-02': 1}),
                         {'2026-11-01': 7, '2026-11-02': 1})


if __name__ == '__main__':
    unittest.main()
