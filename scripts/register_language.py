#!/usr/bin/env python3
"""Register app and website languages in every place that lists them.

Adding a language touches a dozen files (see docs/engineering/localization.md
and site/src/i18n/TRANSLATING.md). This script makes those edits together and
can be run again safely: a language that is already registered is skipped.

    python3 scripts/register_language.py bn fa ha     # named languages
    python3 scripts/register_language.py --all        # every language below
    python3 scripts/register_language.py --list

It registers; it does not translate. Translators still create the per-language
files (ARB, pack overlay, InfoPlist.strings, store draft, site dictionaries).
The check scripts and tests fail until those files exist.

The metadata below is the single source for the app and the site. Store
locales come from Apple's App Store localizations page and Google Play's
supported-languages page (checked 2026-11-01); an empty tuple means that store
has no locale for the language, so the listing draft is kept but not usable.
"""

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Platform fonts for scripts without a bundled font (site/src/styles/base.css).
ARABIC = "'Geeza Pro', 'Noto Naskh Arabic', 'Segoe UI', Tahoma, sans-serif"
DEVANAGARI = "'Kohinoor Devanagari', 'Noto Sans Devanagari', 'Nirmala UI', system-ui, sans-serif"
FONTS = {
    'Arab': ARABIC,
    'Deva': DEVANAGARI,
    'Beng': "'Kohinoor Bangla', 'Noto Sans Bengali', 'Nirmala UI', system-ui, sans-serif",
    'Telu': "'Kohinoor Telugu', 'Noto Sans Telugu', 'Nirmala UI', system-ui, sans-serif",
    'Taml': "'Tamil Sangam MN', 'Noto Sans Tamil', 'Nirmala UI', system-ui, sans-serif",
    'Gujr': "'Kohinoor Gujarati', 'Noto Sans Gujarati', 'Nirmala UI', system-ui, sans-serif",
    'Knda': "'Kannada Sangam MN', 'Noto Sans Kannada', 'Nirmala UI', system-ui, sans-serif",
    'Mlym': "'Malayalam Sangam MN', 'Noto Sans Malayalam', 'Nirmala UI', system-ui, sans-serif",
    'Guru': "'Gurmukhi Sangam MN', 'Noto Sans Gurmukhi', 'Nirmala UI', system-ui, sans-serif",
    'Orya': "'Oriya Sangam MN', 'Noto Sans Oriya', 'Nirmala UI', system-ui, sans-serif",
    'Ethi': "'Kefa', 'Noto Sans Ethiopic', 'Nyala', system-ui, sans-serif",
    'Mymr': "'Myanmar Sangam MN', 'Noto Sans Myanmar', 'Myanmar Text', system-ui, sans-serif",
}


@dataclass(frozen=True)
class Language:
    code: str  # website code and Apple/Android name, e.g. 'bn', 'zh-Hans'
    og: str  # Open Graph locale
    name: str  # native name, for the language menu
    english: str
    script: str = 'Latn'  # ISO 15924; a key of FONTS gets a platform font stack
    rtl: bool = False
    apple: tuple[str, ...] = ()  # App Store locales; () = none
    play: tuple[str, ...] = ()  # Google Play locales; () = none
    letter_grid: bool = True  # False: word search is left out for this language
    sayings: bool = True  # False: Finish the saying is left out (too few genuine sayings)
    index: bool = True  # False: pages are noindex until a native speaker has read them

    @property
    def arb(self) -> str:
        return self.code.replace('-', '_')

    @property
    def prefix(self) -> str:
        return self.code.lower()


