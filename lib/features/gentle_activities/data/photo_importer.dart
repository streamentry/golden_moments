import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

/// Explicit system-picker import. No library scanning or network requests.
class PhotoImporter {
  PhotoImporter({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  Future<List<XFile>> choose(int remaining) async {
    if (remaining < 1) return [];
    if (remaining == 1) {
      final file = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024,
        imageQuality: 85, requestFullMetadata: false,
      );
      return file == null ? [] : [file];
    }
    return _picker.pickMultiImage(
      maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
      requestFullMetadata: false, limit: remaining,
    );
  }

  /// Android may destroy the activity while its system picker is open.
  /// The caller asks the user before adding recovered selections.
  Future<List<XFile>> recover() async {
    if (!Platform.isAndroid) return [];
    final response = await _picker.retrieveLostData();
    if (response.exception != null) throw response.exception!;
    return response.files ?? [];
  }

  /// Re-encoding keeps pixels rather than copying EXIF/GPS metadata.
  Future<Uint8List> normalize(XFile file) async {
    if (await file.length() > 20 * 1024 * 1024) {
      throw const FormatException('This photo is too large to import.');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(await file.readAsBytes());
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width * descriptor.height > 40000000) {
        throw const FormatException('Choose a smaller photo.');
      }
      final scale = min(1.0, 1024 / max(descriptor.width, descriptor.height));
      codec = await descriptor.instantiateCodec(
        targetWidth: max(1, (descriptor.width * scale).round()),
        targetHeight: max(1, (descriptor.height * scale).round()),
      );
      image = (await codec.getNextFrame()).image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw const FormatException('This photo cannot be read.');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }
}
