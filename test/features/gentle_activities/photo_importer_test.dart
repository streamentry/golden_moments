import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_importer.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List> makePng(int width, int height, {bool noise = false}) async {
  final pixels = Uint8List(width * height * 4);
  final random = Random(17);
  for (var offset = 0; offset < pixels.length; offset += 4) {
    pixels[offset] = noise ? random.nextInt(256) : 80;
    pixels[offset + 1] = noise ? random.nextInt(256) : 120;
    pixels[offset + 2] = noise ? random.nextInt(256) : 160;
    pixels[offset + 3] = 255;
  }
  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec();
  final image = (await codec.getNextFrame()).image;
  try {
    final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } finally {
    image.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('detailed images are resized to fit instead of rejected', () async {
    final source = await makePng(1024, 1024, noise: true);
    expect(source.length, greaterThan(FamilyPhotoStore.maxBytesPerPhoto));
    final normalized = await PhotoImporter().normalize(XFile.fromData(source));
    expect(normalized.length, lessThanOrEqualTo(FamilyPhotoStore.maxBytesPerPhoto));
    final codec = await ui.instantiateImageCodec(normalized);
    final image = (await codec.getNextFrame()).image;
    try {
      expect(image.width, lessThan(1024));
      expect(image.width, image.height);
    } finally {
      image.dispose();
      codec.dispose();
    }
  });

  test('small images keep their aspect ratio and are not enlarged', () async {
    final source = await makePng(2, 1);
    final normalized = await PhotoImporter().normalize(XFile.fromData(source));
    final codec = await ui.instantiateImageCodec(normalized);
    final image = (await codec.getNextFrame()).image;
    try {
      expect(image.width, 2);
      expect(image.height, 1);
    } finally {
      image.dispose();
      codec.dispose();
    }
  });

  test('invalid encoded image data is rejected', () async {
    await expectLater(
      PhotoImporter().normalize(XFile.fromData(Uint8List.fromList([1, 2, 3]))),
      throwsA(isA<Exception>()),
    );
  });

  test('source size is checked before decoding', () async {
    await expectLater(
      PhotoImporter().normalize(XFile.fromData(Uint8List(21 * 1024 * 1024))),
      throwsFormatException,
    );
  });
}
