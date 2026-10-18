#!/bin/sh
# Capture the existing real simulator screen; never upload or invent UI.
set -eu
case "${1:-}" in 01|02|03|04|05|06) frame=$1 ;; *) echo 'Usage: capture_ios_screenshot.sh <01-06> <iphone|ipad> <simulator-id>' >&2; exit 2 ;; esac
case "${2:-}" in iphone|ipad) device=$2 ;; *) echo 'Device must be iphone or ipad.' >&2; exit 2 ;; esac
simulator=${3:?Supply the simulator ID showing the approved capture state}
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
out="$root/assets/screenshots/en-US/raw/$device"
mkdir -p "$out"
file="$out/$frame.png"
if [ -e "$file" ]; then echo "Refusing to overwrite $file" >&2; exit 1; fi
xcrun simctl io "$simulator" screenshot "$file"
printf 'Captured current simulator UI: %s\nReview before using it in store assets.\n' "$file"
