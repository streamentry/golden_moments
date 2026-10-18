#!/bin/sh
# Cold-start measurement on a connected physical device (GM-029).
# Usage: sh scripts/measure_startup.sh <device-id> [runs]
# Builds a profile app once per run, launches it cold, and keeps each
# start_up_info.json under build/startup-runs/. Then summarize with
#   python3 scripts/startup_stats.py build/startup-runs/*.json
# Time to first frame is a proxy for "interactive home"; see startup_stats.py.
set -eu
device="${1:?device id required (flutter devices)}"
runs="${2:-20}"
mkdir -p build/startup-runs
i=1
while [ "$i" -le "$runs" ]; do
  flutter run --profile --trace-startup -d "$device" --no-resident >/dev/null 2>&1 || true
  if [ -f build/start_up_info.json ]; then
    cp build/start_up_info.json "build/startup-runs/run-$(printf '%02d' "$i").json"
  else
    echo "run $i produced no start_up_info.json" >&2
  fi
  i=$((i + 1))
done
echo "Saved to build/startup-runs/. Now run: python3 scripts/startup_stats.py build/startup-runs/*.json"
