#!/usr/bin/env python3
"""Upgrade the website to support all languages from docs/languages.csv.

Registers every language in:
- site/src/i18n/locales.ts
- site/src/i18n/ui/<code>.json
- site/src/i18n/games/<code>.json
- site/src/content/guides-i18n/<code>/
- site/src/i18n/play.ts (NO_SAYINGS_GAME and NO_LETTER_GRID)
- site/scripts/check-site.mjs (LOCALE_PREFIXES and RTL_PREFIXES)
- lib/l10n/language_names.dart (nativeLanguageNames)
"""

from __future__ import annotations

import csv
import json
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

OG_COUNTRIES = {
    'aa': 'ET', 'ab': 'GE', 'ae': 'IR', 'af': 'ZA', 'ak': 'GH', 'am': 'ET',
    'an': 'ES', 'ar': 'AR', 'as': 'IN', 'av': 'RU', 'ay': 'BO', 'az': 'AZ',
    'azb': 'IR', 'ba': 'RU', 'be': 'BY', 'bg': 'BG', 'bh': 'IN', 'bi': 'VU',
    'bm': 'ML', 'bn': 'BD', 'bo': 'CN', 'br': 'FR', 'bs': 'BA', 'ca': 'ES',
    'ce': 'RU', 'ch': 'GU', 'co': 'FR', 'cr': 'CA', 'cs': 'CZ', 'cu': 'BG',
    'cv': 'RU', 'cy': 'GB', 'da': 'DK', 'de': 'DE', 'dv': 'MV', 'dz': 'BT',
    'ee': 'GH', 'el': 'GR', 'en': 'US', 'eo': '001', 'es': 'ES', 'et': 'EE',
    'eu': 'ES', 'fa': 'IR', 'ff': 'SN', 'fi': 'FI', 'fj': 'FJ', 'fo': 'FO',
    'fr': 'FR', 'fy': 'NL', 'ga': 'IE', 'gd': 'GB', 'gl': 'ES', 'gn': 'PY',
    'gu': 'IN', 'gv': 'IM', 'ha': 'NG', 'he': 'IL', 'hi': 'IN', 'ho': 'PG',
    'hr': 'HR', 'ht': 'HT', 'hu': 'HU', 'hy': 'AM', 'hz': 'NA', 'ia': '001',
    'id': 'ID', 'ie': '001', 'ig': 'NG', 'ii': 'CN', 'ik': 'US', 'io': '001',
    'is': 'IS', 'it': 'IT', 'iu': 'CA', 'ja': 'JP', 'jv': 'ID', 'ka': 'GE',
    'kg': 'CD', 'ki': 'KE', 'kj': 'AO', 'kk': 'KZ', 'kl': 'GL', 'km': 'KH',
    'kn': 'IN', 'ko': 'KR', 'kr': 'NG', 'ks': 'IN', 'ku': 'TR', 'kv': 'RU',
    'kw': 'GB', 'ky': 'KG', 'la': 'VA', 'lb': 'LU', 'lg': 'UG', 'li': 'NL',
    'ln': 'CD', 'lo': 'LA', 'lt': 'LT', 'lu': 'CD', 'lv': 'LV', 'mg': 'MG',
    'mh': 'MH', 'mi': 'NZ', 'mk': 'MK', 'ml': 'IN', 'mn': 'MN', 'mr': 'IN',
    'ms': 'MY', 'mt': 'MT', 'my': 'MM', 'na': 'NR', 'nb': 'NO', 'nd': 'ZW',
    'ne': 'NP', 'ng': 'NA', 'nl': 'NL', 'nn': 'NO', 'no': 'NO', 'nr': 'ZA',
    'nv': 'US', 'ny': 'MW', 'oc': 'FR', 'oj': 'CA', 'om': 'ET', 'or': 'IN',
    'os': 'GE', 'pa': 'IN', 'pi': 'IN', 'pl': 'PL', 'ps': 'AF', 'pt': 'PT',
    'qu': 'PE', 'rm': 'CH', 'rn': 'BI', 'ro': 'RO', 'ru': 'RU', 'rw': 'RW',
    'sa': 'IN', 'sc': 'IT', 'sd': 'PK', 'se': 'NO', 'sg': 'CF', 'si': 'LK',
    'sk': 'SK', 'sl': 'SI', 'sm': 'WS', 'sn': 'ZW', 'so': 'SO', 'sq': 'AL',
    'sr': 'RS', 'ss': 'SZ', 'st': 'LS', 'su': 'ID', 'sv': 'SE', 'sw': 'KE',
    'ta': 'IN', 'te': 'IN', 'tg': 'TJ', 'th': 'TH', 'ti': 'ER', 'tk': 'TM',
    'tl': 'PH', 'tn': 'BW', 'to': 'TO', 'tr': 'TR', 'ts': 'ZA', 'tt': 'RU',
    'tw': 'GH', 'ty': 'PF', 'ug': 'CN', 'uk': 'UA', 'ur': 'PK', 'uz': 'UZ',
    've': 'ZA', 'vi': 'VN', 'vo': '001', 'wa': 'BE', 'wo': 'SN', 'xh': 'ZA',
    'yi': '001', 'yo': 'NG', 'za': 'CN', 'zh': 'CN', 'zu': 'ZA'
}

