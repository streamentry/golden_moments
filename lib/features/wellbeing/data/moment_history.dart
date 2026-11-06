import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The calendar days a Daily moment was finished, kept on this phone.
///
/// It holds days only (yyyy-MM-dd): no time of day, length, count, score,
/// streak or list of missed days. A saved record that cannot be read is
/// shown as empty and is never overwritten, so nothing is reset silently.
class MomentHistory extends Equatable {
  const new({required this.days, required this.readable});

  /// Nothing saved yet, or nothing that could be read.
  const new empty() : days = const {}, readable = true;

  /// Day keys (yyyy-MM-dd), each at most once.
  final Set<String> days;

  /// False when a saved record exists but cannot be read.
  final bool readable;

  @override
  List<Object?> get props => [days, readable];
}

class MomentHistoryStore {
  const new({this.key = _defaultKey});

  static const _defaultKey = 'wellbeing.momentDays.v1';
  static const _schemaVersion = 1;

  final String key;

  /// The day key for [day] in the device's own calendar: yyyy-MM-dd.
  static String dayKey(DateTime day) {
    String two(int n) => n.toString().padLeft(2, '0');
    final year = day.year.toString().padLeft(4, '0');
    return '$year-${two(day.month)}-${two(day.day)}';
  }

  static final _dayPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  Future<MomentHistory> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return const MomentHistory.empty();
    final parsed = _parse(raw);
    return parsed ?? const MomentHistory(days: {}, readable: false);
  }

  /// Records [day] as finished. Returns false, and changes nothing, when the
  /// saved history cannot be read.
  Future<bool> markDone(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    final current = raw == null ? const MomentHistory.empty() : _parse(raw);
    if (current == null) return false;
    final days = {...current.days, dayKey(day)};
    final encoded = jsonEncode({
      'v': _schemaVersion,
      'days': days.toList()..sort(),
    });
    return await prefs.setString(key, encoded);
  }

  /// Removes every saved day, including an unreadable record.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Null when [raw] is not a well-formed current-version record.
  static MomentHistory? _parse(String raw) {
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (json is! Map || json['v'] != _schemaVersion) return null;
    final days = json['days'];
    if (days is! List || days.any((dynamic e) => e is! String)) return null;
    final keys = days.cast<String>();
    if (keys.any((k) => !_dayPattern.hasMatch(k))) return null;
    return MomentHistory(days: keys.toSet(), readable: true);
  }
}
