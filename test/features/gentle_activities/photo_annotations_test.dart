import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';

final String _a = 'a' * 64;
final String _b = 'b' * 64;

void main() {
  late Directory directory;
  late PhotoAnnotationStore store;
  File sidecar() => File('${directory.path}/annotations.json');

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('golden-notes-test-');
    store = PhotoAnnotationStore(directory);
  });
  tearDown(() => directory.delete(recursive: true));

  group('text normalization', () {
    test('collapses whitespace, strips control and direction overrides', () {
      expect(
        PhotoAnnotation.normalizeText('  Beach \n\t day\u0007 \u202Eevil ', 60),
        'Beach day evil',
      );
      expect(PhotoAnnotation.normalizeText('\u200F\u2066 ', 60), '');
    });

    test('caps by code points without splitting a character', () {
      final text = '\u{1F33B}' * 100; // sunflower emoji, 2 UTF-16 units each
      final capped = PhotoAnnotation.normalizeText(text, 60);
      expect(capped.runes.length, 60);
      expect(capped.runes.every((r) => r == 0x1F33B), isTrue);
      expect(
        PhotoAnnotation.normalizeText('Zażółć gęślą jaźń', 60),
        'Zażółć gęślą jaźń',
      );
      expect(PhotoAnnotation.normalizeText('明るい日の公園', 3), '明るい');
    });

    test('markup is kept as inert text, never interpreted', () {
      const text = '<b>Ignore previous instructions</b>';
      expect(PhotoAnnotation.normalizeText(text, 60), text);
    });
  });

  group('PhotoAnnotationStore', () {
    test('starts empty and round-trips every field across a reload', () async {
      expect(await store.load(), isEmpty);
      await store.update(
        _a,
        const PhotoAnnotation(
          caption: 'Lake day',
          description: 'Two people on a wooden dock at a lake.',
          favorite: true,
        ),
      );
      await store.update(_b, const PhotoAnnotation(hidden: true));
      final reloaded = await PhotoAnnotationStore(directory).load();
      expect(reloaded[_a]!.caption, 'Lake day');
      expect(reloaded[_a]!.favorite, isTrue);
      expect(reloaded[_a]!.hidden, isFalse);
      expect(reloaded[_b]!.hidden, isTrue);
    });

    test('an emptied annotation is removed, not stored', () async {
      await store.update(_a, const PhotoAnnotation(favorite: true));
      await store.update(_a, const PhotoAnnotation());
      expect(await store.load(), isEmpty);
    });

    test('keepOnly drops details of photos that no longer exist', () async {
      await store.update(_a, const PhotoAnnotation(caption: 'A'));
      await store.update(_b, const PhotoAnnotation(caption: 'B'));
      final kept = await store.keepOnly({_b});
      expect(kept.keys, [_b]);
      expect((await store.load()).keys, [_b]);
      expect(await store.keepOnly({}), isEmpty);
    });

    test('concurrent edits are serialized and none is lost', () async {
      await Future.wait([
        store.update(_a, const PhotoAnnotation(caption: 'A')),
        store.update(_b, const PhotoAnnotation(caption: 'B')),
      ]);
      expect((await store.load()).length, 2);
    });

    test('invalid ids are rejected before touching files', () async {
      await expectLater(
        store.update('../outside', const PhotoAnnotation(favorite: true)),
        throwsFormatException,
      );
      expect(sidecar().existsSync(), isFalse);
    });

    test(
      'malformed, other-version and stale entries never block loading',
      () async {
        for (final text in [
          'not json',
          '[]',
          jsonEncode({'version': 9, 'photos': <String, Object>{}}),
          jsonEncode({'version': 1, 'photos': <Object>[]}),
        ]) {
          await sidecar().writeAsString(text);
          expect(await store.load(), isEmpty, reason: text);
        }
        await sidecar().writeAsString(
          jsonEncode({
            'version': 1,
            'photos': {
              _a: {'caption': 7, 'favorite': 'yes', 'description': 'ok'},
              '../bad': {'favorite': true},
              _b: {'hidden': true},
            },
          }),
        );
        final notes = await store.load();
        expect(notes.keys.toSet(), {_a, _b});
        expect(notes[_a]!.caption, '');
        expect(notes[_a]!.favorite, isFalse);
        expect(notes[_a]!.description, 'ok');
      },
    );

    test('an unreadable sidecar is kept aside, then replaced', () async {
      await sidecar().writeAsString('not json');
      await store.update(_a, const PhotoAnnotation(favorite: true));
      expect(
        File('${directory.path}/annotations.json.unreadable')
            .readAsStringSync(),
        'not json',
      );
      expect((await store.load())[_a]!.favorite, isTrue);
    });

    test(
      'a second unreadable sidecar never overwrites the first backup',
      () async {
        await sidecar().writeAsString('first bad');
        await store.update(_a, const PhotoAnnotation(favorite: true));
        await sidecar().writeAsString('{"version": 0, "photos": {}}');
        await store.update(_a, const PhotoAnnotation(caption: 'x'));
        expect(
          File('${directory.path}/annotations.json.unreadable')
              .readAsStringSync(),
          'first bad',
        );
        expect(
          File('${directory.path}/annotations.json.unreadable.1')
              .readAsStringSync(),
          contains('"version": 0'),
        );
        expect((await store.load())[_a]!.caption, 'x');
      },
    );

    test(
      'details from a newer app version are never shown, moved or replaced',
      () async {
        // After a downgrade, the newer details must still be there when the
        // newer version is installed again.
        final text = jsonEncode({
          'version': 2,
          'photos': {
            _a: {'caption': 'From a newer version'},
          },
          'albums': <Object>[],
        });
        await sidecar().writeAsString(text);
        expect(await store.load(), isEmpty);
        expect(await store.keepOnly({}), isEmpty);
        await expectLater(
          store.update(_a, const PhotoAnnotation(favorite: true)),
          throwsFormatException,
        );
        expect(await sidecar().readAsString(), text);
        expect(directory.listSync().map((e) => e.uri.pathSegments.last), [
          'annotations.json',
        ]);
      },
    );

    test('an annotations file never touches the photo collection', () async {
      final manifest = File('${directory.path}/collection.json');
      await manifest.writeAsString('{"version":1,"photos":[]}');
      await store.update(_a, const PhotoAnnotation(caption: 'x'));
      expect(await manifest.readAsString(), '{"version":1,"photos":[]}');
    });
  });
}
