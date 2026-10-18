import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';

void main() {
  late Directory directory;
  late FamilyPhotoStore store;
  // These bytes exercise storage guards, not the separate image decoder.
  Uint8List image(int value) => Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, value]);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('golden-photo-test-');
    store = FamilyPhotoStore(directory);
  });
  tearDown(() async { await directory.delete(recursive: true); });
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
    await Future.wait([store.add([image(1)]), store.add([image(2)])]);
    expect((await store.load()).length, 2);
  });
  test('invalid batch leaves existing collection unchanged', () async {
    final previous = await store.add([image(1)]);
    await expectLater(store.add([image(2), Uint8List.fromList([0])]), throwsFormatException);
    expect(await store.load(), previous);
  });
  test('oversized photos rejected', () async {
    await expectLater(store.add([Uint8List(FamilyPhotoStore.maxBytesPerPhoto + 1)]), throwsFormatException);
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
    await File('${directory.path}/collection.json').writeAsString(jsonEncode({
      'version': 1, 'photos': ['../outside'],
    }));
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
    expect(await store.fileFor(ids.first).exists(), isFalse);
    await store.clear();
    expect(await store.load(), isEmpty);
    expect(await store.fileFor(ids.last).exists(), isFalse);
    expect(await other.readAsString(), 'keep');
  });
}
