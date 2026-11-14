# Translating with OpenCode

How to close the remaining language gap with OpenCode as the translation
sub-agent. It complements [localization](localization.md) and
`site/src/i18n/TRANSLATING.md`; those stay the rules. All output is machine-made
and stays marked unreviewed (AGENTS.md).

## Tool

`scripts/opencode_translate.py` calls `opencode run -m <model>` and writes a file
only when the repo's own checker passes:

| Command | Writes | Checked by |
| --- | --- | --- |
| `gaps` | nothing; lists what is missing | |
| `app <code> "<Language>" -m <model>` | `lib/l10n/arb/app_<code>.arb`, `assets/data/i18n/packs_<code>.json`, `ios/Runner/<code>.lproj/InfoPlist.strings`, `metadata/i18n/<code>.json` | `scripts/check_arb.py`, overlay shape, `scripts/store_locales.py` rules |
| `guides <code> "<Language>" -m <model> [--limit N]` | missing or English-copy guides in `site/src/content/guides-i18n/<code>/` | `site/scripts/check-guide-translation.py`, plus no `911`, no `!`, not mostly English |

The store draft needs the language in `scripts/store_locales.py` first, so run
`app` once, review, register, then run `app` again for the store draft (the
other files are rewritten).

To run the whole job as a Claude Code `/goal`, paste the text in
[OpenCode translation goal](opencode-goal.md).

## Per language, in order

1. **Translate the app text:** `python3 scripts/opencode_translate.py app <code> "<Language (script)>" -m <model>`.
2. **Quality review** by a different model than the translator (a Claude
   sub-agent is fine): read the ARB, overlay and store draft and answer
   SHIPPABLE or NOT SHIPPABLE as unreviewed machine translation, listing
   wrong-meaning, reversed-negation, invented-word and safety-wording defects.
   NOT SHIPPABLE: delete that language's files and do not register it.
3. **Register:** add a `Language(...)` entry to `scripts/register_language.py`
   if it is not listed (`--list`), then run
   `python3 scripts/register_language.py <code>` and
   `dart format test/l10n/arb_files_test.dart`.
4. **Also by hand:** add the code to `LOW_CONFIDENCE_LOCALES` in
   `site/src/data/illustration-names.test.ts` (picture names stay English).
5. **Store draft:** run step 1 again so `metadata/i18n/<code>.json` is written.
6. **Guides:** `python3 scripts/opencode_translate.py guides <code> "<Language>" -m <model>`,
   then the same review on a sample of at least 5 guides, health guides first.

## Checks before every commit

```sh
python3 scripts/pack_text.py --check
python3 scripts/store_locales.py --check
python3 scripts/release_metadata.py --check
python3 -m unittest discover -s tests -p 'test_*.py'
flutter gen-l10n && dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings && flutter test
cd site && pnpm exec vitest run
```

For guide batches also run `NODE_OPTIONS=--max-old-space-size=12288 pnpm exec astro build`
and `NODE_OPTIONS=--max-old-space-size=12288 node scripts/check-site.mjs` in `site/`.
New language names in Markdown need adding to `.github/cspell.json`.

## Known traps (seen in the 2026-11 batches)

- U.S. helpline numbers: `todayWornOutTry2/3` must name no 1-800 number outside English.
- Store names: a localized prefix rarely fits 30 characters; plain "Golden Moments" is fine.
  Keywords are counted in UTF-8 bytes, so non-Latin scripts fit few terms.
- `test/l10n/arb_files_test.dart` uses an unoffered language (`ie`) as an example;
  if you add that language, switch the example to another unoffered code.
- `lib/l10n/language_names.dart` has no `gn` entry (the native name has an apostrophe);
  fix that generator before adding Guarani.
- `web-visual` once failed on a Play button "outside of the viewport" and passed on
  the next run and locally; diagnose before calling a failure unrelated.
- Guides reverted for wrong health wording (Xhosa, Yoruba, Tatar, Turkmen,
  Kinyarwanda, Samoan, Breton, Setswana, Romansh, two Tajik guides) and app languages
  dropped as NOT SHIPPABLE (Tigrinya, Tibetan, Dhivehi, Wolof, Luganda, Chuvash,
  Ossetian, Northern Sami) need a stronger model or a native translator.
