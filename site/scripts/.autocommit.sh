#!/bin/sh
# Commit and push translation output every 30 min while agy_translate.py runs.
cd /Volumes/SANDISK-Data/golden_moments || exit 1
n=2
while :; do
  sleep 1800
  git add site/src/i18n/ui site/src/i18n/games site/src/i18n/play site/src/content/guides-i18n
  if ! git diff --cached --quiet; then
    git commit -q -m "feat(i18n): translate site with agy (batch $n)

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>" && git push -q -u origin feat/agy-translations-2; n=$((n+1))
  fi
  pgrep -f "agy_translate.py run" >/dev/null || break
done
