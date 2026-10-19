import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';

/// Recovering from a photo list that can no longer be read: the list is
/// kept aside, never deleted or overwritten, and the copies whose content
/// still matches their names come back. A list written by a newer app
/// version is never touched.
void main() {
  late Directory directory;
  late FamilyPhotoStore store;
  Uint8List image(int value) =>
      Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, value]);
  File list() => File('${directory.path}/collection.json');
  List<File> keptAside() => [
    for (final entry in directory.listSync())
      if (entry is File &&
          entry.uri.pathSegments.last.startsWith('collection.damaged-'))
        entry,
  ];

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('golden-recovery-');
    store = FamilyPhotoStore(directory);
  });
  tearDown(() => directory.delete(recursive: true));

  group('a damaged list', () {
    for (final (name, content) in [
      ('not JSON', 'not json'),
      ('cut off part-way', '{"version": 1, "photos": ["ab'),
      ('the wrong shape', '{"version": 1, "photos": "none"}'),
      ('no version', '{"photos": []}'),
    ]) {
      test('$name: is reported as damaged and can be set aside', () async {
        final ids = await store.add([image(1), image(2)]);
        await list().writeAsString(content);

        await expectLater(
          store.load(),
          throwsA(
            isA<UnreadablePhotoList>().having(
              (e) => e.canSetAside,
              'canSetAside',
              isTrue,
            ),
          ),
        );
        // Still never overwritten by a change.
        await expectLater(store.add([image(3)]), throwsFormatException);
        expect(await list().readAsString(), content);

        expect(await store.setAsideDamagedList(), isTrue);
        expect(list().existsSync(), isFalse);
        expect(keptAside(), hasLength(1));
        expect(await keptAside().single.readAsString(), content);
        expect((await store.load()).toSet(), ids.toSet());
        for (final id in ids) {
          expect(store.fileFor(id).existsSync(), isTrue);
        }
      });
    }

    test('after recovery the next change writes a fresh list and keeps the '
        'old one aside', () async {
      final ids = await store.add([image(1)]);
      await list().writeAsString('not json');
      expect(await store.setAsideDamagedList(), isTrue);
      final more = await store.add([image(2)]);
      expect(more.toSet(), {...ids, ...more});
      final written = jsonDecode(await list().readAsString()) as Map;
      expect(written['version'], 1);
      expect(keptAside(), hasLength(1));
      // Removing every photo copy also removes lists kept aside, which
      // name only photos that are now gone.
      final other = File('${directory.path}/keep.txt')..writeAsStringSync('x');
      await store.clear();
      expect(keptAside(), isEmpty);
      expect(other.existsSync(), isTrue);
    });

    test('a copy whose content no longer matches its name is not shown, and '
        'is tidied away by the next change, as the dialog says', () async {
      final ids = await store.add([image(1), image(2)]);
      await store.fileFor(ids.first).writeAsBytes(image(9));
      await list().writeAsString('not json');
      expect(await store.setAsideDamagedList(), isTrue);
      expect(await store.load(), [ids.last]);
      // Kept until the collection is next changed, then removed like any
      // copy the list does not name.
      expect(store.fileFor(ids.first).existsSync(), isTrue);
      await store.add([image(3)]);
      await store.load();
      expect(store.fileFor(ids.first).existsSync(), isFalse);
    });

    test('photo details of recovered photos are kept', () async {
      final ids = await store.add([image(1)]);
      final notes = PhotoAnnotationStore(directory);
      await notes.update(
        ids.single,
        const PhotoAnnotation(caption: 'At the lake', favorite: true),
      );
      await list().writeAsString('not json');
      expect(await store.setAsideDamagedList(), isTrue);
      final kept = await notes.keepOnly((await store.listed()).toSet());
      expect(kept[ids.single]?.caption, 'At the lake');
      expect(kept[ids.single]?.favorite, isTrue);
    });

    test('a second recovery keeps both earlier lists', () async {
      await store.add([image(1)]);
      await list().writeAsString('first');
      expect(await store.setAsideDamagedList(), isTrue);
      await store.add([image(2)]);
      await list().writeAsString('second');
      expect(await store.setAsideDamagedList(), isTrue);
      final contents = {
        for (final file in keptAside()) file.readAsStringSync(),
      };
      expect(contents, {'first', 'second'});
    });
  });

  group('nothing is moved', () {
    test('when the list is fine', () async {
      final ids = await store.add([image(1)]);
      final before = await list().readAsString();
      expect(await store.setAsideDamagedList(), isFalse);
      expect(await list().readAsString(), before);
      expect(await store.load(), ids);
      expect(keptAside(), isEmpty);
    });

    test('when there is no list', () async {
      expect(await store.setAsideDamagedList(), isFalse);
      expect(keptAside(), isEmpty);
    });

    test('when a newer app version wrote the list', () async {
      await store.add([image(1)]);
      final newer = jsonEncode({
        'version': 2,
        'photos': <String>[],
        'albums': ['Summer'],
      });
      await list().writeAsString(newer);
      await expectLater(
        store.load(),
        throwsA(
          isA<UnreadablePhotoList>()
              .having((e) => e.fromNewerVersion, 'fromNewerVersion', isTrue)
              .having((e) => e.canSetAside, 'canSetAside', isFalse),
        ),
      );
      expect(await store.setAsideDamagedList(), isFalse);
      expect(await list().readAsString(), newer);
      expect(keptAside(), isEmpty);
    });

    for (final version in ['2.0', '1e30', '99999999999999999999']) {
      test('when a newer version is written as $version', () async {
        await store.add([image(1)]);
        final newer = '{"version": $version, "photos": []}';
        await list().writeAsString(newer);
        await expectLater(
          store.load(),
          throwsA(
            isA<UnreadablePhotoList>().having(
              (e) => e.fromNewerVersion,
              'fromNewerVersion',
              isTrue,
            ),
          ),
        );
        expect(await store.setAsideDamagedList(), isFalse);
        expect(await list().readAsString(), newer);
      });
    }

    test(
      'when the list cannot be read right now, which is not damage',
      () async {
        await store.add([image(1)]);
        final before = await list().readAsString();
        await Process.run('chmod', ['000', list().path]);
        addTearDown(() => Process.run('chmod', ['644', list().path]));
        // Someone allowed to read anything (root) cannot test this.
        final unreadable = await list().readAsString().then(
          (_) => false,
          onError: (_) => true,
        );
        if (!unreadable) return;
        await expectLater(store.load(), throwsA(isA<FileSystemException>()));
        await expectLater(
          store.setAsideDamagedList(),
          throwsA(isA<FileSystemException>()),
        );
        await Process.run('chmod', ['644', list().path]);
        expect(await list().readAsString(), before);
        expect(keptAside(), isEmpty);
      },
    );

    test('when something other than a plain file is in its place', () async {
      await Directory('${directory.path}/collection.json').create();
      await expectLater(
        store.load(),
        throwsA(
          isA<UnreadablePhotoList>().having(
            (e) => e.canSetAside,
            'canSetAside',
            isFalse,
          ),
        ),
      );
      expect(await store.setAsideDamagedList(), isFalse);
      expect(
        Directory('${directory.path}/collection.json').existsSync(),
        isTrue,
      );
    });

    test('when the list is a link: neither it nor its target moves', () async {
      final target = File(
        '${directory.parent.path}/elsewhere-${directory.hashCode}',
      );
      await target.writeAsString('not json');
      addTearDown(() => target.existsSync() ? target.delete() : null);
      await Link(list().path).create(target.path);
      expect(await store.setAsideDamagedList(), isFalse);
      expect(Link(list().path).existsSync(), isTrue);
      expect(await target.readAsString(), 'not json');
    });
  });
}
