#!/bin/sh
# Capture the six Google Play phone frames from the real app on a running
# Android emulator: the Android counterpart of capture_store_screens.sh.
#
# integration_test/store_screens_test.dart drives the app to each frame and
# pauses; this script then saves the emulator screen with `adb exec-out
# screencap` (the real UI and status bar, nothing drawn). The status bar is
# set with System UI demo mode. It never overwrites an existing capture.
#
# Usage: sh scripts/capture_play_screens.sh <emulator-serial>
set -eu
serial=${1:?Supply the running emulator serial, for example emulator-5554}
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
out="$root/assets/screenshots/en-US/raw/android"
for frame in 01 02 03 04 05 06; do
  if [ -e "$out/$frame.png" ]; then echo "Refusing to overwrite $out/$frame.png" >&2; exit 1; fi
done
mkdir -p "$out"

adb_() { adb -s "$serial" "$@"; }

# A folder inside the app's own private storage, reached with `run-as`
# (debug builds only), so the app can read the demo photos and write its
# ready markers without any permission. The debug app is installed first so
# the folder exists; the test's own install (`adb install -r`) keeps it.
(cd "$root" && flutter build apk --debug --flavor production >/dev/null)
adb_ install -r -t "$root/build/app/outputs/flutter-apk/app-production-debug.apk" >/dev/null
package=com.mindfulness.golden_moments
work=/data/user/0/$package/files/gm-capture
app() { adb_ shell run-as "$package" "$@"; }
app rm -rf "$work"
app mkdir -p "$work"
for photo in demo-teacup.png demo-flowers.png; do
  adb_ push "$root/assets/screenshots/en-US/art/$photo" "/data/local/tmp/$photo" >/dev/null
  app cp "/data/local/tmp/$photo" "$work/$photo"
  adb_ shell rm -f "/data/local/tmp/$photo"
done

demo() { adb_ shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null; }
adb_ shell settings put global sysui_demo_allowed 1
demo enter
demo clock -e hhmm 0941
demo network -e wifi show -e level 4 -e fully true
demo network -e mobile hide
demo battery -e level 100 -e plugged false
demo notifications -e visible false

(cd "$root" && flutter test integration_test/store_screens_test.dart \
  -d "$serial" --flavor production --dart-define=GM_CAPTURE_DIR="$work") &
test_pid=$!

while kill -0 "$test_pid" 2>/dev/null; do
  for ready in $(app ls "$work" | tr -d '\r' | grep '\.ready$' || true); do
    frame=$(basename "$ready" .ready)
    adb_ exec-out screencap -p > "$out/$frame.png"
    app rm -f "$work/$ready"
    app touch "$work/$frame.done"
    echo "Captured frame $frame"
  done
  sleep 1
done
status=0
wait "$test_pid" || status=$?
demo exit
# Flutter uninstalls the test app afterwards, which removes the folder too.
app rm -rf "$work" 2>/dev/null || true
[ "$status" -eq 0 ] || exit "$status"
printf 'Saved six frames in %s. Review each before using it in store assets.\n' "$out"