LANGUAGES = {l.code: l for l in (
    Language('bn', 'bn_BD', 'বাংলা', 'Bengali', 'Beng', apple=('bn-BD',), play=('bn-BD',)),
    Language('ur', 'ur_PK', 'اردو', 'Urdu', 'Arab', True, ('ur-PK',), ('ur',)),
    Language('mr', 'mr_IN', 'मराठी', 'Marathi', 'Deva', apple=('mr-IN',), play=('mr-IN',)),
    Language('te', 'te_IN', 'తెలుగు', 'Telugu', 'Telu', apple=('te-IN',), play=('te-IN',)),
    Language('sw', 'sw_KE', 'Kiswahili', 'Swahili', play=('sw',)),
    Language('ha', 'ha_NG', 'Hausa', 'Hausa', sayings=False, index=False),
    Language('pa', 'pa_IN', 'ਪੰਜਾਬੀ', 'Punjabi (Gurmukhi)', 'Guru', apple=('pa-IN',), play=('pa',)),
    Language('fil', 'fil_PH', 'Filipino', 'Filipino', play=('fil',)),
    Language('ta', 'ta_IN', 'தமிழ்', 'Tamil', 'Taml', apple=('ta-IN',), play=('ta-IN',)),
    Language('fa', 'fa_IR', 'فارسی', 'Persian', 'Arab', True, play=('fa',)),
    Language('am', 'am_ET', 'አማርኛ', 'Amharic', 'Ethi', play=('am',)),
    Language('jv', 'jv_ID', 'Basa Jawa', 'Javanese'),
    Language('gu', 'gu_IN', 'ગુજરાતી', 'Gujarati', 'Gujr', apple=('gu-IN',), play=('gu',)),
    Language('kn', 'kn_IN', 'ಕನ್ನಡ', 'Kannada', 'Knda', apple=('kn-IN',), play=('kn-IN',)),
    Language('yo', 'yo_NG', 'Yorùbá', 'Yoruba'),
    Language('ps', 'ps_AF', 'پښتو', 'Pashto', 'Arab', True),
    Language('ms', 'ms_MY', 'Bahasa Melayu', 'Malay', apple=('ms',), play=('ms',)),
    Language('om', 'om_ET', 'Afaan Oromoo', 'Oromo'),
    Language('my', 'my_MM', 'မြန်မာ', 'Burmese', 'Mymr', play=('my-MM',), letter_grid=False),
    Language('ml', 'ml_IN', 'മലയാളം', 'Malayalam', 'Mlym', apple=('ml-IN',), play=('ml-IN',)),
    Language('sd', 'sd_PK', 'سنڌي', 'Sindhi', 'Arab', True),
    Language('or', 'or_IN', 'ଓଡ଼ିଆ', 'Odia', 'Orya', apple=('or-IN',)),
    Language('uz', 'uz_UZ', 'Oʻzbekcha', 'Uzbek'),
    Language('ig', 'ig_NG', 'Igbo', 'Igbo'),
    Language('su', 'su_ID', 'Basa Sunda', 'Sundanese'),
    Language('zu', 'zu_ZA', 'isiZulu', 'Zulu'),
    Language('az', 'az_AZ', 'Azərbaycan dili', 'Azerbaijani', play=('az-AZ',)),
    Language('so', 'so_SO', 'Soomaali', 'Somali'),
    Language('as', 'as_IN', 'অসমীয়া', 'Assamese', 'Beng'),
    Language('ro', 'ro_RO', 'Română', 'Romanian', apple=('ro',), play=('ro',)),
    Language('ne', 'ne_NP', 'नेपाली', 'Nepali', 'Deva', play=('ne-NP',)),
)}


def quoted_if_needed(value: str) -> str:
    """pbxproj leaves letters, digits and _ $ . / bare and quotes everything else (a hyphen)."""
    return value if re.fullmatch(r'[\w$./]+', value) else f'"{value}"'


def pbx_id(code: str) -> str:
    """A stable 24-hex object id for a language's InfoPlist.strings file reference."""
    return hashlib.sha1(f'GoldenMoments InfoPlist.strings {code}'.encode()).hexdigest()[:24].upper()


# Each editor takes the file text and a Language and returns new text. Editors
# are idempotent: they return the text unchanged when the language is present.

def edit_pack_text(text: str, lang: Language) -> str:
    match = re.search(r"LOCALES = \(\n(.*?)\n\)", text, re.S)
    assert match, 'LOCALES tuple not found in scripts/pack_text.py'
    names = re.findall(r"'([A-Za-z_]+)'", match.group(1))
    if lang.arb in names:
        return text
    names.append(lang.arb)
    lines, line = [], '   '
    for name in names:
        piece = f" '{name}',"
        if len(line) + len(piece) > 79:
            lines.append(line)
            line = '   '
        line += piece
    lines.append(line)
    return text[:match.start(1)] + '\n'.join(lines) + text[match.end(1):]


def edit_info_plist(text: str, lang: Language) -> str:
    block = re.search(r'(<key>CFBundleLocalizations</key>\s*<array>)(.*?)(</array>)', text, re.S)
    assert block, 'CFBundleLocalizations not found in Info.plist'
    if f'<string>{lang.code}</string>' in block.group(2):
        return text
    body = block.group(2).rstrip('\t \n') + f'\n\t\t<string>{lang.code}</string>\n\t'
    return text[:block.start(2)] + body + text[block.end(2):]


