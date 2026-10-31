#!/usr/bin/env python3
"""Print the App Store part of the plan's "#1" scorecard for Golden Moments.

Reads Apple's public iTunes Search and Lookup APIs (no key, nothing sent but
the search term). Two of the plan's five measures come from here: App Store
search rank for the head terms, and the average rating with its count.

    python3 scripts/store_scorecard.py [--country us]

Caveats that belong next to every number: the Search API approximates, but is
not identical to, the App Store's own search results (personalization, ads and
timing differ), so a rank here is evidence, not proof. A rating average without
its count says little. Google Play has no equivalent public API; read it in
Play Console or by hand and say so. Record results in
docs/strategy/keyword-research.csv with the date and source.
"""

import argparse
import json
import sys
import urllib.parse
import urllib.request
from typing import Any

APP_ID = 6749312459
SEARCH = 'https://itunes.apple.com/search'
LOOKUP = 'https://itunes.apple.com/lookup'
HEAD_TERMS = (
    'dementia activities',
    'dementia games',
    'alzheimers activities',
    'alzheimers games',
    'reminiscence dementia',
)
SEARCH_LIMIT = 50


def rank_of(results: list[dict[str, Any]], track_id: int = APP_ID) -> int | None:
    """1-based position of the app in a search result list, or None."""
    for position, result in enumerate(results, start=1):
        if result.get('trackId') == track_id:
            return position
    return None


def top_names(results: list[dict[str, Any]], count: int = 3) -> list[str]:
    """Names of the first results, for the "who is ahead" column."""
    return [r.get('trackName', '?') for r in results[:count]]


def summarize_listing(record: dict[str, Any]) -> dict[str, Any]:
    """The listing facts the scorecard needs, with missing values kept missing."""
    return {
        'version': record.get('version'),
        'rating': record.get('averageUserRating'),
        'rating_count': record.get('userRatingCount'),
        'released': record.get('currentVersionReleaseDate'),
        'advisory': record.get('contentAdvisoryRating'),
        'genre': record.get('primaryGenreName'),
    }


def _get(url: str, params: dict[str, Any]) -> dict[str, Any]:
    query = urllib.parse.urlencode(params)
    with urllib.request.urlopen(f'{url}?{query}', timeout=30) as response:
        return json.load(response)


def search(term: str, country: str) -> list[dict[str, Any]]:
    data = _get(SEARCH, {'term': term, 'country': country, 'entity': 'software', 'limit': SEARCH_LIMIT})
    return data.get('results', [])


def lookup(country: str) -> dict[str, Any] | None:
    results = _get(LOOKUP, {'id': APP_ID, 'country': country}).get('results', [])
    return summarize_listing(results[0]) if results else None


def format_rank(rank: int | None) -> str:
    return f'#{rank}' if rank else f'not in top {SEARCH_LIMIT}'


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('--country', default='us')
    args = parser.parse_args()

    listing = lookup(args.country)
    if listing is None:
        sys.exit(f'The app was not found in the {args.country} storefront.')
    print(f'Listing ({args.country}): version {listing["version"]}, '
          f'rating {listing["rating"]} from {listing["rating_count"]} ratings, '
          f'advisory {listing["advisory"]}, genre {listing["genre"]}, '
          f'released {listing["released"]}')
    print('Rank in the iTunes Search API (approximates App Store search):')
    for term in HEAD_TERMS:
        results = search(term, args.country)
        print(f'  {term}\t{format_rank(rank_of(results))}\tahead: {"; ".join(top_names(results))}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
