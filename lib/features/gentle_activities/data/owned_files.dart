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
FileSystemEntityType entryType(String path) =>
    FileSystemEntity.typeSync(path, followLinks: false);

/// True only for a regular file. A symbolic link, even one pointing at a
/// file, is not an app-owned copy and is never read through.
bool isPlainFile(String path) => entryType(path) == FileSystemEntityType.file;

/// Creates the owned folder if needed and refuses one that has been replaced
/// by a symbolic link or a file, so no store ever works outside it.
Future<void> ensureOwnedDirectory(Directory directory) async {
  final type = entryType(directory.path);
  if (type == FileSystemEntityType.notFound) {
    await directory.create(recursive: true);
  } else if (type != FileSystemEntityType.directory) {
    // No path in the message: it may name a person's device folders.
    throw const FileSystemException('The app folder is not a plain folder.');
  }
}

/// Removes one entry inside an owned folder without following it. A link is
/// unlinked and its target is left alone; a folder is never removed.
Future<void> removeEntry(String path, StoreFileOps ops) async {
  final type = entryType(path);
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
/// finished, across all store instances in this process. Each store keys by
/// its folder, so two screens opening the same collection cannot interleave
/// writes or clean up a copy another instance is about to index.
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
