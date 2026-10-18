# Product specification: gentle shared activities

Status: implementation candidate, not clinically validated or published. Decision date: 2026-10-18.

## Goal and ICP

Help a family member or caregiver start a manageable picture activity with another adult. The US search audience includes people seeking activities to share with someone living with dementia or Alzheimer's. Do not collect diagnosis, age or stage to score eligibility.

The job is **find something comfortable to enjoy together**, not improve a test score. Respect the interests and preferences of the person participating, even when another person installs the app.

| ID | Story | Acceptance |
| --- | --- | --- |
| G1 | Start without setup or internet | Four tiles/two pairs using bundled illustrations; no account/download gate |
| G2 | Change challenge without judgment | Visible pictures by default; 4/6/8/12 tiles when enough pictures exist |
| G3 | Avoid pressure | No clock, score, penalty or automatic mismatch dismissal |
| P1 | Use selected pictures | System picker only; one collection up to 24 copies; no scanning, recognition or upload |
| P2 | Reuse pictures offline | Normalized independent copies survive app restart |
| P3 | Control copies | Confirm individual/remove-all; original library files untouched |
| V1 | Simply look | One picture at a time; optional open-ended prompt; no completion requirement |
| L1 | Retain old content | Explicit library entry; preserve existing identifiers and pack storage |

Import errors retain valid content. Corrupt manifests are not silently reset. Matching needs two different pictures; viewing can start with one. Starter illustrations are not described as family photographs.

## Boundaries

No AI, account service, custom sync, album watcher, family roles, medical monitoring, diagnosis, assessment or therapeutic promises. Payments remain a separate validated decision; this upgrade introduces no paywall or entitlement.

The new native-mobile flow is English-first. Retained translations of older screens do not constitute localization of new screens. Generic photo labels are a known accessibility limitation, not descriptive alt text.

## Validation

Show the first three screenshot concepts to five caregivers. Proposed comprehension gate: four understand recreational shared photo activities and none infer diagnosis or treatment. Observe unassisted startup of the easiest activity. This tests usability, not medical efficacy or statistical market demand.

Use consented interviews/diaries for a small pilot instead of silently adding telemetry. Never infer cognition from taps. Stop or change the activity when uncomfortable. Business retention targets are hypotheses, not judgments about families.
