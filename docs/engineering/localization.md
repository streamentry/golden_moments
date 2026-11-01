# Localization

The app offers 20 languages in the submitted 1.6.0, and 51 in this branch (the
31 added for the top-50 expansion, 2026-11-01: 50 languages, Chinese counting once). English is the source; every
other language falls back to English for anything not yet translated. By
maintainer decision (2026-10-31) the translations are machine-made and ship before native
review; `docs/specs/release-status.json` records each language as unreviewed
until a person who reads it has checked it (see `WORKBOARD.md`, GM-036, and
[native review](native-review.md) for the order, checklist and sign-off steps).
Run `python3 scripts/check_arb.py lib/l10n/arb/app_<locale>.arb` for a quick
check of keys, placeholders and plural structure, then `flutter gen-l10n`.

| Language | ARB / overlay name | Apple and Android name |
| --- | --- | --- |
| English (source) | `en` | `en` |
| Spanish | `es` | `es` |
| Portuguese (Brazil) | `pt_BR` | `pt-BR` |
| French | `fr` | `fr` |
| German | `de` | `de` |
| Italian | `it` | `it` |
| Dutch | `nl` | `nl` |
| Polish | `pl` | `pl` |
| Russian | `ru` | `ru` |
| Ukrainian | `uk` | `uk` |
| Turkish | `tr` | `tr` |
| Arabic (right to left) | `ar` | `ar` |
| Hindi | `hi` | `hi` |
| Japanese | `ja` | `ja` |
| Korean | `ko` | `ko` |
| Chinese, Simplified | `zh_Hans` | `zh-Hans` |
| Chinese, Traditional | `zh_Hant` | `zh-Hant` |
| Vietnamese | `vi` | `vi` |
| Indonesian | `id` | `id` |
| Thai | `th` | `th` |
| Bengali | `bn` | `bn` |
| Persian (right to left) | `fa` | `fa` |
| Hausa | `ha` | `ha` |
| Urdu (right to left) | `ur` | `ur` |
| Marathi | `mr` | `mr` |
| Telugu | `te` | `te` |
| Swahili | `sw` | `sw` |
| Punjabi | `pa` | `pa` |
| Filipino | `fil` | `fil` |
| Tamil | `ta` | `ta` |
| Amharic | `am` | `am` |
| Javanese | `jv` | `jv` |
| Gujarati | `gu` | `gu` |
| Kannada | `kn` | `kn` |
| Yoruba | `yo` | `yo` |
| Pashto (right to left) | `ps` | `ps` |
| Malay | `ms` | `ms` |
| Oromo | `om` | `om` |
| Burmese | `my` | `my` |
| Malayalam | `ml` | `ml` |
| Sindhi (right to left) | `sd` | `sd` |
| Odia | `or` | `or` |
| Uzbek | `uz` | `uz` |
| Igbo | `ig` | `ig` |
| Sundanese | `su` | `su` |
| Zulu | `zu` | `zu` |
| Azerbaijani | `az` | `az` |
| Somali | `so` | `so` |
| Assamese | `as` | `as` |
| Romanian | `ro` | `ro` |
| Nepali | `ne` | `ne` |

`lib/l10n/arb/app_pt.arb` and `app_zh.arb` exist only because the Flutter
generator needs a base file; the app never selects them, so leave them empty.

## Files a translator produces per language

Replace `<locale>` with the ARB name and `<lang>` with the Apple name above.

1. **App text: `lib/l10n/arb/app_<locale>.arb`.** Translate the values of
   `lib/l10n/arb/app_en.arb`, keeping every key and every `{placeholder}`
   exactly; read each `@key` description for context. Leave out a key to show
   it in English. Do not copy the `@key` metadata blocks.
2. **Picture-pack text: `assets/data/i18n/packs_<locale>.json`.** Copy
   `assets/data/i18n/packs_en.json` and translate the values: topic `name` and
   `description`, pack `title`, `description` and `theme`, and each picture
   caption under `images` (captions are read aloud on picture tiles). Keep every
   id unchanged. Delete any entry you do not translate; it then shows in
   English. Never edit `packs_en.json` by hand: it is generated.
3. **iOS system text: `ios/Runner/<lang>.lproj/InfoPlist.strings`.** Translate
   `NSPhotoLibraryUsageDescription`, the message iOS shows when the app first
   asks to choose photos. It must stay true: only chosen photos are copied, on
   this device, and the library is not scanned. Keep `CFBundleDisplayName` as
   `Golden Moments` unless the maintainer approves a local name.

The tone rules in `DESIGN.md` apply in every language: plain adult words, no
score, brain or clinical vocabulary, no praise with emoji, nothing that
promises a health benefit.

## How the app uses them

- ARB text comes from `AppLocalizations` (`context.l10n`).
- Picture-pack text comes from `PackText` (`context.packText`,
  `lib/l10n/pack_text.dart`), loaded by `PackTextDelegate` alongside the other
  localizations, so it follows a language change. It changes only what is
  shown: pack ids, saved choices and saved games stay English. A missing,
  damaged or partial overlay shows English field by field and never stops the
  app. English needs no overlay file at runtime.
- iOS picks `InfoPlist.strings` by the device or per-app language; the
  `.lproj` folders are bundled through the `InfoPlist.strings` variant group in
  `ios/Runner.xcodeproj` and listed in `CFBundleLocalizations` and
  `knownRegions`.
- Android 13 and later offer the languages in the per-app language setting from
  `android/app/src/main/res/xml/locales_config.xml`.

## Adding or changing languages

Run `python3 scripts/register_language.py <code>` (see `--list` for the
languages it knows). It makes every edit below in one step and is safe to run
again; then run `dart format test/l10n/arb_files_test.dart`. It registers, it
does not translate. By hand, change all of these together: the ARB files, `LOCALES` in
`scripts/pack_text.py`, `CFBundleLocalizations` in `ios/Runner/Info.plist`, the
`.lproj` folders and the Xcode variant group, `knownRegions`, and
`locales_config.xml`. Then run `python3 scripts/pack_text.py` to add an empty
overlay for the new language.

When the English catalog in `assets/data/packs_index.json` changes, run
`python3 scripts/pack_text.py` to regenerate `packs_en.json`, then update the
overlays that translated the changed text.

## Languages Flutter has no widget text for

Flutter's own Material and Cupertino widgets (back buttons, tooltips, dialog
labels) have text for about 115 languages. Hausa, Yoruba, Igbo, Javanese,
Sundanese, Oromo, Somali and Sindhi are not among them, and any Material widget
fails to build under such a language. `lib/l10n/fallback_localizations.dart`
supplies Flutter's English widget text for exactly those languages (the real
delegates still win everywhere else); the app's own text stays in the chosen
language. `test/l10n/fallback_localizations_test.dart` covers all eight. Checked
in the iOS simulator with Hausa.

## Checks

```sh
python3 scripts/pack_text.py --check          # overlays valid, packs_en current
python3 -m unittest tests.test_pack_text tests.test_platform_locales -v
flutter gen-l10n                              # ARB files compile
flutter test test/l10n                        # ARB parity, overlays, layout
```

The checks catch a stale `packs_en.json`, an overlay with an unknown id, a
non-text value or an unknown field, a missing overlay or `InfoPlist.strings`,
and platform language lists that differ from the ARB files. They cannot judge
translation quality or truthfulness. Native review should read each file,
then check the running app at 200% text, in Arabic right to left, and with
VoiceOver or TalkBack; until then the language is listed as unreviewed.
