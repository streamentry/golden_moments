# Helper mode: a way for a family helper to lock changes, without a password

Status: proposal, dated 2026-11-06. Not approved, not built, not in any release.
It is move 4 in [next-moves](next-moves.md). A maintainer decision is needed
before any code.

## Problem

A person living with dementia can change things they did not mean to change:
remove a photo copy, clear a history, change the language or the comfort settings,
or leave an activity by mistake. A helper wants a quiet way to stop that without
making the person do something hard to get past.

Competitors use a PIN for this (Recollect, Forget-Me-Not; see
[competitors](competitors.md)). The requirements study cited there warns against
passwords for people with dementia, who may forget them or use them badly. So
this proposal does not use a password.

## What it protects (and what it does not)

Protects: the settings screen, the language and comfort choices, and delete actions
(removing photo copies, clearing progress or reminders).

Does not protect: starter play, which must stay open to the person. It does not
make the app secure against someone who has the phone. It is not a parental-control
or safety feature and must not be described as one.

## Options

| Option | How the helper gets in | How the person is kept out | Verdict |
| --- | --- | --- | --- |
| A. PIN | Types a PIN | Person cannot see the PIN | Rejected for now: a PIN is a password in practice, and the study warns against it |
| B. Press and hold | Holds a button on the helper screen for 3 seconds | Hold is hard to do by accident; no text explains it on the main screen | Recommended to test |
| C. Helper confirms with the device passcode | Uses the phone's own lock | Depends on the device | Possible; needs platform APIs and a native review, so it is out of scope for now |

Option B needs no account, no network and no stored secret. It also adds no
permission. It does rely on the person not being able to do the hold by accident.

## Rules any version must keep

- No account, no network request, no stored PIN or password, no telemetry.
- No clock, timer or countdown on the helper screen. A hold that lasts 3 seconds is
  a gesture, not a timer shown to the person.
- Starter play and the Home screen stay open. Helper mode never blocks play.
- Exit must be easy for the helper and must not be a hidden trap: the lock screen
  says how to leave it in plain words.
- Locking is stored only on this phone, and clears when the app is reinstalled.
- The copy must not say the lock keeps the person safe, prevents misuse, or
  protects against anything medical.

## First step, before any design

Audit which delete actions can be reached from settings or the game screens, and
which of them ask for confirmation. Current examples: the progress page asks first
(`lib/features/wellbeing/presentation/progress_page.dart`); other delete paths need the
same check. The audit is evidence for the decision and costs no product change.

## Tests a build would need

- Locked: the settings screen and delete actions are unreachable; starter play still
  opens.
- Unlocked by hold, locked again by hold; a short tap does nothing.
- Lock state survives a restart; a corrupt stored value falls back to unlocked and is
  not overwritten.
- Text scale at 200% and the 48 by 48 tap target still hold on the lock control.

## Decisions needed

1. Approve the press-and-hold option (B) for a test, or choose another.
2. Confirm the protected list above.
3. Decide whether a field test with helpers is needed before release.

## Recommendation

Approve option B as a small test with the audit first. Do not build a PIN. Do not
describe this as a safety feature in any store or site copy.