RTL_CODES = {'ar', 'fa', 'ur', 'ps', 'sd', 'he', 'ug', 'yi', 'dv', 'ks', 'azb'}
NO_GRID_SCRIPTS = {'zh', 'bo', 'dz', 'km', 'lo', 'ii'}

CUSTOM_NATIVE = {
    'ab': 'Аҧсуа бызшәа',
    'av': 'Авар мацӀ',
    'ba': 'Башҡорт теле',
    'be': 'Беларуская',
    'bg': 'Български',
    'bi': 'Bislama',
    'bm': 'Bamanankan',
    'bo': 'བོད་ཡིག',
    'br': 'Brezhoneg',
    'bs': 'Bosanski',
    'ce': 'Нохчийн мотт',
    'co': 'Corsu',
    'cr': 'ᓀᐦᐃᔭᐍᐏᐣ',
    'cu': 'Ѩзыкъ словѣньскъ',
    'cv': 'Чӑваш чӗлхи',
    'cy': 'Cymraeg',
    'dv': 'ދިވެހި',
    'dz': 'རྫོང་ཁ',
    'ee': 'Eʋegbe',
    'eo': 'Esperanto',
    'et': 'Eesti',
    'eu': 'Euskara',
    'ff': 'Fulfulde',
    'fj': 'Vosa Vakaviti',
    'fo': 'Føroyskt',
    'fy': 'Frysk',
    'ga': 'Gaeilge',
    'gd': 'Gàidhlig',
    'gl': 'Galego',
    'gn': 'Avañe\'ẽ',
    'gv': 'Gaelg',
    'ht': 'Kreyòl ayisyen',
    'hy': 'Հայերեն',
    'ia': 'Interlingua',
    'ie': 'Interlingue',
    'ii': 'ꆈꌠ꒿ Nuosuhxop',
    'ik': 'Iñupiaq',
    'io': 'Ido',
    'is': 'Íslenska',
    'iu': 'ᐃᓄᒃᑎᑐᑦ',
    'ka': 'ქართული',
    'kk': 'Қазақ тілі',
    'kl': 'Kalaallisut',
    'km': 'ខ្មែរ',
    'ks': 'كشميري',
    'ku': 'Kurdî',
    'kv': 'Коми кыв',
    'kw': 'Kernewek',
    'ky': 'Кыргызча',
    'la': 'Latina',
    'lb': 'Lëtzebuergesch',
    'lg': 'Luganda',
    'li': 'Limburgs',
    'ln': 'Lingála',
    'lo': 'ພາສາລາວ',
    'lt': 'Lietuvių',
    'lu': 'Tshiluba',
    'lv': 'Latviešu',
    'mg': 'Fiteny malagasy',
    'mi': 'Te reo Māori',
    'mk': 'Македонски',
    'mt': 'Malti',
    'nn': 'Norsk nynorsk',
    'no': 'Norsk',
    'oc': 'Occitan',
    'os': 'Ирон æвзаг',
    'pi': 'पालि',
    'pt': 'Português',
    'qu': 'Runa Simi',
    'rm': 'Rumantsch',
    'rn': 'Ikirundi',
    'rw': 'Ikinyarwanda',
    'sa': 'संस्कृतम्',
    'sc': 'Sardu',
    'se': 'Davvisámegiella',
    'sg': 'Yângâ tî sängö',
    'si': 'සිංහල',
    'sm': 'Gagana fa\'a Samoa',
    'sn': 'ChiShona',
    'sq': 'Shqip',
    'sr': 'Српски',
    'ss': 'SiSwati',
    'st': 'Sesotho',
    'tg': 'Тоҷикӣ',
    'ti': 'ትግርኛ',
    'tk': 'Türkmen',
    'tl': 'Tagalog',
    'tn': 'Setswana',
    'to': 'Faka Tonga',
    'ts': 'Xitsonga',
    'tt': 'Татар теле',
    'ug': 'ئۇيغۇرچە',
    've': 'Tshivenḓa',
    'vo': 'Volapük',
    'wa': 'Walon',
    'wo': 'Wollof',
    'xh': 'IsiXhosa',
    'yi': 'ייִдиш',
    'za': 'Vahcuengh',
    'zh': '中文',
    'azb': 'تورکجه',
}


