# Delivery sequence and stopping rules

This is a proposed sequence, not a calendar commitment or authorization to implement every feature. [The catalog](feature-catalog.json) is authoritative for feature membership and dependencies. Keep release approval in [release-status.json](../release-status.json), not this file.

## R0: Earn trust in the existing product

Harden and verify what is already promised: immediate offline catalog/start, clear navigation and exit, comfortable matching and viewing, reliable imports, accessibility, content rights, privacy, and truthful store assets. Remove friction before adding modes.

First implementation slice: **board first, visible exit, settings on request** (GM-001, GM-002, GM-005, GM-012, GM-013, GM-016). Preserve the default four-tile visible mode, then test the complete start/play/stop loop on small phones and iPad. Do not ship a collection of individually attractive screens with an unusable journey.

Then close import/storage/privacy and native-release gates. Existing pending gates remain pending until evidence is recorded. Test core activities in airplane mode with no previous cache, all included packs, and an upgrade from the current installed data format.

Exit: no critical data-loss/privacy/accessibility defect, supported-platform build evidence, every advertised capability demonstrated, and the formative comprehension/startup checks in [validation](validation.md). R0 is not complete just because a PR merges.

## R1: Make returning effortless and personal

Add remembered comfort settings, safe resume, optional photo descriptions, favorites/hiding, interest filters, familiar replay and same-device companion setup. Keep default home complexity stable: return improvements should remove decisions, not add dashboard cards.

Sequence: GM-003 and GM-004 establish versioned preferences/session contracts; GM-019 and GM-020 establish annotations and visibility; GM-024 and GM-026 reuse those preferences; GM-037 composes existing controls instead of creating accounts or a second role system.

Exit: participants can repeat their preferred activity without reconfiguration; photos and preferences survive restart/upgrade; descriptive accessibility and opt-out choices are respected across every entry point. Observe reuse before selecting R2.

## R2: Prove one new reason to return

Prototype **one** new activity first: tap-to-place photo puzzle (GM-009) or simple picture sorting (GM-010). Reuse content/persistence/rendering; do not ship both by default. Optional on-device reading (GM-011) and additional languages (GM-036) have separate capability/validation gates.

Choose using documented demand, usability evidence, reusable implementation and maintenance cost. A proposal that broadens permissions, data flow, licensing or recurring expense needs review even if its UI looks small. No automatic increase in difficulty, score ladder or treatment framing.

Exit: the chosen activity wins observed voluntary selection for a meaningful portion of the target pilot without reducing accessibility or increasing assistance. A failed prototype should be removed or kept unshipped, not saved by more modes.

## R3: Explicitly conditional extensions

GM-021 (multiple albums), GM-022 (file-based photo packs), GM-035 (one-time purchase), and GM-038 (local reminders) remain deferred. This document describes their boundaries so later work is safer; it does not approve them. Each needs a separate recorded decision and a complete acceptance slice. Cloud sync, voice recording and a custom backend are not added to the roadmap by implication.

## Prioritization rule

Safety, data preservation, accessibility and truthful claims are release constraints, not features that lose a popularity contest. For optional work, record a short comparison across user value, observed demand, reduction in setup, delivery risk, and ongoing maintenance. Use low/medium/high with evidence; do not fabricate numeric precision from missing usage data.

A useful feature must have: a named user job, a cheaper alternative, a source or testable hypothesis, acceptance checks, and a maintenance owner. Defer work whose benefit is only more screens, novelty, or competitor parity.

## Seven-day decision loop

1. Establish the actual baseline build and recruit a small representative usability group with appropriate consent and participant assent.
2. Observe start/play/exit and one photo-import journey before offering instructions; record assistance and discomfort, not cognition.
3. Prototype the highest-friction interaction, test the same task with counterbalanced order, and record failures.
4. Decide on the first implementation slice; preserve actual test evidence and update WORKBOARD. Do not invent completion when recruitment or devices are unavailable.

Stop or reverse work for unwanted distress, data loss, unexpected network transmission, inaccessible essential controls, or medical misunderstanding. If usability is good but discovery is weak, change distribution rather than adding unrelated disease keywords. If there is no voluntary reuse, reconsider the activity before adding sync or subscriptions.
