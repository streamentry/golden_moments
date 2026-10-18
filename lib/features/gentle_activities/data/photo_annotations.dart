import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

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
/// and can never make a photo unavailable. Writes are serialized and atomic.
class PhotoAnnotationStore {
  new(this.directory);

  static const int schemaVersion = 1;
  static const int maxEntries = 24;
  static final _validId = RegExp(r'^[a-f0-9]{64}$');

  final Directory directory;
  Future<void> _pending = Future<void>.value();

  File get _file => File('${directory.path}/annotations.json');

  Future<T> _serial<T>(Future<T> Function() action) {
    final operation = _pending.then((_) => action());
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<Map<String, PhotoAnnotation>> load() => _serial(_read);

  /// Never throws: any problem means no annotations.
  Future<Map<String, PhotoAnnotation>> _read() async {
    try {
      if (!_file.existsSync()) return {};
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
    await directory.create(recursive: true);
    // Keep an unreadable file aside once instead of silently destroying it.
    if (_file.existsSync() && !await _isReadable()) {
      await _file.rename('${directory.path}/annotations.json.unreadable');
    }
    final temporary = File('${directory.path}/annotations.json.tmp');
    await temporary.writeAsString(
      jsonEncode({
        'version': schemaVersion,
        'photos': {
          for (final entry in notes.entries) entry.key: entry.value.toJson(),
        },
      }),
      flush: true,
    );
    await temporary.rename(_file.path);
  }

  Future<bool> _isReadable() async {
    try {
      final data = jsonDecode(await _file.readAsString());
      return data is Map &&
          data['version'] == schemaVersion &&
          data['photos'] is Map;
    } on Object {
      return false;
    }
  }

  /// Sets or clears one photo's details and returns everything stored.
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
  Future<Map<String, PhotoAnnotation>> keepOnly(Set<String> ids) =>
      _serial(() async {
        final notes = await _read();
        final before = notes.length;
        notes.removeWhere((id, _) => !ids.contains(id));
        if (notes.length != before) await _write(notes);
        return notes;
      });
}
