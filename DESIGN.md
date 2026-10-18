---
version: alpha
name: Golden Moments
description: >-
  Warm, calm, adult picture activities that a caregiver and an older adult,
  including someone living with dementia, can enjoy together. Big pictures,
  plain words, nothing to fail. Dimensions are Flutter logical pixels
  (iOS points / Android dp) and scale with the system text size.
colors:
  primary: "#7A5600"
  on-primary: "#FFFFFF"
  primary-container: "#FFE08A"
  on-primary-container: "#222222"
  accent: "#C99200"
  secondary: "#16688C"
  on-secondary: "#FFFFFF"
  background: "#FDF9F0"
  surface: "#F5EDE0"
  surface-sunken: "#EADFCB"
  on-surface: "#222222"
  on-surface-variant: "#5C5346"
  outline: "#7D7366"
  success: "#256B29"
  on-success: "#FFFFFF"
  warning: "#8C4A00"
  on-warning: "#FFFFFF"
  error: "#B03127"
  on-error: "#FFFFFF"
typography:
  headline-display:
    fontFamily: Roboto
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.2
  headline-lg:
    fontFamily: Roboto
    fontSize: 30px
    fontWeight: 700
    lineHeight: 1.2
  headline-md:
    fontFamily: Roboto
    fontSize: 28px
    fontWeight: 700
    lineHeight: 1.25
  headline-sm:
    fontFamily: Roboto
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.3
  title-lg:
    fontFamily: Roboto
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.3
  title-md:
    fontFamily: Roboto
    fontSize: 20px
    fontWeight: 700
    lineHeight: 1.35
  title-sm:
    fontFamily: Roboto
    fontSize: 18px
    fontWeight: 700
    lineHeight: 1.35
  body-lg:
    fontFamily: Roboto
    fontSize: 20px
    fontWeight: 400
    lineHeight: 1.4
  body-md:
    fontFamily: Roboto
    fontSize: 18px
    fontWeight: 400
    lineHeight: 1.4
  body-sm:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.4
  label-lg:
    fontFamily: Roboto
    fontSize: 20px
    fontWeight: 700
    lineHeight: 1.2
  label-md:
    fontFamily: Roboto
    fontSize: 18px
    fontWeight: 700
    lineHeight: 1.2
  label-sm:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: 700
    lineHeight: 1.2
rounded:
  md: 8px
  lg: 16px
  xl: 28px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  tile-gap: 12px
  md: 16px
  lg: 24px
  xl: 32px
  target-min: 48px
  target-primary: 56px
  target-hero: 64px
  tile-min: 64px
  content-max: 720px
components:
  button-hero:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.full}"
    height: 64px
    padding: 24px
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.full}"
    height: 56px
    padding: 24px
  button-secondary:
    backgroundColor: "{colors.background}"
    textColor: "{colors.primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.full}"
    height: 56px
    padding: 24px
  button-tertiary:
    backgroundColor: "{colors.background}"
    textColor: "{colors.primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.full}"
    height: 56px
    padding: 16px
  tile:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    size: 64px
    padding: 8px
  tile-selected:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
    rounded: "{rounded.lg}"
  tile-matched:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    rounded: "{rounded.lg}"
  tile-hidden:
    backgroundColor: "{colors.surface-sunken}"
    textColor: "{colors.on-surface-variant}"
    rounded: "{rounded.lg}"
  chip:
    backgroundColor: "{colors.background}"
    textColor: "{colors.on-surface}"
    typography: "{typography.label-md}"
    rounded: "{rounded.md}"
    height: 48px
  chip-selected:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: 16px
  sheet:
    backgroundColor: "{colors.background}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.xl}"
    padding: 24px
  dialog:
    backgroundColor: "{colors.background}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-lg}"
    rounded: "{rounded.xl}"
    padding: 24px
  app-bar:
    backgroundColor: "{colors.background}"
    textColor: "{colors.on-surface}"
    typography: "{typography.title-lg}"
    height: 64px
  snackbar:
    backgroundColor: "{colors.on-surface}"
    textColor: "{colors.background}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
  ornament:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.full}"
  status-success:
    backgroundColor: "{colors.success}"
    textColor: "{colors.on-success}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.md}"
  status-warning:
    backgroundColor: "{colors.warning}"
    textColor: "{colors.on-warning}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.md}"
  status-error:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-error}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.md}"
