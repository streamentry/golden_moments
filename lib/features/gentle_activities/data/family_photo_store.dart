import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Stores normalized PNG copies in an app-owned directory, never originals.
/// File names are content hashes, not user-provided paths or person names.
class FamilyPhotoStore {
  FamilyPhotoStore(this.directory);

  static const maxPhotos = 24;
  static const int maxBytesPerPhoto = 2 * 1024 * 1024;
  static final _validId = RegExp(r'^[a-f0-9]{64}$');
  static const _pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
  final Directory directory;
  Future<void> _pending = Future<void>.value();

  File get _manifest => File('${directory.path}/collection.json');

  File fileFor(String id) {
    if (!_validId.hasMatch(id))
      throw const FormatException('Invalid photo ID.');
    return File('${directory.path}/$id.png');
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final operation = _pending.then((_) => action());
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<List<String>> load() => _serial(_read);

  Future<List<String>> _read() async {
    await directory.create(recursive: true);
    if (!await _manifest.exists()) return [];
    final data = jsonDecode(await _manifest.readAsString());
    if (data is! Map<String, dynamic> ||
        data['version'] != 1 ||
        data['photos'] is! List) {
      throw const FormatException('The photo collection cannot be read.');
    }
    final values = data['photos'] as List<dynamic>;
    if (values.length > maxPhotos ||
        values.any(
          (dynamic id) => id is! String || !_validId.hasMatch(id),
        )) {
      throw const FormatException('Invalid photo collection.');
    }
    final ids = values.cast<String>();
    if (ids.toSet().length != ids.length) {
      throw const FormatException('Duplicate photo IDs.');
    }
    // Missing copies do not prevent the remaining pictures from being used.
    final available = <String>[];
    for (final id in ids) {
      if (await fileFor(id).exists()) available.add(id);
    }
    return available;
  }

  Future<void> _save(List<String> ids) async {
    final temporary = File('${directory.path}/collection.json.tmp');
    await temporary.writeAsString(
      jsonEncode({'version': 1, 'photos': ids}),
      flush: true,
    );
    await temporary.rename(_manifest.path);
  }

  /// All validation happens before changing the current manifest.
  Future<List<String>> add(List<Uint8List> images) => _serial(() async {
    final ids = await _read();
    final additions = <String, Uint8List>{};
    for (final bytes in images) {
      if (bytes.length < 8 ||
          bytes.length > maxBytesPerPhoto ||
          List<int>.generate(8, (i) => bytes[i]).asMap().entries.any(
            (entry) => entry.value != _pngSignature[entry.key],
          )) {
        throw const FormatException('Choose a smaller, valid photo.');
      }
      final id = sha256.convert(bytes).toString();
      if (!ids.contains(id)) additions[id] = bytes;
    }
    if (ids.length + additions.length > maxPhotos) {
      throw const FormatException('A collection can hold up to 24 photos.');
    }
    final written = <File>[];
    try {
      for (final entry in additions.entries) {
        final file = fileFor(entry.key);
        // Reuse a verified orphan from an interrupted previous import.
        if (!await file.exists()) {
          await file.writeAsBytes(entry.value, flush: true);
          written.add(file);
        } else if (sha256.convert(await file.readAsBytes()).toString() !=
            entry.key) {
          throw const FormatException('A saved photo could not be verified.');
        }
      }
      final updated = [...ids, ...additions.keys];
      await _save(updated);
      return updated;
    } catch (_) {
      for (final file in written) {
        try {
          await file.delete();
        } on FileSystemException {
          /* Retain original error. */
        }
      }
      rethrow;
    }
  });

  Future<List<String>> remove(String id) => _serial(() async {
    final file = fileFor(id); // Validate before any filesystem operation.
    final ids = await _read();
    ids.remove(id);
    await _save(ids);
    if (await file.exists()) await file.delete();
    return ids;
  });

  Future<void> clear() => _serial(() async {
    await _read(); // Do not silently overwrite a corrupt collection.
    await _save([]);
    // Include orphan copies left by an interrupted import. Never traverse.
    await for (final entry in directory.list(followLinks: false)) {
      final name = entry.uri.pathSegments.last;
      if (entry is File &&
          name.endsWith('.png') &&
          _validId.hasMatch(name.substring(0, name.length - 4))) {
        await entry.delete();
      }
    }
  });
}
