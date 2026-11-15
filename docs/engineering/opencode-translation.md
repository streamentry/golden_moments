# Translating with OpenCode

How to close the remaining language gap with OpenCode as the translation
sub-agent. It complements [localization](localization.md) and
`site/src/i18n/TRANSLATING.md`; those stay the rules. All output is machine-made
and stays marked unreviewed (AGENTS.md).

## Tool

`scripts/opencode_translate.py` calls `opencode run -m <model>` and writes a file
only when the repo's own checker passes. Use `opencode/deepseek-v4.1-flash` for
translation; the project OpenCode config sets it as the default for new sessions:

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
- Bihari (`bh`) is blocked: the Library of Congress identifies `bih` as the
  Bihari languages remainder group and records `bh` as deprecated, while this
  repo labels the native name as Bhojpuri. One variety should not stand in for
  the whole group without a maintainer decision. [LOC code changes](https://www.loc.gov/standards/iso639-2/php/code_changes.php)
- Fulah (`ff`), Zhuang (`za`) and Kanuri (`kr`) are blocked for now: the
  OpenCode paid route had no balance and its free DeepSeek Flash request timed
  out on the first language; a Go-route probe also reported its monthly usage
  limit reached, and no Extra Usage was enabled. Codex Luna then could not
  produce reliable full app translations from the existing site wording. No
  app files were registered; retry with a capable model or a native translator.
- Twi (`tw`) is blocked for now: Codex Luna could not verify natural Twi from
  the existing site text, so it left the app files untouched. Revisit with a
  Twi-capable model or a native translator.
- Kashmiri (`ks`) and Sango (`sg`) are also blocked: the Codex Luna fallback
  could not reliably produce the full app text in the target language, so it
  left their files untouched. Revisit with a capable model or native translators.
- Aymara (`ay`), Xitsonga (`ts`) and Swati (`ss`) are blocked for now: Codex
  Luna could not reliably produce the full app translations, and the existing
  site text was too inconsistent to ground them. No files were written; retry
  with a capable model or native translators.
- Afar (`aa`), Nuosu (`ii`) and North Ndebele (`nd`) are blocked: Codex Luna
  could not produce reliable app text from the available site references, which
  were inconsistent, unreviewed or English. No files were written; retry with
  a capable model or native translators.
- Kwanyama (`kj`) and Ndonga (`ng`) are blocked: Codex Luna could not reliably
  author or validate the full privacy, caregiver-support, and safety text from
  the narrow, unreviewed site terminology. No files were written; retry with
  capable models or native translators.
- Fijian (`fj`) and Samoan (`sm`) are blocked: Codex Luna could not validate
  the full safety and caregiver text from the inconsistent, English-heavy site
  references. No files were written; retry with capable models or native
  translators.
- Herero (`hz`) is blocked: Codex Luna could not reliably translate the full
  app and pack content from the available terminology references. No files
  were written; retry with a capable model or native translator.
- Breton (`br`), Abkhaz (`ab`) and Kalaallisut (`kl`) are blocked: Codex Luna
  could not safely translate the complete app from existing, unreviewed site
  text or limited terminology references. No files were written; retry with
  capable models or native translators.
- Bislama (`bi`) and Inuktitut (`iu`) are blocked: Codex Luna could not
  reliably produce the full safety-sensitive app text from the existing site
  references. No files were written; retry with capable models or native
  translators.
- Plains Cree (`cr`) is blocked: Codex Luna could not reliably translate the
  full app and pack copy in Canadian Aboriginal syllabics from the unreviewed
  site dictionaries. No files were written; retry with a Cree-capable model or
  a native translator.
- Ojibwe (`oj`) is blocked: Codex Luna could not reliably translate the full
  app from the inconsistent site UI/play references, especially the crisis and
  privacy copy. No files were written; retry with an Ojibwe-capable model or a
  native translator.
- Navajo (`nv`) is blocked: Codex Luna could not verify a full app translation
  from site strings that mix English and Navajo. No files were written; retry
  with a Navajo-capable model or a native translator.
- Tahitian (`ty`) and Nauruan (`na`) are blocked: Codex Luna could not
  translate the 455 app strings reliably from the inconsistent site references,
  and no fluent reader was available. No files were written; retry with capable
  models or native translators.
- Inupiaq (`ik`) is blocked: Codex Luna could not reliably author the app text
  from the rough site references, especially local-support wording. No files
  were written; retry with an Inupiaq-capable model or native translator.
- Interlingue (`ie`), Volapük (`vo`) and Pali (`pi`) are blocked: Codex Luna
  could not reliably translate the full app, and the existing site material is
  insufficient for safety, privacy and caregiver-support wording. No files
  were written; retry with capable models or qualified translators.
- Avestan (`ae`) is blocked: the language is preserved in an ancient religious
  corpus, and its referenced dictionary is outdated for modern caregiver,
  privacy and safety wording. No files were written; do not invent modern terms.
  [Avestan language, Encyclopaedia Iranica](https://www.iranicaonline.org/articles/avestan-language/)
- Old Church Slavonic (`cu`) is blocked: the surviving corpus is historical and
  ecclesiastical, with no native speakers or modern UI standard for caregiver
  and safety instructions. No files were written; a qualified Slavist would
  need to define and review any modern adaptation.
- Komi (`kv`) is blocked: Codex Luna could not translate the full app reliably
  from the available site text, particularly safety and privacy copy. No files
  were written; retry with a Komi-capable model or native translator.
- Manx (`gv`) and Cornish (`kw`) are blocked: Codex Luna could not reliably
  translate the full app from the inconsistent site references, particularly
  the privacy, recovery and safety copy. No files were written; retry with
  capable models or native translators.
- Tongan (`to`) is blocked: Codex Luna could not reliably produce the full app
  translation from the inconsistent existing site text. No files were written;
  retry with a Tongan-capable model or native translator.
- Hiri Motu (`ho`), Chamorro (`ch`), Dzongkha (`dz`) and Marshallese (`mh`)
  are blocked: Codex Luna could not reliably translate the full safety,
  privacy, and caregiver copy from the available site references. No files
  were written; retry with capable models or native translators.
- Breton (`br`) and Turkmen (`tk`) app text are deferred under the known-traps
  rule: prior guide translations failed health wording, and the available
  fallback is not clearly stronger. Retry only with a stronger model or native
  translators.
- Romansh (`rm`) app text is deferred for the same reason: prior guide
  translations failed health wording, and the available fallback is not clearly
  stronger. Retry only with a stronger model or native translators.
- Tajik (`tg`) currently has two guide files blocked: the prior translation
  failed health wording, and the available model is not clearly stronger. Keep
  those files on English fallback until a stronger model or native translator
  can review them.
- Lingala (`ln`) guides are blocked after the first health-guide review: the
  Alzheimer’s guide lost hedges, added an invented definition, and mistranslated
  core advice (including “stop” and “trust”). Its generated file was reverted.
- Uyghur (`ug`) guides are blocked after the first health-guide review: the
  treatment disclaimer contains a malformed word for “slow,” and several game
  terms are made up or inconsistent. Its generated file was reverted.
- Chichewa (`ny`) guides are blocked after the first health-guide review: the
  Alzheimer’s guide translates “dementia” as “forgetting,” changing its
  definition and a prevalence statistic. Its generated file was reverted.
- Quechua (`qu`) guides are blocked after the first health-guide review: the
  Alzheimer’s guide's double negation could imply games may treat Alzheimer’s,
  and it conflates dementia with memory loss. Its generated file was reverted.
- Bashkir (`ba`) guides are blocked after the health-guide review found a
  flipped treatment disclaimer, lost hedges, invented or incorrect terms, and
  other meaning changes. All 51 existing Bashkir guide files were removed so
  the site uses English fallback; retry only with a stronger translator and
  native-speaker review.
- Shona (`sn`) guides are blocked after the health-guide review found missing
  health hedges and a late-stage statement changed from possibility to
  certainty, along with other meaning changes. The generated guide was
  reverted; retry only with a stronger Shona translator and native-speaker
  review.
- Aragonese (`an`) guides are blocked after two Claude reviews. After one
  correction, the second review still found likely invented or malformed verbs,
  mixed verb forms, and inconsistent reader address. All 67 existing guide
  files were removed so the site uses English fallback; retry only with a
  stronger Aragonese translator and native-speaker review.
- Ido (`io`) guides are blocked pending qualified native-speaker review. The
  final Claude review found unresolved terminology and meaning issues in the
  health guide, including touch/tap forms, the word for a team, a health verb,
  and how the card game Bridge is identified. Health claims, privacy, and
  negations passed. Keep all 51 existing Ido guides in place, unreviewed, until
  a qualified Ido reviewer resolves these findings; do not treat them as
  shippable.
- Southern Sotho (`st`) guides are blocked pending qualified native-speaker
  review. The second Claude review found the health-guide description still
  drops “often” and flagged a malformed form for “folded.” Keep the one
  generated health guide in place and unreviewed; do not treat the locale as
  shippable until a qualified Sesotho reviewer resolves these findings.
- Sanskrit (`sa`) guides are blocked after the first health-guide review found
  multiple meaning changes, including a garden bed translated as a sleeping bed,
  TV as telephone, caregiver instructions changed to “put everything outside,”
  and a non-voluntary change to a late-stage ability statement. The generated
  guide was reverted; retry only with a qualified Sanskrit linguist and native
  review.
- Yoruba (`yo`) guides are blocked after a prior health-guide review found
  incorrect health wording. All 43 existing Yoruba guide files were removed so
  the site uses English fallback; retry only with a stronger translator and
  qualified Yoruba review.
- Chechen (`ce`) is blocked: the Codex Luna fallback found that the existing
  site references contain mixed-script, garbled and Russian text, and could not
  safely translate the full app from them. No files were written; retry with a
  Chechen-capable model or native translator.
- Venda (`ve`) and South Ndebele (`nr`) are blocked: Codex Luna could not
  produce reliable app copy from the inconsistent or insufficient site
  references. No files were written; retry with capable models or native
  translators.
- Limburgish (`li`) is blocked: Codex Luna could not reliably translate the
  full app from the incomplete site terminology references without guessing at
  privacy, safety and caregiver language. No files were written; retry with a
  Limburgish-capable model or native translator.
- Avar (`av`), Sardinian (`sc`) and Walloon (`wa`) are blocked: Codex Luna
  could not independently translate the full app reliably, and the existing
  site text was inconsistent or unverified. No files were written; retry with
  capable models or native translators.
- `web-visual` once failed on a Play button "outside of the viewport" and passed on
  the next run and locally; diagnose before calling a failure unrelated.
- App Xhosa (`xh`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found that most ARB and pack values were Zulu or mixed Zulu/Xhosa, with wrong
  privacy and safety wording and English leakage. Its files were deleted; retry
  only with a stronger model or a native translator.
- South Azerbaijani (`azb`) was NOT SHIPPABLE in the 2026-11-14 draft: the
  Claude review found lost negations in privacy/reminder copy, reversed counts,
  incorrect Back/Hidden labels, and mixed scripts. Its files were deleted and
  it was not registered. A dictionary reference was found, but the draft needs
  a stronger translator or native reviewer before it can be retried.
- Bambara (`bm`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found that dementia was conflated with reminders, privacy/control meanings
  were reversed, safety guidance was garbled, and pack names were wrong. Its
  files were deleted and it was not registered; retry only with a stronger
  model or a native translator.
- Kinyarwanda (`rw`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude
  review found a false app-deletion/privacy claim, inaccurate photo-backup
  wording, wrong animal captions, and duplicate weekday chips. Its files were
  deleted and it was not registered; retry only with a stronger model or a
  native translator.
- Akan (`ak`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found a reversed hearing-loss health claim and many wrong pack animal labels.
  Its files were deleted and it was not registered; retry only with a stronger
  model or a native translator.
- Kirundi (`rn`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found reminder controls with the same reversed action, a false app-deletion
  privacy statement, and wrong animal and weekday labels. Its files were
  deleted and it was not registered; retry only with a stronger model or a
  native translator.
- Kikuyu (`ki`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found reversed privacy/legal conditions, wrong reminder timing, and many
  incorrect picture captions. Its files were deleted and it was not registered;
  retry only with a stronger model or a native translator.
- Setswana (`tn`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found a broken negation in the medical disclaimer, incorrect no-timer wording,
  duplicate weekday labels, and wrong picture captions. Its files were deleted
  and it was not registered; retry only with a stronger model or a native
  translator.
- Kongo (`kg`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found a medical claim, a reversed legal condition, false reminder timing,
  wrong picture captions and advice, and text in Kituba rather than the `kg`
  target variety. Its files were deleted and it was not registered; retry only
  with a stronger model or a native translator.
- Guarani (`gn`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found wrong picture captions, wrong controls, garbled safety language, and a
  missing negation in the iOS photo-library statement. Its files were deleted
  and it was not registered. The language-name generator fix remains in place;
  retry the translation only with a stronger model or a native translator.
- Tatar (`tt`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found an ambiguous medical disclaimer, reversed photo/pair counts, and a
  mistranslated stop button. Its files were deleted and it was not registered;
  retry only with a stronger model or a native translator.
- Ewe (`ee`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude review
  found missing negations in privacy and health copy, incorrect safety and
  picture-caption meanings, and English leakage. Its files were deleted and it
  was not registered; retry only with a stronger model or a native translator.
- Luba-Katanga (`lu`) was NOT SHIPPABLE in the 2026-11-14 draft: the Claude
  review found the text was mainly Tshiluba rather than Kiluba, with false
  safety guidance, unreliable health hedges, and wrong pack captions. Its files
  were deleted and it was not registered; retry only with a stronger model or
  a native Kiluba translator.
- Guides were reverted for wrong health wording (Xhosa, Tatar, Turkmen,
  Kinyarwanda, Samoan, Breton, Setswana, Romansh, two Tajik guides). Other app
  languages dropped as NOT SHIPPABLE—Tigrinya (`ti`), Tibetan (`bo`), Dhivehi
  (`dv`), Wolof (`wo`), Luganda (`lg`), Chuvash (`cv`), Ossetian (`os`) and
  Northern Sami (`se`)—need a stronger model or a native translator.