---

# Golden Moments design system

This file is the design contract for every screen, store asset and agent-written change. It follows the open [DESIGN.md format](https://github.com/google-labs-code/design.md): the YAML tokens above are normative, and the prose explains how to apply them. Code implements the tokens in `lib/design_system.dart` (`gm…` constants and `gmBuildTheme`). If code and this file disagree, fix one of them in the same change. Validate with `npx @google/design.md lint DESIGN.md`.

Dimensions are Flutter logical pixels, which are iOS points or Android dp. Type sizes are the size at 100% system text, and they grow with the user's text-size setting.

## Overview

**Promise.** A caregiver can hand over the phone or tablet, tap once, and share a comfortable picture activity with an adult they love. No explanation is needed and nothing can be failed.

**Two people, one screen.**

| Person | Context | Design consequence |
| --- | --- | --- |
| The *player*: an adult, often 70–95, who may be living with dementia | Presbyopia, lower contrast sensitivity, a yellowing lens that blurs blue/green/violet differences, tremor or arthritis, hearing loss, reduced working memory, low confidence with apps | Large, plain targets, recognition over recall, one decision per moment, nothing timed, no penalty, no childish tone |
| The *setter*: a family member or care professional | Busy and often anxious. Sets up photos, chooses the comfort level and sits alongside | Setup is explicit and reversible. Privacy is clear. They can switch to an easier mode in one tap, with no settings maze |

**Personality.** A well-lit family album open on a kitchen table: warm, unhurried, dignified and adult. It is **not** a casino (no confetti, streaks or countdowns), **not** a clinic (no scores, brain ages, medical badges or blue clinical chrome) and **not** a children's game (no cartoon praise, sing-song copy or emoji rewards).

**Principles,** in priority order when they conflict:

1. **Nothing to fail.** There is no clock, score, penalty, lives or forced recall. A mismatch is a neutral pause, and stopping halfway is a good outcome.
2. **One tap to a good moment.** The first activity starts from the home screen with no account, download, tutorial or permission prompt.
3. **Recognition over recall.** Pictures stay visible by default. Every icon has a word. Controls stay in the same place on every screen.
4. **Big, plain, steady.** Large type, large targets, high contrast, opaque surfaces and little motion. Text scaling never breaks the layout.
5. **Calm feedback.** Every tap gets an immediate, visible response. Celebration is a warm sentence, not fireworks.
6. **Adult dignity.** Use concrete, respectful language. Prompts invite conversation and never quiz names.
7. **Private by default.** Only photos the setter explicitly selects are used. They are copied, stay on the device and are never uploaded.
8. **An easy way out.** "Done for now" and Back are always visible. Every destructive action asks first.

Evidence base, with confidence:

- *High:* WCAG 2.2 contrast and target-size criteria, and Apple HIG and Material accessibility guidance.
- *Moderate:* systematic reviews of age-friendly mobile design, which point to simplified navigation, enlarged text and targets, and error tolerance.
- *Low to moderate:* dementia-specific touchscreen guidance. Studies are small, and errorless designs help often but are not proven superior.

Treat this file as a usability standard, not a clinical claim.

## Colors

The palette is "Golden Hour": warm parchment surfaces, near-black ink and one antique-gold action color. Bright gold is decoration only. Measured on parchment (`#FDF9F0`), the old `#C99200` scores 2.6:1, below the 3:1 floor even for large text and outlines.

| Token | Name | Hex | Use | Contrast |
| --- | --- | --- | --- | --- |
| `primary` | Antique Gold | `#7A5600` | Action fills, button text, focus and selection outlines, links | 6.7:1 with white; 6.3:1 on background; 5.7:1 on surface |
| `primary-container` | Sunlit Gold | `#FFE08A` | Selected chip or tile fills, gentle highlights | Ink on it: 12.3:1 |
| `accent` | Honey | `#C99200` | Decorative fills and illustrations only, **never text or the only outline** | 2.6:1 on background (decorative) |
| `secondary` | Sapphire | `#16688C` | Informational accents and the "Daily" badge | 6.2:1 with white |
| `background` | Parchment | `#FDF9F0` | Page, sheet and dialog background | — |
| `surface` | Linen | `#F5EDE0` | Tiles, cards and grouped content | Ink on it: 13.7:1 |
| `surface-sunken` | Oat | `#EADFCB` | Hidden-tile backs and pressed wells | Ink on it: 12.1:1 |
| `on-surface` | Ink | `#222222` | All primary text and icons | 15:1 on background |
| `on-surface-variant` | Walnut | `#5C5346` | Secondary text, captions and helper text | 6.5:1 on surface |
| `outline` | Driftwood | `#7D7366` | Resting tile and card borders, dividers that identify a control | 4.0:1 on surface (≥3:1 non-text) |
| `success` | Fern | `#256B29` | "Ready" or "saved" status (icon + word) | 6.5:1 with white; 5.6:1 on surface |
| `warning` | Amber Clay | `#8C4A00` | "Needs attention" status (icon + word) | 6.8:1 with white |
| `error` | Brick | `#B03127` | Destructive confirmations and real failures only | 6.3:1 with white |

Rules:

- **Target AAA where it is cheap.** Body text is ≥7:1 (ink gives 13–15:1). Every text pair meets WCAG AA 4.5:1. Control boundaries and state indicators meet 3:1.
- **Color is never the only signal.** Selection adds a 4px border. A match adds a check badge plus its spoken state. Status adds an icon and a word.
- **Difficulty is not a status.** Never color difficulty green, orange or red, because "hard" is not "danger". Difficulty chips are neutral.
- **Red means a real problem.** A mismatch is not an error. Do not show it in red, shake it or play a buzzer.
- **Avoid hue-only distinctions** between blue, green and violet. Aging lenses compress them.
- **No pure white pages** (glare) and no pure black text. Use parchment and ink.
- **Light only, no dark mode.** Dark ink on warm paper is the most legible pairing for aging eyes, and one verified palette is safer than two. `gmBuildTheme()` builds the only theme and the app sets `ThemeMode.light`. Android has no `values-night`/`drawable-night` resources and sets `forceDarkAllowed=false` (MIUI forced a black background, #18). iOS sets `UIUserInterfaceStyle=Light`, and the web declares `color-scheme: only light`. Do not add dark tokens or night resources.

## Typography

Use **Roboto, bundled** in `assets/fonts` (Regular 400, Medium 500, Bold 700). It renders the same offline on every platform, and it still scales with the user's system text size. Use only the bundled weights; 600 is not bundled. Name the family in every style so component text never falls back to another font.

| Token | Flutter role | Size / weight | Use |
| --- | --- | --- | --- |
| `headline-display` | `displayLarge` | 32 / 700 | Rare hero numbers or words |
| `headline-lg` | `headlineLarge` | 30 / 700 | Reserved |
| `headline-md` | `headlineMedium` | 28 / 700 | Home greeting, one per screen |
| `headline-sm` | `headlineSmall` | 24 / 700 | Section, sheet, dialog and empty-state titles |
| `title-lg` | `titleLarge` | 24 / 700 | App bar titles |
| `title-md` | `titleMedium` | 20 / 700 | Card titles, list titles |
| `title-sm` | `titleSmall` | 18 / 700 | Small group labels |
| `body-lg` | `bodyLarge` | 20 / 400 | **Default reading text** and instructions |
| `body-md` | `bodyMedium` | 18 / 400 | Secondary paragraphs and helper text |
| `body-sm` | `bodySmall` | 16 / 400 | Captions and metadata. **Floor for any text** |
| `label-lg` | `labelLarge` | 20 / 700 | Button labels |
| `label-md` | `labelMedium` | 18 / 700 | Chips and tab labels |
| `label-sm` | `labelSmall` | 16 / 700 | Badges and status pills |

Rules:

- **Nothing below 16px** at 100% text size, including badges, tab labels and progress text.
- **Never cap or clamp the user's text scale.** Layouts must work at 200%: wrap, scroll or reflow. Never truncate a button label or instruction. Truncation is allowed only for long pack titles, at two or more lines.
- Use sentence case everywhere. **No ALL-CAPS** words or labels, because capitals remove word shape. No italics for paragraphs. Weight is never below 400.
- Left-align reading text. Center only short one-line titles in dialogs or empty states.
- Keep the measure to about 60–70 characters per line with the `content-max` 720px column.
- Keep text out of images. Every word on screen is live text so it scales and is read aloud.
- Use theme roles (`Theme.of(context).textTheme.*`), not `TextStyle(fontSize: …)` literals.

## Layout

- **Spacing scale:** `xs` 4, `sm` 8, `tile-gap` 12, `md` 16, `lg` 24 (screen gutter), `xl` 32 (section break).
- **One column, centered, ≤720px wide** on every screen, including iPad, landscape and Android tablets and foldables. Extra width becomes margin, not a denser layout. The one exception is the tile grid, which may use three columns at ≥600px when there are six or more tiles.
- **Reading order is action order:** title, then one sentence of guidance, then the single primary action, then secondary actions, then fine print. Each screen has exactly one primary (filled) button.
- **Everything scrolls.** Wrap screen bodies in a scroll view so 200% text, landscape and split-screen never clip essential content. Avoid fixed heights on anything that holds text.
- **Respect safe areas and edge-to-edge** (Android 15+ draws behind system bars; iPhone has the notch and home indicator). Use `SafeArea` and keep targets out of the gesture zones.
- **Rotation and resizing are supported.** Android 16 ignores orientation locks on large screens, so every screen must reflow at any size class.
- **Placement is consistent:** Back stays top-left, help (ⓘ) top-right, and "Done for now" or "Close" is the last item on the screen. Controls never move between turns of a game.
- **Tile grid:** two columns on phones, aspect ratio about 1.1. The gap is `tile-gap`. Use the **largest tiles that fit the whole board on one screen** (`gmBoardColumns`), because scrolling a memory board forces the player to remember what has gone out of view. Tiles never drop below `tile-min` (64px, well above the 48px target minimum); only a board that cannot fit at that size scrolls. The gentle board's four tiles are far larger.

## Elevation & Depth

Hierarchy comes from **tone and borders, not shadows**. Pages are parchment. Tiles and cards are linen, with a 1px Driftwood border, or a 4px Antique Gold border when selected. Elevation is limited to 0 for content, 2 for raised cards and 8 for dialogs and sheets. Do not stack shadows.

Every surface that carries text is **opaque**. Translucent or blurred "glass" layers (for example iOS 26 Liquid Glass) are fine in system-owned chrome but never behind instructions, labels or pictures. The scrim behind dialogs and sheets darkens the page (about 50% ink) so the foreground is unambiguous.

## Shapes

| Token | Radius | Applies to |
| --- | --- | --- |
| `rounded.md` | 8px | Chips, badges, snackbars, small wells |
| `rounded.lg` | 16px | Picture tiles, cards, photo frames |
| `rounded.xl` | 28px | Bottom sheets (top corners) and dialogs |
| `rounded.full` | pill | All buttons, and the circular check badge |

Pill buttons and rounded-rectangle tiles stay distinct: older adults should be able to tell "button" from "picture" by shape alone. Pictures are cropped to the tile shape and never letterboxed into a different shape.

## Components

Material 3 widgets are themed centrally in `gmBuildTheme`. Screens use stock `FilledButton`, `OutlinedButton`, `TextButton`, `ChoiceChip`, `SwitchListTile`, `AlertDialog` and `showModalBottomSheet`, and inherit everything from the theme. Do not restyle them per screen.

**Buttons** are always a verb plus an object ("Start a gentle game", "Add photos"), with an icon *and* a label.

| Variant | Widget | Height | Use |
| --- | --- | --- | --- |
| Hero | `FilledButton` + `minimumSize: Size.fromHeight(64)` | 64 | The one main action on Home |
| Primary | `FilledButton` | ≥56 | The single main action on a screen or dialog |
| Secondary | `OutlinedButton` (2px Antique Gold border) | ≥56 | Peer choices: "Your family photos", "Look together" |
| Tertiary | `TextButton` | ≥56 (≥48 in dialogs) | Exits and low-stakes options: "Done for now", "Not now" |
| Destructive | `FilledButton` with `error` colors | ≥56 | Only inside a confirmation that names the consequence |

**Picture tile:** the heart of the product. Tap only: no drag, swipe, long-press, double-tap or multi-finger gestures.

| State | Visual | Spoken (VoiceOver/TalkBack) |
| --- | --- | --- |
| Resting, visible | Linen, 1px Driftwood border, picture inset 8px | "Picture name, tile 3", button |
| Hidden (optional mode) | Oat back, neutral photo glyph (not "?") | "Hidden picture, tile 3". **Never announce the hidden content** |
| Selected | 4px Antique Gold border | value "Selected" |
| Matched | 4px Antique Gold border + gold check badge (white ring), picture stays visible | value "Matched", disabled |
| Mismatch | Both stay as they are until the **next deliberate tap**. No shake, red, sound or timer | Live region: "Take your time. Tap a picture to continue." |

**Comfort-level chips:** `ChoiceChip`, at least 48px tall, labelled "4 tiles", "6 tiles", "8 tiles" or "12 tiles". More tiles are a *choice*, never a level-up, and the app never raises difficulty automatically.

**Switch rows:** `SwitchListTile` with a plain title and a one-line subtitle that explains the consequence ("Turn off only when you prefer hidden tiles"). The whole row is the target.

**Dialogs and sheets:** a title in `headline-sm`, body text in `body-lg`, and at most two actions (the safe one on the right as primary). Never auto-dismiss, never count down and never trap the user. Destructive confirmations name exactly what will be removed and say that originals in the photo library are untouched.

**Snackbars:** for non-essential, recoverable news only ("The picture library is unavailable. Your local activities still work."). Anything the user must act on goes inline or in a dialog.

**Status badges and progress:** an icon, a word and a color ("Ready", "Saving 2 of 5", "Needs attention"). Text is at least 16px, and progress is determinate with a percentage where known.

**Empty and error states:** say what happened, what still works and the one next action, in that order. Use a calm outline icon in Walnut. Brick is reserved for genuine failure icons.

**Ornament:** Honey (`accent`) dots, frames or illustration fills that carry no meaning. If removing it would lose information, it is not an ornament; use `primary`.

**Tabs and navigation bars** (none ship today; the picture library is bundled and opens directly): if one is added, give it an icon plus an always-visible label at ≥16px, with targets ≥48px. Show a numeric badge only when the number is useful.

## Interaction & Game Feel

The 2026 mobile-game playbook, filtered for older adults and shared play:

- **First play in one tap, within 10 seconds of launch.** Skip the splash-to-menu maze, forced tutorial, account wall and permission prompt. Teach by doing: the first board is four large visible pictures with a one-line instruction.
- **Core loop:** look, then tap one, then tap its pair, then a calm acknowledgement, then (optionally) talk about it. A session lasts about 2–5 minutes, and every screen is a natural stopping point.
- **Difficulty is player-owned.** Visible pictures and four tiles are the default. Hidden tiles and 6, 8 or 12 tiles are opt-in, and the choice persists within the session. There is no dynamic difficulty, no locked content behind performance and no "level failed".
- **Feedback timing:** a tap shows a visible state change within 100ms. Flips and cross-fades take 200–300ms with ease-out curves. State changes persist; nothing disappears on a timer.
- **Celebration is quiet:** "All pairs together. Play again or take a break." plus a soft optional chime. No confetti, fireworks, stars, emoji or "Congratulations!".
- **Motion:** honor Reduce Motion (`MediaQuery.disableAnimations`) by swapping flips for instant changes. Nothing flashes more than 3 times per second, and there is no parallax or autoplaying animation.
- **Sound:** always optional and never the only carrier of information. There are no failure sounds, and the tap sound is soft.
- **Haptics:** at most a light selection tick on a match, and none on a mismatch.
- **Ethical retention:** no streaks, daily-reward calendars, energy, lives, loot, countdowns, leaderboards, ads, push-notification nagging or purchase pressure. Return visits must come from a good experience.
- **Sharing:** a share prompt may appear after a good moment. It is always dismissible ("Not now"), never timed, never blocks play and never says "challenge".
- **Next deliberate tap, everywhere:** both the gentle board and the picture-pack game leave a mismatch face up, and a hint's pair visible, until the player taps again. That tap turns them over and starts the next turn. No game state changes on a timer.
- **Optional prompts** in Look Together are open-ended ("What do you notice in this picture?"). They are never "Who is this?" or "Do you remember…?".

## Voice & Content

Write plain, warm, adult English at about a US grade-6 reading level. Use short sentences, verbs on buttons and no jargon.

| Do | Don't |
| --- | --- |
| "Start a gentle game" | "Play now!!" / "Train your brain" |
| "Take your time. Tap a picture to continue." | "Wrong! Try again" |
| "All pairs together. Play again or take a break." | "🎉 Congratulations! 12 moves in 0:43" |
| "Done for now" | "Quit game" / "Give up" |
| "What do you notice in this picture?" | "Who is this? Do you remember?" |
| "Copies stay on this device." | "Secure cloud AI sync" |

Never use: brain age, score, IQ, train, sharpen, decline, therapy, treatment, prevent, clinically proven, "for patients" or medical symbols. Mentioning dementia or Alzheimer's describes the audience, not an outcome.

## Accessibility

Acceptance for any screen change. "Implemented" is not "verified"; record device checks in `docs/specs/release-status.json` only when they were actually performed.

- **Targets:** ≥48×48 for every control, ≥56 high for buttons, 64 for the Home hero action and tiles ≥64 (as large as the screen allows). Interactive elements are at least 8px apart.
- **Contrast:** text ≥4.5:1, with body text aimed at ≥7:1. Control boundaries and selection indicators are ≥3:1. Re-measure when a color token changes.
- **Text scale:** check 100%, 150% and 200%, portrait and landscape, on iPhone SE, iPhone Pro Max and iPad. Nothing essential clips or truncates.
- **Screen readers:** every tile is a button with a positional label and a state value. Hidden tiles never leak their picture. Live regions announce turn guidance. Decorative icons are excluded. Personal-photo labels are currently positional, so do not claim descriptive alt text.
- **Motion and sound:** the app is fully usable with Reduce Motion on and the sound off.
- **Focus:** keyboard and switch-access focus is visible (a ≥3:1 focus ring) and follows the reading order.
- **Store labels:** declare an App Store *Accessibility Nutrition Label* feature (VoiceOver, Larger Text, Sufficient Contrast, Reduced Motion, Differentiate Without Color) only after it has passed on a real device for the submitted build.

**Store design:** real UI dominates every screenshot, with one message per frame. Use consented or licensed demonstration pictures, never sensitive user content. No medical symbols, clinical badges, scores or invented reviews. See `docs/specs/screenshots.md` for sequence and release gates.

## Do's and Don'ts

- **Do** start the first activity in one tap with four visible pictures and no setup.
- **Do** use `Theme.of(context)` roles and `gm…` tokens. Add a token here before adding a new color or size in code.
- **Do** pair every icon with a word and every color with a shape, icon or word.
- **Do** let content scroll and reflow at 200% text, in landscape and on iPad.
- **Do** keep "Done for now" or Back visible on every screen, and confirm before deleting copies.
- **Do** honor Reduce Motion and keep sound optional.
- **Don't** add clocks, move counters, scores, streaks, confetti, countdowns or auto-dismissing dialogs, anywhere in the app.
- **Don't** use bright gold (`accent`) for text or as the only outline, or color difficulty as green, orange or red.
- **Don't** set text below 16px, use ALL CAPS, or clamp the user's text scale.
- **Don't** auto-advance turns, auto-hide mismatches, or raise difficulty automatically.
- **Don't** use translucent backgrounds behind text, or pure white pages.
- **Don't** imply diagnosis, treatment, cognitive measurement or clinical validation in UI, copy or store art.

## References

- [DESIGN.md specification (Google Labs)](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md), [designmd.app](https://designmd.app/) and [designmd.ai](https://designmd.ai/): format and agent usage.
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/): 1.4.3/1.4.6 contrast, 1.4.11 non-text contrast, 2.2.1 timing adjustable, 2.3.1 flashes, 2.5.5/2.5.8 target size.
- [Apple HIG: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) and [Material 3 accessibility](https://m3.material.io/foundations/designing/overview).
- [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/): no essential timing, and not relying on color alone.
- Systematic review of age-friendly mobile app design ([PMC12350549](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12350549/)), touchscreen guidelines for older adults with dementia ([University of Twente](https://essay.utwente.nl/essays/95898)), and [making software accessible for users with dementia](https://discovery.dundee.ac.uk/en/publications/making-software-accessible-for-users-with-dementia/).
