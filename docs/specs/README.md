# Specifications and status

## Start here

Read [the product contract](product.md), then the [senior-first specification](senior-first/README.md). The latter is the complete proposed feature plan for becoming a preferred simple picture-activity app for older adults and their families, not a claim of market leadership.

| Need | Canonical document |
| --- | --- |
| Product goal and current promises | [Product](product.md) |
| All feature IDs, phases and dependencies | [Feature catalog](senior-first/feature-catalog.json) |
| What actually existed when planned | [Inspected baseline](senior-first/baseline.md) |
| Delivery order and stopping rules | [Roadmap](senior-first/roadmap.md) |
| User stories, acceptance and edge cases | Functional documents linked from [senior-first](senior-first/README.md) |
| Comparative success and testing | [Validation](senior-first/validation.md) |
| Sources, competitors and evidence gaps | [Research](senior-first/research.md) |
| Current photo format and privacy boundary | [Offline photos](offline-photos.md) |
| Safety, accessibility and store screenshots | [Safety](safety-accessibility.md), [screenshots](screenshots.md) |
| Actual release evidence | [release-status.json](release-status.json) |

## Do not confuse plans with verification

The feature catalog records proposed phase and baseline state only. `source_present` is not a pass against every new acceptance criterion. The existing release record remains the acceptance authority; implemented, tested, merged, device-verified and published are separate states.

| Existing capability | Source area | Required evidence |
| --- | --- | --- |
| Gentle matching | lib/features/gentle_activities/models and presentation | Board/widget tests and supported-device review |
| Family photos | data/family_photo_store.dart; data/photo_importer.dart; photo_collection_page.dart | Native picker, storage, deletion and upgrade tests |
| Shared viewing | presentation/photo_together_page.dart | Navigation, accessibility and participant review |
| Offline starter | presentation/gentle_home_page.dart; lib/bootstrap.dart | Fresh airplane-mode installed app with no previous cache |
| Accessible layout | Presentation files; DESIGN.md | Real assistive-technology, large-text, contrast and rotation checks |
| Included catalog | Bundled pack data/assets and catalog tests | All packs usable without runtime download; old saved data preserved |

The catalog is now fully bundled; do not revive the old download requirement. Future albums, file exchange, reminders and payments remain conditional. No new backend, clinical functionality or publication permission is implied by this specification.