def load_csv_rows() -> list[dict[str, str]]:
    csv_path = ROOT / 'docs/languages.csv'
    with csv_path.open(encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)
        raw_rows = [[c.strip() for c in r] for r in reader]

    locales_ts = (ROOT / 'site/src/i18n/locales.ts').read_text(encoding='utf-8')
    pattern = re.compile(
        r"\{\s*code:\s*'([^']+)',\s*prefix:\s*'([^']*)',\s*bcp47:\s*'([^']+)',"
        r"\s*htmlLang:\s*'([^']+)',\s*og:\s*'([^']+)',\s*name:\s*'([^']+)',"
        r"\s*englishName:\s*'([^']+)',\s*dir:\s*'([^']+)'\s*\}"
    )
    existing_codes = {m[0] for m in pattern.findall(locales_ts)}

    new_locales = []
    for r in raw_rows:
        code = r[0]
        t = r[1]
        name = r[3].split(';')[0].split(',')[0].strip()
        native = r[4]
        if code in existing_codes and code != 'az':
            continue
        if code == 'az' and t == 'aze':
            continue
        if code == 'az' and t == 'azb':
            code = 'azb'
            name = 'South Azerbaijani'

        clean_native = CUSTOM_NATIVE.get(code, native.split(',')[0].split(';')[0].strip('\"').strip())
        if clean_native and clean_native[0].islower():
            clean_native = clean_native[0].upper() + clean_native[1:]

        prefix = code.lower()
        bcp47 = code
        htmlLang = code
        country = OG_COUNTRIES.get(code, '001')
        og = f'{code}_{country}'
        direction = 'rtl' if code in RTL_CODES else 'ltr'

        new_locales.append({
            'code': code,
            'prefix': prefix,
            'bcp47': bcp47,
            'htmlLang': htmlLang,
            'og': og,
            'name': clean_native,
            'englishName': name,
            'dir': direction,
        })
    return new_locales


