import 'dart:convert';

import 'package:golden_moments/data/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Topics the person chose to see first in the library (GM-024).
///
/// Optional and changeable at any time. Nothing is asked up front, nothing
/// is assumed from age or history, and an empty choice means "everything".
/// Kept only on this device.
class InterestStore {
  const new();

  static const String storageKey = 'gm.library.interests';
  static const int schemaVersion = 1;

  /// Chosen topic ids. Malformed or unknown-version data means no choice.
  Future<Set<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null) return {};
      final json = jsonDecode(raw);
      if (json is! Map || json['v'] != schemaVersion) return {};
      final ids = json['topics'];
      if (ids is! List) return {};
      return {
        for (final id in ids)
          if (id is String && id.isNotEmpty && id.length <= 64) id,
      };
    } on Object {
      return {};
    }
  }

  /// False if the choice could not be saved; it still applies this session.
  Future<bool> save(Set<String> topics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (topics.isEmpty) return await prefs.remove(storageKey);
      return await prefs.setString(
        storageKey,
        jsonEncode({'v': schemaVersion, 'topics': topics.toList()..sort()}),
      );
    } on Object {
      return false;
    }
  }
}

/// The categories to show for a set of chosen topics. No choice shows
/// everything, and a choice that matches nothing available (for example a
/// topic that no longer exists) falls back to everything rather than an empty
/// screen, so a stale choice can never hide the library.
List<Category> categoriesForInterests(
  List<Category> categories,
  Set<String> chosen,
) {
  if (chosen.isEmpty) return categories;
  final matching = [
    for (final category in categories)
      if (chosen.contains(category.id)) category,
  ];
  return matching.isEmpty ? categories : matching;
}
