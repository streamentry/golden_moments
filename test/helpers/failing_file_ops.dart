import 'dart:io';

import 'package:golden_moments/features/gentle_activities/data/owned_files.dart';

/// One file step a store performs.
enum FileStep { write, rename, delete }

/// Real file operations, except the step [failWhen] picks, which fails the
/// way a device does: a write on a full disk stops part-way with half of the
/// bytes on disk, a rename or delete is refused. Messages carry no paths.
class FailingFileOps extends StoreFileOps {
  /// Decides by step and entry name (never a full path) whether to fail.
  bool Function(FileStep step, String name)? failWhen;

  static const diskFull = FileSystemException(
    'No space left on device',
    '',
    OSError('No space left on device', 28),
  );

  static const refused = FileSystemException(
    'Operation not permitted',
    '',
    OSError('Operation not permitted', 1),
  );

  bool _fails(FileStep step, FileSystemEntity entity) =>
      failWhen?.call(step, entity.uri.pathSegments.last) ?? false;

  @override
  Future<void> write(File file, List<int> bytes) async {
    if (_fails(FileStep.write, file)) {
      await file.writeAsBytes(bytes.sublist(0, bytes.length ~/ 2), flush: true);
      throw diskFull;
    }
    await super.write(file, bytes);
  }

  @override
  Future<void> rename(File file, String newPath) async {
    if (_fails(FileStep.rename, file)) throw refused;
    await super.rename(file, newPath);
  }

  @override
  Future<void> delete(FileSystemEntity entity) async {
    if (_fails(FileStep.delete, entity)) throw refused;
    await super.delete(entity);
  }
}

/// Names of the entries directly inside [directory], sorted.
List<String> entryNames(Directory directory) =>
    directory
        .listSync(followLinks: false)
        .map((e) => e.uri.pathSegments.last)
        .toList()
      ..sort();
