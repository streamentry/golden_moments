---
version: alpha
name: Golden Moments
description: >-
  Warm, calm, adult picture activities that a caregiver and an older adult,
  including someone living with dementia, can enjoy together. A well-lit family
  album open on a kitchen table: parchment and linen surfaces, antique-gold
  actions, soft serif headlines, big pictures mounted like prints, plain words
  and nothing to fail. Dimensions are Flutter logical pixels (iOS points,
  Android dp, CSS px) and scale with the system or browser text size.
colors:
  primary: "#7A5600"
  primary-deep: "#5F4300"
  on-primary: "#FFFFFF"
  primary-container: "#FFE08A"
  on-primary-container: "#222222"
  accent: "#C99200"
  accent-pale: "#FFE9B0"
  accent-deep: "#F2C95C"
  secondary: "#16688C"
  on-secondary: "#FFFFFF"
  secondary-container: "#EEF5F8"
  secondary-outline: "#C7DBE5"
  background: "#FDF9F0"
  surface: "#F5EDE0"
  surface-raised: "#FFFDF7"
  surface-sunken: "#EADFCB"
  on-surface: "#222222"
  on-surface-variant: "#5C5346"
  outline: "#7D7366"
  on-ink: "#F3EAD9"
  on-ink-variant: "#D9CFBD"
  on-ink-link: "#FFE9B0"
  shadow-ink: "#3C2C0A"
  success: "#256B29"
  on-success: "#FFFFFF"
  warning: "#8C4A00"
  on-warning: "#FFFFFF"
  error: "#B03127"
  on-error: "#FFFFFF"
typography:
  headline-hero:
    fontFamily: Fraunces
    fontSize: 56px
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: -0.015em
  headline-display:
    fontFamily: Fraunces
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.2
  headline-lg:
    fontFamily: Fraunces
    fontSize: 30px
    fontWeight: 700
    lineHeight: 1.2
  headline-md:
    fontFamily: Fraunces
    fontSize: 28px
    fontWeight: 700
    lineHeight: 1.25
  headline-sm:
    fontFamily: Fraunces
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.3
  title-lg:
    fontFamily: Fraunces
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
  sm: 4px
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
  2xl: 48px
  mat: 6px
  target-min: 48px
  target-primary: 56px
  target-hero: 64px
  tile-min: 64px
  content-max: 720px
  wide-max: 1160px
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
  button-primary-pressed:
    backgroundColor: "{colors.primary-deep}"
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
  badge-match:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    size: 36px
  print:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: 6px
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
  notice:
    backgroundColor: "{colors.secondary-container}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-md}"
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
    textColor: "{colors.on-ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
  footer:
    backgroundColor: "{colors.on-surface}"
    textColor: "{colors.on-ink}"
    typography: "{typography.body-md}"
    padding: 48px
  ornament:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.full}"
  tape:
    backgroundColor: "{colors.accent-pale}"
    rounded: "{rounded.sm}"
    height: 22px
  breathing-circle:
    backgroundColor: "{colors.accent-deep}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.full}"
    size: 300px
  notice-outline:
    backgroundColor: "{colors.secondary-outline}"
    height: 1px
  footer-link:
    backgroundColor: "{colors.on-surface}"
    textColor: "{colors.on-ink-link}"
    typography: "{typography.body-md}"
  footer-fine-print:
    backgroundColor: "{colors.on-surface}"
    textColor: "{colors.on-ink-variant}"
    typography: "{typography.body-sm}"
  shadow:
    backgroundColor: "{colors.shadow-ink}"
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

