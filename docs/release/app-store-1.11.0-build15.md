# 1.11.0 build 15 release record (iOS and Android): ready to build, not uploaded

**State (2026-11-28):** version bump and release notes merged with the nudge
change (PR #312). Nothing is built, uploaded or submitted. The maintainer runs
the release on their Mac, following [publishing-with-api.md](publishing-with-api.md);
fill in the sections below as each step finishes, and read both stores back
before saying either is live.

## Content

- Reminders pick from 50 calm lines on the device (`docs/retention/nudges.md`):
  no line returns within 21 days, a skip line at most once a week, slow-down
  and last-note lines. iOS only, opt-in, as before.
- Home shows one of those lines under Today's activity, on every platform.
- New strings in all 116 translated app languages, machine-made and unreviewed.
- Release notes (English in every listing, as in 1.10.0): see
  `metadata/app-store.en-US.json`.

## Checks before building (on the merge commit)

- Same as CI plus: `flutter test --coverage` (757 passed on the PR branch),
  `release_metadata.py --check`, `store_locales.py --check` (115 of 115).
- CI `app-copy-coverage` is red by a recorded maintainer exception (see
  WORKBOARD, 2026-11-28); every other check must be green.

## Before upload: try on a device

- Turn on a reminder for a time a few minutes ahead, close the app, check the
  note on the lock screen at 100% and 200% text and with VoiceOver, and tap it:
  the day's activity should open.
- Home: the line under Today's activity at 200% text, in English and one
  right-to-left language (Arabic).

## Commands (from `publishing-with-api.md`; run on the Mac)

1. `git fetch origin && git worktree add ../gm-1.11.0 origin/main`
2. Android: `sh backups/golden-moments-android-20261018/build-android.sh ../gm-1.11.0`,
   then `keytool -printcert -jarfile <aab>` (upload certificate `B5:3D:D5:57:…:F7:2F`).
3. iOS: in the worktree, `flutter build ios --release --no-codesign --config-only`,
   set Release signing in the worktree only, `xcodebuild … archive`,
   `xcodebuild -exportArchive`, `codesign --verify --deep --strict`, check
   1.11.0 (15) in `Info.plist`.
4. Upload and submit through the App Store Connect API (set What's New on every
   localization) and the Android Publisher API (production track, notes per
   locale), as in section 3 and 4 of the guide.

## iOS

- Not built.

## Android

- Not built.
