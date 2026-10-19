#!/bin/sh
# Capture the six App Store frames from the real app on a booted simulator.
#
# integration_test/store_screens_test.dart drives the app to each frame and
# pauses; this script then saves the simulator screen with
# `xcrun simctl io screenshot` (the real UI and status bar, nothing drawn).
# It never overwrites an existing capture.
#
# Usage: sh scripts/capture_store_screens.sh <iphone|ipad> <simulator-id>
set -eu
case "${1:-}" in iphone|ipad) device=$1 ;; *) echo 'Usage: capture_store_screens.sh <iphone|ipad> <simulator-id>' >&2; exit 2 ;; esac
simulator=${2:?Supply the booted simulator ID}
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
out="$root/assets/screenshots/en-US/raw/$device"
for frame in 01 02 03 04 05 06; do
  if [ -e "$out/$frame.png" ]; then echo "Refusing to overwrite $out/$frame.png" >&2; exit 1; fi
done
mkdir -p "$out"

# A folder both the simulator app and simctl can write to.
work=$(mktemp -d /tmp/gm-store-capture.XXXXXX)
cp "$root/assets/screenshots/en-US/art/demo-teacup.png" \
   "$root/assets/screenshots/en-US/art/demo-flowers.png" "$work/"

xcrun simctl status_bar "$simulator" override --time 9:41 --dataNetwork wifi \
  --wifiMode active --wifiBars 3 --batteryState discharging --batteryLevel 100 \
  --cellularMode notSupported

(cd "$root" && flutter test integration_test/store_screens_test.dart \
  -d "$simulator" --dart-define=GM_CAPTURE_DIR="$work") &
test_pid=$!

while kill -0 "$test_pid" 2>/dev/null; do
  for ready in "$work"/*.ready; do
    [ -e "$ready" ] || continue
    frame=$(basename "$ready" .ready)
    xcrun simctl io "$simulator" screenshot "$work/$frame.png" >/dev/null 2>&1
    rm -f "$ready"
    touch "$work/$frame.done"
    echo "Captured frame $frame"
  done
  sleep 1
done
wait "$test_pid"

for frame in 01 02 03 04 05 06; do
  cp "$work/$frame.png" "$out/$frame.png"
done
rm -rf "$work"
printf 'Saved six frames in %s. Review each before using it in store assets.\n' "$out"
