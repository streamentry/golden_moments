import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    'startup_stats', ROOT / 'scripts/startup_stats.py')
stats = importlib.util.module_from_spec(spec)
spec.loader.exec_module(stats)


class StartupStatsTests(unittest.TestCase):
    def test_median_and_percentile(self):
        self.assertEqual(stats.median([3, 1, 2]), 2)
        self.assertEqual(stats.median([1, 2, 3, 4]), 2.5)
        values = list(range(1, 21))  # 1..20
        self.assertEqual(stats.percentile(values, 0.95), 19)
        self.assertEqual(stats.percentile(values, 1.0), 20)
        self.assertEqual(stats.percentile([5], 0.95), 5)

    def test_summary_flags_too_few_runs(self):
        few = stats.summarize([1000.0] * 5)
        self.assertFalse(few['enough_runs'])
        enough = stats.summarize([1000.0 + i for i in range(20)])
        self.assertTrue(enough['enough_runs'])
        self.assertEqual(enough['runs'], 20)
        self.assertEqual(enough['min_ms'], 1000.0)
        self.assertEqual(enough['max_ms'], 1019.0)

    def test_reads_files_and_reports_unusable_ones(self):
        with tempfile.TemporaryDirectory() as directory:
            good = Path(directory) / 'good.json'
            good.write_text(json.dumps({'timeToFirstFrameMicros': 1500000}))
            bad = Path(directory) / 'bad.json'
            bad.write_text('{not json')
            missing = Path(directory) / 'none.json'
            zero = Path(directory) / 'zero.json'
            zero.write_text(json.dumps({'timeToFirstFrameMicros': 0}))
            runs, problems = stats.read_runs([good, bad, missing, zero])
        self.assertEqual(runs, [1500.0])
        self.assertEqual(len(problems), 3)

    def test_nothing_usable_is_an_error_not_a_number(self):
        with tempfile.TemporaryDirectory() as directory:
            bad = Path(directory) / 'bad.json'
            bad.write_text('[]')
            self.assertEqual(stats.main([str(bad)]), 1)


if __name__ == '__main__':
    unittest.main()
