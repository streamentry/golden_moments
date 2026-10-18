# Product contract: gentle personal activities

Status: implementation candidate plus proposed senior-first roadmap, not clinically validated or published. Updated 2026-10-18 against `2aecea2b53e6c3e67a21a4213a5dd2e1753d1334`.

## Goal and audience

Help older adults and the people spending time with them choose a manageable picture activity and enjoy it without pressure. The US search audience initially includes caregivers seeking dementia or Alzheimer's activities. Age does not imply dementia; independent use and supported/shared use must both remain respectful and usable.

The job is **find something comfortable to enjoy**, not improve a test score. Participant choice, interest and dignity outrank completion or engagement targets. Do not collect diagnosis, age or stage to decide eligibility.

The complete proposed feature plan is [senior-first](senior-first/README.md), with an indexed [catalog](senior-first/feature-catalog.json), [delivery sequence](senior-first/roadmap.md), acceptance tests and [evidence](senior-first/research.md). Number-one choice is an ambition to test through preference and dependable use, not a market/medical claim.

## Existing core promises

Keep these stable story IDs for compatibility with earlier specifications:

| ID | Story | Acceptance / extension |
| --- | --- | --- |
| G1 | Start without setup or internet | Four tiles/two pairs using included content; no account/download gate; GM-001 and GM-023 |
| G2 | Change challenge without judgment | Visible pictures by default; 4/6/8/12 tiles when available; GM-006 and GM-007 |
| G3 | Avoid pressure | No clock, score, penalty or automatic mismatch dismissal; easy exit; GM-002 |
| P1 | Use selected pictures | System picker only; current collection bounded to 24 copies; GM-018 |
| P2 | Reuse pictures offline | Normalized independent copies survive restart; GM-027 |
| P3 | Control copies | Confirm removal; original library files untouched; GM-020 and GM-027 |
| V1 | Simply look | One picture at a time with optional prompt, no completion requirement; GM-008 |
| L1 | Retain included content | All eight packs bundled; preserve identities and old storage; GM-023 |

A story appearing here is not proof of full device verification. Import errors retain valid content. Corrupt manifests are not silently reset. Matching needs two different images; viewing can start with one. Starter illustrations must not be marketed as personal family photographs.

## Boundaries and expansion

No AI processing, custom backend, account service, cloud sync, album watcher, remote family roles, clinical monitoring, diagnosis, cognitive scoring or therapeutic promises. No automatic difficulty escalation or forced naming of relatives.

Current release scope remains one bounded collection, matching/viewing and included content. Persistent comfort, safe resume, descriptions and favorites are proposed next improvements. New puzzle/sorting modes are separately validated experiments. Multiple albums, file sharing, reminders and payments require explicit approval; specifying them does not implement or approve them. Voice recording remains deferred.

The new native-mobile flow is English-first. Legacy translations do not establish complete localization. Descriptive photo accessibility and support for every assistive-technology configuration must not be claimed before implemented and tested.

## Acceptance and commercial truth

Use the formative comprehension, usable-start, voluntary-reuse and comparative-preference protocol in [validation](senior-first/validation.md). All thresholds are proposed decisions, not industry benchmarks. Use consented observations/diaries while no custom telemetry is approved; never infer cognition from taps.

The existing US goal is 10,000 cumulative first-time installs over 12 months, not active users or payers. Unknown App Store demand remains unknown. Preserve [canonical metadata](../../metadata/app-store.en-US.json); do not use a broader senior audience to add misleading disease keywords. Publication remains subject to [release-status.json](release-status.json) and actual native/store review.
