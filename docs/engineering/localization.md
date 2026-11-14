# Localization

This branch has 63 language codes: the 50 in release 1.7.0 (the 20 of 1.6.0 plus the
31 added for the top-50 expansion, 2026-11-01) and 13 added on 2026-11-06 so that every
App Store localization Apple lists is covered (Catalan, Czech, Danish, Greek, Finnish,
Hebrew, Croatian, Hungarian, Norwegian Bokmål, Portuguese (Portugal), Slovak, Slovenian
and Swedish). Apple listed 50 App Store localizations on that date, counting English
and its regional variants (en-AU, en-CA, en-GB). The three regional English variants are
not added: they would copy the US English listing and have to be kept in step with it.
English is the source; every other language falls back to English for anything not yet
translated. By
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
| Catalan | `ca` | `ca` |
| Czech | `cs` | `cs` |
| Danish | `da` | `da` |
| Greek | `el` | `el` |
| Finnish | `fi` | `fi` |
| Hebrew (right to left) | `he` | `he` |
| Croatian | `hr` | `hr` |
| Hungarian | `hu` | `hu` |
| Norwegian Bokmål | `nb` | `no` (App Store only) |
| Portuguese (Portugal) | `pt_PT` | `pt-PT` |
| Slovak | `sk` | `sk` |
| Slovenian | `sl` | `sl` |
| Swedish | `sv` | `sv` |

Portuguese: a device in Portugal gets `pt_PT`; every other Portuguese (with no region
or any other region) gets `pt_BR` (`resolveAppLocale` in `lib/l10n/l10n.dart`).

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
does not translate (to machine-translate with OpenCode, see
[opencode-translation.md](opencode-translation.md)). By hand, change all of these together: the ARB files, `LOCALES` in
`scripts/pack_text.py`, `CFBundleLocalizations` in `ios/Runner/Info.plist`, the
`.lproj` folders and the Xcode variant group, `knownRegions`, and
`locales_config.xml`. Then run `python3 scripts/pack_text.py` to add an empty
overlay for the new language.

When the English catalog in `assets/data/packs_index.json` changes, run
`python3 scripts/pack_text.py` to regenerate `packs_en.json`, then update the
overlays that translated the changed text.

## How the language is chosen

**App.** On first open the app follows the device's language list (`resolveAppLocale` in `lib/l10n/l10n.dart`). The person can choose another language on Home, under **Language** (`lib/features/language/`). That choice is saved on the phone under `app.language.v1` as a language tag and loads before the first frame (`lib/bootstrap.dart`). The first option in the picker, **Use this device's language**, clears the choice. A saved tag the app does not offer is ignored. The picker names each language in its own words from `lib/l10n/language_names.dart`, which is generated from the website's locale list.

**Website.** The language menu in the footer always lets the reader choose. On a first visit to the English home page, `site/src/components/LanguageChoice.astro` sends the reader to the first language their browser asks for that the site offers (`site/src/lib/language-choice.ts`). Any choice from the menu, English included, is stored in the `gm_lang` cookie for a year, and a stored choice is never overridden. The redirect uses `location.replace`, so Back does not return to English and redirect again. Other pages are never redirected.

**Sitemaps.** `/sitemap.xml` is the root index. It links to `/sitemap-en.xml` and to `/<prefix>/sitemap.xml` for every other published, indexable language (`site/src/lib/sitemap.ts`). A test fails if any indexable language is missing from the index (`site/src/lib/sitemap.test.ts`).

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
