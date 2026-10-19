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
/// leaves behind (staging files, copies an existing manifest does not list)
/// is removed on the next load. With no manifest at all, copies whose
/// content matches their name are adopted rather than removed. Changes start
/// from the manifest as written, never from the filtered display list, and
/// a file that cannot be inspected is an error, never "absent". Symbolic
/// links are never read, written or deleted through.
class FamilyPhotoStore {
  new(this.directory, {this.fileOps = const StoreFileOps()});

  static const maxPhotos = 24;
  static const int maxBytesPerPhoto = 2 * 1024 * 1024;
  static final _validId = RegExp(r'^[a-f0-9]{64}$');
  static final _copyName = RegExp(r'^([a-f0-9]{64})\.png(\.tmp)?$');
  static const _manifestName = 'collection.json';
  static final _asideName = RegExp(r'^collection\.damaged-[0-9-]+\.json$');
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

  /// The photos that can be shown, in collection order. Also tidies what an
  /// interrupted change left behind; that tidying never changes the result.
  ///
  /// Throws, rather than returning fewer photos, when the manifest or a copy
  /// cannot be inspected or read: callers prune photo details by this list.
  Future<List<String>> load() => _serial(() async {
    final indexed = await _readManifest();
    try {
      // Without a manifest only staging files go; copies are adopted below.
      await _removeLeftovers(indexed?.toSet());
    } on Object {
      // Left for the next load; the indexed photos are unaffected.
    }
    final ids = indexed ?? await _adoptable();
    return [
      for (final id in ids)
        if (await confirmedType(fileFor(id).path) == FileSystemEntityType.file)
          id,
    ];
  });

  /// Every photo the collection lists, including ones whose copy cannot be
  /// shown right now (a moment's error, or something else in its place).
  /// Without a manifest, the copies [load] would adopt. Prune photo details
  /// by this, never by [load]: a copy that is unusable for a moment must
  /// not lose its caption, favorite or hidden choice. Throws like [load].
  Future<List<String>> listed() =>
      _serial(() async => await _readManifest() ?? await _adoptable());

  /// The ids the manifest lists, or null only when there is genuinely no
  /// manifest. A manifest that cannot be inspected or read, or anything
  /// other than a well-formed current manifest in a plain file, is surfaced
  /// as an error and never overwritten.
  Future<List<String>?> _readManifest() async {
    await ensureOwnedDirectory(directory);
    final type = await confirmedType(_manifest.path);
    if (type == FileSystemEntityType.notFound) return null;
    if (type != FileSystemEntityType.file) {
      throw const UnreadablePhotoList('The photo collection cannot be read.');
    }
    const damaged = UnreadablePhotoList(
      'The photo collection is damaged.',
      canSetAside: true,
    );
    // A read that fails (no permission, an I/O error) is thrown as it is:
    // the list may be fine, so it is never treated as damaged.
    final text = await _manifest.readAsString().onError<FormatException>(
      (_, _) => throw damaged,
    );
    final Object? data;
    try {
      data = jsonDecode(text);
    } on FormatException {
      throw damaged;
    }
    final version = data is Map<String, dynamic> ? data['version'] : null;
    // Any number above 1 is a later format, however it was written.
    if (version is num && version > 1) {
      throw const UnreadablePhotoList(
        'A newer app version saved the photo collection.',
        fromNewerVersion: true,
      );
    }
    if (data is! Map<String, dynamic> ||
        version != 1 ||
        data['photos'] is! List) {
      throw damaged;
    }
    final values = data['photos'] as List<dynamic>;
    if (values.length > maxPhotos ||
        values.any((dynamic id) => id is! String || !_validId.hasMatch(id))) {
      throw damaged;
    }
    final ids = values.cast<String>();
    if (ids.toSet().length != ids.length) throw damaged;
    return ids;
  }

  /// Moves a damaged photo list aside, never deleting or overwriting it, so
  /// the copies whose content still matches their names become the
  /// collection again, as after a first import that stopped before its list
  /// was written. Photo details stay with their photos. Only a plain file
  /// whose content cannot be used is moved: a list from a newer app version,
  /// a link or anything else in its place is left exactly as it is. Returns
  /// whether a list was set aside. Only ever run at the person's request.
  Future<bool> setAsideDamagedList() => _serial(() async {
    try {
      await _readManifest();
      return false;
    } on UnreadablePhotoList catch (problem) {
      if (!problem.canSetAside) return false;
    }
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    var aside = File('${directory.path}/collection.damaged-$stamp.json');
    for (
      var n = 1;
      await confirmedType(aside.path) != FileSystemEntityType.notFound;
      n++
    ) {
      aside = File('${directory.path}/collection.damaged-$stamp-$n.json');
    }
    await fileOps.rename(_manifest, aside.path);
    return true;
  });

