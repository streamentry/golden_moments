import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('store_scorecard', ROOT / 'scripts/store_scorecard.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class StoreScorecardTests(unittest.TestCase):
    def test_rank_is_one_based_position_of_the_app(self):
        results = [{'trackId': 1}, {'trackId': module.APP_ID}, {'trackId': 3}]
        self.assertEqual(module.rank_of(results), 2)

    def test_rank_is_missing_not_zero_when_absent(self):
        self.assertIsNone(module.rank_of([{'trackId': 1}, {'trackId': 2}]))
        self.assertEqual(module.format_rank(None), f'not in top {module.SEARCH_LIMIT}')
        self.assertEqual(module.format_rank(1), '#1')

    def test_top_names_keep_order_and_tolerate_missing_names(self):
        results = [{'trackName': 'A'}, {}, {'trackName': 'C'}, {'trackName': 'D'}]
        self.assertEqual(module.top_names(results), ['A', '?', 'C'])

    def test_listing_keeps_missing_values_missing(self):
        listing = module.summarize_listing({'version': '1.5.0', 'userRatingCount': 0})
        self.assertEqual(listing['version'], '1.5.0')
        self.assertEqual(listing['rating_count'], 0)
        self.assertIsNone(listing['rating'])


if __name__ == '__main__':
    unittest.main()
