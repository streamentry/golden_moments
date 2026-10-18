# Prove preference, protect the participant

Feature phase/state: [catalog](feature-catalog.json). Targets below are proposed decision thresholds, not industry benchmarks, clinical endpoints or measurements already obtained. [Research](research.md) supplies design rationale; [baseline](baseline.md) records existing evidence limitations.

## GM-039

**Co-design and comparative usability.** Market leadership starts with observed preference, not a feature count.

### Who and how

Recruit both independent older users and shared-use pairs through opt-in, appropriately moderated channels. Do not equate age with dementia. Include varied device familiarity, vision, hearing and dexterity. A pair is one comparison unit; record the participant's and helper's responses separately rather than counting two endorsements.

Explain the usability task, data collected and right to stop. Obtain appropriate consent and ongoing participant assent; use an authorized representative where needed and applicable. Do not collect diagnoses or test cognition. A participant's discomfort overrides a helper's wish to finish. No concealed audio/video recording or upload of family photographs.

Use an available photo viewer, a simple printed-picture activity and relevant established apps as alternatives when they solve the same job. Record versions and task differences. Use the same consented or licensed pictures where practical; do not force equivalent functionality where it does not exist. Counterbalance order and separate initial setup from returning use.

### Formative sequence

| Stage | Proposed sample | Task / decision gate |
| --- | --- | --- |
| Copy comprehension | Five target caregivers | At least four understand shared recreational photo activities; none infer diagnosis, treatment or prevention |
| Usability | Twelve use units, split between independent users and pairs where feasible | At least ten start and exit the easiest activity without moderator rescue; aim for start within 30 seconds after home is visible |
| Personal-photo journey | Participants who choose to use photos | Observe choose/import/play/reopen/remove; preserve originals in every test and document assistance/abort reasons |
| Reuse and comparison | Twenty use units over seven days | At least eight voluntarily return on another day; at least twelve prefer Golden Moments for their next comparable session |

These small convenience samples support iteration, not a statistically established market winner. Record denominators, missing responses and withdrawals; a skipped task is not a success. Report ties and preference for another tool. A helper-assisted success is distinct from an independent one. Failure of a threshold triggers diagnosis and redesign, not coercion or retrospective redefinition.

### Measures

- **Successful comfortable session:** a chosen activity can start, continue as desired, and end without a critical error or unwanted pressure; completion is not required. Record observed comfort cautiously, not as a medical score.
- **Time to start:** home visible to first meaningful interaction; report median/range, setup state, assistance and device. A tap count alone misses reading/confusion.
- **Voluntary reuse:** another day of participant-accepted use without researcher reminders or mandated care routines; use consented diaries/interviews while no telemetry is approved.
- **Preference:** which alternative the participant would choose next, why, and whether the helper agrees. Evaluate independence and shared use separately.
- **Trust/guardrails:** data preserved, no unexpected disclosure, understandable purpose, no inaccessible essential controls, and no unacceptable distress.

Stop a session immediately when the participant wants to stop. Serious privacy, destructive import or misleading medical expectations block release regardless of favorable average preference. The 10,000-install objective is a business goal, not a usability success criterion.

## GM-040

**Traceable engineering and release acceptance.**

### Test layers

| Layer | Required coverage | What it cannot prove |
| --- | --- | --- |
| Pure/Dart unit | Board transitions, duplicate taps, filters, schema validation and deterministic selections | Native permission behavior or usability |
| Filesystem/service | Quotas, atomic update failures, missing files, migration, deletion confinement and corruption recovery | OS backup semantics on every device |
| Widget/semantics | Complete routes, scale/size matrices, controls, focus/labels and hidden-card privacy | VoiceOver/TalkBack end-to-end correctness |
| Browser integration | Entire included catalog with external requests blocked; retained browser behavior | Mobile photo picker, Assistive Access or signed archive |
| Native device | Fresh offline install, import/recovery, HEIC/cloud originals, upgrade, rotation, accessibility and lifecycle | Clinical benefit or universal compatibility |
| Product evaluation | Comprehension, assistance, preference and voluntary reuse | Population-wide market leadership |

### Minimum scenario matrix

Test fresh and upgraded installations; offline and online; empty/one/full photo collection; valid/corrupt/missing files; iOS and Android picker cancellation; cloud-only source; denied/restricted access; low storage; background termination; rotation and large text; screen reader/switch use; all included packs; hidden/favorite content; and every actually claimed language/platform. Future sharing/purchases require their own security/transaction matrix before approval.

Use the SDK pinned in `.fvmrc`. Run formatting, strict analysis, full Flutter tests, existing browser checks and the Python documentation/metadata checks. A non-fatal analyzer run is diagnostic, not strict success. Do not lower existing coverage/spelling gates or delete tests. Baseline exceptions require explicit scoped maintainer handling, not silent reuse for new failures.

Every acceptance record contains feature ID, tested commit/build, platform/device/OS, preconditions, steps, expected/actual result, evidence location, reviewer and date. Use synthetic/licensed fixtures. Revalidate affected gates after behavior/dependency changes; do not inherit pass status from a different build merely because the PR title sounds similar.

For this documentation-only change, run the new catalog/link checks and existing Python metadata checks. Do not claim Flutter, native, usability or screenshot validation from writing requirements. Keep [release-status.json](../release-status.json) unchanged until matching execution evidence is available.

### Release stop conditions

Block publication for original-photo modification, destructive/corrupt migration, unexpected data transmission, inability to exit, inaccessible essential actions, medical misunderstanding, unresolved asset rights, screenshots of proposed features, or a failed mandatory native/store gate. Implementation, testing, merge, device verification and publication remain separate states.
