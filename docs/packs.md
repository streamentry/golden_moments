# Bundled picture-pack catalog

Every catalog picture ships in the application. There is no runtime image host,
pack download, account, or downloaded-pack prerequisite. This includes all game
pictures, category icons, pack thumbnails, and previews.

`assets/data/packs_index.json` is the catalog. Its existing `url`, `thumbnailUrl`,
`iconUrl`, and `previewImages` field names are retained for compatibility, but
values are Flutter asset paths under `assets/images/catalog/`. IDs, package
identity, existing downloaded files, and family-photo storage are preserved.
Previously saved downloads are no longer needed to start the shipped packs.

## Current inventory

- 8 packs, 5 categories, 84 game pictures.
- 121 image files including thumbnails, category icons, and previews.
- 3,914,100 image bytes (about 3.9 MB), plus the bundled font.
- Original source URL, asset path, byte count, and SHA-256 for each image are in
  `docs/catalog-image-sources.json`.

The source record documents provenance; it is not a new rights clearance or
permission to publish. Existing store licensing and privacy review gates remain.
One unavailable mountain preview was replaced with a working source already used
by another picture in that same pack.

## Updating content

1. Keep existing pack and image IDs stable. Add or replace the catalog metadata
   and reviewed image sources. Review content and usage rights before shipping.
2. For remote maintainer sources, explicitly run
   `python3 scripts/bundle_catalog.py`. This imports files and rewrites source
   URLs to local asset paths. `--refresh` explicitly reacquires recorded sources.
   An image made locally from another bundled photo (a crop or resize, marked
   `derivedFrom` in the source record) is never fetched again.
   This is a maintainer tool, never an app-startup, build, or CI requirement.
3. Commit the local files, catalog, and source/checksum record together. Assets
   must be declared in `pubspec.yaml` before packaging. New inventory counts
   must be reviewed in the catalog tests and browser checks.
4. Validate without network:

```sh
python3 scripts/validate_packs.py --check-urls
python3 -m unittest discover -s tests -v
flutter test test/bundled_catalog_test.dart test/game_pack_loader_test.dart
flutter analyze
flutter test
```

The validator treats bundled asset paths as local files. It does not need the
`requests` package to validate this catalog. Flutter tests decode every catalog
image and start every pack without initializing storage, HTTP, or downloads.

## Runtime and verification

Pack cards start games directly using `AssetImage`. The catalog home has no
download tab or offline warning. The native gentle home still opens its existing
local activities; its picture-library entry now opens the included catalog
immediately. Family-photo import remains explicit and stores user-selected
copies separately; these private photos are not redistributed as app assets.

The browser build also uses the packaged renderer and font. The visual runner
starts with an empty browser context, blocks all external network requests,
checks every local image response, and tests the catalog and complete game flow.
Same-origin HTTP requests serve the installed web build's files; this does not
claim an installable PWA or an offline cold launch with its web server removed.
Native install, picker, device accessibility, and store publication gates remain
separate. See `docs/visual-testing.md` and `docs/specs/release-status.json`.
