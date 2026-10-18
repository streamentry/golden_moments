import 'dart:io';

/// The single-step file operations the local photo stores perform.
///
/// Each method is one boundary, so tests can make exactly one step fail (a
/// full disk part-way through a write, a rename that never happens, a delete
/// the system refuses) and prove the previous collection is still the one
/// that loads. Production code uses this default implementation.
class StoreFileOps {
  const new();

  /// Writes and flushes [bytes] to an already-created, app-owned temporary
  /// file.
  Future<void> write(File file, List<int> bytes) =>
      file.writeAsBytes(bytes, flush: true);

  /// Replaces whatever is at [newPath] with [file] in one step.
  Future<void> rename(File file, String newPath) => file.rename(newPath);

  /// Removes one directory entry: a file, or a symbolic link itself (never
  /// what the link points to).
  Future<void> delete(FileSystemEntity entity) => entity.delete();
}

/// Suffix for staging files. A leftover one is never the source of truth.
const String stagingSuffix = '.tmp';

/// The type of the entry at [path] itself, without following a link.
///
/// Beware: this reports `notFound` for ANY failure to inspect the entry
/// (no permission, an I/O error), not only for a missing one. Use it only
/// where "absent" is the safe reading; use [confirmedType] wherever treating
/// an existing entry as absent could lose data.
FileSystemEntityType entryType(String path) =>
    FileSystemEntity.typeSync(path, followLinks: false);

/// Like [entryType], but a reported absence is confirmed by trying to open
/// the entry: only "no such file or directory" means absent. Any other
/// failure (no permission, an I/O error, something present after all) is
/// thrown, so a transient problem is surfaced instead of being mistaken for
/// an empty collection or a missing copy.
Future<FileSystemEntityType> confirmedType(String path) async {
  final type = entryType(path);
  if (type != FileSystemEntityType.notFound) return type;
  try {
    final handle = await File(path).open();
    await handle.close();
  } on PathNotFoundException {
    return FileSystemEntityType.notFound;
  }
  // Openable, so it exists, yet it could not be inspected a moment ago.
  throw const FileSystemException('A file in the app folder changed.');
}

/// Creates the owned folder if needed and refuses one that has been replaced
/// by a symbolic link or a file, so no store ever works outside it.
Future<void> ensureOwnedDirectory(Directory directory) async {
  final type = await confirmedType(directory.path);
  if (type == FileSystemEntityType.directory) return;
  if (type == FileSystemEntityType.notFound) {
    await directory.create(recursive: true);
    return;
  }
  // No path in the message: it may name a person's device folders.
  throw const FileSystemException('The app folder is not a plain folder.');
}

/// Removes one entry inside an owned folder without following it. A link is
/// unlinked and its target is left alone; a folder is never removed. An
/// entry that cannot be inspected is reported, never assumed gone.
Future<void> removeEntry(String path, StoreFileOps ops) async {
  final type = await confirmedType(path);
  if (type == FileSystemEntityType.notFound) return;
  if (type == FileSystemEntityType.link) {
    await ops.delete(Link(path));
  } else if (type == FileSystemEntityType.file) {
    await ops.delete(File(path));
  } else {
    throw const FileSystemException('Unexpected item in the app folder.');
  }
}

/// Writes [bytes] to a fresh staging file next to [target], flushes it and
/// renames it over [target]. Until the rename, [target] is untouched; after
/// it, [target] is complete. A stale staging file or a planted link at the
/// staging name is removed first and never written through. On failure the
/// staging file is removed and the original error is rethrown.
Future<void> replaceAtomically(
  File target,
  List<int> bytes,
  StoreFileOps ops,
) async {
  final staging = File('${target.path}$stagingSuffix');
  await removeEntry(staging.path, ops);
  try {
    // Exclusive creation fails rather than following a link raced in here.
    await staging.create(exclusive: true);
    await ops.write(staging, bytes);
    await ops.rename(staging, target.path);
  } on Object {
    try {
      await removeEntry(staging.path, ops);
    } on Object {
      // Keep the original error; the next load removes the staging file.
    }
    rethrow;
  }
}

final Map<String, Future<void>> _tails = {};

/// Runs [action] after every earlier action with the same [key] has
/// finished, across all store instances. Each store keys by its folder's
/// absolute path, so two screens opening the same collection cannot
/// interleave writes or clean up a copy another instance is about to index.
///
/// Limits: the queue lives in this isolate's memory. It does not coordinate
/// other isolates or processes (this app touches the folder from its single
/// UI isolate only), and two different spellings of one folder (a relative
/// path, a trailing slash, a link to it) would get separate queues; the
/// stores always use the one path the app derives at start-up.
Future<T> serializeOn<T>(String key, Future<T> Function() action) {
  final previous = _tails[key] ?? Future<void>.value();
  final operation = previous.then((_) => action());
  // One completed future per folder is kept; the app uses one folder.
  _tails[key] = operation.then<void>(
    (_) {},
    onError: (Object _, StackTrace _) {},
  );
  return operation;
}
