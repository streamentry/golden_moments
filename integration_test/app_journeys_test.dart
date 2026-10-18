import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'journeys/comfort_settings.dart';
import 'journeys/family_photos.dart';
import 'journeys/first_game.dart';
import 'journeys/look_together.dart';
import 'journeys/pack_library.dart';
import 'journeys/stop_and_resume.dart';
import 'support/app_harness.dart';

/// End-to-end journeys through the real app on a device or simulator: the
/// production bootstrap, real storage and bundled assets, no network and no
/// system picker. See integration_test/README.md for how to run them.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Golden Moments journeys', () {
    journey(
      'J1 fresh install: one gentle start, four visible tiles, finish, '
      'play again, done for now',
      firstGentleGame,
    );
    journey(
      'J2 stop and resume: carry on restores the board, start fresh '
      'forgets it, a finished board is never offered',
      stopAndResume,
    );
    journey(
      'J3 comfort settings from Home: 8 hidden tiles, then reset to 4 '
      'visible',
      comfortSettingsFromHome,
    );
    journey(
      'J4 look together with the included pictures',
      lookTogetherIncluded,
    );
    journey(
      'J5 family photos from an installed collection, without the picker',
      familyPhotosInstalledCollection,
    );
    journey(
      'J6 picture-pack library: favorites, not for me, topic, pack, play',
      picturePackLibrary,
    );
    journey(
      'J7a 200% text: first gentle game',
      (tester) => firstGentleGame(tester, textScale: 2),
    );
    journey(
      'J7b 200% text: look together',
      (tester) => lookTogetherIncluded(tester, textScale: 2),
    );
  });
}