This file is the design contract for every screen, web page, store asset and agent-written change. It follows the open [DESIGN.md format](https://github.com/google-labs-code/design.md): the YAML tokens above are normative, and the prose explains how to apply them. Code implements the tokens twice, one to one:

| Surface | Implementation | Validate with |
| --- | --- | --- |
| Flutter app (iOS, Android, web build) | `lib/design_system.dart`: `gm…` constants and `gmBuildTheme()` | `flutter test test/design_system_test.dart` |
| Website (`site/`, Astro) | `site/src/styles/tokens.css`: `--gm-*` custom properties, then `base.css` and `components.css` | `pnpm --dir site verify` |
| This file | — | `npx @google/design.md lint DESIGN.md` (0 errors, 0 warnings) |

If code and this file disagree, fix one of them in the same change. Dimensions are logical pixels, which are iOS points, Android dp or CSS px. Type sizes are the size at 100% system text, and they grow with the user's text-size setting; on the web they are `rem` so they follow the browser's text size too.

## Overview

**Promise.** A caregiver can hand over the phone or tablet, tap once, and share a comfortable picture activity with an adult they love. No explanation is needed and nothing can be failed.

**Two people, one screen.**

| Person | Context | Design consequence |
| --- | --- | --- |
| The *player*: an adult, often 70–95, who may be living with dementia | Presbyopia, lower contrast sensitivity, a yellowing lens that blurs blue/green/violet differences, tremor or arthritis, hearing loss, reduced working memory, low confidence with apps | Large, plain targets, recognition over recall, one decision per moment, nothing timed, no penalty, no childish tone |
| The *setter*: a family member or care professional | Busy and often anxious. Sets up photos, chooses the comfort level and sits alongside. On the website, reads guides late at night on a phone | Setup is explicit and reversible. Privacy is clear. They can switch to an easier mode in one tap, with no settings maze. Pages read like a trusted magazine, not a clinic or a casino |

### Atmosphere

The direction is **Golden Hour**: a well-lit family album open on a kitchen table in late-afternoon sun. Everything follows from that picture.

| Album quality | What it means on screen |
| --- | --- |
| Paper, not glass | Opaque parchment and linen surfaces with hairlines. No translucency, blur, glass or pure white glare |
| Prints, not thumbnails | Every picture is *mounted*: a print-white mat with a hairline edge, inside a linen card or tile, with softly rounded corners |
| Warm light | One sunlit glow (`primary-container` at about 60%) may sit in a hero corner. Shadows, where they exist, are warm umber (`shadow-ink`), never grey or black |
| Handwritten titles, printed captions | Headlines and large titles are **Fraunces**, a soft old-style serif. Everything that is *read*, from body text to buttons, is **Roboto**. Two families, never a third |
| Gold leaf, used sparingly | One antique-gold action color carries every action. Brighter golds are ornament: a dot before an eyebrow, a tape strip, a glow, the sunrise rule |
| Unhurried | Spacing breathes, motion is short and eased, and nothing moves on its own |

It is **not** a casino (no confetti, streaks or countdowns), **not** a clinic (no scores, brain ages, medical badges or blue clinical chrome) and **not** a children's game (no cartoon praise, sing-song copy or emoji rewards).

### Signature details

Use these consistently; they are what makes a screen recognizably Golden Moments.

1. **The mounted print.** A picture sits on a `surface-raised` mat with a 1px `surface-sunken` hairline, inset `mat` (6px) around the picture, which has `rounded.sm` corners; the mat has `rounded.md` corners and sits `sm` inside its linen card or tile. App: `GmMountedPicture`. Web: `.game-card__print`, `.print`, `.target__print`.
2. **The sunrise rule.** A 4px line that runs pale to deep gold (`accent-pale` → `accent` → `primary`) along the top of the website header, and a 4px `accent` rule along the top of the ink footer. Decorative; it never carries meaning and is never the only outline of a control.
3. **The golden-hour glow.** One soft radial `primary-container` glow at about 60%, in one corner of a hero or call-to-action band. Ink stays ≥13:1 on it, so text may sit over it. Never more than one glow per screen, never behind a picture tile.
4. **Hairlines, not boxes.** Groups are separated by a 1px `surface-sunken` line or a tone change (parchment to linen), not by borders around everything. Only controls and tiles get a `outline` border, so a border *means* "you can tap this".
5. **Serif headline, sans everything else.** A Fraunces headline over Roboto body text, with generous space between them, is the typographic signature. Never set a button, chip, label or paragraph in Fraunces.
6. **Big numerals.** Where a step or count is shown (How it works), the numeral is Fraunces at `headline-hero` size in `primary`, over a 3px ink rule.

**Principles,** in priority order when they conflict:

1. **Nothing to fail.** There is no clock, score, penalty, lives or forced recall. A mismatch is a neutral pause, and stopping halfway is a good outcome.
2. **One tap to a good moment.** The first activity starts from the home screen with no account, download, tutorial or permission prompt.
3. **Recognition over recall.** Pictures stay visible by default. Every icon has a word. Controls stay in the same place on every screen.
4. **Big, plain, steady.** Large type, large targets, high contrast, opaque surfaces and little motion. Text scaling never breaks the layout.
5. **Calm feedback.** Every tap gets an immediate, visible response. Celebration is a warm sentence, not fireworks.
6. **Adult dignity.** Use concrete, respectful language. Prompts invite conversation and never quiz names.
7. **Private by default.** Only photos the setter explicitly selects are used. They are copied, stay on the device and are never uploaded.
8. **An easy way out.** "Done for now" and Back are always visible. Every destructive action asks first.
9. **Beautiful because it is calm.** Beauty here comes from proportion, warmth, type and restraint, never from effects. If a flourish would cost legibility, contrast or stillness, it is cut.

Evidence base, with confidence:

- *High:* WCAG 2.2 contrast and target-size criteria, and Apple HIG and Material accessibility guidance.
- *Moderate:* systematic reviews of age-friendly mobile design, which point to simplified navigation, enlarged text and targets, and error tolerance.
- *Low to moderate:* dementia-specific touchscreen guidance. Studies are small, and errorless designs help often but are not proven superior.

Treat this file as a usability standard, not a clinical claim.

## Colors

The palette is "Golden Hour": warm parchment surfaces, near-black ink and one antique-gold action color, with a small gold ramp for ornament and light. Bright gold is decoration only. Measured on parchment (`#FDF9F0`), Honey `#C99200` scores 2.6:1, below the 3:1 floor even for large text and outlines.

### Surfaces and ink

| Token | Name | Hex | Use | Contrast |
| --- | --- | --- | --- | --- |
| `background` | Parchment | `#FDF9F0` | Page, sheet and dialog background | — |
| `surface` | Linen | `#F5EDE0` | Tiles, cards, grouped content, alternating page bands | Ink on it: 13.7:1 |
| `surface-raised` | Print White | `#FFFDF7` | The mat of a mounted print; the answer box and the step numeral disc on the web | Ink: 15.6:1; `primary`: 6.5:1; `outline`: 4.6:1 |
| `surface-sunken` | Oat | `#EADFCB` | Hidden-tile backs, pressed wells, hairlines and picture placeholders | Ink on it: 12.1:1 |
| `on-surface` | Ink | `#222222` | All primary text and icons. Also the one dark surface: the website footer, snackbars and tooltips | 15:1 on background |
| `on-surface-variant` | Walnut | `#5C5346` | Secondary text, captions, helper text and calm empty-state icons | 6.5:1 on surface; 7.4:1 on print white |
| `outline` | Driftwood | `#7D7366` | Resting tile and card borders, and dividers that identify a control | 4.0:1 on surface (≥3:1 non-text) |
| `on-ink` | Parchment on Ink | `#F3EAD9` | Reading text on an ink surface | 13.3:1 on ink |
| `on-ink-variant` | Oat on Ink | `#D9CFBD` | Fine print and dividers on an ink surface | 10.3:1 on ink |
| `on-ink-link` | Sunlit on Ink | `#FFE9B0` | Links on an ink surface | 13.3:1 on ink |
| `shadow-ink` | Umber | `#3C2C0A` | The only shadow tint, at 8–18% opacity | — |

### Gold

| Token | Name | Hex | Use | Contrast |
| --- | --- | --- | --- | --- |
| `primary` | Antique Gold | `#7A5600` | Action fills, button text, focus and selection outlines, links, big numerals | 6.7:1 with white; 6.3:1 on background; 5.7:1 on surface |
| `primary-deep` | Deep Antique | `#5F4300` | Pressed and hovered fills, the 2px ledge under a filled web button | 9.2:1 with white; 8.7:1 on background |
| `primary-container` | Sunlit Gold | `#FFE08A` | Selected chip or tile fills, gentle highlights, the glow (at about 60%), text selection on the web | Ink on it: 12.3:1; `primary` on it: 5.2:1 |
| `accent-pale` | Sunlit Pale | `#FFE9B0` | The pale start of the sunrise rule and the breathing circle; tape strips | Decorative (1.1:1 on background) |
| `accent-deep` | Sunlit Deep | `#F2C95C` | The warm centre of the breathing circle and glows | Decorative (1.5:1 on background) |
| `accent` | Honey | `#C99200` | Eyebrow dots, hidden-tile frame, the footer rule and illustration fills: **never text or the only outline** | Decorative (2.6:1 on background) |

### Information and status

| Token | Name | Hex | Use | Contrast |
| --- | --- | --- | --- | --- |
| `secondary` | Sapphire | `#16688C` | Informational accents, the "Daily" badge and notice icons | 6.2:1 with white; 5.6:1 on `secondary-container` |
| `secondary-container` | Sky | `#EEF5F8` | Informational notice and research-band fills | Ink on it: 14.4:1 |
| `secondary-outline` | Sky Line | `#C7DBE5` | Borders of those notices, with a 6–8px `secondary` left rule | Decorative |
| `success` | Fern | `#256B29` | "Ready" or "saved" status (icon + word) | 6.5:1 with white; 5.6:1 on surface |
| `warning` | Amber Clay | `#8C4A00` | "Needs attention" status (icon + word) | 6.8:1 with white |
| `error` | Brick | `#B03127` | Destructive confirmations and real failures only | 6.3:1 with white; 5.5:1 on surface |

Derived values with no token of their own: the **scrim** behind dialogs and sheets is `on-surface` at 50%; the **glow** is `primary-container` at about 60%; **shadows** are `shadow-ink` at 8–18%.

Rules:

- **Target AAA where it is cheap.** Body text is ≥7:1 (ink gives 13–15:1). Every text pair meets WCAG AA 4.5:1. Control boundaries and state indicators meet 3:1.
- **Color is never the only signal.** Selection adds a 4px border. A match adds a check badge plus its spoken state. Status adds an icon and a word.
- **Difficulty is not a status.** Never color difficulty green, orange or red, because "hard" is not "danger". Difficulty chips are neutral.
- **Red means a real problem.** A mismatch is not an error. Do not show it in red, shake it or play a buzzer.
- **Avoid hue-only distinctions** between blue, green and violet. Aging lenses compress them.
- **No pure white pages** (glare) and no pure black text. Use parchment and ink. Print White exists for the small mat around a picture, never for a page.
- **One warm family.** Every neutral leans warm, every shadow is umber, and the one cool color (Sapphire) is reserved for information so it stays meaningful.
- **Light only, no dark mode.** Dark ink on warm paper is the most legible pairing for aging eyes, and one verified palette is safer than two. `gmBuildTheme()` builds the only theme and the app sets `ThemeMode.light`. Android has no `values-night`/`drawable-night` resources and sets `forceDarkAllowed=false` (MIUI forced a black background, #18). iOS sets `UIUserInterfaceStyle=Light`, and the web declares `color-scheme: only light`. Do not add dark tokens or night resources.

## Typography

Two bundled families, so text renders the same offline on every platform and still scales with the user's text size:

| Family | Role | Files | Why |
| --- | --- | --- | --- |
| **Fraunces** Bold 700 | Headlines and large titles (`headline-*`, `title-lg`) | App: `assets/fonts/Fraunces-Bold.ttf`. Web: `site/public/fonts/fraunces-latin-700-normal.woff2`. Both are one static instance of the variable font (weight 700, optical size 48, SOFT 50, WONK 0), subset to Latin, so the app and the website draw the identical letterforms | A soft old-style serif with the warmth of a printed album title. Optical size 48 keeps hairlines sturdy for aging eyes; WONK off keeps letters conventional and recognizable |
| **Roboto** 400 / 500 / 700 | Everything that is read: body, labels, buttons, chips, small titles, captions | App: `assets/fonts/Roboto-*.ttf`. Web: `site/public/fonts/roboto-latin-*.woff2` | Large x-height, open apertures and even color at 16–20px |

Use only the bundled weights (Fraunces 700; Roboto 400, 500, 700). Name the family in every style so component text never falls back to another font; Fraunces styles list Roboto as their fallback.

| Token | Flutter role | Family / size / weight | Use |
| --- | --- | --- | --- |
| `headline-hero` | — (web only) | Fraunces 56 / 700, tracking −0.015em | The website hero title and the big step numerals. The web clamps it between 38 and 68px with the viewport |
| `headline-display` | `displayLarge` | Fraunces 32 / 700 | Rare hero words in the app |
| `headline-lg` | `headlineLarge` | Fraunces 30 / 700 | Reserved |
| `headline-md` | `headlineMedium` | Fraunces 28 / 700 | Home greeting, one per screen; website `h1` on inner pages (clamped 34–46px) |
| `headline-sm` | `headlineSmall` | Fraunces 24 / 700 | Section, sheet, dialog and empty-state titles; website `h2` (clamped 26–34px) |
| `title-lg` | `titleLarge` | Fraunces 24 / 700 | App bar titles, pack and card titles; website `h3` |
| `title-md` | `titleMedium` | Roboto 20 / 700 | List titles, FAQ questions, small card titles |
| `title-sm` | `titleSmall` | Roboto 18 / 700 | Small group labels |
| `body-lg` | `bodyLarge` | Roboto 20 / 400 | **Default reading text** and instructions |
| `body-md` | `bodyMedium` | Roboto 18 / 400 | Secondary paragraphs and helper text |
| `body-sm` | `bodySmall` | Roboto 16 / 400 | Captions and metadata. **Floor for any text** |
| `label-lg` | `labelLarge` | Roboto 20 / 700 | Button labels |
| `label-md` | `labelMedium` | Roboto 18 / 700 | Chips, navigation and tab labels, eyebrows |
| `label-sm` | `labelSmall` | Roboto 16 / 700 | Badges and status pills |

Rules:

- **Nothing below 16px** at 100% text size, including badges, tab labels and progress text.
- **Fraunces is never smaller than 24px** and never carries a control label, a chip, a caption or a paragraph. If a title must shrink below 24, it becomes `title-md` in Roboto.
- **Never cap or clamp the user's text scale.** Layouts must work at 200%: wrap, scroll or reflow. Never truncate a button label or instruction. Truncation is allowed only for long pack titles, at two or more lines.
- Use sentence case everywhere. **No ALL-CAPS** words or labels, because capitals remove word shape. No italics for paragraphs. Weight is never below 400.
- **Tracking stays open.** Letter spacing is 0 everywhere except the web hero, where Fraunces may tighten to −0.015em above 38px. Never tighten body or label text.
- Left-align reading text. Center only short one-line titles in dialogs or empty states.
- Keep the measure to about 60–70 characters per line with the `content-max` 720px column. Ledes may run to 38em in a lighter Walnut.
- Keep text out of images. Every word on screen is live text so it scales and is read aloud.
- Use theme roles (`Theme.of(context).textTheme.*`) and CSS custom properties, not `TextStyle(fontSize: …)` or `font-size: 17px` literals.

## Layout

- **Spacing scale:** `xs` 4, `sm` 8, `tile-gap` 12, `md` 16, `lg` 24 (screen gutter), `xl` 32 (section break), `2xl` 48 (page section on the web), `mat` 6 (the print mat). Rhythm comes from using the far ends of the scale together: a tight `sm` between a title and its lede, then a generous `xl` or `2xl` before the next group. Avoid uniform padding everywhere.
- **One column, centered, ≤720px wide** on every app screen, including iPad, landscape and Android tablets and foldables. Extra width becomes margin, not a denser layout. The one exception is the tile grid, which may use three columns at ≥600px when there are six or more tiles.
- **The website** uses the same 720px reading column for articles and games, and a `wide-max` 1160px frame for the hero, card grids and bands. Gutters are 16px, 24px from 600px. Wide screens get margin and breathing room, never more columns of text.
- **Reading order is action order:** title, then one sentence of guidance, then the single primary action, then secondary actions, then fine print. Each screen has exactly one primary (filled) button.
- **Everything scrolls.** Wrap screen bodies in a scroll view so 200% text, landscape and split-screen never clip essential content. Avoid fixed heights on anything that holds text.
- **Respect safe areas and edge-to-edge** (Android 15+ draws behind system bars; iPhone has the notch and home indicator). Use `SafeArea` and keep targets out of the gesture zones.
- **Rotation and resizing are supported.** Android 16 ignores orientation locks on large screens, so every screen must reflow at any size class.
- **Placement is consistent:** Back stays top-left, help (ⓘ) top-right, and "Done for now" or "Close" is the last item on the screen. Controls never move between turns of a game.
- **Tile grid:** two columns on phones, aspect ratio about 1.1. The gap is `tile-gap`. Use the **largest tiles that fit the whole board on one screen** (`gmBoardColumns`), because scrolling a memory board forces the player to remember what has gone out of view. Tiles never drop below `tile-min` (64px, well above the 48px target minimum); only a board that cannot fit at that size scrolls. The gentle board's four tiles are far larger.
- **Page bands on the web** alternate parchment and linen, separated by a 1px Oat hairline, so a long page reads as chapters. A band holds one idea and one heading.

## Elevation & Depth

Hierarchy comes from **tone, hairlines and mounting, not shadows**. Pages are parchment. Tiles and cards are linen, with a 1px Driftwood border, or a 4px Antique Gold border when selected. Inside them, a picture sits on a Print White mat, which is the one step *up* from the page. Elevation is limited to 0 for content, 2 for raised cards and 8 for dialogs and sheets. Do not stack shadows.

Where a shadow exists, it is **warm umber** (`shadow-ink`), never grey or black:

| Name | Use | Spec |
| --- | --- | --- |
| Raised | A hovered web card, the answer box, the hero note | `0 1px 2px` umber 10% + `0 6px 18px` umber 8% |
| Print | A photo print lying on the page (hero album) | `0 2px 3px` umber 14% + `0 12px 28px` umber 14% |
| Hairline | The mat of a mounted print on the web | `0 1px 2px` umber 18% |
| Modal | Dialogs and sheets in the app | Material elevation 8 with `shadowColor` umber |

Scrolling shows by tone too. When content scrolls under the app bar, the bar turns linen. A fixed bottom bar ("Done for now", Start again, Next) gets a 1px Driftwood line along its top edge only while content continues beneath it. Text cut off at that edge then reads as "more below" rather than as clipped.

Every surface that carries text is **opaque**. Translucent or blurred "glass" layers (for example iOS 26 Liquid Glass) are fine in system-owned chrome but never behind instructions, labels or pictures. The scrim behind dialogs and sheets darkens the page (about 50% ink) so the foreground is unambiguous. The one allowed translucency is the golden-hour glow, which sits *behind* an opaque page color and is itself a tint of the page.

## Shapes

| Token | Radius | Applies to |
| --- | --- | --- |
| `rounded.sm` | 4px | The picture inside a mat, small inner corners |
| `rounded.md` | 8px | Chips, badges, snackbars, small wells, the print mat |
| `rounded.lg` | 16px | Picture tiles, cards, notices |
| `rounded.xl` | 28px | Bottom sheets (top corners), dialogs and call-to-action bands |
| `rounded.full` | pill | All buttons, the circular check badge, eyebrow dots |

Nesting steps down one level: a `lg` card holds an `md` mat, which holds an `sm` picture, so inner corners stay concentric. Pill buttons and rounded-rectangle tiles stay distinct: older adults should be able to tell "button" from "picture" by shape alone. Pictures are cropped to the tile shape and never letterboxed into a different shape.

## Components

Material 3 widgets are themed centrally in `gmBuildTheme`. Screens use stock `FilledButton`, `OutlinedButton`, `TextButton`, `ChoiceChip`, `SwitchListTile`, `AlertDialog` and `showModalBottomSheet`, and inherit everything from the theme. Do not restyle them per screen. The website mirrors each component as a class in `site/src/styles/components.css` with the same tokens.

**Buttons** are always a verb plus an object ("Start a gentle game", "Add photos"), with an icon *and* a label.

| Variant | App widget / web class | Height | Resting | Hover / pressed | Use |
| --- | --- | --- | --- | --- | --- |
| Hero | `FilledButton` + `minimumSize: Size.fromHeight(64)` / `.btn--primary.btn--hero` | 64 | `primary` fill, white label | `primary-deep` fill; web adds a 2px `primary-deep` ledge and a 1px press | The one main action on Home and in the website hero |
| Primary | `FilledButton` / `.btn--primary` | ≥56 | `primary` fill | `primary-deep` | The single main action on a screen or dialog |
| Secondary | `OutlinedButton` (2px Antique Gold border) / `.btn` | ≥56 | parchment fill, gold border and label | `primary-container` fill, ink label | Peer choices: "Your family photos", "Look together" |
| Tertiary | `TextButton` / `.btn--quiet` | ≥56 (≥48 in dialogs) | underlined gold label | linen fill | Exits and low-stakes options: "Done for now", "Not now" |
| Destructive | `FilledButton` with `error` colors | ≥56 | `error` fill | darker by the Material overlay | Only inside a confirmation that names the consequence |

Focus is a 3px `primary` ring, offset 3px, on every platform. Disabled buttons drop to 55% opacity and lose the gold outline, so a disabled control never says "tap me".

**Picture tile:** the heart of the product. Tap only: no drag, swipe, long-press, double-tap or multi-finger gestures.

| State | Visual | Spoken (VoiceOver/TalkBack) |
| --- | --- | --- |
| Resting, visible | Linen, 1px Driftwood border, picture inset 8px with `rounded.md` corners | "Picture name, tile 3", button |
| Hidden (optional mode) | Oat back with an inset 2px Honey frame and a 3×3 dot ornament (not "?") | "Hidden picture, tile 3". **Never announce the hidden content** |
| Selected | 4px Antique Gold border | value "Selected" |
| Matched | 4px Antique Gold border + `badge-match` (gold disc, white check, white ring), picture stays visible | value "Matched", disabled |
| Mismatch | Both stay as they are until the **next deliberate tap**. No shake, red, sound or timer | Live region: "Take your time. Tap a picture to continue." |

**Mounted print** (`print`): the picture treatment everywhere a picture is shown but not played. The picture is cropped to its frame, inset `mat` inside a Print White mat with a 1px Oat hairline and `rounded.md` corners, and decoded at the size it is shown (`GmMountedPicture`). Pack covers are 16:9 and at least 1170px wide, so they stay sharp on a large phone; topic pictures are square. The pack title is `title-lg` in Fraunces. Favorite and "Not for me" sit in a footer under a hairline, apart from the picture that starts the pack. Family photos get the same treatment: on Your family photos and on the gentle board each photo is cropped to its square and mounted, never letterboxed; its state and Options sit under a hairline. Look together is the one place a photo is shown whole. On the website hero, prints lie on the page at slight angles with a tape strip in `accent-pale`, and settle a little on hover.

**Comfort-level chips:** `ChoiceChip`, at least 48px tall, labelled "4 tiles", "6 tiles", "8 tiles" or "12 tiles". They have equal widths and fill full rows: all on one row when every label fits, otherwise two per row, otherwise one, so no choice sits alone. More tiles are a *choice*, never a level-up, and the app never raises difficulty automatically.

**Switch rows:** `SwitchListTile` with a plain title and a one-line subtitle that explains the consequence ("Turn off only when you prefer hidden tiles"). The whole row is the target.

**Dialogs and sheets:** a title in `headline-sm` (Fraunces), body text in `body-lg`, and at most two actions (the safe one on the right as primary). When both labels do not fit side by side, the actions stack full width with the primary first. Sheet actions span the sheet. Dialogs keep a 16px side margin, so at large text a label wraps between words, never inside one. Never auto-dismiss, never count down and never trap the user. Destructive confirmations name exactly what will be removed and say that originals in the photo library are untouched.

**Notices** (`notice`, web): a Sky fill with a Sky Line border and a 6px Sapphire left rule for information, or a linen fill with an Antique Gold rule for warm guidance. An outline icon, a bold one-line title in `body-lg`, then `body-md`. Anything the user must act on goes inline or in a dialog, not in a notice.

**Snackbars:** for non-essential, recoverable news only ("The picture library is unavailable. Your local activities still work."). Ink fill, `on-ink` text, `rounded.md`. Anything the user must act on goes inline or in a dialog.

**Status badges and progress:** an icon, a word and a color ("Ready", "Saving 2 of 5", "Needs attention"). Text is at least 16px, and progress is determinate with a percentage where known.

**Empty and error states:** say what happened, what still works and the one next action, in that order. Use a calm outline icon in Walnut. Brick is reserved for genuine failure icons.

**Ornament:** Honey (`accent`) dots, frames or illustration fills, the sunrise rule, the hero `tape` strip and the glow carry no meaning. `shadow` names the umber tint every shadow is mixed from, at 8–18%. If removing it would lose information, it is not an ornament; use `primary`.

**Website header and footer:** the header is parchment with the sunrise rule along its top and a 1px Oat hairline below; the brand name is Fraunces `title-lg`. Navigation links are Roboto `label-md` pills, linen on hover, Sunlit Gold with a 3px Antique Gold underline when current. The footer is the one ink surface: `on-ink` text, `on-ink-link` links, an `accent` rule along its top and an `on-ink-variant` hairline above the fine print.

**Tabs and navigation bars** (none ship in the app today; the picture library is bundled and opens directly): if one is added, give it an icon plus an always-visible label at ≥16px, with targets ≥48px. Show a numeric badge only when the number is useful.

## Interaction & Game Feel

The 2026 mobile-game playbook, filtered for older adults and shared play:

- **First play in one tap, within 10 seconds of launch.** Skip the splash-to-menu maze, forced tutorial, account wall and permission prompt. Teach by doing: the first board is four large visible pictures with a one-line instruction.
- **Core loop:** look, then tap one, then tap its pair, then a calm acknowledgement, then (optionally) talk about it. A session lasts about 2–5 minutes, and every screen is a natural stopping point.
- **Difficulty is player-owned.** Visible pictures and four tiles are the default. Hidden tiles and 6, 8 or 12 tiles are opt-in, and the choice persists within the session. There is no dynamic difficulty, no locked content behind performance and no "level failed".
- **Feedback timing:** a tap shows a visible state change within 100ms. Flips and cross-fades take 200–300ms with ease-out curves (`cubic-bezier(0.16, 1, 0.3, 1)` on the web, `Curves.easeOut` in the app). Hover and focus changes take 150ms. State changes persist; nothing disappears on a timer.
- **Motion clarifies, never decorates.** The only things that move are the thing just tapped (a flip, a 1px press), a card lifting 3px on hover, and the hero prints settling on hover. No parallax, no autoplay, no looping ornament, no scroll-driven animation.
- **Celebration is quiet:** "All pairs together. Play again or take a break." plus a soft optional chime. No confetti, fireworks, stars, emoji or "Congratulations!".
- **Motion:** honor Reduce Motion (`MediaQuery.disableAnimations`, `prefers-reduced-motion`) by swapping flips and transitions for instant changes. Nothing flashes more than 3 times per second.
- **Sound:** always optional and never the only carrier of information. There are no failure sounds, and the tap sound is soft.
- **Haptics:** at most a light selection tick on a match, and none on a mismatch.
- **Ethical retention:** no streaks, daily-reward calendars, energy, lives, loot, countdowns, leaderboards, ads, push-notification nagging or purchase pressure. Return visits must come from a good experience.
- **Sharing:** word of mouth from one caregiver to another is the best way families find the app, so make sharing easy and ask rarely. See *Sharing* under Voice & Content.
- **Next deliberate tap, everywhere:** both the gentle board and the picture-pack game leave a mismatch face up, and a hint's pair visible, until the player taps again. That tap turns them over and starts the next turn. No game state changes on a timer.
- **One paced exception:** the website's calm breathing pause (`site/src/games/CalmBreathing.tsx`) changes its circle on a timer, because pacing is the activity. It starts only on a tap, stops on a tap or by itself after six breaths, announces only starting and stopping, and honors Reduce Motion. Its circle is the one place the full gold ramp appears at once (`accent-pale` → `primary-container` → `accent-deep`, with a 3px `primary` edge). No game uses this pattern.
- **Optional prompts** in Look Together are open-ended ("What do you notice in this picture?"). They are never "Who is this?" or "Do you remember…?".

## Voice & Content

Write plain, warm, adult English at about a US grade-6 reading level. Use short sentences, verbs on buttons and no jargon. The voice matches the type: a headline may be warm and a little literary ("Gentle games and activities for people with dementia"); the sentence under it is plain and practical.

| Do | Don't |
| --- | --- |
| "Start a gentle game" | "Play now!!" / "Train your brain" |
| "Take your time. Tap a picture to continue." | "Wrong! Try again" |
| "All pairs together. Play again or take a break." | "🎉 Congratulations! 12 moves in 0:43" |
| "Done for now" | "Quit game" / "Give up" |
| "What do you notice in this picture?" | "Who is this? Do you remember?" |
| "Copies stay on this device." | "Secure cloud AI sync" |

### Sharing

Make sharing easy to find and rare to be asked about. Share from a warm moment, never from a gate.

- **Always available, never pushed:** a quiet "Share with family" text button sits at the bottom of Home (`ShareWithFamilyButton`).
- **Suggested rarely, inline:** after a finished game, `ShareInvitation` can appear *inside* the end-of-game message, never as a separate pop-up. It reads "Enjoying these pictures together? Another family might enjoy them too." with one "Share with family" button.
- **When (`SharePolicy`):** first after the 3rd finished game, then at most once every 30 days. It stops for good after one share or after being passed by twice. Carrying on (Play again, Done for now, another pack) is a complete answer; there is no "Not now" decision to make.
- **Never:** during play, at launch, by notification, with a countdown, as a condition for continuing ("share to continue"), or in exchange for rewards or unlocks. Don't say "challenge" or "invite friends to compete".
- **The message** is plain and personal and carries the right store link for the device: Google Play on Android, the App Store on Apple devices once the listing exists, and search guidance until then. No tracking parameters.
- **Privacy:** the counters live only on this device (`shared_preferences`). Nothing is sent anywhere until the person chooses a share target.

Never use: brain age, score, IQ, train, sharpen, decline, therapy, treatment, prevent, clinically proven, "for patients" or medical symbols. Mentioning dementia or Alzheimer's describes the audience, not an outcome.

## Accessibility

Acceptance for any screen change. "Implemented" is not "verified"; record device checks in `docs/specs/release-status.json` only when they were actually performed.

- **Targets:** ≥48×48 for every control, ≥56 high for buttons, 64 for the Home hero action and tiles ≥64 (as large as the screen allows). Interactive elements are at least 8px apart.
- **Contrast:** text ≥4.5:1, with body text aimed at ≥7:1. Control boundaries and selection indicators are ≥3:1. Re-measure when a color token changes; the figures in the Colors tables are the record.
- **Text scale:** check 100%, 150% and 200%, portrait and landscape, on iPhone SE, iPhone Pro Max and iPad. Nothing essential clips or truncates. Fraunces is wider than Roboto, so re-check every headline that sits beside an icon or an action at 200%.
- **Screen readers:** every tile is a button with a positional label and a state value. Hidden tiles never leak their picture. Live regions announce turn guidance. Decorative icons, prints, glows and rules are excluded. Personal-photo labels are currently positional, so do not claim descriptive alt text.
- **Motion and sound:** the app and the website are fully usable with Reduce Motion on and the sound off.
- **Focus:** keyboard and switch-access focus is visible (a 3px `primary` ring, ≥3:1) and follows the reading order.
- **Store labels:** declare an App Store *Accessibility Nutrition Label* feature (VoiceOver, Larger Text, Sufficient Contrast, Reduced Motion, Differentiate Without Color) only after it has passed on a real device for the submitted build.

**Store design:** real UI dominates every screenshot, with one message per frame. Use consented or licensed demonstration pictures, never sensitive user content. No medical symbols, clinical badges, scores or invented reviews. Frame captions are Fraunces on parchment, over a single glow at most. See `docs/specs/screenshots.md` for sequence and release gates.

## Do's and Don'ts

- **Do** start the first activity in one tap with four visible pictures and no setup.
- **Do** use `Theme.of(context)` roles, `gm…` tokens and `--gm-*` custom properties. Add a token here before adding a new color, size or font in code.
- **Do** mount every picture on a Print White mat inside its linen card, and keep corners concentric (16 → 8 → 4).
- **Do** set headlines in Fraunces and everything that is read in Roboto, with generous space between them.
- **Do** pair every icon with a word and every color with a shape, icon or word.
- **Do** let content scroll and reflow at 200% text, in landscape and on iPad.
- **Do** keep "Done for now" or Back visible on every screen, and confirm before deleting copies.
- **Do** honor Reduce Motion and keep sound optional.
- **Don't** add clocks, move counters, scores, streaks, confetti, countdowns or auto-dismissing dialogs, anywhere in the app or on the website.
- **Don't** use bright gold (`accent`, `accent-pale`, `accent-deep`) for text or as the only outline, or color difficulty as green, orange or red.
- **Don't** set text below 16px, Fraunces below 24px, ALL CAPS, tightened tracking in body text, or a clamped text scale.
- **Don't** add a third typeface, a grey shadow, a second glow, a gradient behind body text or a dark mode.
- **Don't** auto-advance turns, auto-hide mismatches, or raise difficulty automatically.
- **Don't** use translucent backgrounds behind text, or pure white pages.
- **Don't** imply diagnosis, treatment, cognitive measurement or clinical validation in UI, copy or store art.

## References

- [DESIGN.md specification (Google Labs)](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md), [designmd.app](https://designmd.app/) and [designmd.ai](https://designmd.ai/): format and agent usage.
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/): 1.4.3/1.4.6 contrast, 1.4.11 non-text contrast, 2.2.1 timing adjustable, 2.3.1 flashes, 2.5.5/2.5.8 target size.
- [Apple HIG: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) and [Material 3 accessibility](https://m3.material.io/foundations/designing/overview).
- [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/): no essential timing, and not relying on color alone.
- [Fraunces](https://github.com/undercasetype/Fraunces) (SIL Open Font License 1.1) and [Roboto](https://github.com/googlefonts/roboto-classic): the two bundled families, with licence texts beside the font files.
- Systematic review of age-friendly mobile app design ([PMC12350549](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12350549/)), touchscreen guidelines for older adults with dementia ([University of Twente](https://essay.utwente.nl/essays/95898)), and [making software accessible for users with dementia](https://discovery.dundee.ac.uk/en/publications/making-software-accessible-for-users-with-dementia/).