def main() -> None:
    new_locales = load_csv_rows()
    print(f'Adding {len(new_locales)} new locales...')

    # 1. Update site/src/i18n/locales.ts
    locales_file = ROOT / 'site/src/i18n/locales.ts'
    text = locales_file.read_text(encoding='utf-8')
    start = text.index('export const LOCALES')
    end = text.index('\n];', start)
    existing_part = text[:end]
    new_entries = []
    for loc in new_locales:
        code = loc['code']
        safe_name = loc['name'].replace("'", "\\'")
        safe_english = loc['englishName'].replace("'", "\\'")
        if f"code: '{code}'" not in existing_part:
            line = (
                f"  {{ code: '{code}', prefix: '{loc['prefix']}', bcp47: '{loc['bcp47']}', "
                f"htmlLang: '{loc['htmlLang']}', og: '{loc['og']}', name: '{safe_name}', "
                f"englishName: '{safe_english}', dir: '{loc['dir']}' }},"
            )
            new_entries.append(line)

    if new_entries:
        text = text[:end] + '\n' + '\n'.join(new_entries) + text[end:]
        locales_file.write_text(text, encoding='utf-8')
        print(f'Updated {locales_file.relative_to(ROOT)}')

    # 2. Update site/src/i18n/ui/<code>.json
    ui_en_path = ROOT / 'site/src/i18n/ui/en.json'
    ui_en_data = json.loads(ui_en_path.read_text(encoding='utf-8'))
    for loc in new_locales:
        code = loc['code']
        dst = ROOT / f'site/src/i18n/ui/{code}.json'
        if not dst.exists():
            data = dict(ui_en_data)
            # Update common languages label to language's native name
            common = dict(data['common'])
            common['languages'] = loc['name']
            data['common'] = common
            dst.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')

    # 3. Update site/src/i18n/games/<code>.json
    games_en_path = ROOT / 'site/src/i18n/games/en.json'
    games_en_data = json.loads(games_en_path.read_text(encoding='utf-8'))
    for loc in new_locales:
        code = loc['code']
        dst = ROOT / f'site/src/i18n/games/{code}.json'
        if not dst.exists():
            dst.write_text(json.dumps(games_en_data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')

    # 4. Update site/src/content/guides-i18n/<code>/
    src_guides = ROOT / 'site/src/content/guides'
    for loc in new_locales:
        code = loc['code']
        dst_guides = ROOT / f'site/src/content/guides-i18n/{code}'
        for root, dirs, files in os.walk(src_guides):
            rel = os.path.relpath(root, src_guides)
            target_dir = dst_guides / rel if rel != '.' else dst_guides
            target_dir.mkdir(parents=True, exist_ok=True)
            for file in files:
                if file.endswith('.md'):
                    target_file = target_dir / file
                    if not target_file.exists():
                        content = (Path(root) / file).read_text(encoding='utf-8')
                        m = re.search(r'updated:\s*([0-9-]+)', content)
                        if m:
                            updated_date = m.group(1)
                            content = content.replace(f'updated: {updated_date}', f'updated: {updated_date}\ntranslatedFrom: {updated_date}')
                        target_file.write_text(content, encoding='utf-8')

    # 5. Update site/src/i18n/play.ts
    play_ts_path = ROOT / 'site/src/i18n/play.ts'
    play_ts = play_ts_path.read_text(encoding='utf-8')

    # Add to NO_SAYINGS_GAME
    m_sayings = re.search(r'NO_SAYINGS_GAME: readonly string\[\] = \[(.*?)\];', play_ts, re.S)
    if m_sayings:
        existing_sayings = set(re.findall(r"'([^']+)'", m_sayings.group(1)))
        new_sayings = [loc['code'] for loc in new_locales if loc['code'] not in existing_sayings]
        if new_sayings:
            formatted = ', '.join(f"'{c}'" for c in new_sayings)
            sep = ', ' if m_sayings.group(1).strip() else ''
            new_sayings_body = m_sayings.group(1) + sep + formatted
            play_ts = play_ts[:m_sayings.start(1)] + new_sayings_body + play_ts[m_sayings.end(1):]

    # Add to NO_LETTER_GRID
    m_grid = re.search(r'NO_LETTER_GRID: readonly string\[\] = \[(.*?)\];', play_ts, re.S)
    if m_grid:
        existing_grid = set(re.findall(r"'([^']+)'", m_grid.group(1)))
        new_grid = [c for c in NO_GRID_SCRIPTS if c not in existing_grid]
        if new_grid:
            formatted = ', '.join(f"'{c}'" for c in new_grid)
            sep = ', ' if m_grid.group(1).strip() else ''
            new_grid_body = m_grid.group(1) + sep + formatted
            play_ts = play_ts[:m_grid.start(1)] + new_grid_body + play_ts[m_grid.end(1):]

    play_ts_path.write_text(play_ts, encoding='utf-8')
    print(f'Updated {play_ts_path.relative_to(ROOT)}')

    # 6. Update site/scripts/check-site.mjs
    check_site_path = ROOT / 'site/scripts/check-site.mjs'
    check_site = check_site_path.read_text(encoding='utf-8')

    m_prefixes = re.search(r'const LOCALE_PREFIXES = new Set\(\[(.*?)\]\);', check_site, re.S)
    if m_prefixes:
        existing_prefixes = set(re.findall(r"'([^']+)'", m_prefixes.group(1)))
        new_prefixes = [loc['prefix'] for loc in new_locales if loc['prefix'] not in existing_prefixes]
        if new_prefixes:
            formatted = ', '.join(f"'{p}'" for p in new_prefixes)
            sep = ', ' if m_prefixes.group(1).strip() else ''
            new_prefixes_body = m_prefixes.group(1) + sep + formatted
            check_site = check_site[:m_prefixes.start(1)] + new_prefixes_body + check_site[m_prefixes.end(1):]

    m_rtl = re.search(r'const RTL_PREFIXES = new Set\(\[(.*?)\]\);', check_site, re.S)
    if m_rtl:
        existing_rtl = set(re.findall(r"'([^']+)'", m_rtl.group(1)))
        new_rtl = [loc['prefix'] for loc in new_locales if loc['dir'] == 'rtl' and loc['prefix'] not in existing_rtl]
        if new_rtl:
            formatted = ', '.join(f"'{p}'" for p in new_rtl)
            sep = ', ' if m_rtl.group(1).strip() else ''
            new_rtl_body = m_rtl.group(1) + sep + formatted
            check_site = check_site[:m_rtl.start(1)] + new_rtl_body + check_site[m_rtl.end(1):]

    check_site_path.write_text(check_site, encoding='utf-8')
    print(f'Updated {check_site_path.relative_to(ROOT)}')

    # 7. Update lib/l10n/language_names.dart
    lang_names_path = ROOT / 'lib/l10n/language_names.dart'
    # Parse all locales from locales.ts
    locales_ts = (ROOT / 'site/src/i18n/locales.ts').read_text(encoding='utf-8')
    pattern = re.compile(
        r"\{\s*code:\s*'([^']+)',\s*prefix:\s*'([^']*)',\s*bcp47:\s*'([^']+)',"
        r"\s*htmlLang:\s*'([^']+)',\s*og:\s*'([^']+)',\s*name:\s*'([^']+)',"
        r"\s*englishName:\s*'([^']+)',\s*dir:\s*'([^']+)'\s*\}"
    )
    all_locales = pattern.findall(locales_ts)
    dart_lines = [
        "// GENERATED from site/src/i18n/locales.ts (native names). Do not edit by hand.",
        "// Keys are the language tags the site and the app share",
        "// (Locale.toLanguageTag()).",
        "",
        "/// The name each language uses for itself, for the language picker.",
        "const Map<String, String> nativeLanguageNames = {",
    ]
    for m in all_locales:
        code = m[0]
        native_name = m[5].replace("'", "\\'")
        dart_lines.append(f"  '{code}': '{native_name}',")
    dart_lines.append("};\n")
    lang_names_path.write_text('\n'.join(dart_lines), encoding='utf-8')
    print(f'Updated {lang_names_path.relative_to(ROOT)}')

    print('All CSV languages successfully added!')


if __name__ == '__main__':
    main()
