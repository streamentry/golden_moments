import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/features/gentle_activities/models/gentle_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An unfinished matching board that can be picked up again (GM-004).
///
/// It holds stable picture IDs and tile positions only: no score, time,
/// attempt count or file path. Starter pictures and family photos use separate
/// `sourceKey`s so one never offers the other's board.
@immutable
class GentleSession {
  const new({
    required this.cards,
    required this.matched,
    required this.selected,
  });

  factory fromBoard(GentleBoard board) => GentleSession(
    cards: board.cards,
    matched: board.matchedIndices,
    selected: board.selectedIndices,
  );

  /// Returns null for anything that is not a well-formed current-version
  /// record. Callers treat null as "nothing to resume".
  static GentleSession? fromJson(Object? json) {
    if (json is! Map || json['v'] != schemaVersion) return null;
    final cards = json['cards'];
    final matched = json['matched'];
    final selected = json['selected'];
    if (cards is! List ||
        matched is! List ||
        selected is! List ||
        cards.any((dynamic e) => e is! String) ||
        matched.any((dynamic e) => e is! int) ||
        selected.any((dynamic e) => e is! int)) {
      return null;
    }
    return GentleSession(
      cards: cards.cast<String>(),
      matched: matched.cast<int>(),
      selected: selected.cast<int>(),
    );
  }

  static const int schemaVersion = 1;
  static const String storageKeyPrefix = 'gm.gentle.session.';

  final List<String> cards;
  final List<int> matched;
  final List<int> selected;

  Map<String, Object> toJson() => {
    'v': schemaVersion,
    'cards': cards,
    'matched': matched,
    'selected': selected,
  };

  /// The board, only if every picture is still available and the saved
  /// arrangement is one this activity could actually have reached.
  GentleBoard? toBoard({required Set<String> availablePictureIds}) {
    if (!cards.every(availablePictureIds.contains)) return null;
    return GentleBoard.tryRestore(
      cards: cards,
      matched: matched,
      selected: selected,
    );
  }
}

/// Local-only persistence for [GentleSession]. Every failure means "no
/// session"; nothing here can block play or touch photos and packs.
class GentleSessionStore {
  const new();

  static String _key(String sourceKey) =>
      '${GentleSession.storageKeyPrefix}$sourceKey';

  Future<GentleSession?> load(String sourceKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(sourceKey));
      if (raw == null) return null;
      return GentleSession.fromJson(jsonDecode(raw));
    } on Object {
      return null;
    }
  }

  Future<bool> save(String sourceKey, GentleSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _key(sourceKey),
        jsonEncode(session.toJson()),
      );
    } on Object {
      return false;
    }
  }

  Future<void> clear(String sourceKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(sourceKey));
    } on Object {
      // Nothing to clean up if storage is unavailable.
    }
  }
}