def edit_pbxproj(text: str, lang: Language) -> str:
    ident = pbx_id(lang.code)
    if f'path = {quoted_if_needed(lang.code + ".lproj/InfoPlist.strings")}' in text:
        return text
    assert ident not in text, f'pbx id collision for {lang.code}'
    ref = (f'\t\t{ident} /* {lang.code} */ = {{isa = PBXFileReference; includeInIndex = 1; '
           f'lastKnownFileType = text.plist.strings; name = {quoted_if_needed(lang.code)}; '
           f'path = {quoted_if_needed(lang.code + ".lproj/InfoPlist.strings")}; sourceTree = "<group>"; }};\n')
    refs = list(re.finditer(r'^\t\t[0-9A-F]{24} /\* [\w-]+ \*/ = \{isa = PBXFileReference;[^\n]*InfoPlist\.strings[^\n]*\n', text, re.M))
    assert refs, 'no InfoPlist.strings file references found'
    text = text[:refs[-1].end()] + ref + text[refs[-1].end():]
    regions = re.search(r'(knownRegions = \(\n)(.*?)(\t\t\t\);)', text, re.S)
    assert regions, 'knownRegions not found'
    text = text[:regions.end(2)] + f'\t\t\t\t{quoted_if_needed(lang.code)},\n' + text[regions.end(2):]
    group = re.search(r'(/\* InfoPlist\.strings \*/ = \{\s*isa = PBXVariantGroup;\s*children = \(\n)(.*?)(\t\t\t\);)', text, re.S)
    assert group, 'InfoPlist.strings variant group not found'
    return text[:group.end(2)] + f'\t\t\t\t{ident} /* {lang.code} */,\n' + text[group.end(2):]


def edit_locales_config(text: str, lang: Language) -> str:
    if f'android:name="{lang.code}"' in text:
        return text
    return text.replace('</locale-config>', f'    <locale android:name="{lang.code}" />\n</locale-config>', 1)


def edit_store_locales(text: str, lang: Language) -> str:
    if re.search(rf"^    '{re.escape(lang.code)}': ", text, re.M):
        return text
    entry = f"    '{lang.code}': ({_fmt(lang.apple)}, {_fmt(lang.play)}),\n"
    match = re.search(r"(LANGUAGES: dict[^\n]*\{\n.*?)(\n\})", text, re.S)
    assert match, 'LANGUAGES not found in scripts/store_locales.py'
    return text[:match.end(1)] + '\n' + entry.rstrip('\n') + text[match.end(1):]


def _fmt(values: tuple[str, ...]) -> str:
    if not values:
        return '()'
    return '(' + ', '.join(repr(v) for v in values) + (',' if len(values) == 1 else '') + ')'


def _add_to_list(text: str, name: str, code: str) -> str:
    match = re.search(rf"({name}: readonly string\[\] = \[)(.*?)(\];)", text, re.S)
    assert match, f'{name} not found in site/src/i18n/play.ts'
    if f"'{code}'" in match.group(2):
        return text
    sep = ', ' if match.group(2).strip() else ''
    return text[:match.end(2)] + f"{sep}'{code}'" + text[match.end(2):]


def edit_play_ts(text: str, lang: Language) -> str:
    if not lang.letter_grid:
        text = _add_to_list(text, 'NO_LETTER_GRID', lang.code)
    if not lang.sayings:
        text = _add_to_list(text, 'NO_SAYINGS_GAME', lang.code)
    return text


def edit_arb_test(text: str, lang: Language) -> str:
    """Append the language to the Dart set; run `dart format` on the file afterwards."""
    match = re.search(r"(const _appLocales = \{\n)(.*?)(\n\};)", text, re.S)
    assert match, '_appLocales not found in test/l10n/arb_files_test.dart'
    if f"'{lang.arb}'" in match.group(2):
        return text
    return text[:match.end(2)] + f"\n  '{lang.arb}'," + text[match.end(2):]


def edit_locales_ts(text: str, lang: Language) -> str:
    if f"code: '{lang.code}'," in text:
        return text
    entry = (f"  {{ code: '{lang.code}', prefix: '{lang.prefix}', bcp47: '{lang.code}', htmlLang: '{lang.code}', "
             f"og: '{lang.og}', name: '{lang.name}', englishName: '{lang.english}', dir: '{'rtl' if lang.rtl else 'ltr'}' }},\n")
    start = text.index('export const LOCALES')
    end = text.index('\n];', start)
    return text[:end + 1] + entry + text[end + 1:]


