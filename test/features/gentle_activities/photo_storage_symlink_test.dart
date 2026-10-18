// Symbolic links need extra privileges on Windows; the app ships on iOS and
// Android, whose file systems behave like these.
@TestOn('!windows')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';

/// Real temporary folders and real symbolic links (GM-027): whatever a link
/// inside the app folder points to, the stores never read, write or delete
/// through it. Only synthetic bytes are used.
void main() {
  late Directory root;
  late Directory owned;
  late Directory outside;
  late File secret;
  late FamilyPhotoStore store;

  Uint8List image(int value) =>
      Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, value]);
  String idOf(Uint8List bytes) => sha256.convert(bytes).toString();
  FileSystemEntityType typeOf(String path) =>
      FileSystemEntity.typeSync(path, followLinks: false);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('golden-symlink-test-');
    owned = await Directory('${root.path}/owned').create();
    outside = await Directory('${root.path}/outside').create();
    secret = File('${outside.path}/secret.bin');
    await secret.writeAsString('outside');
    store = FamilyPhotoStore(owned);
  });
  tearDown(() => root.delete(recursive: true));

  group('FamilyPhotoStore', () {
    test(
      'a copy replaced by a link is not shown and only the link goes',
      () async {
        final ids = await store.add([image(1), image(2)]);
        final copy = store.fileFor(ids.first);
        await copy.delete();
        await Link(copy.path).create(secret.path);

        expect(await store.load(), [ids.last]);
        await store.remove(ids.first);
        expect(typeOf(copy.path), FileSystemEntityType.notFound);
        expect(await secret.readAsString(), 'outside');
      },
    );

    test(
      'a dangling link at a new copy name is never written through',
      () async {
        final id = idOf(image(1));
        final target = File('${outside.path}/created.png');
        await Link('${owned.path}/$id.png').create(target.path);

        expect(await store.add([image(1)]), [id]);
        expect(target.existsSync(), isFalse);
        expect(typeOf(store.fileFor(id).path), FileSystemEntityType.file);
        expect(await store.fileFor(id).readAsBytes(), image(1));
      },
    );

    test('a link to a real file at a new copy name is replaced', () async {
      final id = idOf(image(1));
      await File('${outside.path}/$id.png').writeAsBytes(image(1));
      await Link('${owned.path}/$id.png').create('${outside.path}/$id.png');

      expect(await store.add([image(1)]), [id]);
      expect(typeOf(store.fileFor(id).path), FileSystemEntityType.file);
      expect(File('${outside.path}/$id.png').existsSync(), isTrue);
    });

    test('a link at the index staging name is never written through', () async {
      await Link('${owned.path}/collection.json.tmp').create(secret.path);
      await store.add([image(1)]);
      expect(await secret.readAsString(), 'outside');
      expect(
        typeOf('${owned.path}/collection.json'),
        FileSystemEntityType.file,
      );
    });

    test('a link at a copy staging name is never written through', () async {
      final id = idOf(image(1));
      await Link('${owned.path}/$id.png.tmp').create(secret.path);
      await store.add([image(1)]);
      expect(await secret.readAsString(), 'outside');
      expect(await store.fileFor(id).readAsBytes(), image(1));
    });

    test(
      'an index replaced by a link is refused, not read or replaced',
      () async {
        final id = idOf(image(1));
        await File('${owned.path}/$id.png').writeAsBytes(image(1));
        final elsewhere = File('${outside.path}/collection.json');
        final text = jsonEncode({
          'version': 1,
          'photos': [id],
        });
        await elsewhere.writeAsString(text);
        await Link('${owned.path}/collection.json').create(elsewhere.path);

        await expectLater(store.load(), throwsFormatException);
        await expectLater(store.add([image(2)]), throwsFormatException);
        await expectLater(store.clear(), throwsFormatException);
        expect(
          typeOf('${owned.path}/collection.json'),
          FileSystemEntityType.link,
        );
        expect(await elsewhere.readAsString(), text);
        expect(File('${owned.path}/$id.png').existsSync(), isTrue);
      },
    );

    test('remove-all unlinks planted links and keeps their targets', () async {
      await store.add([image(1)]);
      final id = idOf(image(9));
      final target = File('${outside.path}/$id.png');
      await target.writeAsBytes(image(9));
      await Link('${owned.path}/$id.png').create(target.path);
      final folderLink = Link('${owned.path}/${idOf(image(8))}.png');
      await folderLink.create(outside.path);

      await store.clear();
      expect(await store.load(), isEmpty);
      expect(typeOf('${owned.path}/$id.png'), FileSystemEntityType.notFound);
      expect(typeOf(folderLink.path), FileSystemEntityType.notFound);
      expect(await target.readAsBytes(), image(9));
      expect(await secret.readAsString(), 'outside');
    });

    test('a photo folder replaced by a link is refused entirely', () async {
      final id = idOf(image(1));
      final copy = File('${outside.path}/$id.png');
      await copy.writeAsBytes(image(1));
      final stray = File('${outside.path}/${idOf(image(2))}.png');
      await stray.writeAsBytes(image(2));
      final manifest = File('${outside.path}/collection.json');
      await manifest.writeAsString(
        jsonEncode({
          'version': 1,
          'photos': [id],
        }),
      );
      final linked = Link('${root.path}/linked');
      await linked.create(outside.path);
      final linkedStore = FamilyPhotoStore(Directory(linked.path));

      await expectLater(
        linkedStore.load(),
        throwsA(isA<FileSystemException>()),
      );
      await expectLater(
        linkedStore.clear(),
        throwsA(isA<FileSystemException>()),
      );
      await expectLater(
        linkedStore.add([image(3)]),
        throwsA(isA<FileSystemException>()),
      );
      expect(copy.existsSync(), isTrue);
      expect(stray.existsSync(), isTrue);
      expect(manifest.existsSync(), isTrue);
      expect(
        File('${outside.path}/${idOf(image(3))}.png').existsSync(),
        isFalse,
      );
    });
  });

  group('PhotoAnnotationStore', () {
    final a = 'a' * 64;

    test(
      'a sidecar replaced by a link is not read and is moved aside',
      () async {
        final elsewhere = File('${outside.path}/notes.json');
        final text = jsonEncode({
          'version': 1,
          'photos': {
            a: {'caption': 'Outside'},
          },
        });
        await elsewhere.writeAsString(text);
        final sidecar = '${owned.path}/annotations.json';
        await Link(sidecar).create(elsewhere.path);
        final notes = PhotoAnnotationStore(owned);

        expect(await notes.load(), isEmpty);
        await notes.update(a, const PhotoAnnotation(caption: 'Inside'));
        expect(await elsewhere.readAsString(), text);
        expect(typeOf(sidecar), FileSystemEntityType.file);
        expect(
          typeOf('${owned.path}/annotations.json.unreadable'),
          FileSystemEntityType.link,
        );
        expect((await notes.load())[a]!.caption, 'Inside');
      },
    );

    test(
      'a link at the sidecar staging name is never written through',
      () async {
        await Link('${owned.path}/annotations.json.tmp').create(secret.path);
        final notes = PhotoAnnotationStore(owned);
        await notes.update(a, const PhotoAnnotation(favorite: true));
        expect(await secret.readAsString(), 'outside');
        expect((await notes.load())[a]!.favorite, isTrue);
      },
    );

    test('a folder replaced by a link: nothing read or written', () async {
      final elsewhere = File('${outside.path}/annotations.json');
      final text = jsonEncode({
        'version': 1,
        'photos': {
          a: {'caption': 'Outside'},
        },
      });
      await elsewhere.writeAsString(text);
      final staging = File('${outside.path}/annotations.json.tmp');
      await staging.writeAsString('keep');
      final linked = Link('${root.path}/linked');
      await linked.create(outside.path);
      final notes = PhotoAnnotationStore(Directory(linked.path));

      expect(await notes.load(), isEmpty);
      expect(await notes.keepOnly({}), isEmpty);
      await expectLater(
        notes.update(a, const PhotoAnnotation(favorite: true)),
        throwsA(isA<FileSystemException>()),
      );
      expect(await elsewhere.readAsString(), text);
      expect(await staging.readAsString(), 'keep');
    });
  });
}
