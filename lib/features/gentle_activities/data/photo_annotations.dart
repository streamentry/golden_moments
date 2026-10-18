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

  /// For display: never throws, and any problem means no details. Also
  /// removes a staging file an interrupted write left behind.
  Future<Map<String, PhotoAnnotation>> load() => _serial(() async {
    if (!_isOwnedFolder) return {};
    try {
      await removeEntry('${_file.path}$stagingSuffix', fileOps);
    } on Object {
      // Left for the next load; it is never read as annotations.
    }
    try {
      return await _parse() ?? {};
    } on Object {
      return {};
    }
  });

  /// False when the folder is missing, cannot be inspected or has been
  /// replaced by a link. Used only where "no details" is the safe answer.
  bool get _isOwnedFolder =>
      entryType(directory.path) == FileSystemEntityType.directory;

  /// The stored details, `{}` when there is no sidecar, or null when the
  /// sidecar is unusable: a link or folder in its place, invalid text, or
  /// another version. A failure to inspect or read it (no permission, an I/O
  /// error) is thrown, never mistaken for damage, so it can never cause the
  /// real sidecar to be moved aside and replaced.
  Future<Map<String, PhotoAnnotation>?> _parse() async {
    final type = await confirmedType(_file.path);
    if (type == FileSystemEntityType.notFound) return {};
    if (type != FileSystemEntityType.file) return null;
    final bytes = await _file.readAsBytes();
    final Object? data;
    try {
      data = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return null;
    }
    if (data is! Map ||
        data['version'] != schemaVersion ||
        data['photos'] is! Map) {
      return null;
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
  }

  /// Keeps an unusable sidecar (or a link in its place) aside under the
  /// first free name instead of destroying it or writing through it.
  Future<void> _moveAside() async {
    var aside = '${directory.path}/$_name.unreadable';
    for (var n = 1; entryType(aside) != FileSystemEntityType.notFound; n++) {
      aside = '${directory.path}/$_name.unreadable.$n';
    }
    if (await confirmedType(aside) != FileSystemEntityType.notFound) {
      throw const FileSystemException('A backup name could not be checked.');
    }
    if (entryType(_file.path) == FileSystemEntityType.link) {
      await Link(_file.path).rename(aside); // Moves the link, not its target.
    } else {
      await fileOps.rename(_file, aside);
    }
  }

  Future<void> _write(Map<String, PhotoAnnotation> notes) => replaceAtomically(
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

  /// Sets or clears one photo's details and returns everything stored.
  /// A failed read or write is reported and leaves the sidecar in place.
  Future<Map<String, PhotoAnnotation>> update(
    String id,
    PhotoAnnotation note,
  ) => _serial(() async {
    if (!_validId.hasMatch(id)) {
      throw const FormatException('Invalid photo ID.');
    }
    await ensureOwnedDirectory(directory);
    final stored = await _parse();
    final notes = stored ?? <String, PhotoAnnotation>{};
    if (note.isEmpty) {
      notes.remove(id);
    } else {
      notes[id] = note;
    }
    if (stored == null) await _moveAside();
    await _write(notes);
    return notes;
  });

  /// Drops details for photos that no longer exist. Used after a copy is
  /// removed so deleting a photo also deletes what was written about it.
  ///
  /// Optional details must never stop the photos from opening, so this
  /// never throws. If the sidecar cannot be read, nothing is written and no
  /// details are shown this time. If writing the smaller sidecar fails (for
  /// example on a full disk), the previous one stays intact, the result
  /// still contains only [ids], and the next call retries the write.
  Future<Map<String, PhotoAnnotation>> keepOnly(Set<String> ids) =>
      _serial(() async {
        if (!_isOwnedFolder) return {};
        final Map<String, PhotoAnnotation>? notes;
        try {
          notes = await _parse();
        } on Object {
          return {};
        }
        if (notes == null) return {};
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
