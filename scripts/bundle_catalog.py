#!/usr/bin/env python3
"""Maintainer-only import of catalog image sources into versioned Flutter assets.

Normal builds/tests never run this network importer. Re-running reuses verified
files. --refresh explicitly fetches the recorded source URLs again.
"""
import argparse
import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / 'assets/data/packs_index.json'
SOURCES = ROOT / 'docs/catalog-image-sources.json'
DEST = ROOT / 'assets/images/catalog'


def image_extension(data):
    if data.startswith(b'\xff\xd8\xff'):
        return '.jpg'
    if data.startswith(b'\x89PNG\r\n\x1a\n'):
        return '.png'
    if data.startswith(b'RIFF') and data[8:12] == b'WEBP':
        return '.webp'
    raise ValueError('Source did not return a supported image')


def strings(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from strings(child)
    elif isinstance(value, str):
        yield value


def rewrite(value, paths):
    if isinstance(value, dict):
        return {key: rewrite(child, paths) for key, child in value.items()}
    if isinstance(value, list):
        return [rewrite(child, paths) for child in value]
    return paths.get(value, value) if isinstance(value, str) else value


def reusable(old, refresh, root=ROOT):
    """The recorded entry to keep without fetching, or None to fetch.

    An entry made locally from another bundled photo (it has ``derivedFrom``)
    is always kept, even with --refresh: its source URL names the photo, not
    these exact bytes, so fetching would replace it with a different file.
    """
    if not old:
        return None
    if old.get('derivedFrom'):
        return old
    path = root / old['asset']
    if refresh or not path.is_file():
        return None
    if hashlib.sha256(path.read_bytes()).hexdigest() == old['sha256']:
        return old
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--refresh', action='store_true')
    args = parser.parse_args()
    index = json.loads(INDEX.read_text())
    previous = json.loads(SOURCES.read_text())['images'] if SOURCES.exists() else []
    known = {entry['source']: entry for entry in previous}
    urls = {value for value in strings(index) if value.startswith('https://')}
    urls.update(known)
    DEST.mkdir(parents=True, exist_ok=True)

    def acquire(url):
        kept = reusable(known.get(url), args.refresh)
        if kept:
            return kept
        key = hashlib.sha256(url.encode()).hexdigest()[:24]
        existing = list(DEST.glob(key + '.*'))
        if existing and not args.refresh:
            data = existing[0].read_bytes()
            image_extension(data)
            return {'asset': str(existing[0].relative_to(ROOT)), 'source': url,
                    'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}
        temporary = DEST / f'{key}.part'
        try:
            subprocess.run(['curl', '--fail', '--location', '--silent',
                            '--show-error', '--retry', '2', '--max-time', '45',
                            url, '--output', str(temporary)], check=True)
            data = temporary.read_bytes()
            target = DEST / (key + image_extension(data))
            temporary.replace(target)
            return {'asset': str(target.relative_to(ROOT)), 'source': url,
                    'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}
        finally:
            temporary.unlink(missing_ok=True)

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        entries = sorted(executor.map(acquire, sorted(urls)), key=lambda x: x['asset'])
    paths = {entry['source']: entry['asset'] for entry in entries}
    updated = rewrite(index, paths)
    for pack in updated['packs']:
        if pack['difficulty'] == 'meidum':
            pack['difficulty'] = 'medium'
        pack['tags'] = ['medium' if tag == 'meidum' else tag for tag in pack.get('tags', [])]
    SOURCES.write_text(json.dumps({'images': entries}, indent=2) + '\n')
    INDEX.write_text(json.dumps(updated, indent=2) + '\n')
    print(f'Bundled {len(entries)} images ({sum(x["bytes"] for x in entries):,} bytes).')


if __name__ == '__main__':
    main()
