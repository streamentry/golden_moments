import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/features/gentle_activities/data/owned_files.dart';

/// Optional, local-only details about one family photo (GM-019/GM-020).
///
/// Everything here is plain text or a yes/no choice made by the person using
/// the app. Nothing is inferred about who is in a photo, and none of it is
/// needed to play.
@immutable
class PhotoAnnotation {
  const new({
    this.caption = '',
    this.description = '',
    this.favorite = false,
    this.hidden = false,
  });

  /// Reads one stored entry field by field; a bad field becomes its default.
  factory fromJson(Object? json) {
    if (json is! Map) return const PhotoAnnotation();
    final caption = json['caption'];
    final description = json['description'];
    return PhotoAnnotation(
      caption: caption is String ? normalizeText(caption, maxCaption) : '',
      description: description is String
          ? normalizeText(description, maxDescription)
          : '',
      favorite: json['favorite'] == true,
      hidden: json['hidden'] == true,
    );
  }

  static const int maxCaption = 60;
  static const int maxDescription = 280;

  static final _unsafe = RegExp(
    // Control characters and bidirectional overrides can reorder or hide text.
    r'[\u0000-\u001F\u007F-\u009F\u200E\u200F\u202A-\u202E\u2066-\u2069]',
  );

  /// Plain text only: control and direction-override characters become
  /// spaces, whitespace runs collapse, ends are trimmed, and the result is
  /// capped at [max] code points.
  static String normalizeText(String input, int max) {
    final cleaned = input
        .replaceAll(_unsafe, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final runes = cleaned.runes;
    if (runes.length <= max) return cleaned;
    return String.fromCharCodes(runes.take(max)).trimRight();
  }

  final String caption;
  final String description;
  final bool favorite;
  final bool hidden;

  bool get isEmpty =>
      caption.isEmpty && description.isEmpty && !favorite && !hidden;

  PhotoAnnotation copyWith({
    String? caption,
    String? description,
    bool? favorite,
    bool? hidden,
  }) => PhotoAnnotation(
    caption: normalizeText(caption ?? this.caption, maxCaption),
    description: normalizeText(description ?? this.description, maxDescription),
    favorite: favorite ?? this.favorite,
    hidden: hidden ?? this.hidden,
  );

  Map<String, Object> toJson() => {
    if (caption.isNotEmpty) 'caption': caption,
    if (description.isNotEmpty) 'description': description,
    if (favorite) 'favorite': true,
    if (hidden) 'hidden': true,
  };

  @override
  bool operator ==(Object other) =>
      other is PhotoAnnotation &&
      other.caption == caption &&
      other.description == description &&
      other.favorite == favorite &&
      other.hidden == hidden;

  @override
  int get hashCode => Object.hash(caption, description, favorite, hidden);
}

/// A small versioned sidecar next to the photo collection. It is optional by
/// design: a missing, unreadable or newer-version file means "no annotations"
/// and can never make a photo unavailable. Writes are serialized (across
/// every instance on the same folder) and atomic, and a symbolic link in
/// place of the sidecar is never read or written through.
class PhotoAnnotationStore {
  new(this.directory, {this.fileOps = const StoreFileOps()});

  static const int schemaVersion = 1;
  static const int maxEntries = 24;
  static final _validId = RegExp(r'^[a-f0-9]{64}$');
  static const _name = 'annotations.json';

  final Directory directory;

  /// Replaced only in tests, to fail one file step at a time.
  final StoreFileOps fileOps;

  File get _file => File('${directory.path}/$_name');

  Future<T> _serial<T>(Future<T> Function() action) =>
      serializeOn('annotations:${directory.absolute.path}', action);

  /// Also removes a staging file an interrupted write left behind.
  Future<Map<String, PhotoAnnotation>> load() => _serial(() async {
    if (!_isOwnedFolder) return {};
    try {
      await removeEntry('${_file.path}$stagingSuffix', fileOps);
    } on Object {
      // Left for the next load; it is never read as annotations.
    }
    return await _read();
  });

  /// False when the folder is missing or has been replaced by a link.
  bool get _isOwnedFolder =>
      entryType(directory.path) == FileSystemEntityType.directory;

  /// Never throws: any problem means no annotations.
  Future<Map<String, PhotoAnnotation>> _read() async {
    try {
      if (!_isOwnedFolder || !isPlainFile(_file.path)) return {};
      final data = jsonDecode(await _file.readAsString());
      if (data is! Map ||
          data['version'] != schemaVersion ||
          data['photos'] is! Map) {
        return {};
      }
      final result = <String, PhotoAnnotation>{};
      for (final entry in (data['photos'] as Map).entries) {
        final id = entry.key;
        if (id is! String || !_validId.hasMatch(id)) continue;
        final note = PhotoAnnotation.fromJson(entry.value);
        if (!note.isEmpty) result[id] = note;
        if (result.length >= maxEntries) break;
      }
      return result;
    } on Object {
      return {};
    }
  }

  Future<void> _write(Map<String, PhotoAnnotation> notes) async {
    await ensureOwnedDirectory(directory);
    // Keep an unreadable file (or a link) aside instead of silently
    // destroying it or writing through it.
    final type = entryType(_file.path);
    if (type != FileSystemEntityType.notFound && !await _isReadable()) {
      // Never overwrite an earlier backup: use the first free name.
      var aside = '${directory.path}/$_name.unreadable';
      for (var n = 1; entryType(aside) != FileSystemEntityType.notFound; n++) {
        aside = '${directory.path}/$_name.unreadable.$n';
      }
      if (type == FileSystemEntityType.link) {
        await Link(_file.path).rename(aside); // Moves the link, not its target.
      } else {
        await fileOps.rename(_file, aside);
      }
    }
    await replaceAtomically(
      _file,
      utf8.encode(
        jsonEncode({
          'version': schemaVersion,
          'photos': {
            for (final entry in notes.entries) entry.key: entry.value.toJson(),
          },
        }),
      ),
      fileOps,
    );
  }

  Future<bool> _isReadable() async {
    try {
      if (!isPlainFile(_file.path)) return false;
      final data = jsonDecode(await _file.readAsString());
      return data is Map &&
          data['version'] == schemaVersion &&
          data['photos'] is Map;
    } on Object {
      return false;
    }
  }

  /// Sets or clears one photo's details and returns everything stored.
  /// A failed write is reported and leaves the previous sidecar in place.
  Future<Map<String, PhotoAnnotation>> update(
    String id,
    PhotoAnnotation note,
  ) => _serial(() async {
    if (!_validId.hasMatch(id)) {
      throw const FormatException('Invalid photo ID.');
    }
    final notes = await _read();
    if (note.isEmpty) {
      notes.remove(id);
    } else {
      notes[id] = note;
    }
    await _write(notes);
    return notes;
  });

  /// Drops details for photos that no longer exist. Used after a copy is
  /// removed so deleting a photo also deletes what was written about it.
  ///
  /// The result only ever contains [ids], even if writing the smaller
  /// sidecar fails (for example on a full disk): optional details must never
  /// stop the photos from opening. The previous sidecar then stays intact,
  /// its stale entries are never shown, and the next call retries the write.
  Future<Map<String, PhotoAnnotation>> keepOnly(Set<String> ids) =>
      _serial(() async {
        final notes = await _read();
        final before = notes.length;
        notes.removeWhere((id, _) => !ids.contains(id));
        if (notes.length != before) {
          try {
            await _write(notes);
          } on Object {
            // Retried on the next call; see above.
          }
        }
        return notes;
      });
}