def edit_held_from_index(text: str, lang: Language) -> str:
    if lang.index:
        return text
    match = re.search(r"(HELD_FROM_INDEX: ReadonlySet<string> = new Set\(\[)(.*?)(\]\);)", text, re.S)
    assert match, 'HELD_FROM_INDEX not found in site/src/i18n/locales.ts'
    if f"'{lang.code}'" in match.group(2):
        return text
    sep = ', ' if match.group(2).strip() else ''
    return text[:match.end(2)] + f"{sep}'{lang.code}'" + text[match.end(2):]


def edit_base_css(text: str, lang: Language) -> str:
    if lang.script not in FONTS or f':root:lang({lang.code})' in text:
        return text
    block = (f":root:lang({lang.code}) {{\n  --font-sans: {FONTS[lang.script]};\n  --font-display: var(--font-sans);\n}}\n")
    marker = '\n/* Arrows point the way the text reads. */'
    assert marker in text, 'font-stack marker not found in base.css'
    return text.replace(marker, block + marker, 1)


def _add_to_set(text: str, name: str, prefix: str) -> str:
    match = re.search(rf"(const {name} = new Set\(\[)(.*?)(\]\);)", text, re.S)
    assert match, f'{name} not found in site/scripts/check-site.mjs'
    if f"'{prefix}'" in match.group(2):
        return text
    sep = ', ' if match.group(2).strip() else ''
    return text[:match.end(2)] + f"{sep}'{prefix}'" + text[match.end(2):]


def edit_check_site(text: str, lang: Language) -> str:
    text = _add_to_set(text, 'LOCALE_PREFIXES', lang.prefix)
    if lang.rtl:
        text = _add_to_set(text, 'RTL_PREFIXES', lang.prefix)
    return text


def edit_release_status(text: str, lang: Language) -> str:
    data = json.loads(text)
    languages = data['localization']['languages']
    if lang.code in languages:
        return text
    languages[lang.code] = {'status': 'unreviewed', 'reviewer': None, 'evidence': None, 'date': None}
    indent = 2 if '\n  "' in text else 4
    return json.dumps(data, indent=indent, ensure_ascii=False) + ('\n' if text.endswith('\n') else '')


EDITORS = (
    ('scripts/pack_text.py', edit_pack_text),
    ('ios/Runner/Info.plist', edit_info_plist),
    ('ios/Runner.xcodeproj/project.pbxproj', edit_pbxproj),
    ('android/app/src/main/res/xml/locales_config.xml', edit_locales_config),
    ('scripts/store_locales.py', edit_store_locales),
    ('site/src/i18n/play.ts', edit_play_ts),
    ('test/l10n/arb_files_test.dart', edit_arb_test),
    ('site/src/i18n/locales.ts', edit_locales_ts),
    ('site/src/i18n/locales.ts', edit_held_from_index),
    ('site/src/styles/base.css', edit_base_css),
    ('site/scripts/check-site.mjs', edit_check_site),
    ('docs/specs/release-status.json', edit_release_status),
)


def register(codes: list[str], root: Path = ROOT) -> dict[str, int]:
    """Apply every editor for each language; returns files changed per language."""
    changed = {}
    for code in codes:
        lang = LANGUAGES[code]
        count = 0
        for rel, editor in EDITORS:
            path = root / rel
            before = path.read_text(encoding='utf-8')
            after = editor(before, lang)
            if after != before:
                path.write_text(after, encoding='utf-8')
                count += 1
        changed[code] = count
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('codes', nargs='*', help='language codes to register')
    parser.add_argument('--all', action='store_true', help='register every language in the table')
    parser.add_argument('--list', action='store_true', help='print the table and exit')
    args = parser.parse_args()
    if args.list:
        for lang in LANGUAGES.values():
            print(f'{lang.code}\t{lang.english}\t{lang.script}\t{"rtl" if lang.rtl else "ltr"}\tapple={list(lang.apple)}\tplay={list(lang.play)}')
        return 0
    codes = list(LANGUAGES) if args.all else args.codes
    unknown = [c for c in codes if c not in LANGUAGES]
    if unknown or not codes:
        sys.exit(f'Unknown or missing languages: {unknown or "none given"}. Use --list.')
    for code, count in register(codes).items():
        print(f'{code}: {count} file(s) changed' if count else f'{code}: already registered')
    return 0


if __name__ == '__main__':
    sys.exit(main())
