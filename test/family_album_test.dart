import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A valid PNG of [width] x [height]; contents never matter here.
Uint8List _png(int seed, int width, int height) {
  List<int> chunk(String type, List<int> data) {
    final body = [...ascii.encode(type), ...data];
    var crc = 0xFFFFFFFF;
    for (final b in body) {
      crc ^= b;
      for (var k = 0; k < 8; k++) {
        crc = (crc & 1) != 0 ? 0xEDB88320 ^ (crc >> 1) : crc >> 1;
      }
    }
    crc ^= 0xFFFFFFFF;
    return [
      ...(ByteData(4)..setUint32(0, data.length)).buffer.asUint8List(),
      ...body,
      ...(ByteData(4)..setUint32(0, crc)).buffer.asUint8List(),
    ];
  }

  final raw = BytesBuilder();
  for (var y = 0; y < height; y++) {
    raw.addByte(0);
    for (var x = 0; x < width; x++) {
      raw.add([(seed * 60 + x) % 256, (y * 3) % 256, 120]);
    }
  }
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  return Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    ...chunk('IHDR', header.buffer.asUint8List()),
    ...chunk('IDAT', ZLibCodec().encode(raw.toBytes())),
    ...chunk('IEND', const []),
  ]);
}

/// Portrait and landscape photos, as families really have.
List<ActivityPicture> _seed(Directory dir) {
  final ids = <String>[];
  for (var i = 0; i < 4; i++) {
    final bytes = i.isEven ? _png(i, 30, 40) : _png(i, 40, 30);
    final id = sha256.convert(bytes).toString();
    File('${dir.path}/$id.png').writeAsBytesSync(bytes);
    ids.add(id);
  }
  File('${dir.path}/collection.json')
      .writeAsStringSync(jsonEncode({'version': 1, 'photos': ids}));
  return [
    for (final id in ids)
      ActivityPicture(id: id, label: 'Photo', path: '${dir.path}/$id.png'),
  ];
}

Widget _app(Widget home) => MaterialApp(theme: gmBuildTheme(), home: home);

/// Cropped to its square and mounted with rounded corners, never
/// letterboxed (DESIGN.md › Shapes).
void _expectMountedCrop(WidgetTester tester, Finder picture) {
  expect(tester.widget<PictureView>(picture).fit, BoxFit.cover);
  final clip = tester.widget<ClipRRect>(
    find.ancestor(of: picture, matching: find.byType(ClipRRect)).first,
  );
  expect(clip.borderRadius, BorderRadius.circular(gmRadiusMd));
}

void main() {
  late Directory dir;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('family-album-');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  testWidgets('photo cards show each photo cropped like a mounted print, '
      'with Options in a footer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    _seed(dir);
    await tester.pumpWidget(
      _app(PhotoCollectionPage(directoryProvider: () async => dir)),
    );
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    final pictures = find.byType(PictureView);
    expect(pictures, findsNWidgets(4));
    for (var i = 0; i < 4; i++) {
      _expectMountedCrop(tester, pictures.at(i));
      final card = find.ancestor(
        of: pictures.at(i),
        matching: find.byType(Card),
      );
      final divider = find.descendant(of: card, matching: find.byType(Divider));
      expect(divider, findsOneWidget);
      expect(
        tester.getRect(divider).bottom,
        lessThanOrEqualTo(
          tester
              .getRect(
                find.descendant(of: card, matching: find.text('Options')),
              )
              .top,
        ),
      );
    }
  });

  testWidgets('family photos on the board are cropped to the tile, not '
      'letterboxed', (tester) async {
    final pictures = _seed(dir);
    await tester.pumpWidget(_app(GentleGamePage(pictures: pictures)));
    await tester.pumpAndSettle();
    final tiles = find.byType(PictureView);
    expect(tiles, findsWidgets);
    for (var i = 0; i < tiles.evaluate().length; i++) {
      _expectMountedCrop(tester, tiles.at(i));
    }
  });

  test('a photo is shown whole unless a screen asks to crop it', () {
    // Look together shows the whole photo.
    expect(
      PictureView(picture: ActivityPicture.samples.first).fit,
      BoxFit.contain,
    );
  });
}
