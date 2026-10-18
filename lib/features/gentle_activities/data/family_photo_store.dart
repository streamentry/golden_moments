import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:golden_moments/features/gentle_activities/data/owned_files.dart';

/// Stores normalized PNG copies in an app-owned directory, never originals.
/// File names are content hashes, not user-provided paths or person names.
///
/// Every write goes to a staging file that is flushed and then renamed into
/// place, so an interruption leaves either the previous file or the new one.
/// Copies are written before the manifest that indexes them, and the manifest
/// drops a reference before its copy is deleted. Whatever an interruption
/// leaves behind (staging files, copies no manifest lists) is removed on the
/// next load. Symbolic links are never read, written or deleted through.
class FamilyPhotoStore {
  new(this.directory, {this.fileOps = const StoreFileOps()});

  static const maxPhotos = 24;
  static const int maxBytesPerPhoto = 2 * 1024 * 1024;
  static final _validId = RegExp(r'^[a-f0-9]{64}$');
  static final _copyName = RegExp(r'^([a-f0-9]{64})\.png(\.tmp)?$');
  static const _manifestName = 'collection.json';
  static const _pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
  final Directory directory;

  /// Replaced only in tests, to fail one file step at a time.
  final StoreFileOps fileOps;

  File get _manifest => File('${directory.path}/$_manifestName');

  File fileFor(String id) {
    if (!_validId.hasMatch(id)) {
      throw const FormatException('Invalid photo ID.');
    }
    return File('${directory.path}/$id.png');
  }

  Future<T> _serial<T>(Future<T> Function() action) =>
      serializeOn('photos:${directory.absolute.path}', action);

  /// The photos that can be shown. Also tidies what an interrupted change
  /// left behind; that tidying never blocks or changes the result.
  Future<List<String>> load() => _serial(() async {
    final indexed = await _readManifest();
    try {
      await _removeLeftovers(indexed?.toSet());
    } on Object {
      // Left for the next load; the indexed photos are unaffected.
    }
    return _available(indexed);
  });

  /// The ids the manifest lists, or null when there is no manifest yet.
  /// Anything other than a well-formed current manifest in a plain file is
  /// surfaced as an error and never overwritten.
  Future<List<String>?> _readManifest() async {
    await ensureOwnedDirectory(directory);
    final type = entryType(_manifest.path);
    if (type == FileSystemEntityType.notFound) return null;
    if (type != FileSystemEntityType.file) {
      throw const FormatException('The photo collection cannot be read.');
    }
    final data = jsonDecode(await _manifest.readAsString());
    if (data is! Map<String, dynamic> ||
        data['version'] != 1 ||
        data['photos'] is! List) {
      throw const FormatException('The photo collection cannot be read.');
    }
    final values = data['photos'] as List<dynamic>;
    if (values.length > maxPhotos ||
        values.any((dynamic id) => id is! String || !_validId.hasMatch(id))) {
      throw const FormatException('Invalid photo collection.');
    }
    final ids = values.cast<String>();
    if (ids.toSet().length != ids.length) {
      throw const FormatException('Duplicate photo IDs.');
    }
    return ids;
  }

  /// Missing copies do not prevent the remaining pictures from being used.
  /// A copy replaced by a link is treated as missing and never read through.
  List<String> _available(List<String>? indexed) => [
    for (final id in indexed ?? const <String>[])
      if (isPlainFile(fileFor(id).path)) id,
  ];

  Future<List<String>> _read() async => _available(await _readManifest());

  Future<void> _save(List<String> ids) => replaceAtomically(
    _manifest,
    utf8.encode(jsonEncode({'version': 1, 'photos': ids})),
    fileOps,
  );

  /// Removes staging files and, when [keep] is given, hash-named copies it
  /// does not list. Without a manifest ([keep] is null) copies are kept: they
  /// may be all that is left of an interrupted first import. Only entries
  /// directly inside the folder with names this store creates are touched;
  /// links are unlinked, folders and other files are left. Tries every
  /// entry, then rethrows the first failure.
  Future<void> _removeLeftovers(Set<String>? keep) async {
    final leftovers = <String>[];
    await for (final entry in directory.list(followLinks: false)) {
      final name = entry.uri.pathSegments.last;
      final copy = _copyName.firstMatch(name);
      final staging =
          name == '$_manifestName$stagingSuffix' ||
          (copy != null && copy[2] != null);
      final unindexed = copy != null && keep != null && !keep.contains(copy[1]);
      if (staging || unindexed) leftovers.add(entry.path);
    }
    Object? firstError;
    StackTrace? firstStack;
    for (final path in leftovers) {
      try {
        await removeEntry(path, fileOps);
      } on Object catch (error, stack) {
        firstError ??= error;
        firstStack ??= stack;
      }
    }
    if (firstError != null) Error.throwWithStackTrace(firstError, firstStack!);
  }

  /// True when [file] is a plain file whose content hashes to [id].
  Future<bool> _holds(File file, String id) async =>
      isPlainFile(file.path) &&
      sha256.convert(await file.readAsBytes()).toString() == id;

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
    final written = <String>[];
    try {
      for (final entry in additions.entries) {
        final file = fileFor(entry.key);
        // Reuse a verified copy left by an interrupted earlier import. Any
        // other entry at this name is unindexed (a damaged copy or a link)
        // and is replaced, never written through.
        if (await _holds(file, entry.key)) continue;
        // Recorded first, so a copy that fails part-way is removed too.
        written.add(file.path);
        await replaceAtomically(file, entry.value, fileOps);
      }
      final updated = [...ids, ...additions.keys];
      await _save(updated);
      return updated;
    } on Object {
      for (final path in written) {
        try {
          await removeEntry(path, fileOps);
        } on Object {
          // Keep the original error; the next load removes unindexed copies.
        }
      }
      rethrow;
    }
  });

  /// Drops the reference first, then the copy. If deleting the copy fails
  /// the photo is already gone from the collection, the failure is still
  /// reported, and the next load removes the unindexed copy.
  Future<List<String>> remove(String id) => _serial(() async {
    final file = fileFor(id); // Validate before any filesystem operation.
    final ids = await _read();
    ids.remove(id);
    await _save(ids);
    await removeEntry(file.path, fileOps);
    return ids;
  });

  Future<void> clear() => _serial(() async {
    await _read(); // Do not silently overwrite a corrupt collection.
    await _save([]);
    // Include orphan copies left by an interrupted import. Never traverse.
    await _removeLeftovers(const {});
  });
}
