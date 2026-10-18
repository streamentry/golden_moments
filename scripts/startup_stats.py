#!/usr/bin/env python3
"""Summarize cold-start measurements taken on a real device (GM-029).

Reads the JSON files written by `flutter run --profile --trace-startup`
(`build/start_up_info.json`, one per run) and prints the count, median,
95th percentile, minimum and maximum of time to first frame in milliseconds.

Time to first frame is a proxy: it is not the time until the home screen is
interactive. Record device, OS, build mode and conditions with the numbers,
and never quote a figure that was not measured on the oldest supported
physical device in a release or profile build. This script measures nothing
by itself and changes nothing.
"""
import argparse
import json
import math
import sys
from pathlib import Path

MIN_RUNS = 20  # the proposed budget needs at least this many runs


def percentile(values, fraction):
    """Nearest-rank percentile of a non-empty list, 0 < fraction <= 1."""
    ordered = sorted(values)
    rank = max(1, math.ceil(fraction * len(ordered)))
    return ordered[rank - 1]


def median(values):
    ordered = sorted(values)
    middle = len(ordered) // 2
    if len(ordered) % 2:
        return float(ordered[middle])
    return (ordered[middle - 1] + ordered[middle]) / 2


def read_runs(paths):
    """Time to first frame in ms for each readable file; others are reported."""
    runs, problems = [], []
    for path in paths:
        try:
            data = json.loads(Path(path).read_text(encoding='utf-8'))
            micros = data['timeToFirstFrameMicros']
            if not isinstance(micros, (int, float)) or micros <= 0:
                raise ValueError('not a positive number')
            runs.append(micros / 1000)
        except (OSError, ValueError, KeyError, TypeError) as error:
            problems.append(f'{path}: {error}')
    return runs, problems


def summarize(runs):
    return {
        'runs': len(runs),
        'median_ms': round(median(runs), 1),
        'p95_ms': round(float(percentile(runs, 0.95)), 1),
        'min_ms': round(min(runs), 1),
        'max_ms': round(max(runs), 1),
        'enough_runs': len(runs) >= MIN_RUNS,
    }


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('files', nargs='+', help='start_up_info.json files')
    args = parser.parse_args(argv)
    runs, problems = read_runs(args.files)
    for problem in problems:
        print(f'WARNING: skipped {problem}', file=sys.stderr)
    if not runs:
        print('ERROR: no usable measurements', file=sys.stderr)
        return 1
    result = summarize(runs)
    print(json.dumps(result, indent=2))
    if not result['enough_runs']:
        print(f'NOTE: fewer than {MIN_RUNS} runs; not enough for a budget.',
              file=sys.stderr)
    return 0


if __name__ == '__main__':
    sys.exit(main())
