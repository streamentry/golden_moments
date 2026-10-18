import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'app_harness.dart';

/// A small, valid, generated PNG: bands of colour that differ by [seed].
/// No real photo is ever used; the same seed always gives the same bytes.
Uint8List generatedPng(int seed, {int size = 64}) {
  final raw = BytesBuilder();
  for (var y = 0; y < size; y++) {
    raw.addByte(0); // No filter for this row.
    for (var x = 0; x < size; x++) {
      final band = ((x + y) ~/ 8 + seed) % 4;
      raw.add([
        (seed * 70 + band * 40) % 256,
        (120 + band * 30) % 256,
        (200 - seed * 50 + x) % 256,
      ]);
    }
  }
  final header = ByteData(13)
    ..setUint32(0, size)
    ..setUint32(4, size)
    ..setUint8(8, 8) // Bit depth.
    ..setUint8(9, 2) // Truecolour RGB.
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  return (BytesBuilder()
        ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
        ..add(_chunk('IHDR', header.buffer.asUint8List()))
        ..add(_chunk('IDAT', ZLibCodec().encode(raw.toBytes())))
        ..add(_chunk('IEND', const [])))
      .toBytes();
}

List<int> _chunk(String type, List<int> data) {
  final typeBytes = ascii.encode(type);
  final length = ByteData(4)..setUint32(0, data.length);
  final crc = ByteData(4)..setUint32(0, _crc32([...typeBytes, ...data]));
  return [
    ...length.buffer.asUint8List(),
    ...typeBytes,
    ...data,
    ...crc.buffer.asUint8List(),
  ];
}

final List<int> _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final b in bytes) {
    crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}

/// The content-hash name the app gives a copy.
String photoId(List<int> bytes) => sha256.convert(bytes).toString();

/// Writes copies and a version-1 manifest straight into the app's real
/// storage, as an earlier installed version would have left them, before
/// the photo screen is opened. Returns the ids in collection order.
Future<List<String>> seedInstalledCollection(List<Uint8List> images) async {
  final folder = await familyPhotoDirectory();
  await folder.create(recursive: true);
  final ids = <String>[];
  for (final bytes in images) {
    final id = photoId(bytes);
    await File('${folder.path}/$id.png').writeAsBytes(bytes, flush: true);
    ids.add(id);
  }
  await File('${folder.path}/collection.json')
      .writeAsString(jsonEncode({'version': 1, 'photos': ids}), flush: true);
  return ids;
}

/// What the app has on disk right now.
class StoredCollection {
  const new(this.manifest, this.copies, this.annotations);

  /// Ids listed by collection.json, in order.
  final List<String> manifest;

  /// Hash-named copy files present in the folder.
  final Set<String> copies;

  /// The annotations sidecar's photo entries, or empty when there is none.
  final Map<String, dynamic> annotations;
}

Future<StoredCollection> readStoredCollection() async {
  final folder = await familyPhotoDirectory();
  final manifest = jsonDecode(
    await File('${folder.path}/collection.json').readAsString(),
  ) as Map<String, dynamic>;
  final copies = {
    for (final entry in folder.listSync())
      if (entry is File && entry.path.endsWith('.png'))
        entry.uri.pathSegments.last.replaceAll('.png', ''),
  };
  final sidecar = File('${folder.path}/annotations.json');
  final annotations = sidecar.existsSync()
      ? (jsonDecode(await sidecar.readAsString())
                as Map<String, dynamic>)['photos']
            as Map<String, dynamic>
      : <String, dynamic>{};
  return StoredCollection(
    (manifest['photos'] as List<dynamic>).cast<String>(),
    copies,
    annotations,
  );
}

/// The bytes of one stored copy.
Future<List<int>> readCopy(String id) async {
  final folder = await familyPhotoDirectory();
  return await File('${folder.path}/$id.png').readAsBytes();
}
