#!/usr/bin/env python3
"""Print first-time App Store downloads per day for Golden Moments.

Reads Apple's "App Downloads Standard" analytics report (daily instances),
created by the ONGOING analytics report request turned on 2026-10-30. Apple
produces the first data a day or two after the request. Nothing is sent
anywhere except App Store Connect; the key file is read, never printed.

    ASC_KEY_ID=... ASC_ISSUER=... python3 scripts/store_downloads.py [--days 14]

The key is read from ~/.appstoreconnect/private_keys/AuthKey_<ASC_KEY_ID>.p8
unless ASC_KEY_PATH is set.
"""

import argparse
import csv
import gzip
import io
import os
import sys
import time
from collections import defaultdict

APP_ID = '6749312459'
BASE = 'https://api.appstoreconnect.apple.com'
REPORT_NAME = 'App Downloads Standard'
FIRST_TIME = 'First-time download'


def first_time_downloads(tsv_text):
    """Sums first-time downloads per date from one report segment (TSV)."""
    totals = defaultdict(int)
    for row in csv.DictReader(io.StringIO(tsv_text), delimiter='\t'):
        if row.get('Download Type') != FIRST_TIME:
            continue
        try:
            totals[row['Date']] += int(row.get('Counts') or 0)
        except (KeyError, ValueError):
            continue
    return dict(totals)


def merge(*parts):
    out = defaultdict(int)
    for part in parts:
        for day, count in part.items():
            out[day] += count
    return dict(out)


def _session():
    import jwt
    import requests

    key_id = os.environ['ASC_KEY_ID']
    path = os.environ.get('ASC_KEY_PATH') or os.path.expanduser(
        f'~/.appstoreconnect/private_keys/AuthKey_{key_id}.p8')
    with open(path, encoding='utf-8') as handle:
        key = handle.read()
    now = int(time.time())
    token = jwt.encode(
        {'iss': os.environ['ASC_ISSUER'], 'iat': now, 'exp': now + 1100,
         'aud': 'appstoreconnect-v1'},
        key, algorithm='ES256', headers={'kid': key_id, 'typ': 'JWT'})
    session = requests.Session()
    session.headers['Authorization'] = f'Bearer {token}'
    return session


def _get(session, path):
    response = session.get(path if path.startswith('http') else BASE + path, timeout=60)
    response.raise_for_status()
    return response.json()


def fetch(days):
    session = _session()
    requests_ = _get(session, f'/v1/apps/{APP_ID}/analyticsReportRequests')['data']
    ongoing = [r for r in requests_ if r['attributes'].get('accessType') == 'ONGOING']
    if not ongoing:
        sys.exit('No ONGOING analytics report request exists for the app.')
    reports = _get(session, f"/v1/analyticsReportRequests/{ongoing[0]['id']}/reports"
                            f"?filter[name]={REPORT_NAME.replace(' ', '%20')}")['data']
    if not reports:
        sys.exit(f'No "{REPORT_NAME}" report yet.')
    instances = _get(session, f"/v1/analyticsReports/{reports[0]['id']}/instances"
                              f"?filter[granularity]=DAILY&limit={days}")['data']
    parts = []
    for instance in instances:
        segments = _get(session, f"/v1/analyticsReportInstances/{instance['id']}/segments")['data']
        for segment in segments:
            raw = session.get(segment['attributes']['url'], timeout=120).content
            parts.append(first_time_downloads(gzip.decompress(raw).decode('utf-8')))
    return merge(*parts)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('--days', type=int, default=14)
    args = parser.parse_args()
    totals = fetch(args.days)
    if not totals:
        print('No daily data yet. Apple usually needs a day or two after the request.')
        return 0
    for day in sorted(totals):
        print(f'{day}\t{totals[day]}')
    print(f'average\t{sum(totals.values()) / len(totals):.1f} first-time downloads/day '
          f'over {len(totals)} days')
    return 0


if __name__ == '__main__':
    sys.exit(main())
