import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comfort choices for the matching activity (GM-003).
///
/// Only concrete, adjustable preferences live here: how many tiles and whether
/// pictures stay visible. Nothing is derived from success, speed or mistakes,
/// and resetting never touches family photos or packs.
@immutable
class GentlePreferences {
  const new({this.pairs = defaultPairs, this.keepVisible = true});

  /// Reads each field on its own so one invalid value never discards the rest.
  /// Unknown newer versions and malformed data fall back to defaults.
  factory fromJson(Object? json) {
    if (json is! Map) return const GentlePreferences();
    final version = json['v'];
    if (version is! int || version < 1 || version > schemaVersion) {
      return const GentlePreferences();
    }
    final pairs = json['pairs'];
    final keepVisible = json['keepVisible'];
    return GentlePreferences(
      pairs: pairs is int && pairChoices.contains(pairs) ? pairs : defaultPairs,
      keepVisible: keepVisible is! bool || keepVisible,
    );
  }

  static const int schemaVersion = 1;
  static const String storageKey = 'gm.gentle.preferences';
  static const int defaultPairs = 2;
  static const List<int> pairChoices = [2, 3, 4, 6];

  /// Number of picture pairs; the board has twice as many tiles.
  final int pairs;
  final bool keepVisible;

  GentlePreferences copyWith({int? pairs, bool? keepVisible}) =>
      GentlePreferences(
        pairs: pairs ?? this.pairs,
        keepVisible: keepVisible ?? this.keepVisible,
      );

  Map<String, Object> toJson() => {
    'v': schemaVersion,
    'pairs': pairs,
    'keepVisible': keepVisible,
  };

  @override
  bool operator ==(Object other) =>
      other is GentlePreferences &&
      other.pairs == pairs &&
      other.keepVisible == keepVisible;

  @override
  int get hashCode => Object.hash(pairs, keepVisible);
}

/// Local-only persistence for [GentlePreferences]. Failures fall back to the
/// defaults so the activity always starts.
class GentlePreferencesStore {
  const new();

  Future<GentlePreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(GentlePreferences.storageKey);
      if (raw == null) return const GentlePreferences();
      return GentlePreferences.fromJson(jsonDecode(raw));
    } on Object {
      return const GentlePreferences();
    }
  }

  /// Returns false when the choice could not be saved; it still applies to
  /// the current session.
  Future<bool> save(GentlePreferences value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        GentlePreferences.storageKey,
        jsonEncode(value.toJson()),
      );
    } on Object {
      return false;
    }
  }

  /// Removes comfort choices only. Photos, packs and share state are separate.
  Future<bool> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(GentlePreferences.storageKey);
    } on Object {
      return false;
    }
  }
}
