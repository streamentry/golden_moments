#!/usr/bin/env python3
"""Validate/export US store copy locally. This script never publishes anything."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'metadata/app-store.en-US.json'
GOOGLE_SOURCE = ROOT / 'metadata/google-play.en-US.json'
GOOGLE_EXPORTS = ('name', 'short_description', 'full_description', 'release_notes')
STATUS = ROOT / 'docs/specs/release-status.json'
EXPORTS = {key: key + '.txt' for key in (
    'name', 'subtitle', 'keywords', 'promotional_text', 'description', 'release_notes')}
REQUIRED_FEATURES = {'gentle_matching', 'family_photos', 'photo_viewer', 'offline_starter', 'accessible_layout'}
REQUIRED_GATES = {'flutter_tests', 'ios_archive', 'ios_photo_picker',
    'android_photo_picker_recovery', 'fresh_install_offline', 'upgrade_preserves_packs',
    'accessibility_device_review', 'caregiver_comprehension', 'privacy_and_sdk_audit',
    'medical_claims_review', 'real_screenshot_review', 'store_configuration'}


def validate(data, status, release=False, root=ROOT):
    errors = []
    for key, limit in {'name': 30, 'subtitle': 30, 'promotional_text': 170,
                       'description': 4000, 'release_notes': 4000}.items():
        value = data.get(key)
        if not isinstance(value, str) or not value.strip() or len(value) > limit:
            errors.append(f'{key}: required text, maximum {limit} characters')
    keywords = data.get('keywords', '')
    if not isinstance(keywords, str) or len(keywords.encode('utf-8')) > 100:
        errors.append('keywords: maximum 100 UTF-8 bytes')
    else:
        words = keywords.split(',')
        if any(not word or word != word.strip() for word in words):
            errors.append('keywords: empty term or extra separator whitespace')
        if len({word.lower() for word in words}) != len(words):
            errors.append('keywords: duplicate terms')
        visible = set(re.findall(r'[a-z]+', (str(data.get('name', '')) + ' ' +
                       str(data.get('subtitle', ''))).lower()))
        if any(word.lower() in visible for word in words):
            errors.append('keywords: repeats a name/subtitle term')
    screenshots = data.get('screenshots', [])
    copy = '\n'.join(str(data.get(key, '')) for key in EXPORTS).lower()
    copy += '\n' + '\n'.join(str(s.get('headline', '')) + ' ' +
                             str(s.get('supporting_text', '')) for s in screenshots).lower()
    for phrase in ['clinically proven', 'treats dementia', 'prevents dementia',
                   'slows alzheimer', 'improves memory', 'brain training',
                   'keep your mind sharp', 'reduces agitation']:
        if phrase in copy:
            errors.append(f'unsupported promotional claim: {phrase}')
    if [s.get('order') for s in screenshots] != list(range(1, 7)):
        errors.append('screenshots: six uniquely ordered entries required')
    features = status.get('features', {})
    for screen in screenshots:
        if not screen.get('headline') or not screen.get('capture'):
            errors.append('screenshots: missing headline or capture instructions')
        for feature in screen.get('requires', []):
            if feature not in features:
                errors.append(f'screenshots: unknown feature {feature}')
    if release:
        required = REQUIRED_FEATURES | set(data.get('requires_features', []))
        for screen in screenshots:
            required.update(screen.get('requires', []))
        for feature in required:
            entry = features.get(feature, {})
            if entry.get('status') != 'verified' or not entry.get('evidence'):
                errors.append(f'release feature not verified: {feature}')
        gates = status.get('gates', {})
        for gate in REQUIRED_GATES | set(gates):
            result = gates.get(gate, {})
            if result.get('status') != 'passed' or not result.get('evidence'):
                errors.append(f'release gate not evidenced: {gate}')
        try:
            provenance = json.loads((root / 'docs/specs/asset-provenance.json').read_text(encoding='utf-8'))
        except (OSError, ValueError):
            provenance = {'groups': []}
            errors.append('asset provenance register missing or unreadable')
        groups = provenance.get('groups', [])
        if not groups:
            errors.append('asset provenance register has no groups')
        for group in groups:
            gid = group.get('id')
            rights = group.get('rights_status')
            if rights not in ('reviewed', 'license_text_bundled', 'not_shipped'):
                errors.append(f'asset rights unreviewed: {gid}')
            elif rights in ('reviewed', 'license_text_bundled') and group.get('missing'):
                errors.append(f'asset rights incomplete: {gid}')
            elif rights == 'not_shipped' and group.get('paths'):
                errors.append(f'asset marked not shipped but lists files: {gid}')
        for screen in screenshots:
            for platform in ['iphone', 'ipad']:
                capture = screen.get('files', {}).get(platform)
                if not capture:
                    errors.append(f'screenshot {screen.get("order")}: missing {platform} capture')
                    continue
                path = (root / capture).resolve()
                if not path.is_relative_to(root.resolve()) or not path.is_file():
                    errors.append(f'screenshot {screen.get("order")}: invalid capture path')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--write', action='store_true')
    mode.add_argument('--check', action='store_true')
    mode.add_argument('--release', action='store_true')
    args = parser.parse_args()
    try:
        data = json.loads(SOURCE.read_text(encoding='utf-8'))
        google = json.loads(GOOGLE_SOURCE.read_text(encoding='utf-8'))
        status = json.loads(STATUS.read_text(encoding='utf-8'))
    except (OSError, ValueError) as error:
        print(f'ERROR: cannot read metadata/status: {error}')
        return 1
    errors = validate(data, status, release=args.release)
    for field, limit in {'name': 30, 'short_description': 80,
                         'full_description': 4000, 'release_notes': 500}.items():
        value = google.get(field)
        if not isinstance(value, str) or not value.strip() or len(value) > limit:
            errors.append(f'Google Play {field}: required text, maximum {limit} characters')
    for google_field, apple_field in {'name': 'name', 'full_description': 'description',
                                       'release_notes': 'release_notes'}.items():
        if google.get(google_field) != data.get(apple_field):
            errors.append(f'Google Play {google_field}: differs from canonical app copy')
    if not errors:
        out = ROOT / 'metadata/en-US'
        out.mkdir(parents=True, exist_ok=True)
        for key, filename in EXPORTS.items():
            expected = data[key] + '\n'
            path = out / filename
            if args.write:
                path.write_text(expected, encoding='utf-8')
            elif not path.is_file() or path.read_text(encoding='utf-8') != expected:
                errors.append(f'outdated export: {path.relative_to(ROOT)}; run --write')
        out = ROOT / 'metadata/google-play/en-US'
        out.mkdir(parents=True, exist_ok=True)
        for key in GOOGLE_EXPORTS:
            expected = google[key] + '\n'
            path = out / (key + '.txt')
            if args.write:
                path.write_text(expected, encoding='utf-8')
            elif not path.is_file() or path.read_text(encoding='utf-8') != expected:
                errors.append(f'outdated export: {path.relative_to(ROOT)}; run --write')
    for error in errors:
        print(f'ERROR: {error}')
    if errors:
        return 1
    print(f'Metadata valid: name {len(data["name"])}/30; subtitle {len(data["subtitle"])}/30; keywords {len(data["keywords"].encode("utf-8"))}/100 bytes.')
    if not args.release:
        print('Copy validation is not release approval. Run --release before submission.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
