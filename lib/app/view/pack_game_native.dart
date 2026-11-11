import 'package:flutter/widgets.dart';
import 'package:golden_moments/app/view/platform_home_native.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/game/game.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/l10n/pack_text.dart';

/// Replaces the platform check in tests; null follows the platform.
@visibleForTesting
bool? debugPackGamesOnGentleBoard;

/// On iOS and Android a pack opens on the gentle board, like every other
/// game there: four visible pictures by default, and the same comfort
/// settings (tile count, hidden tiles, contrast) apply (product story G2).
/// Desktop keeps the picture-pack game until its photo flows are tested.
Widget packGamePage(BuildContext context, Pack pack) {
  if (!(debugPackGamesOnGentleBoard ?? usesGentleActivities)) {
    return GamePage(gamePack: pack);
  }
  final text = context.packText;
  return GentleGamePage(
    title: text.packTitle(pack),
    pictures: packPictures(pack, text),
    // Each pack keeps its own unfinished board.
    sessionKey: 'pack-${pack.id}',
  );
}

/// The pack's photos as gentle-board pictures, named in the app language.
/// Ids carry the pack id, so they never meet a drawing's name.
@visibleForTesting
List<ActivityPicture> packPictures(Pack pack, PackText text) => [
  for (final image in pack.images)
    ActivityPicture(
      id: '${pack.id}/${image.id}',
      label: text.caption(pack.id, image.id, image.caption),
      asset: image.url,
    ),
];
