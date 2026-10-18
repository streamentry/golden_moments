import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';

import '../../helpers/failing_file_ops.dart';

/// Failures injected at every write boundary of the photo stores (GM-027,
/// GM-030). Each case proves three things: the caller is told it failed,
/// the previous collection is still the one that loads, and nothing the
/// failed step wrote is left behind.
void main() {
  late Directory directory;
  late FailingFileOps ops;
  late FamilyPhotoStore store;

  Uint8List image(int value) =>
      Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, value]);
  File manifest() => File('${directory.path}/collection.json');
  List<String> expectedNames(List<String> ids) =>
      ['collection.json', for (final id in ids) '$id.png']..sort();
  final failed = throwsA(isA<FileSystemException>());

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('golden-interrupt-');
    ops = FailingFileOps();
    store = FamilyPhotoStore(directory, fileOps: ops);
  });
  tearDown(() => directory.delete(recursive: true));

  group('adding photos', () {
    for (final (label, step, name) in [
      ('a copy write stops part-way (disk full)', FileStep.write, '.png.tmp'),
      (
        'a finished copy is not renamed into place',
        FileStep.rename,
        '.png.tmp',
      ),
      (
        'the new index write stops part-way (disk full)',
        FileStep.write,
        'collection.json.tmp',
      ),
      (
        'the new index is not renamed into place',
        FileStep.rename,
        'collection.json.tmp',
      ),
    ]) {
      test(
        '$label: reported, previous collection kept, nothing left',
        () async {
          final previous = await store.add([image(1), image(2)]);
          final before = await manifest().readAsBytes();
          ops.failWhen = (s, entry) => s == step && entry.endsWith(name);

          await expectLater(store.add([image(3), image(4)]), failed);
          expect(await manifest().readAsBytes(), before);
          expect(entryNames(directory), expectedNames(previous));
          expect(await FamilyPhotoStore(directory).load(), previous);

          // Once there is room again the same photos can be added.
          ops.failWhen = null;
          expect(await store.add([image(3), image(4)]), hasLength(4));
        },
      );
    }

    test(
      'a staging file that cannot be cleaned up is removed on load',
      () async {
        final previous = await store.add([image(1)]);
        ops.failWhen = (s, entry) =>
            entry == 'collection.json.tmp' &&
            (s == FileStep.write || s == FileStep.delete);
        await expectLater(store.add([image(2)]), failed);
        expect(
          File('${directory.path}/collection.json.tmp').existsSync(),
          isTrue,
        );
        ops.failWhen = null;
        expect(await store.load(), previous);
        expect(entryNames(directory), expectedNames(previous));
      },
    );
  });

  group('removing one photo', () {
    test('the index update fails: photo and copy stay', () async {
      final ids = await store.add([image(1), image(2)]);
      ops.failWhen = (s, entry) =>
          s == FileStep.rename && entry == 'collection.json.tmp';
      await expectLater(store.remove(ids.first), failed);
      expect(await FamilyPhotoStore(directory).load(), ids);
      expect(entryNames(directory), expectedNames(ids));
    });

    test('deleting the copy fails after the index update: reported, '
        'then tidied on the next load', () async {
      final ids = await store.add([image(1), image(2)]);
      ops.failWhen = (s, entry) =>
          s == FileStep.delete && entry == '${ids.first}.png';
      await expectLater(store.remove(ids.first), failed);
      // The reference went first, so the photo is no longer offered.
      expect(store.fileFor(ids.first).existsSync(), isTrue);
      expect(await FamilyPhotoStore(directory).load(), [ids.last]);
      expect(entryNames(directory), expectedNames([ids.last]));
    });
  });

  group('removing all photos', () {
    test('the index update fails: everything stays', () async {
      final ids = await store.add([image(1), image(2)]);
      ops.failWhen = (s, entry) =>
          s == FileStep.write && entry == 'collection.json.tmp';
      await expectLater(store.clear(), failed);
      expect(await FamilyPhotoStore(directory).load(), ids);
      expect(entryNames(directory), expectedNames(ids));
    });

    test('one copy cannot be deleted: the rest go, failure reported, '
        'the next load finishes', () async {
      final ids = await store.add([image(1), image(2), image(3)]);
      ops.failWhen = (s, entry) =>
          s == FileStep.delete && entry == '${ids[1]}.png';
      await expectLater(store.clear(), failed);
      expect(entryNames(directory), expectedNames([ids[1]]));
      expect(await FamilyPhotoStore(directory).load(), isEmpty);
      expect(entryNames(directory), ['collection.json']);
    });
  });

  group('photo details', () {
    final a = 'a' * 64;
    final b = 'b' * 64;
    File sidecar() => File('${directory.path}/annotations.json');

    late PhotoAnnotationStore notes;
    setUp(() => notes = PhotoAnnotationStore(directory, fileOps: ops));

    for (final step in [FileStep.write, FileStep.rename]) {
      test('a failed ${step.name} keeps the previous details', () async {
        await notes.update(a, const PhotoAnnotation(caption: 'Lake day'));
        final before = await sidecar().readAsBytes();
        ops.failWhen = (s, entry) =>
            s == step && entry == 'annotations.json.tmp';
        await expectLater(
          notes.update(a, const PhotoAnnotation(caption: 'Changed')),
          failed,
        );
        expect(await sidecar().readAsBytes(), before);
        expect(entryNames(directory), ['annotations.json']);
        expect((await notes.load())[a]!.caption, 'Lake day');
      });
    }

    test('an unreadable file moved aside survives a failed write', () async {
      await sidecar().writeAsString('damaged');
      ops.failWhen = (s, entry) =>
          s == FileStep.write && entry == 'annotations.json.tmp';
      await expectLater(
        notes.update(a, const PhotoAnnotation(favorite: true)),
        failed,
      );
      expect(
        File('${directory.path}/annotations.json.unreadable')
            .readAsStringSync(),
        'damaged',
      );
      expect(await notes.load(), isEmpty);
    });

    test('pruning that cannot be saved never blocks the photos', () async {
      await notes.update(a, const PhotoAnnotation(caption: 'A'));
      await notes.update(b, const PhotoAnnotation(caption: 'B'));
      final before = await sidecar().readAsBytes();
      ops.failWhen = (s, entry) =>
          s == FileStep.write && entry == 'annotations.json.tmp';

      final kept = await notes.keepOnly({b});
      expect(kept.keys, [b]);
      expect(await sidecar().readAsBytes(), before);

      // Retried, and saved, as soon as writing works again.
      ops.failWhen = null;
      expect((await notes.keepOnly({b})).keys, [b]);
      expect((await PhotoAnnotationStore(directory).load()).keys, [b]);
    });

    test(
      'a staging file left by a stopped app is removed, never read',
      () async {
        await notes.update(a, const PhotoAnnotation(caption: 'Kept'));
        await File('${directory.path}/annotations.json.tmp').writeAsString(
          jsonEncode({
            'version': 1,
            'photos': {
              a: {'caption': 'Unfinished'},
            },
          }),
        );
        expect((await notes.load())[a]!.caption, 'Kept');
        expect(entryNames(directory), ['annotations.json']);
      },
    );
  });
}
