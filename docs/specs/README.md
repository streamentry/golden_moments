# Specifications and status

Read [product](product.md), [offline photos](offline-photos.md), [safety/accessibility](safety-accessibility.md), and [screenshots](screenshots.md) together. [release-status.json](release-status.json) is the acceptance record.

`implemented_unverified` means source exists. `verified` requires linked evidence. Store publication is separate and never inferred from a merge.

| Feature | Source under lib/features/gentle_activities | Required evidence |
| --- | --- | --- |
| Gentle matching | models/gentle_board.dart; presentation/gentle_game_page.dart | Board/widget tests and device review |
| Family photos | data/family_photo_store.dart; data/photo_importer.dart; presentation/photo_collection_page.dart | Filesystem tests, native picker/storage/upgrade tests |
| Shared viewing | presentation/photo_together_page.dart | Navigation and caregiver review |
| Offline starter | presentation/gentle_home_page.dart; lib/bootstrap.dart | Fresh airplane-mode install, no cached content |
| Accessible layout | Presentation files; DESIGN.md | Screen readers, large text, contrast, rotation |
| Legacy library | Explicit home action | Existing packs and downloads preserved |

No sync or clinical functionality is implied. Release gates stay pending until evidence exists.