  /// Without a manifest (a first import stopped before its index was
  /// written), the plain hash-named copies whose content matches their name
  /// are the collection: oldest first, at most [maxPhotos]. Nothing is
  /// written here; the next change records them in a new manifest.
  Future<List<String>> _adoptable() async {
    final found = <(DateTime, String)>[];
    await for (final entry in directory.list(followLinks: false)) {
      final copy = _copyName.firstMatch(entry.uri.pathSegments.last);
      if (entry is! File || copy == null || copy[2] != null) continue;
      if (await _holds(entry, copy[1]!)) {
        found.add((entry.lastModifiedSync(), copy[1]!));
      }
    }
    found.sort((a, b) {
      final byTime = a.$1.compareTo(b.$1);
      return byTime != 0 ? byTime : a.$2.compareTo(b.$2);
    });
    return [for (final (_, id) in found.take(maxPhotos)) id];
  }

  /// The ids a change starts from: the manifest exactly as written (or the
  /// adopted copies), minus only photos whose copy is confirmed to be gone.
  /// A copy that is merely unreadable or replaced keeps its place, so a
  /// change can never drop its reference and let cleanup delete its file.
  Future<List<String>> _current() async {
    final ids = await _readManifest() ?? await _adoptable();
    return [
      for (final id in ids)
        if (await confirmedType(fileFor(id).path) !=
            FileSystemEntityType.notFound)
          id,
    ];
  }

  Future<void> _save(List<String> ids) => replaceAtomically(
    _manifest,
    utf8.encode(jsonEncode({'version': 1, 'photos': ids})),
    fileOps,
  );

  /// Removes staging files and, when [keep] is given, hash-named copies it
  /// does not list. Without a manifest ([keep] is null) copies are kept.
  /// Only entries directly inside the folder with names this store creates
  /// are touched; links are unlinked, folders and other files are left.
  /// Tries every entry, then rethrows the first failure.
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

  /// True when [file] is a plain file whose content hashes to [id]. A file
  /// that is present but cannot be read is an error, not a mismatch.
  Future<bool> _holds(File file, String id) async =>
      await confirmedType(file.path) == FileSystemEntityType.file &&
      sha256.convert(await file.readAsBytes()).toString() == id;

  /// All validation happens before changing the current manifest.
  Future<List<String>> add(List<Uint8List> images) => _serial(() async {
    final ids = await _current();
    final additions = <String, Uint8List>{};
    final repairs = <String, Uint8List>{};
    for (final bytes in images) {
      if (bytes.length < 8 ||
          bytes.length > maxBytesPerPhoto ||
          List<int>.generate(8, (i) => bytes[i]).asMap().entries.any(
            (entry) => entry.value != _pngSignature[entry.key],
          )) {
        throw const FormatException('Choose a smaller, valid photo.');
      }
      final id = sha256.convert(bytes).toString();
      if (!ids.contains(id)) {
        additions[id] = bytes;
      } else if (!await _holds(fileFor(id), id)) {
        // Listed, but its copy was replaced or damaged: write it again.
        repairs[id] = bytes;
      }
    }
    if (ids.length + additions.length > maxPhotos) {
      throw const FormatException('A collection can hold up to 24 photos.');
    }
    // A repaired copy is never removed on failure: the rename either did not
    // happen (the old entry stays) or left the correct content in place.
    for (final entry in repairs.entries) {
      await replaceAtomically(fileFor(entry.key), entry.value, fileOps);
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
    final ids = await _current();
    ids.remove(id);
    await _save(ids);
    await removeEntry(file.path, fileOps);
    return ids;
  });

  Future<void> clear() => _serial(() async {
    await _current(); // Do not silently overwrite a corrupt collection.
    await _save([]);
    // Include orphan copies left by an interrupted import. Never traverse.
    await _removeLeftovers(const {});
    // Lists set aside by a recovery name only photos that are now gone.
    await for (final entry in directory.list(followLinks: false)) {
      final name = entry.uri.pathSegments.last;
      if (_asideName.hasMatch(name)) await removeEntry(entry.path, fileOps);
    }
  });
}

/// The photo list exists but cannot be used. Only a plain file whose content
/// is damaged [canSetAside]; a list a newer app version wrote
/// ([fromNewerVersion]) or anything other than a plain file is never moved.
class UnreadablePhotoList extends FormatException {
  const new(
    super.message, {
    this.canSetAside = false,
    this.fromNewerVersion = false,
  });

  final bool canSetAside;
  final bool fromNewerVersion;
}
