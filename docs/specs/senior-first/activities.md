# Activities: comfort before variety

Feature phase/state: [catalog](feature-catalog.json). [Research S1](research.md) supports the emphasis on enjoyment and choice; it does not validate clinical outcomes. Every new mode reuses the same content, rendering, accessibility and persistence contracts. Ship one validated addition at a time.

## GM-006

**Visible-picture matching.** Keep the current low-pressure core and make it exceptionally dependable.

Acceptance:
- Fresh default: two distinct images, each shown twice, all four tiles visible. Counts of 4/6/8/12 are offered only when enough unique valid images exist.
- Tapping one tile selects it once; the same tile cannot match itself. Rapid/repeated input cannot duplicate a match or corrupt state.
- A mismatch uses neutral feedback and remains until the next deliberate action. No penalty, countdown, buzzer, flash or demand to try harder.
- Matched tiles retain their position and a non-color indicator so the layout does not jump. Their semantics remain understandable even when no further action is available.
- A missing image receives a calm fallback and a recoverable path; it cannot create a pair that looks blank and therefore appears to match arbitrarily.

Test: deterministic board construction, invalid inputs, repeated taps, completion, corrupt image fixture, semantics and replay. Existing correct behavior must not regress during layout work.

## GM-007

**Optional hidden-picture matching.** Support users who enjoy additional challenge without making it the default.

Acceptance:
- A direct choice explains that pictures will be hidden. Changing visibility does not secretly change board size or discard the session.
- Hidden tiles do not reveal names, captions, alt text or matching identifiers through semantics, tooltips, debug text or reading aloud.
- Visible mode can be restored at any point. No achievement tier, cognitive score or automatic promotion distinguishes the two modes.
- Any reveal timing remains user-controlled; do not introduce the legacy game's automatic mismatch behavior into gentle mode.

Test: visual and semantics trees before/after reveal, keyboard/switch use, visibility toggles midway through a mismatch, and persisted settings.

## GM-008

**Look together and optional conversation.** Viewing is a complete activity, not a consolation for failing a game.

Acceptance:
- One image fills a stable, comfortably bounded space. Labeled Previous/Next controls are available without requiring swipes. One photo is sufficient; empty collections offer included pictures or selection.
- Captions and conversation suggestions can be hidden independently. Prompts are manually advanced and can be silenced for the whole session.
- No name quiz, truth judgment, chronological accuracy check or required spoken response. Use invitations such as 'We can just enjoy this picture' rather than 'Do you remember who this is?'
- A participant can skip or hide an uncomfortable image without explanation. Removing/hiding it applies consistently to favorites and later suggestions.
- No auto-playing slideshow, sound or surprise transition by default. Viewing can stop immediately.

Test: one-photo and empty cases, long/absent captions, large text, manual skip, hidden content and no autoplay after resuming.

## GM-009

**Tap-to-place picture puzzle - optional experiment.** Reuse an enjoyed photo without requiring drag precision.

Acceptance before promotion:
- Start with two or four large pieces over a visible reference picture. The user chooses complexity; completion never increases it automatically.
- Tap a piece then a destination to place it. Dragging can be additional but never the only method. Offer a visible reference and optional placement help.
- A nonmatching placement leaves the board usable with neutral feedback. No timing, attempt score, failure sound or mandatory completion.
- Cropping preserves important image content; portrait/landscape and face-rich photos receive an explicit preview, not silent face detection.
- Same image ownership, favorite/hide rules, descriptions, exit and session contracts as matching. Implement only after the comparative pilot selects this mode.

Test: motor-access alternatives, screen readers, two/four pieces, portrait source, help, undo and interruption recovery. Stop the experiment if assistance rises materially relative to matching.

## GM-010

**Simple picture sorting - optional experiment.** Offer a different interaction with familiar content.

Acceptance before promotion:
- Start with a few clearly distinct included pictures and two clearly labeled groups. Avoid ambiguous categories, obscure cultural knowledge or forced name recognition.
- Tap picture then group; support undo, a visible example and an optional guided placement. Never require a swipe or drag.
- Feedback is neutral and does not characterize the person as right/wrong or capable/incapable. Looking or stopping remains valid.
- User-created family photos are not automatically classified by AI. Sorting uses editor-reviewed labels or explicit local annotations only.
- Reuse matched accessibility/storage contracts rather than creating a second game framework or separate progression system.

Test: ambiguity review with users, color-independent cues, assistive input, undo, empty category and optional guidance. Compare against the simpler photo viewer, not only other games.

## GM-011

**Read visible text aloud - optional capability.** Reading text is distinct from recording or identifying voices.

Acceptance before approval:
- User-initiated playback of visible instructions or opted-in descriptions; Stop is immediate. No microphone permission, voice upload, speech recognition or family recording.
- Use a confirmed on-device voice already available to the OS. If a suitable offline voice is unavailable, explain that reading is unavailable and keep the full text experience; no automatic voice download or cloud fallback.
- Respect system volume and interruptions. Avoid speaking over VoiceOver/TalkBack or announcing hidden cards. Provide readable text for every audio cue.
- Verify the chosen Flutter/native API and traffic on supported versions before claiming offline speech. Dependencies, privacy and licensing are reviewed separately.

Test: no installed voice, airplane mode, screen reader enabled, sound disabled, incoming audio interruption, hidden tiles and leaving the screen. No therapeutic claims are attached to narration.
