# Loop run 2026-11-09 (third pass): centred reading text in the app

Purpose: the same loop prompt as [loop-2026-11-08.md](loop-2026-11-08.md). Earlier 2026-11-09 passes are in [loop-2026-11-09.md](loop-2026-11-09.md) (line height) and [loop-2026-11-09-claims.md](loop-2026-11-09-claims.md) (claims and meta descriptions).

## Searched

Standard searches and one page fetch. Snippets are not evidence on their own.

1. **AbilityNet, "Designing for Dementia" (2025 fact sheet, read as a search snippet):** "Where possible, use left-aligned text, and avoid centred or fully justified text." Source: <https://abilitynet.org.uk/factsheets/designing-dementia>.
2. **W3C WAI, "Developing Websites for Older People" (snippet):** avoid fully aligned text (technique C19) and text style that makes reading harder for older people. Source: <https://www.w3.org/WAI/older-users/developing/>.
3. **Image and link wording:** checked the built site for images without alt text (none; 79,855 images have `alt=""`. The pictures page checked by hand pairs each one with a visible name, so the empty alt is correct there, but the other pages were not checked one by one), duplicate IDs (none in 11,823 pages), and ARIA or in-page references to missing IDs (none). These checks conform, so no change.

## Finding

The audit row for alignment ([audit-2026-11-07.md](audit-2026-11-07.md)) checked only justified text and marked the row "Conforms". It did not check centred text. `DESIGN.md` already says: "Left-align reading text. Center only short one-line titles in dialogs or empty states." The app broke that rule in nine places where multi-line reading copy was centred:

| File | Text |
| --- | --- |
| `features/home/presentation/screens/home_page.dart` | library error body |
| `features/home/presentation/widgets/daily_packs_section.dart` | empty-state message |
| `features/home/presentation/widgets/library_section.dart` | library empty body |
| `features/category/presentation/screens/category_page.dart` | category empty body |
| `features/pack/presentation/screens/pack_page.dart` | "choices slow" note; pack empty body |
| `features/game/presentation/screens/game_page.dart` | game error body |
| `features/gentle_activities/presentation/photo_together_page.dart` | conversation prompt |
| `features/wellbeing/presentation/daily_moment_page.dart` | daily prompt |

## Change

Removed `textAlign: TextAlign.center` from those nine `Text` widgets, so they use the default (left in left-to-right languages, start-aligned in right-to-left languages, which is what the app wants). Titles, buttons, counters, picture names and short confirmations stay centred, as `DESIGN.md` allows. The formatter also collapsed two multi-line calls to one line; no text changed.

## Verification

- `flutter analyze --fatal-infos --fatal-warnings`: no issues.
- `dart format`: no changes.
- `flutter test`: 686 of 686 pass.

## Not verified

- No visual check of the changed screens on a device or at 200% text. The layouts are simpler (left-aligned), so they should not overflow, but that is not shown here.
- Right-to-left languages (Arabic, Persian, Hebrew, Urdu, and others) were not rendered. Start alignment follows the locale automatically.
- There is no regression guard. A future centred body paragraph would not fail a test. A guard would need a list of the approved centred labels, which would be a larger change.

## Next idea

A guard test that lists the approved centred labels and fails when a new one appears without review. This also needs the decision on how strict the rule should be for buttons and dialog titles.
