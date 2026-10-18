// File permissions stand in for a storage error the app cannot control (a
// file or folder that cannot be inspected or read for a moment). They do not
// apply on Windows, and root ignores them, so those runs skip.
@TestOn('!windows')
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';

import '../../helpers/failing_file_ops.dart';

void main() {
  late Directory directory;
  late FamilyPhotoStore store;
  late List<String> ids;

  Uint8List image(int value) =>
      Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, value]);
  void chmod(String mode, String path) =>
      Process.runSync('chmod', [mode, path]);
  File manifest() => File('${directory.path}/collection.json');
  final failed = throwsA(isA<FileSystemException>());

  /// True when permissions really block this user (not root).
  bool enforced(String path) {
    try {
      File(path).readAsBytesSync();
      return false;
    } on FileSystemException {
      return true;
    }
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('golden-access-test-');
    store = FamilyPhotoStore(directory);
    ids = await store.add([image(1), image(2)]);
  });
  tearDown(() async {
    chmod('755', directory.path);
    chmod('644', manifest().path);
    await directory.delete(recursive: true);
  });

  Future<void> expectNothingLost() async {
    chmod('755', directory.path);
    chmod('644', manifest().path);
    expect(
      entryNames(directory),
      ['collection.json', for (final id in ids) '$id.png']..sort(),
    );
    expect(await FamilyPhotoStore(directory).load(), ids);
  }

  test('an index that cannot be read is an error, never an empty '
      'collection', () async {
    chmod('000', manifest().path);
    if (!enforced(manifest().path)) {
      markTestSkipped('This user can read any file.');
      return;
    }
    await expectLater(store.load(), failed);
    await expectLater(store.add([image(3)]), failed);
    await expectLater(store.remove(ids.first), failed);
    await expectLater(store.clear(), failed);
    await expectNothingLost();
  });

  test('a folder that cannot be inspected is an error, never an empty '
      'collection', () async {
    // Inside such a folder the index looks absent to a plain type check.
    chmod('000', directory.path);
    if (!enforced(manifest().path)) {
      markTestSkipped('This user can read any folder.');
      return;
    }
    await expectLater(store.load(), failed);
    await expectLater(store.add([image(3)]), failed);
    await expectLater(store.remove(ids.first), failed);
    await expectLater(store.clear(), failed);
    await expectNothingLost();
  });

  test('a folder that can be listed but whose entries cannot be inspected '
      'is an error, never an empty collection', () async {
    // Readable but not searchable: listing works, while inspecting any
    // entry fails with "permission denied", which a plain type check would
    // report as "not found".
    chmod('444', directory.path);
    if (!enforced(manifest().path)) {
      markTestSkipped('This user can read any folder.');
      return;
    }
    expect(directory.listSync(), isNotEmpty);
    expect(
      FileSystemEntity.typeSync(manifest().path, followLinks: false),
      FileSystemEntityType.notFound,
    );
    await expectLater(store.load(), failed);
    await expectLater(store.listed(), failed);
    await expectLater(store.add([image(3)]), failed);
    await expectLater(store.remove(ids.first), failed);
    await expectLater(store.clear(), failed);
    await expectNothingLost();
  });

  group('photo details', () {
    final a = 'a' * 64;
    File sidecar() => File('${directory.path}/annotations.json');

    test('a read failure is reported and never treated as damage', () async {
      final notes = PhotoAnnotationStore(directory);
      await notes.update(a, const PhotoAnnotation(caption: 'Lake day'));
      final before = await sidecar().readAsBytes();
      chmod('000', sidecar().path);
      addTearDown(() => chmod('644', sidecar().path));
      if (!enforced(sidecar().path)) {
        markTestSkipped('This user can read any file.');
        return;
      }

      await expectLater(
        notes.update(a, const PhotoAnnotation(caption: 'Changed')),
        failed,
      );
      // For display only: nothing to show, nothing written.
      expect(await notes.load(), isEmpty);
      expect(await notes.keepOnly({}), isEmpty);

      chmod('644', sidecar().path);
      expect(await sidecar().readAsBytes(), before);
      expect(
        File('${directory.path}/annotations.json.unreadable').existsSync(),
        isFalse,
      );
      expect((await notes.load())[a]!.caption, 'Lake day');
    });
  });
}
