import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';

import '../../helpers/failing_file_ops.dart';

void main() {
  late Directory directory;
  late FamilyPhotoStore store;
  // These bytes exercise storage guards, not the separate image decoder.
  Uint8List image(int value) =>
      Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, value]);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('golden-photo-test-');
    store = FamilyPhotoStore(directory);
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });
  test('starts empty and keeps copies across reloads', () async {
    expect(await store.load(), isEmpty);
    final ids = await store.add([image(1), image(2)]);
    expect(ids.length, 2);
    expect(await FamilyPhotoStore(directory).load(), ids);
    expect(await store.fileFor(ids.first).readAsBytes(), image(1));
  });
  test('duplicates do not consume extra slots', () async {
    await store.add([image(1)]);
    expect((await store.add([image(1), image(1)])).length, 1);
  });
  test('concurrent additions are serialized', () async {
    await Future.wait([
      store.add([image(1)]),
      store.add([image(2)]),
    ]);
    expect((await store.load()).length, 2);
  });
  test('invalid batch leaves existing collection unchanged', () async {
    final previous = await store.add([image(1)]);
    await expectLater(
      store.add([
        image(2),
        Uint8List.fromList([0]),
      ]),
      throwsFormatException,
    );
    expect(await store.load(), previous);
  });
  test('oversized photos rejected', () async {
    await expectLater(
      store.add([Uint8List(FamilyPhotoStore.maxBytesPerPhoto + 1)]),
      throwsFormatException,
    );
  });
  test('capacity enforced before new copies are saved', () async {
    final ids = await store.add(List.generate(24, image));
    await expectLater(store.add([image(25)]), throwsFormatException);
    expect(await store.load(), ids);
  });
  test('malformed manifest is not overwritten', () async {
    final file = File('${directory.path}/collection.json');
    await file.writeAsString('not json');
    await expectLater(store.add([image(1)]), throwsFormatException);
    expect(await file.readAsString(), 'not json');
  });
  test('path traversal rejected', () async {
    await File('${directory.path}/collection.json').writeAsString(
      jsonEncode({
        'version': 1,
        'photos': ['../outside'],
      }),
    );
    await expectLater(store.load(), throwsFormatException);
    await expectLater(store.remove('../outside'), throwsFormatException);
  });
  test('missing copies skipped without losing available pictures', () async {
    final ids = await store.add([image(1), image(2)]);
    await store.fileFor(ids.first).delete();
    expect(await store.load(), [ids.last]);
  });
  test('clear never deletes unrelated files', () async {
    final other = File('${directory.path}/keep.txt');
    await other.writeAsString('keep');
    final ids = await store.add([image(1), image(2)]);
    expect(await store.remove(ids.first), [ids.last]);
    expect(store.fileFor(ids.first).existsSync(), isFalse);
    await store.clear();
    expect(await store.load(), isEmpty);
    expect(store.fileFor(ids.last).existsSync(), isFalse);
    expect(await other.readAsString(), 'keep');
  });
  test('the index keeps the exact format installed apps wrote', () async {
    final ids = await store.add([image(1), image(2)]);
    expect(
      await File('${directory.path}/collection.json').readAsString(),
      jsonEncode({'version': 1, 'photos': ids}),
    );
  });
  test(
    'two stores on the same folder never lose one another’s photos',
    () async {
      // The collection screen creates a new store each time it (re)loads.
      final other = FamilyPhotoStore(directory);
      await Future.wait([
        store.add([image(1)]),
        other.add([image(2)]),
        store.add([image(3)]),
      ]);
      expect((await FamilyPhotoStore(directory).load()).length, 3);
    },
  );

  group('restart after the app was stopped part-way through a change', () {
    String idOf(Uint8List bytes) => sha256.convert(bytes).toString();

    test('a copy written but never indexed is removed on load', () async {
      final previous = await store.add([image(1), image(2)]);
      // Stopped after writing the copy, before replacing the index.
      final orphan = File('${directory.path}/${idOf(image(3))}.png');
      await orphan.writeAsBytes(image(3));
      expect(await FamilyPhotoStore(directory).load(), previous);
      expect(orphan.existsSync(), isFalse);
      expect(
        entryNames(directory),
        ['collection.json', for (final id in previous) '$id.png']..sort(),
      );
    });

    test(
      'a complete but unrenamed index is never used and is removed',
      () async {
        final previous = await store.add([image(1)]);
        final extra = idOf(image(2));
        await File('${directory.path}/$extra.png').writeAsBytes(image(2));
        await File('${directory.path}/collection.json.tmp').writeAsString(
          jsonEncode({
            'version': 1,
            'photos': [...previous, extra],
          }),
        );
        expect(await FamilyPhotoStore(directory).load(), previous);
        expect(entryNames(directory), [
          '${previous.single}.png',
          'collection.json',
        ]);
      },
    );

    test('a half-written copy never appears and is removed', () async {
      final previous = await store.add([image(1)]);
      final partial = File('${directory.path}/${idOf(image(2))}.png.tmp');
      await partial.writeAsBytes(image(2).sublist(0, 4));
      expect(await FamilyPhotoStore(directory).load(), previous);
      expect(partial.existsSync(), isFalse);
    });

    test('a damaged unindexed copy is replaced, not trusted', () async {
      // Older builds could leave a truncated copy under its final name when
      // the disk filled; adding that photo again then failed every time.
      await store.add([image(1)]);
      final id = idOf(image(2));
      await File('${directory.path}/$id.png')
          .writeAsBytes(image(2).sublist(0, 5));
      expect(await store.add([image(2)]), contains(id));
      expect(await store.fileFor(id).readAsBytes(), image(2));
    });

    test('without an index, copies are kept and staging is removed', () async {
      // A first import stopped before its index existed: never guess.
      final id = idOf(image(1));
      await File('${directory.path}/$id.png').writeAsBytes(image(1));
      await File('${directory.path}/collection.json.tmp').writeAsString('{');
      expect(await store.load(), isEmpty);
      expect(entryNames(directory), ['$id.png']);
      // Choosing the same photo again reuses the verified copy.
      expect(await store.add([image(1)]), [id]);
    });

    test('a copy whose reference was dropped is removed on load', () async {
      final ids = await store.add([image(1), image(2)]);
      // Stopped after the index dropped the photo, before its copy went.
      await File('${directory.path}/collection.json').writeAsString(
        jsonEncode({
          'version': 1,
          'photos': [ids.last],
        }),
      );
      expect(await store.load(), [ids.last]);
      expect(store.fileFor(ids.first).existsSync(), isFalse);
    });
  });
}
