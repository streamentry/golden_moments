import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The person's own choices about included picture packs (GM-020, GM-026).
///
/// Only explicit, reversible choices live here: which packs are favorites and
/// which were marked "Not for me". Nothing is counted, ranked or inferred, and
/// hiding a pack never deletes it. Kept only on this device.
@immutable
class PackPreferences {
  const new({
    this.favorites = const <String>{},
    this.hidden = const <String>{},
  });

  /// Reads each field on its own so one invalid field never discards the
  /// other. Unknown newer versions and malformed data mean no choices.
  factory fromJson(Object? json) =>
      tryFromJson(json) ?? const PackPreferences();

  /// Like [PackPreferences.fromJson], but null when the record as a whole
  /// cannot be understood (not a map, or a missing, older or newer version),
  /// so the caller can leave it untouched instead of writing over it.
  static PackPreferences? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final version = json['v'];
    if (version is! int || version < 1 || version > schemaVersion) {
      return null;
    }
    return PackPreferences(
      favorites: _ids(json['favorites']),
      hidden: _ids(json['hidden']),
    );
  }

  static const int schemaVersion = 1;
  static const String storageKey = 'gm.library.packPreferences';

  /// Upper bound on stored ids per list; far above the included catalog.
  static const int maxIds = 200;
  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_.-]{1,64}$');

  /// Pack ids the person marked as a favorite.
  final Set<String> favorites;

  /// Pack ids the person marked "Not for me".
  final Set<String> hidden;

  bool isFavorite(String packId) => favorites.contains(packId);
  bool isHidden(String packId) => hidden.contains(packId);

  /// A copy with [packId] added to or removed from favorites.
  PackPreferences withFavorite(String packId, {required bool favorite}) =>
      PackPreferences(
        favorites: _toggled(favorites, packId, include: favorite),
        hidden: hidden,
      );

  /// A copy with [packId] hidden or shown again. The favorite mark is kept,
  /// so showing a hidden favorite again returns it to the favorites.
  PackPreferences withHidden(String packId, {required bool hide}) =>
      PackPreferences(
        favorites: favorites,
        hidden: _toggled(hidden, packId, include: hide),
      );

  Map<String, Object> toJson() => {
    'v': schemaVersion,
    'favorites': favorites.toList()..sort(),
    'hidden': hidden.toList()..sort(),
  };

  static Set<String> _ids(Object? value) {
    if (value is! List) return const <String>{};
    final ids = <String>{
      for (final id in value)
        if (id is String && _idPattern.hasMatch(id)) id,
    };
    return Set.unmodifiable(ids.take(maxIds));
  }

  static Set<String> _toggled(
    Set<String> ids,
    String id, {
    required bool include,
  }) => Set.unmodifiable(
    include ? {...ids, id} : {...ids.where((other) => other != id)},
  );

  @override
  bool operator ==(Object other) =>
      other is PackPreferences &&
      setEquals(other.favorites, favorites) &&
      setEquals(other.hidden, hidden);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(favorites),
    Object.hashAllUnordered(hidden),
  );
}

/// What reading the saved record found.
enum PackPreferencesStatus {
  /// Nothing saved yet: a fresh start, safe to write.
  absent,

  /// A record this version understands, safe to write.
  loaded,

  /// A record that exists but could not be read (damaged, written by a newer
  /// version, or storage failed). It must never be written over.
  unreadable,
}

/// The result of [PackPreferencesStore.load].
@immutable
class PackPreferencesLoad {
  const new(this.status, [this.preferences = const PackPreferences()]);

  final PackPreferencesStatus status;

  /// The saved choices; empty unless [status] is loaded.
  final PackPreferences preferences;

  /// False when saving would overwrite a record that could not be read.
  bool get writable => status != PackPreferencesStatus.unreadable;
}

/// Local-only persistence for [PackPreferences]. A failure never stops the
/// library from opening, and a record that cannot be read is reported as
/// such so it is kept rather than replaced.
class PackPreferencesStore {
  const new();

  Future<PackPreferencesLoad> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(PackPreferences.storageKey);
      if (raw == null) {
        return const PackPreferencesLoad(PackPreferencesStatus.absent);
      }
      final parsed = PackPreferences.tryFromJson(jsonDecode(raw));
      if (parsed == null) {
        return const PackPreferencesLoad(PackPreferencesStatus.unreadable);
      }
      return PackPreferencesLoad(PackPreferencesStatus.loaded, parsed);
    } on Object {
      return const PackPreferencesLoad(PackPreferencesStatus.unreadable);
    }
  }

  /// Returns false when the choice could not be saved; it still applies to
  /// the current session.
  Future<bool> save(PackPreferences value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        PackPreferences.storageKey,
        jsonEncode(value.toJson()),
      );
    } on Object {
      return false;
    }
  }

  /// Removes pack favorites and hidden marks only. Topic choices, comfort
  /// settings and family photos are stored separately and are untouched.
  Future<bool> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(PackPreferences.storageKey);
    } on Object {
      return false;
    }
  }
}
