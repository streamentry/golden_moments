import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:image_picker/image_picker.dart';

/// Explicit system-picker import. No library scanning or network requests.
class PhotoImporter {
  PhotoImporter({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  Future<List<XFile>> choose(int remaining) async {
    if (remaining < 1) return [];
    if (remaining == 1) {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      return file == null ? [] : [file];
    }
    return _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      requestFullMetadata: false,
      limit: remaining,
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

  /// Re-encode pixels without EXIF/GPS and fit the store's byte limit.
  /// Detailed photos are resized further rather than rejected just because
  /// their first normalized PNG exceeds the local-copy budget.
  Future<Uint8List> normalize(XFile file) async {
    if (await file.length() > 20 * 1024 * 1024) {
      throw const FormatException('This photo is too large to import.');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      await file.readAsBytes(),
    );
    ui.ImageDescriptor? descriptor;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width * descriptor.height > 40000000) {
        throw const FormatException('Choose a smaller photo.');
      }
      for (var edge = 1024; edge >= 256; edge = (edge * 0.75).floor()) {
        final scale = min(1, edge / max(descriptor.width, descriptor.height));
        final codec = await descriptor.instantiateCodec(
          targetWidth: max(1, (descriptor.width * scale).round()),
          targetHeight: max(1, (descriptor.height * scale).round()),
        );
        ui.Image? image;
        try {
          image = (await codec.getNextFrame()).image;
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          if (data == null) {
            throw const FormatException('This photo cannot be read.');
          }
          if (data.lengthInBytes <= FamilyPhotoStore.maxBytesPerPhoto) {
            return data.buffer.asUint8List(
              data.offsetInBytes,
              data.lengthInBytes,
            );
          }
        } finally {
          image?.dispose();
          codec.dispose();
        }
      }
      throw const FormatException('This photo cannot fit the local collection.');
    } finally {
      descriptor?.dispose();
      buffer.dispose();
    }
  }
}
