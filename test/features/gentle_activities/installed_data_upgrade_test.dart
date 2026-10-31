import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_session.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/failing_file_ops.dart';

/// Data exactly as an installed build wrote it (GM-027). `test/fixtures/
/// installed_v1` holds the only on-disk formats this app has ever used
/// (manifest, annotations, preferences and session are all version 1 since
/// they were introduced) with synthetic 2x2 single-colour PNGs; nothing in it
/// comes from a real photo. An upgrade must keep every id, detail and record.
const _fixture = 'test/fixtures/installed_v1';

void main() {
  late Directory root;
  late Directory photos;
  late List<String> installedIds;
  late List<int> installedManifest;
  late List<int> installedSidecar;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('golden-upgrade-');
    photos = await Directory('${root.path}/family_photos_v1').create();
    for (final file in Directory(
      '$_fixture/family_photos_v1',
    ).listSync().whereType<File>()) {
      await file.copy('${photos.path}/${file.uri.pathSegments.last}');
    }
    installedManifest = await File('${photos.path}/collection.json')
        .readAsBytes();
    installedSidecar = await File('${photos.path}/annotations.json')
        .readAsBytes();
    final manifest = jsonDecode(utf8.decode(installedManifest)) as Map;
    installedIds = (manifest['photos'] as List).cast<String>();
    final prefs = jsonDecode(
      await File('$_fixture/shared_preferences.json').readAsString(),
    ) as Map<String, dynamic>;
    SharedPreferences.setMockInitialValues(prefs.cast<String, Object>());
  });
  tearDown(() => root.delete(recursive: true));

  test('the fixture copies are the content their ids name', () {
    expect(installedIds, hasLength(3));
    for (final id in installedIds) {
      final bytes = File('${photos.path}/$id.png').readAsBytesSync();
      expect(sha256.convert(bytes).toString(), id);
    }
  });

  test('every photo, detail and record loads after the upgrade', () async {
    expect(await FamilyPhotoStore(photos).load(), installedIds);
    final notes = await PhotoAnnotationStore(photos)
        .keepOnly(installedIds.toSet());
    expect(notes.keys.toSet(), installedIds.toSet());
    expect(notes[installedIds[0]]!.caption, 'Lake day');
    expect(notes[installedIds[0]]!.description, 'Two people on a wooden dock.');
    expect(notes[installedIds[0]]!.favorite, isTrue);
    expect(notes[installedIds[1]]!.hidden, isTrue);
    expect(notes[installedIds[2]]!.caption, 'Garden');

    expect(
      await const GentlePreferencesStore().load(),
      const GentlePreferences(pairs: 3, keepVisible: false),
    );
    const sessions = GentleSessionStore();
    final family = await sessions.load('family');
    expect(
      family!.toBoard(availablePictureIds: installedIds.toSet()),
      isNotNull,
    );
    final starter = await sessions.load('starter');
    expect(
      starter!.toBoard(
        availablePictureIds: {
          for (final picture in ActivityPicture.samples) picture.id,
        },
      ),
      isNotNull,
    );

    // Loading never rewrites what the installed build saved.
    expect(
      await File('${photos.path}/collection.json').readAsBytes(),
      installedManifest,
    );
    expect(
      await File('${photos.path}/annotations.json').readAsBytes(),
      installedSidecar,
    );
  });

  test(
    'the first change after the upgrade keeps the installed format',
    () async {
      final store = FamilyPhotoStore(photos);
      // Choosing an existing photo again rewrites the index unchanged.
      final again = await File('${photos.path}/${installedIds[0]}.png')
          .readAsBytes();
      expect(await store.add([again]), installedIds);
      expect(
        await File('${photos.path}/collection.json').readAsBytes(),
        installedManifest,
      );
      await PhotoAnnotationStore(photos)
          .update(installedIds[2], const PhotoAnnotation(caption: 'Garden'));
      expect(
        await File('${photos.path}/annotations.json').readAsBytes(),
        installedSidecar,
      );
    },
  );

  test('an older build stopped mid-change upgrades cleanly', () async {
    // What an interrupted older build could leave: an unindexed copy, a
    // stale index staging file and a stale details staging file.
    final orphan = File('${photos.path}/${'f' * 64}.png');
    await orphan.writeAsBytes([137, 80, 78, 71, 13, 10, 26, 10, 1]);
    await File('${photos.path}/collection.json.tmp').writeAsString('{"vers');
    await File('${photos.path}/annotations.json.tmp').writeAsString('{');

    expect(await FamilyPhotoStore(photos).load(), installedIds);
    expect(
      (await PhotoAnnotationStore(photos).load()).keys.toSet(),
      installedIds.toSet(),
    );
    expect(
      entryNames(photos),
      [
        ...installedIds.map((id) => '$id.png'),
        'annotations.json',
        'collection.json',
      ]..sort(),
    );
  });

  testWidgets('the collection screen shows the installed photos', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: gmBuildTheme(),
        home: PhotoCollectionPage(directoryProvider: () async => photos),
      ),
    );
    for (
      var i = 0;
      i < 100 && find.text('3 of 24 photos').evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('3 of 24 photos'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);
    expect(find.text('Play with these photos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
